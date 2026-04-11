#!/usr/bin/env bash
# =============================================================================
# fix_and_build.sh — Auto-fix & retry for EvoX/LineageOS blossom build
# Fixes: missing lib_driver_cmd_mt66xx dependency in wpa_supplicant
# Usage:  chmod +x fix_and_build.sh && ./fix_and_build.sh
# Run from the ROOT of your AOSP tree (where Android.bp lives).
# =============================================================================

set -euo pipefail

AOSP_ROOT="$(pwd)"
WPA_BP="external/wpa_supplicant_8/wpa_supplicant/Android.bp"
BACKUP_SUFFIX=".bak_fix"
LOG_FILE="fix_build_$(date +%Y%m%d_%H%M%S).log"
TARGET="blossom"
VARIANT="userdebug"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"; }

# ── Sanity check ─────────────────────────────────────────────────────────────
if [[ ! -f "Android.bp" ]]; then
    error "Must be run from the AOSP root directory (Android.bp not found)."
    exit 1
fi

info "AOSP root: $AOSP_ROOT"
info "Log file:  $LOG_FILE"
echo ""

# ── Step 1: Install ccache if missing ────────────────────────────────────────
info "Step 1: Checking ccache..."
if ! command -v ccache &>/dev/null; then
    warn "ccache not found. Installing..."
    sudo apt-get install -y ccache >> "$LOG_FILE" 2>&1
    export USE_CCACHE=1
    export CCACHE_DIR="$HOME/.ccache"
    ccache -M 50G >> "$LOG_FILE" 2>&1
    info "ccache installed and set to 50G cache."
else
    info "ccache already installed: $(ccache --version | head -1)"
    export USE_CCACHE=1
    export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
fi
echo ""

# ── Step 2: Search for lib_driver_cmd_mt66xx ─────────────────────────────────
info "Step 2: Searching for 'lib_driver_cmd_mt66xx' in Android.bp files..."
FOUND_PATHS=$(grep -rl "lib_driver_cmd_mt66xx" --include="Android.bp" "$AOSP_ROOT" 2>/dev/null || true)

if [[ -n "$FOUND_PATHS" ]]; then
    info "Found lib_driver_cmd_mt66xx defined in:"
    echo "$FOUND_PATHS" | tee -a "$LOG_FILE"
    echo ""
    warn "Library exists but isn't visible to wpa_supplicant."
    warn "Checking if it's a Soong namespace issue..."

    # Extract the directory containing the library definition
    LIB_DIR=$(echo "$FOUND_PATHS" | head -1 | xargs dirname)
    info "Library located at: $LIB_DIR"

    # Check if that path is in PRODUCT_SOONG_NAMESPACES
    info "Verifying namespace inclusion..."
    SOONG_NS_FILE="$AOSP_ROOT/device/xiaomi/blossom/BoardConfig.mk"
    if grep -q "lib_driver_cmd_mt66xx" "$SOONG_NS_FILE" 2>/dev/null || \
       grep -rq "$LIB_DIR" "$AOSP_ROOT/device/xiaomi/blossom/" 2>/dev/null; then
        info "Namespace appears to be included. The fix may be a visibility rule."
        APPLY_PATCH=false
    else
        warn "Namespace NOT included. Will attempt to add it."
        APPLY_PATCH=false
        ADD_NAMESPACE=true
        NAMESPACE_PATH="$LIB_DIR"
    fi
else
    warn "lib_driver_cmd_mt66xx NOT found anywhere in tree."
    info "Will patch wpa_supplicant/Android.bp to remove the dependency."
    APPLY_PATCH=true
fi
echo ""

# ── Step 3: Apply fixes ───────────────────────────────────────────────────────
info "Step 3: Applying fixes..."

if [[ "${APPLY_PATCH:-false}" == "true" ]]; then
    # Library is truly missing — patch wpa_supplicant Android.bp to drop it
    if [[ ! -f "$WPA_BP" ]]; then
        error "Cannot find $WPA_BP — is your tree fully synced?"
        exit 1
    fi

    info "Backing up $WPA_BP to ${WPA_BP}${BACKUP_SUFFIX}"
    cp "$WPA_BP" "${WPA_BP}${BACKUP_SUFFIX}"

    info "Patching: removing 'lib_driver_cmd_mt66xx' from wpa_supplicant Android.bp..."
    # Remove lines that reference lib_driver_cmd_mt66xx (handles quoted and unquoted)
    sed -i '/"lib_driver_cmd_mt66xx"/d' "$WPA_BP"
    sed -i "/lib_driver_cmd_mt66xx/d" "$WPA_BP"

    # Verify the patch worked
    if grep -q "lib_driver_cmd_mt66xx" "$WPA_BP"; then
        error "Patch did not fully remove the dependency. Manual intervention needed."
        error "File: $WPA_BP"
        exit 1
    fi
    info "Patch applied successfully."

elif [[ "${ADD_NAMESPACE:-false}" == "true" ]]; then
    # Library exists but namespace isn't wired up — add it to BoardConfig
    SOONG_NS_FILE="$AOSP_ROOT/device/xiaomi/blossom/BoardConfig.mk"
    if [[ -f "$SOONG_NS_FILE" ]]; then
        info "Backing up BoardConfig.mk..."
        cp "$SOONG_NS_FILE" "${SOONG_NS_FILE}${BACKUP_SUFFIX}"
        info "Adding $NAMESPACE_PATH to PRODUCT_SOONG_NAMESPACES in BoardConfig.mk..."
        # Append to existing PRODUCT_SOONG_NAMESPACES or add a new line
        if grep -q "PRODUCT_SOONG_NAMESPACES" "$SOONG_NS_FILE"; then
            sed -i "s|PRODUCT_SOONG_NAMESPACES *:=|PRODUCT_SOONG_NAMESPACES := $NAMESPACE_PATH|" "$SOONG_NS_FILE"
            sed -i "s|PRODUCT_SOONG_NAMESPACES *+=|PRODUCT_SOONG_NAMESPACES += $NAMESPACE_PATH|" "$SOONG_NS_FILE"
        else
            echo "" >> "$SOONG_NS_FILE"
            echo "PRODUCT_SOONG_NAMESPACES += $NAMESPACE_PATH" >> "$SOONG_NS_FILE"
        fi
        info "Namespace added."
    else
        error "Cannot find BoardConfig.mk at $SOONG_NS_FILE"
        exit 1
    fi
else
    info "No patching needed — build environment looks correct."
fi
echo ""

# ── Step 4: Clean Soong cache for affected modules ────────────────────────────
info "Step 4: Cleaning Soong build cache for affected modules..."
rm -rf "$AOSP_ROOT/out/soong/.intermediates/external/wpa_supplicant_8" 2>/dev/null || true
rm -f  "$AOSP_ROOT/out/soong/build.lineage_${TARGET}.ninja" 2>/dev/null || true
rm -f  "$AOSP_ROOT/out/soong/soong.environment.used.lineage_${TARGET}.build" 2>/dev/null || true
info "Cache cleaned."
echo ""

# ── Step 5: Source build environment and retry ────────────────────────────────
info "Step 5: Starting build for lineage_${TARGET}-${VARIANT}..."
echo ""

(
    # Source the build environment inside a subshell
    source build/envsetup.sh >> "$LOG_FILE" 2>&1
    lunch "lineage_${TARGET}-${VARIANT}" >> "$LOG_FILE" 2>&1

    info "lunch done. Launching mka bacon..."
    echo ""

    # Run the build, tee output to log and terminal
    mka bacon 2>&1 | tee -a "$LOG_FILE"
)

BUILD_EXIT=${PIPESTATUS[0]}

echo ""
if [[ $BUILD_EXIT -eq 0 ]]; then
    info "============================================"
    info " BUILD SUCCEEDED!"
    info " Output: $AOSP_ROOT/out/target/product/$TARGET/"
    info "============================================"
else
    error "============================================"
    error " BUILD FAILED (exit $BUILD_EXIT)"
    error " Check $LOG_FILE for full details."
    error " Grep for 'error:' to find the cause:"
    error "   grep -n 'error:' $LOG_FILE | tail -30"
    error "============================================"
    exit $BUILD_EXIT
fi
