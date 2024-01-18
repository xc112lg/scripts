#!/bin/bash

#rm -rf kernel/lge/msm8996
#git clone https://github.com/LG-G6/android_kernel_lge_msm8996 -b lineage-21 kernel/lge/msm8996
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-15
git cherry-pick 3f2fabf57104c80a58dc8ddf9c55d5f7558915be
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

