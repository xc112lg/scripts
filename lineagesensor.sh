#!/usr/bin/env bash
# ============================================================
# fix_sensors_conflict.sh
# Fixes duplicate module: android.hardware.sensors@2.0-subhal-impl-1.0
#
# Strategy: Disable hardware/mediatek/sensors (MTK)
#           Keep hardware/lineage/interfaces/sensors (LineageOS)
#
# Usage: Run from your Android source root (AOSP/LineageOS tree root)
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()   { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()  { echo -e "\n${BOLD}── $* ──${NC}"; }

MTK_SENSORS_DIR="hardware/mediatek/sensors"
LINEAGE_SENSORS_DIR="hardware/lineage/interfaces/sensors"
DEVICE_DIR="device/xiaomi/blossom"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Sensors HAL conflict fixer — blossom (LineageOS HAL)  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Sanity check ─────────────────────────────────────────────
[[ -f "build/make/core/base_rules.mk" ]] || \
    error "Run this script from your Android source root directory."

# ── 1. Verify dirs ───────────────────────────────────────────
step "Verifying source directories"

[[ -d "$MTK_SENSORS_DIR" ]]     || error "MTK sensors dir not found: $MTK_SENSORS_DIR"
[[ -d "$LINEAGE_SENSORS_DIR" ]] || error "LineageOS sensors dir not found: $LINEAGE_SENSORS_DIR"

ok "MTK sensors (to disable) : $MTK_SENSORS_DIR"
ok "LineageOS sensors (keep)  : $LINEAGE_SENSORS_DIR"

# ── 2. Find the conflicting MTK file ─────────────────────────
step "Locating conflicting MTK module file"

CONFLICT_FILE=""

for candidate in \
    "$MTK_SENSORS_DIR/Android.mk" \
    "$MTK_SENSORS_DIR/Android.bp" \
    "$MTK_SENSORS_DIR/2.0/Android.mk" \
    "$MTK_SENSORS_DIR/2.0/Android.bp" \
    "$MTK_SENSORS_DIR/impl/Android.mk" \
    "$MTK_SENSORS_DIR/impl/Android.bp"
do
    if [[ -f "$candidate" ]] && grep -q "subhal-impl" "$candidate" 2>/dev/null; then
        CONFLICT_FILE="$candidate"
        break
    fi
done

# Recursive fallback
if [[ -z "$CONFLICT_FILE" ]]; then
    log "Scanning $MTK_SENSORS_DIR recursively..."
    CONFLICT_FILE=$(grep -rl "subhal-impl-1.0" "$MTK_SENSORS_DIR" 2>/dev/null | head -1 || true)
fi

[[ -n "$CONFLICT_FILE" ]] || {
    warn "Could not auto-detect MTK conflict file. Files found:"
    find "$MTK_SENSORS_DIR" -name "Android.*" 2>/dev/null || true
    error "Could not locate the conflicting module. Check the listing above."
}

ok "MTK conflict file: $CONFLICT_FILE"

# ── 3. Skip if already patched ───────────────────────────────
if grep -q "fix_sensors_conflict\|DISABLED by" "$CONFLICT_FILE" 2>/dev/null; then
    ok "Already patched — skipping disable step."
    ALREADY_PATCHED=true
else
    ALREADY_PATCHED=false
fi

# ── 4. Backup ─────────────────────────────────────────────────
step "Creating backup"

BACKUP="${CONFLICT_FILE}.bak_$(date +%Y%m%d_%H%M%S)"
cp "$CONFLICT_FILE" "$BACKUP"
ok "Backup: $BACKUP"

# ── 5. Disable the MTK module ────────────────────────────────
step "Disabling MTK sensors module"

EXT="${CONFLICT_FILE##*.}"

if [[ "$ALREADY_PATCHED" == false ]]; then
    if [[ "$EXT" == "mk" ]]; then
        TMP=$(mktemp)
        cat > "$TMP" <<'MKEOF'
# -------------------------------------------------------
# DISABLED by fix_sensors_conflict.sh
# Reason: android.hardware.sensors@2.0-subhal-impl-1.0
#         is provided by hardware/lineage/interfaces/sensors
#         (LineageOS HAL) for device/xiaomi/blossom.
# Original backed up as *.bak_*
# -------------------------------------------------------
MKEOF
        sed '/^[[:space:]]*$/d' "$CONFLICT_FILE" | \
            sed 's/^[^#]/#DISABLED &/' >> "$TMP"
        mv "$TMP" "$CONFLICT_FILE"
        ok "Android.mk disabled (lines prefixed with #DISABLED)"

    elif [[ "$EXT" == "bp" ]]; then
        TMP=$(mktemp)
        python3 - "$CONFLICT_FILE" "$TMP" <<'PYEOF'
import re, sys

src = open(sys.argv[1]).read()
out = open(sys.argv[2], 'w')

out.write(
    "// -------------------------------------------------------\n"
    "// DISABLED by fix_sensors_conflict.sh\n"
    "// Reason: android.hardware.sensors@2.0-subhal-impl-1.0\n"
    "//         is provided by hardware/lineage/interfaces/sensors\n"
    "//         (LineageOS HAL) for device/xiaomi/blossom.\n"
    "// Original backed up as *.bak_*\n"
    "// -------------------------------------------------------\n\n"
)

def patch_block(m):
    block = m.group(0)
    if 'subhal-impl' not in block:
        return block
    return re.sub(r'(\{)', r'\1\n    enabled: false,', block, count=1)

patched = re.sub(
    r'\bcc_library(?:_shared|_static|_headers)?\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}',
    patch_block,
    src,
    flags=re.DOTALL
)
out.write(patched)
PYEOF
        mv "$TMP" "$CONFLICT_FILE"
        ok "Android.bp disabled (enabled: false injected)"

    else
        error "Unknown file extension '$EXT' — cannot patch automatically."
    fi
else
    ok "Skipped (already patched)."
fi

# ── 6. Patch BoardConfig.mk ──────────────────────────────────
step "Patching $DEVICE_DIR/BoardConfig.mk"

BOARD_CONFIG="$DEVICE_DIR/BoardConfig.mk"
if [[ ! -f "$BOARD_CONFIG" ]]; then
    warn "$BOARD_CONFIG not found — skipping."
else
    if grep -q "fix_sensors_conflict\|TARGET_SENSORS_HAL" "$BOARD_CONFIG"; then
        warn "BoardConfig.mk already patched — skipping."
    else
        cat >> "$BOARD_CONFIG" <<'EOF'

# --- Sensors HAL: use LineageOS implementation ---
# Patched by fix_sensors_conflict.sh
# hardware/mediatek/sensors module is disabled.
# hardware/lineage/interfaces/sensors is the active HAL.
TARGET_SENSORS_HAL := lineage
EOF
        ok "Appended TARGET_SENSORS_HAL to $BOARD_CONFIG"
    fi
fi

# ── 7. Patch device.mk ───────────────────────────────────────
step "Patching $DEVICE_DIR/device.mk"

DEVICE_MK="$DEVICE_DIR/device.mk"
if [[ ! -f "$DEVICE_MK" ]]; then
    warn "$DEVICE_MK not found — skipping."
else
    if grep -q "fix_sensors_conflict\|subhal-impl-1.0" "$DEVICE_MK"; then
        warn "device.mk already references sensors module — skipping."
    else
        cat >> "$DEVICE_MK" <<'EOF'

# --- Sensors HAL package (LineageOS) ---
# Patched by fix_sensors_conflict.sh
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.0-subhal-impl-1.0
EOF
        ok "Added LineageOS sensors package to $DEVICE_MK"
    fi
fi

# ── 8. Summary ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                     All done!                           ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}Disabled (MTK):${NC}   $CONFLICT_FILE"
echo -e "  ${YELLOW}Backup:${NC}           $BACKUP"
[[ -f "$BOARD_CONFIG" ]] && echo -e "  ${YELLOW}Updated:${NC}          $BOARD_CONFIG"
[[ -f "$DEVICE_MK"    ]] && echo -e "  ${YELLOW}Updated:${NC}          $DEVICE_MK"
echo ""
echo -e "  ${CYAN}Active HAL:${NC}  hardware/lineage/interfaces/sensors"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "    make clean && mka bacon"
echo ""
echo -e "  ${CYAN}To revert:${NC}"
echo -e "    cp \"$BACKUP\" \"$CONFLICT_FILE\""
echo ""
