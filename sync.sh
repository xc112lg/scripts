#!/bin/bash
rm -rf .repo/local_manifests
rm -rf device/xiaomi/sm8150-common
rm -rf frameworks/base
rm -rf rbe


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





