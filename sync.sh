#!/bin/bash
rm -rf .repo/local_manifests
rm -rf device/xiaomi/sm8150-common
rm -rf frameworks/base
rm -rf rbe
git clone https://github.com/xc112lg/rbe --depth 1



export USE_RBE=1                                      
export RBE_DIR="rbe"                      # Path to the extracted reclient directory (relative or absolute)
export NINJA_REMOTE_NUM_JOBS=500                       # Number of parallel remote jobs (adjust based on your RAM, buildbuddy has 80 CPU cores in the free tier)

# --- BuildBuddy Connection Settings ---
export RBE_service="remote.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
export RBE_remote_headers="x-buildbuddy-api-key=NF5nEUUyU7LIy2QkkIIe"    # Your BuildBuddy API key
export RBE_use_rpc_credentials=false                   
export RBE_service_no_auth=true                       

# --- Unified Downloads/Uploads (Recommended) ---
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# --- Execution Strategies (remote_local_fallback is generally best) ---
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback    # Important see below.
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_DUMPER_EXEC_STRATEGY=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# --- Enable RBE for Specific Tools ---
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
export RBE_ABI_DUMPER=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# --- Resource Pools ---
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default


repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs
git clone https://github.com/vayu-development-sources/local_manifests.git -b evo15-dolby .repo/local_manifests
repo sync -c -j64 --force-sync --no-clone-bundle --no-tags --prune
/opt/crave/resync.sh

git clone https://gitlab.com/ArmSM/vendor_xiaomi_miuicamera.git vendor/xiaomi/miuicamera
rm -rf hardware/xiaomi && git clone https://github.com/momenabdulrazek/android_hardware_xiaomi.git -b 15.0 hardware/xiaomi 
rm -rf hardware/qcom-caf/common && git clone https://github.com/momenabdulrazek/android_hardware_qcom-caf_common.git hardware/qcom-caf/common


grep -q '"com.lazada.android"' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java || \
sed -i '/"com.google.android.gms",/a\        "com.lazada.android",\n        "com.shopee.ph",' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java
cat frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java

source scripts/signed.sh
# cd kernel/xiaomi/sm8150
# curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -
# cd -
source build/envsetup.sh
lunch lineage_vayu-bp1a-userdebug
m installclean
# echo legacy
# echo $TARGET_IS_LEGACY
m evolution
mkdir -p vayu
rm -rf vayu/*
cp -r out/target/product/*/*.zip vayu
cp -r out/target/product/*/recovery.img vayu

for file in vayu/*; do
  curl -T "$file" -u :$pixeldrain https://pixeldrain.com/api/file/ || echo "Failed to upload $file"
done





