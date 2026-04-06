#!/bin/bash
# fix_sepolicy.sh - Fix SEPolicy build errors for device/xiaomi/blossom
# Usage: bash fix_sepolicy.sh [device_tree_path]
#        Default path: device/xiaomi/blossom

set -e

DEVICE_PATH="${1:-device/xiaomi/blossom}"
GENFS="$DEVICE_PATH/sepolicy/vendor/genfs_contexts"
FILE_TE="$DEVICE_PATH/sepolicy/vendor/file.te"
PROP_CTX="$DEVICE_PATH/sepolicy/private/property_context"

echo "[1/6] Removing conflicting Mali genfscon (sysfs_gpu)..."
sed -i '/# Graphics/d' "$GENFS"
sed -i '/13040000\.mali.*sysfs_gpu/d' "$GENFS"

echo "[2/6] Removing hardcoded input6 wakeup entry..."
sed -i '/virtual\/input\/input6\/wakeup/d' "$GENFS"

echo "[3/6] Cleaning up double blank lines..."
sed -i '/^$/N;/^\n$/d' "$GENFS"
sed -i '/^# Power$/i\\' "$GENFS"

echo "[4/6] Removing stray property_context duplicate..."
rm -f "$PROP_CTX"

echo "[5/6] Renaming generic 'fp' type in file.te..."
sed -i 's/^type fp,/type sysfs_fp,/' "$FILE_TE"

echo "[6/6] Patching conflicting genfscon rules from MTK/MiUI sepolicy..."
# These paths are already defined in AOSP plat_sepolicy.cil with different labels.
# The vendor copies must be removed.
CONFLICT_PATTERNS=(
    "sched_pelt_multiplier"     # proc_sched  vs AOSP
    "dirty_writeback_centisecs" # proc_vm_dirty vs AOSP proc_dirty
)

MTK_DIRS=(
    "device/mediatek/sepolicy_vndr"
    "device/mediatek/common/sepolicy"
    "vendor/xiaomi/miuicamera"
)

for dir in "${MTK_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for pattern in "${CONFLICT_PATTERNS[@]}"; do
            grep -rl "$pattern" "$dir" 2>/dev/null | while read -r f; do
                echo "  Removing '$pattern' from: $f"
                sed -i "/$pattern/d" "$f"
            done
        done
    fi
done

echo ""
echo "Done. Verify with:"
echo "  cat $GENFS"
echo "  grep -r 'sched_pelt_multiplier\|dirty_writeback_centisecs' device/mediatek vendor/xiaomi/miuicamera 2>/dev/null"
