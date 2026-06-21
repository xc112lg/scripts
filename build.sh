#!/bin/bash
# --- Optimized RBE Configuration for AOSP Builds ---
# Recommendations based on your current setup and performance best practices
git clone https://github.com/xc112lg/rbe1

#!/bin/bash
# RBE CONFIGURATION FOR YOUR BUILDBUDDY INSTANCE
# Based on your .bazelrc showing: app.buildbuddy.io and remote.buildbuddy.io

echo "=== Your BuildBuddy Configuration ==="
echo ""
echo "Instance: buildbuddy.io (self-hosted)"
echo "Dashboard: https://app.buildbuddy.io"
echo "RBE Backend: grpcs://remote.buildbuddy.io"
echo ""

# ============================================
# BUILDBUDDY CONFIGURATION (YOUR SETUP)
# ============================================

# Your RBE service endpoint
# Format: grpcs:// means gRPC with TLS
export RBE_service="remote.buildbuddy.io:443"

# Your BuildBuddy API key
# Get from: https://app.buildbuddy.io/settings/org/api-keys
# CHANGE THIS to your actual key
export RBE_remote_headers="x-buildbuddy-api-key=NF5nEUUyU7LIy2QkkIIe"

# TLS enabled (grpcs:// means secure connection)
export RBE_use_rpc_credentials=true

# Require authentication
export RBE_service_no_auth=false

# ============================================
# RBE CORE SETTINGS (64GB RAM OPTIMIZED)
# ============================================
export USE_RBE=1
export RBE_DIR="rbe1"

# Correct for 64GB RAM
export NINJA_REMOTE_NUM_JOBS=400

# ============================================
# NETWORK OPTIMIZATION
# ============================================
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true
export RBE_compression=gzip
export RBE_compression_level=6
export RBE_max_open_files=10000

# ============================================
# EXECUTION STRATEGIES
# ============================================
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# ============================================
# TOOL ENABLEMENT
# ============================================
export RBE_R8=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_JAR=1
export RBE_ZIP=1
export RBE_TURBINE=1
export RBE_SIGNAPK=1
export RBE_CXX_LINKS=1
export RBE_CXX=1
export RBE_ABI_LINKER=1
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# ============================================
# RESOURCE POOLS
# ============================================
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default

# ============================================
# TIMEOUTS (Optimized for 64GB RAM)
# ============================================
export RBE_exec_timeout=20m
export RBE_reclient_timeout=120m

# ============================================
# CACHING
# ============================================
export RBE_cache_dir="${RBE_DIR}/cache"
export RBE_enable_local_cache=1
export RBE_batch_downloads=true

# ============================================
# LOGGING
# ============================================
export RBE_LOG=INFO
export RBE_VERBOSE=0

# ============================================
# VERIFICATION
# ============================================
echo "✓ Configuration for buildbuddy.io"
echo "  RBE Service: ${RBE_service}"
echo "  Dashboard: https://app.buildbuddy.io"
echo "  Parallel Jobs: ${NINJA_REMOTE_NUM_JOBS}"
echo ""
echo "⚠️  NEXT STEPS:"
echo "  1. Replace YOUR_API_KEY with your actual API key"
echo "     Get from: https://app.buildbuddy.io/settings/org/api-keys"
echo ""
echo "  2. Set file descriptor limit:"
echo "     ulimit -n 10000"
echo ""
echo "  3. Source this config:"
echo "     source rbe_your_buildbuddy.sh"
echo ""
echo "  4. Test:"
echo "     time m"
echo ""
echo "  5. View results:"
echo "     https://app.buildbuddy.io/invocation/ (check your invocation)"

echo "✓ RBE optimized configuration loaded"
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf TMP_PATCHES
#rm -rf frameworks/base
sudo apt update
sudo apt install patchelf -y
rm -rf .repo/local_manifests
repo init -u https://github.com/Evolution-X/manifest -b bq2 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests.git -b lunaris .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
. build/envsetup.sh
export WITH_GMS=false
# export WITH_GMS_COMMS_SUITE := false
# export WITH_PIXEL_LAUNCHER := false
# export TARGET_USE_GPHOTOS := false
# export TARGET_USE_WALLPAPERS := false
export TARGET_USES_PICO_GAPPS=true
sed -i 's|-include vendor/lineage-priv/keys/keys.mk|-include vendor/evolution-priv/keys/keys.mk|' device/xiaomi/blossom/lineage_blossom.mk
sed -i '\|vendor/extras/prebuilt/product/fonts,\$(TARGET_COPY_OUT_PRODUCT)/fonts|d' vendor/extras/evolution.mk
#sed -i '/<item>com.android.nfc<\/item>/d' frameworks/base/core/res/res/values/policy_exempt_apps.xml
#cat frameworks/base/core/res/res/values/policy_exempt_apps.xml
lunch lineage_blossom-bp4a-user
m installclean
m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/tar.sh | bash >/dev/null 2>&1
