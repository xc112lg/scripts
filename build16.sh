
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf device/xiaomi/blossom-kernel
rm -rf vendor/xiaomi
rm -rf vendor/xiaomi/miuicamera
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
#rm -rf build/soong
# Cleanup previous changelog to make it always fresh
rm -rf out/target/product/*/system/etc/Changelog.txt \
       out/target/product/*/obj/ETC/Changelog.txt_intermediates \
       out/target/product/*/gen/ETC/Changelog.txt_intermediates


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

# Clone DerpFest
repo init -u https://github.com/Evolution-X/manifest -b bq2 --depth=1 --git-lfs
#Temp Fix Repo tool
#cd .repo/repo;git pull -r;cd ../..;


# Clone local_manifests repository
git clone https://github.com/xc112lg/local_manifests --depth 1 -b crblossom .repo/local_manifests
#git clone https://github.com/bagaskara815/local_manifests --depth 1 -b 16-derp .repo/local_manifests
# if [ ! 0 == 0 ]
#  then   curl -o .repo/local_manifests https://github.com/bagaskara815/local_manifests.git
#  fi
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# repo sync
#/opt/crave/resync.sh
grep -q '"com.lazada.android"' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java || \
sed -i '/"com.android.chrome",/a\        "com.lazada.android",\n        "com.shopee.ph",' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java
#cat frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java
# sed -i '/name: "libwfdservice"/,/system_ext_specific: true/ s/system_ext_specific: true/system_ext_specific: true,\n    allow_undefined_symbols: true/' vendor/xiaomi/sm8150-common/Android.bp

# grep -q '^PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS *:=' device/xiaomi/vayu/lineage_vayu.mk || echo 'PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false' >> device/xiaomi/vayu/lineage_vayu.mk

if grep -q '$(call inherit-product, vendor/xiaomi/miuicamera/MiuiCamera.mk)' device/xiaomi/blossom/device.mk; then
    sed -i 's|$(call inherit-product, vendor/xiaomi/miuicamera/MiuiCamera.mk)|$(call inherit-product-if-exists, vendor/xiaomi/miuicamera/MiuiCamera.mk)|g' device/xiaomi/blossom/device.mk
fi

# cd hardware/xiaomi
# git fetch https://github.com/xc112lg/android_hardware_xiaomi.git patch-2
# git cherry-pick d894f0a080f0b462c9f6bbccfc6f85c538183c62
# cd -
# # Set up build environment
# cd frameworks/base && curl https://gist.githubusercontent.com/bagaskara815/b2abdff48cae8370ca2a0b867d7769e4/raw/fw.patch >> fw.patch && git am fw.patch && rm fw.patch && cd ../../
# wget https://github.com/bagaskara815/local_manifests/raw/keys/keys.zip && unzip -o keys.zip -d vendor/lineage/signing/ && rm keys.zip

# # disable fsgen
# cd build/soong && curl https://gist.githubusercontent.com/bagaskara815/2f26516ef378fe8eae9803749e331a09/raw/fsgen.patch >> fsgen.patch && git am fsgen.patch && rm fsgen.patch && cd ../../

# # Nfc Fix
# cd packages/apps/Nfc && curl https://gist.githubusercontent.com/bagaskara815/e9ad53683e62a66ff0a4ba5d714bed80/raw/nfcfix.patch >> nfcfix.patch && git am nfcfix.patch && rm nfcfix.patch && cd ../../../

# # GMS temp fix
# cd vendor/google/gms && curl https://gist.githubusercontent.com/bagaskara815/eff6e36fb96db28298d35281eb2b85c4/raw/gms-temp-fix.patch >> gms-temp-fix.patch && git am gms-temp-fix.patch && rm gms-temp-fix.patch && cd ../../../

source build/envsetup.sh

# brunch configuration
lunch lineage_blossom-bp4a-userdebug

# Clean
make installclean

# Run
m evolution
