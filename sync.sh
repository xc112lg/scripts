#!/bin/bash
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-10
git cherry-pick eb3a34918658c0d14a3913b75dc503801b05a020
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

