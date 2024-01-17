#!/bin/bash

#rm -rf kernel/lge/msm8996
#git clone https://github.com/LineageOS/lgkernel -b lineage-2 kernel/lge/msm8996
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-12
git cherry-pick 10f8592ca009d1d42002bf571a5b02e7cbbdb484
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

