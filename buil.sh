#!/usr/bin/env bash
#
# build_orangefox.sh
# Local build script converted from OrangeFox-OFRP.yml (GitHub Actions workflow)
# Target: OrangeFox manifest branch 12.1
#
# Run this on a machine that meets Android/OrangeFox build requirements
# (Ubuntu 20.04/22.04 recommended, ~250GB free disk, 16GB+ RAM, fast internet).

set -eo pipefail
# Note: intentionally NOT using `set -u` (nounset).
# Android's build/envsetup.sh and related build scripts reference variables
# (e.g. TOP, ZSH_VERSION) that are expected to be unset/empty in a normal
# shell, and `set -u` makes bash treat that as a fatal error.

# ============================================================
# CONFIGURATION - edit these to match your device tree
# ============================================================
MANIFEST_BRANCH="12.1"                                              # OrangeFox manifest branch
DEVICE_TREE="https://github.com/xc112lg/android_device_lge_h872"    # Your recovery device tree repo
DEVICE_TREE_BRANCH="main"                                           # Branch of the device tree
DEVICE_NAME="h872"                                                  # PRODUCT_DEVICE codename
DEVICE_PATH="device/lge/h872"                                       # DEVICE_PATH from BoardConfig.mk
BUILD_TARGET="recovery"                                             # boot | recovery | vendorboot
LDCHECK="false"                                                     # true | false
LDCHECKPATH="system/bin/qseecomd"                                   # blob path to check if LDCHECK=true

# Where everything will be built (equivalent to $GITHUB_WORKSPACE/OrangeFox)
WORKSPACE="$(pwd)/OrangeFox"
ORANGEFOX_ROOT="${WORKSPACE}/fox_${MANIFEST_BRANCH}"
OUTPUT_DIR="${ORANGEFOX_ROOT}/out/target/product/${DEVICE_NAME}"

# Where final build artifacts get copied to, instead of a GitHub Release
RELEASE_DIR="$(pwd)/release_out"

# ============================================================
# 1. Build environment setup
# ============================================================
echo ">>> Installing base tools"
sudo apt update
sudo apt install -y aria2 git

echo ">>> Setting up Android build environment via OrangeFox scripts"
mkdir -p "$(pwd)/scripts_setup"
if [ ! -d "$(pwd)/scripts_setup/scripts" ]; then
    git clone https://gitlab.com/OrangeFox/misc/scripts.git "$(pwd)/scripts_setup/scripts"
fi
pushd "$(pwd)/scripts_setup/scripts"
sudo bash setup/android_build_env.sh
popd

# ccache (equivalent of hendrikmuhs/ccache-action)
export USE_CCACHE=1
export CCACHE_EXEC="$(command -v ccache || echo /usr/bin/ccache)"
ccache -M 10G || true

# ============================================================
# 2. Sync OrangeFox manifest
# ============================================================
echo ">>> Syncing OrangeFox manifest (branch ${MANIFEST_BRANCH})"
mkdir -p "${WORKSPACE}"
cd "${WORKSPACE}"

git config --global user.name "$(whoami)"
git config --global user.email "$(whoami)@localhost"

if [ ! -d "sync" ]; then
    git clone https://gitlab.com/OrangeFox/sync.git -b master
fi
cd sync

if [ -f "${ORANGEFOX_ROOT}/build/core/Makefile" ]; then
    echo "OrangeFox tree already synced at ${ORANGEFOX_ROOT}, skipping orangefox_sync.sh"
    echo "(delete ${ORANGEFOX_ROOT} first if you want a clean re-sync)"
else
    ./orangefox_sync.sh --branch "${MANIFEST_BRANCH}" --path "${ORANGEFOX_ROOT}"
fi

# ============================================================
# 3. Clone your device tree
# ============================================================
echo ">>> Cloning device tree"
cd "${ORANGEFOX_ROOT}"
rm -rf ${DEVICE_PATH}
mkdir -p "$(dirname "${DEVICE_PATH}")"
if [ ! -d "${DEVICE_PATH}" ]; then
    git clone "${DEVICE_TREE}" -b "${DEVICE_TREE_BRANCH}" "./${DEVICE_PATH}"
fi
cd "${DEVICE_PATH}"
COMMIT_ID="$(git rev-parse HEAD)"
echo "Device tree commit: ${COMMIT_ID}"

# ============================================================
# 4. Build OrangeFox
# ============================================================
echo ">>> Building OrangeFox (${BUILD_TARGET}) for ${DEVICE_NAME}"
pushd "${ORANGEFOX_ROOT}"
set +e
export ALLOW_MISSING_DEPENDENCIES=true
sed -i 's/return sandboxConfig\.working/return false/g' build/soong/ui/build/sandbox_linux.go
source build/envsetup.sh
set -e

lunch "twrp_${DEVICE_NAME}-eng"
make clean
mka adbd "${BUILD_TARGET}image"
popd

# ============================================================
# 5. Check build output
# ============================================================
BUILD_DATE="$(TZ=UTC date +%Y%m%d)"
echo ">>> Checking build output in ${OUTPUT_DIR}"

img_file="$(find "${OUTPUT_DIR}" -name "${BUILD_TARGET}*.img" -print -quit || true)"
zip_file="$(find "${OUTPUT_DIR}" -name "OrangeFox*.zip" -print -quit || true)"

mkdir -p "${RELEASE_DIR}"

if [ -n "${img_file}" ] && [ -f "${img_file}" ]; then
    MD5_IMG="$(md5sum "${img_file}" | cut -d ' ' -f 1)"
    echo "Image built OK: ${img_file} (md5: ${MD5_IMG})"
    cp -v "${img_file}" "${RELEASE_DIR}/" || true
else
    echo "!!! Recovery image not found. Build likely failed."
fi

if [ -n "${zip_file}" ] && [ -f "${zip_file}" ]; then
    MD5_ZIP="$(md5sum "${zip_file}" | cut -d ' ' -f 1)"
    echo "Zip built OK: ${zip_file} (md5: ${MD5_ZIP})"
    cp -v "${zip_file}" "${RELEASE_DIR}/" || true
else
    echo "Note: zip not present (image may still be valid if build completed 100%)."
fi

# Copy any other relevant artifacts
find "${OUTPUT_DIR}" -maxdepth 1 \( -name "OrangeFox*.img" -o -name "OrangeFox*.tar" -o -name "ramdisk-recovery.*" \) \
    -exec cp -v {} "${RELEASE_DIR}/" \; 2>/dev/null || true

echo ">>> Build summary"
echo "Manifest branch: ${MANIFEST_BRANCH}"
echo "Device: ${DEVICE_NAME}"
echo "Device tree: ${DEVICE_TREE} (${DEVICE_TREE_BRANCH}) @ ${COMMIT_ID}"
echo "Artifacts copied to: ${RELEASE_DIR}"

# ============================================================
# 6. Optional: LDCheck (missing dependency check)
# ============================================================
if [ "${LDCHECK}" = "true" ]; then
    echo ">>> Running LDCheck"
    LDTOOLS_DIR="${ORANGEFOX_ROOT}/tools"
    RECOVERY_ROOT="${OUTPUT_DIR}/${DEVICE_NAME}/recovery/root"

    if [ -d "${LDTOOLS_DIR}" ] && [ -d "${RECOVERY_ROOT}" ]; then
        mv -n "${LDTOOLS_DIR}/libneeds" "${RECOVERY_ROOT}/" 2>/dev/null || true
        mv -n "${LDTOOLS_DIR}/ldcheck" "${RECOVERY_ROOT}/" 2>/dev/null || true
        cd "${RECOVERY_ROOT}"
        python3 ldcheck -p system/lib64:vendor/lib64:system/lib:vendor/lib -d "${LDCHECKPATH}" || true
        echo "Done checking missing dependencies. Review, and reconfigure your tree."
    else
        echo "LDCheck skipped: expected directories not found (${LDTOOLS_DIR} / ${RECOVERY_ROOT})"
    fi
fi

echo ">>> Done."
