#!/bin/bash

#rm -rf kernel/lge/msm8996
#git clone https://github.com/LG-G6/android_kernel_lge_msm8996 -b lineage-21 kernel/lge/msm8996
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-17
git cherry-pick de28f9e8147a0ae6e3691dc39a483c0201261d85
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

