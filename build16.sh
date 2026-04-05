sudo apt update
sudo apt install patchelf -y

rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf device/xiaomi/blossom-kernel
rm -rf vendor/xiaomi
rm -rf vendor/xiaomi/miuicamera
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf hardware/dolby
rm -rf hardware/
#rm -rf build/soong
# Cleanup previous changelog to make it always fresh
rm -rf out/target/product/*/system/etc/Changelog.txt \
       out/target/product/*/obj/ETC/Changelog.txt_intermediates \
       out/target/product/*/gen/ETC/Changelog.txt_intermediates


repo init -u https://github.com/Evolution-X/manifest -b bq2 --depth=1 --git-lfs
#Temp Fix Repo tool
#cd .repo/repo;git pull -r;cd ../..;


# Clone local_manifests repository
#git clone https://github.com/0kaarun/Blossom_local_mainfest --depth 1 -b A16 .repo/local_manifests

git clone https://github.com/xc112lg/local_manifests --depth 1 -b crblossom .repo/local_manifests
# if [ ! 0 == 0 ]
#  then   curl -o .repo/local_manifests https://github.com/bagaskara815/local_manifests.git
#  fi
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# repo sync
/opt/crave/resync.sh
grep -q '"com.lazada.android"' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java || \
sed -i '/"com.android.chrome",/a\        "com.lazada.android",\n        "com.shopee.ph",' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java

# 1. BoardConfig.mk — exclude MTK sensor subhal
sed -i '/BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true/a \
\
# Sensors: use Lineage subhal, exclude conflicting MediaTek subhal\
SOONG_SUBDIR_MAKEFILES_EXCLUDE += hardware/mediatek/sensors' \
device/xiaomi/blossom/BoardConfig.mk

# 2. device.mk — add Lineage subhal package
sed -i '/android.hardware.sensors@2.0.vendor \\/a\    android.hardware.sensors@2.0-subhal-impl-1.0 \\' \
device/xiaomi/blossom/device.mk



source build/envsetup.sh
lunch lineage_blossom-bp4a-userdebug
make clean

m evolution 2>&1 | tee build.log
curl -F "file=@build.log" https://temp.sh/upload

