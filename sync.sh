#!/bin/bash

rm -rf kernel/lge/msm8996
git clone https://github.com/xc112lg/android_kernel_lge_msm8996 -b cd11 kernel/lge/msm8996
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
#cd device/lge/msm8996-common
#git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-11
#git cherry-pick 349a1ef8cfb99d74d40640b8ff2b35e408a9dd58
#cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

