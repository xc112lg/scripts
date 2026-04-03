
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf device/xiaomi/blossom-kernel
rm -rf vendor/xiaomi
rm -rf vendor/xiaomi/miuicamera
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf hardware/dolby
#rm -rf build/soong
# Cleanup previous changelog to make it always fresh
rm -rf out/target/product/*/system/etc/Changelog.txt \
       out/target/product/*/obj/ETC/Changelog.txt_intermediates \
       out/target/product/*/gen/ETC/Changelog.txt_intermediates


# git clone https://github.com/xc112lg/rbe --depth 1



# export USE_RBE=1                                      
# export RBE_DIR="rbe"                      # Path to the extracted reclient directory (relative or absolute)
# export NINJA_REMOTE_NUM_JOBS=500                       # Number of parallel remote jobs (adjust based on your RAM, buildbuddy has 80 CPU cores in the free tier)

# # --- BuildBuddy Connection Settings ---
# export RBE_service="remote.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
# export RBE_remote_headers="x-buildbuddy-api-key=NF5nEUUyU7LIy2QkkIIe"    # Your BuildBuddy API key
# export RBE_use_rpc_credentials=false                   
# export RBE_service_no_auth=true                       

# # --- Unified Downloads/Uploads (Recommended) ---
# export RBE_use_unified_downloads=true
# export RBE_use_unified_uploads=true

# # --- Execution Strategies (remote_local_fallback is generally best) ---
# export RBE_R8_EXEC_STRATEGY=remote_local_fallback
# export RBE_D8_EXEC_STRATEGY=remote_local_fallback
# export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
# export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
# export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
# export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
# export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
# export RBE_CXX_EXEC_STRATEGY=remote_local_fallback    # Important see below.
# export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
# export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
# export RBE_ABI_DUMPER_EXEC_STRATEGY=    # Will make build slower, by a lot. Keeping this for documentation
# export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
# export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
# export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# # --- Enable RBE for Specific Tools ---
# export RBE_R8=1
# export RBE_D8=1
# export RBE_JAVAC=1
# export RBE_JAR=1
# export RBE_ZIP=1
# export RBE_TURBINE=1
# export RBE_SIGNAPK=1
# export RBE_CXX_LINKS=1
# export RBE_CXX=1
# export RBE_ABI_LINKER=1
# export RBE_ABI_DUMPER=    # Will make build slower, by a lot. Keeping this for documentation
# export RBE_CLANG_TIDY=1
# export RBE_METALAVA=1
# export RBE_LINT=1

# # --- Resource Pools ---
# export RBE_JAVA_POOL=default
# export RBE_METALAVA_POOL=default
# export RBE_LINT_POOL=default

# Clone DerpFest
repo init -u https://github.com/Evolution-X/manifest -b bq2 --depth=1 --git-lfs
#Temp Fix Repo tool
#cd .repo/repo;git pull -r;cd ../..;


# Clone local_manifests repository
git clone https://github.com/0kaarun/Blossom_local_mainfest --depth 1 -b A16 .repo/local_manifests
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
# sed -i '/$(call inherit-product, vendor/xiaomi/blossom/blossom-vendor.mk)\n    $(call inherit-product-if-exists, vendor/xiaomi/miuicamera/MiuiCamera.mk/' device/xiaomi/blossom/device.mk

# cd device/xiaomi/blossom
# git fetch https://github.com/xc112lg/android_device_xiaomi_blossom.git patch-3
# sleep 5
# git cherry-pick 523fb262dd41a83f05b4303e53976b9ba1ce6a6d
# cd -
# sed -i 's|$(call inherit-product, vendor/xiaomi/miuicamera/MiuiCamera.mk)|$(call inherit-product-if-exists, vendor/xiaomi/miuicamera/MiuiCamera.mk)|' device/xiaomi/blossom/device.mk
# sed -i 's|$(call inherit-product, hardware/dolby/dolby.mk)|$(call inherit-product-if-exists, hardware/dolby/dolby.mk)|' device/xiaomi/blossom/device.mk

# sed -i '/proc \/tp_gesture/d' device/xiaomi/blossom/sepolicy/**/*
# sed -i '/cpufreq/d' device/xiaomi/blossom/sepolicy/**/*
# sed -i '/gpu_(min|max)_clock/d' device/xiaomi/blossom/sepolicy/**/*

# Path to the Android.mk file
ANDROID_MK="hardware/mediatek/sensors/Android.mk"

# Check if file exists
if [ ! -f "$ANDROID_MK" ]; then
    echo "Error: $ANDROID_MK not found!"
    exit 1
fi

# Create backup
cp "$ANDROID_MK" "${ANDROID_MK}.backup.$(date +%Y%m%d_%H%M%S)"
echo "Backup created"

# Use sed to comment out the module block
# This looks for the pattern and adds # to each line until BUILD_SHARED_LIBRARY
sed -i '/^include $(CLEAR_VARS)/,/^include $(BUILD_SHARED_LIBRARY)/{
    /LOCAL_MODULE := android.hardware.sensors@2.0-subhal-impl-1.0/,/^include $(BUILD_SHARED_LIBRARY)/{
        s/^/# /
    }
}' "$ANDROID_MK"

# Alternative more precise sed command if the above doesn't work
# sed -i '/LOCAL_MODULE := android.hardware.sensors@2.0-subhal-impl-1.0/,/^include $(BUILD_SHARED_LIBRARY)/s/^/# /' "$ANDROID_MK"

echo "Module commented out in $ANDROID_MK"
source build/envsetup.sh

# brunch configuration
lunch lineage_blossom-bp4a-userdebug

# Clean
make installclean

# Run
m evolution
