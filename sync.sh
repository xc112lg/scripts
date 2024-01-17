#!/bin/bash
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-11
git cherry-pick 9b7ede9d1e607a5610044d82af7c7ce7b003842e
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

