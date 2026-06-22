  #!/bin/bash
# --- Optimized RBE Configuration for AOSP Builds ---
# Recommendations based on your current setup and performance best practices
git clone https://github.com/xc112lg/rbe1

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe.sh)
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
#export WITH_GMS=true
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
