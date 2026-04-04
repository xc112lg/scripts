#!/usr/bin/env bash
# ============================================================
# fix_sensors_conflict.sh
# Fixes duplicate module: android.hardware.sensors@2.0-subhal-impl-1.0
# Strategy: Keep hardware/mediatek/sensors (MTK HAL)
#           Remove the conflicting definition from hardware/lineage/interfaces/sensors
# Usage: Run from your Android source root (AOSP/LineageOS tree root)
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()     { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Sanity check: must be run from AOSP root ─────────────────
[[ -f "build/make/core/base_rules.mk" ]] || \
    error "Run this script from your Android source root directory."

LINEAGE_SENSORS_DIR="hardware/lineage/interfaces/sensors"
MTK_SENSORS_DIR="hardware/mediatek/sensors"
DEVICE_DIR="device/xiaomi/blossom"

log "=== Sensors HAL conflict fixer for $DEVICE_DIR ==="
echo ""

# ── 1. Verify MTK sensors dir exists ─────────────────────────
if [[ ! -d "$MTK_SENSORS_DIR" ]]; then
    error "MTK sensors dir not found: $MTK_SENSORS_DIR — cannot continue."
fi
ok "MTK sensors HAL found at: $MTK_SENSORS_DIR"

# ── 2. Find the conflicting file in lineage sensors ───────────
CONFLICT_FILE=""
for candidate in \
    "$LINEAGE_SENSORS_DIR/Android.mk" \
    "$LINEAGE_SENSORS_DIR/Android.bp" \
    "$LINEAGE_SENSORS_DIR/2.0/Android.mk" \
    "$LINEAGE_SENSORS_DIR/2.0/Android.bp" \
    "$LINEAGE_SENSORS_DIR/2.1/Android.mk" \
    "$LINEAGE_SENSORS_DIR/2.1/Android.bp"
do
    if [[ -f "$candidate" ]]; then
        if grep -q "subhal-impl-1.0\|subhal-impl" "$candidate" 2>/dev/null; then
            CONFLICT_FILE="$candidate"
            break
        fi
    fi
done

if [[ -z "$CONFLICT_FILE" ]]; then
    # Broader search
    log "Scanning $LINEAGE_SENSORS_DIR recursively for conflicting module..."
    CONFLICT_FILE=$(grep -rl "subhal-impl-1.0" "$LINEAGE_SENSORS_DIR" 2>/dev/null | head -1 || true)
fi

if [[ -z "$CONFLICT_FILE" ]]; then
    warn "Could not find the conflicting module file automatically."
    warn "Directory listing of $LINEAGE_SENSORS_DIR:"
    find "$LINEAGE_SENSORS_DIR" -name "Android.*" 2>/dev/null || true
    error "Please check the directory above and re-run after updating CONFLICT_FILE in this script."
fi

ok "Conflicting module file found: $CONFLICT_FILE"
echo ""

# ── 3. Backup the conflicting file ───────────────────────────
BACKUP="${CONFLICT_FILE}.bak_$(date +%Y%m%d_%H%M%S)"
cp "$CONFLICT_FILE" "$BACKUP"
ok "Backup created: $BACKUP"

# ── 4. Comment-out or disable the conflicting module ─────────
EXT="${CONFLICT_FILE##*.}"

if [[ "$EXT" == "mk" ]]; then
    log "Disabling conflicting module in $CONFLICT_FILE (Android.mk)..."
    # Wrap the whole file content in an ifeq that never matches
    TMP=$(mktemp)
    cat > "$TMP" <<'MKEOF'
# --- PATCHED by fix_sensors_conflict.sh ---
# Disabled: android.hardware.sensors@2.0-subhal-impl-1.0
# Reason:   Conflicts with hardware/mediatek/sensors (MTK HAL kept instead)
# Original file backed up as *.bak_*
# ------------------------------------------
MKEOF
    # Comment every non-comment, non-blank line
    sed 's/^[^#]/#DISABLED &/' "$CONFLICT_FILE" >> "$TMP"
    mv "$TMP" "$CONFLICT_FILE"
    ok "Android.mk module disabled (lines prefixed with #DISABLED)"

elif [[ "$EXT" == "bp" ]]; then
    log "Disabling conflicting module in $CONFLICT_FILE (Android.bp)..."
    TMP=$(mktemp)
    # Android.bp doesn't support comments per-line easily; wrap in enabled:false
    python3 - "$CONFLICT_FILE" "$TMP" <<'PYEOF'
import re, sys

src  = open(sys.argv[1]).read()
dst  = open(sys.argv[2], 'w')

dst.write("// --- PATCHED by fix_sensors_conflict.sh ---\n")
dst.write("// Disabled: android.hardware.sensors@2.0-subhal-impl-1.0\n")
dst.write("// Reason: conflicts with hardware/mediatek/sensors (MTK HAL kept)\n")
dst.write("// Original backed up as *.bak_*\n\n")

# Insert enabled: false into every cc_library_shared / cc_library block
# that contains "subhal-impl"
def patch_block(m):
    block = m.group(0)
    if 'subhal-impl' not in block:
        return block
    # Add enabled: false after the opening brace
    return re.sub(r'(\{)', r'\1\n    enabled: false,', block, count=1)

patched = re.sub(
    r'cc_library(?:_shared|_static|_headers|)?\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}',
    patch_block,
    src,
    flags=re.DOTALL
)
dst.write(patched)
PYEOF
    mv "$TMP" "$CONFLICT_FILE"
    ok "Android.bp module disabled (enabled: false injected)"
else
    error "Unknown file extension: $EXT — don't know how to patch."
fi

# ── 5. Patch device/xiaomi/blossom BoardConfig.mk ────────────
BOARD_CONFIG="$DEVICE_DIR/BoardConfig.mk"
if [[ ! -f "$BOARD_CONFIG" ]]; then
    warn "$BOARD_CONFIG not found — skipping BoardConfig.mk patch."
else
    if grep -q "USE_MTK_SENSORS_HAL\|fix_sensors_conflict" "$BOARD_CONFIG"; then
        warn "BoardConfig.mk already patched — skipping."
    else
        cat >> "$BOARD_CONFIG" <<'EOF'

# --- Sensors HAL: use MTK implementation ---
# Patched by fix_sensors_conflict.sh
# Keeps hardware/mediatek/sensors and disables
# the conflicting hardware/lineage/interfaces/sensors module.
TARGET_SENSORS_HAL := mtk
EOF
        ok "Appended sensor HAL flag to $BOARD_CONFIG"
    fi
fi

# ── 6. Patch device/xiaomi/blossom/device.mk ─────────────────
DEVICE_MK="$DEVICE_DIR/device.mk"
if [[ ! -f "$DEVICE_MK" ]]; then
    warn "$DEVICE_MK not found — skipping device.mk patch."
else
    if grep -q "android.hardware.sensors@2.0-subhal-impl-1.0\|fix_sensors_conflict" "$DEVICE_MK"; then
        warn "device.mk already references sensors module — skipping."
    else
        cat >> "$DEVICE_MK" <<'EOF'

# --- Sensors HAL package (MTK) ---
# Patched by fix_sensors_conflict.sh
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.0-subhal-impl-1.0
EOF
        ok "Ensured MTK sensors package is listed in $DEVICE_MK"
    fi
fi

# ── 7. Summary ────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Done! Changes made:${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "  ${YELLOW}Backup:${NC}          $BACKUP"
echo -e "  ${YELLOW}Patched (off):${NC}   $CONFLICT_FILE"
[[ -f "$BOARD_CONFIG" ]] && echo -e "  ${YELLOW}Updated:${NC}         $BOARD_CONFIG"
[[ -f "$DEVICE_MK"    ]] && echo -e "  ${YELLOW}Updated:${NC}         $DEVICE_MK"
echo ""
echo -e "  ${CYAN}Next step:${NC}  Clean and rebuild"
echo -e "  ${CYAN}  make clean && mka bacon${NC}"
echo ""
echo -e "  ${CYAN}To revert:${NC}  Restore the backup"
echo -e "  ${CYAN}  cp $BACKUP $CONFLICT_FILE${NC}"
echo ""
