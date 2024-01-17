#!/bin/bash
rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-3
git cherry-pick dd91acfa5ef3bb84ca8e03b0b82360deba360a7b
cd ../../../
source build/envsetup.sh
rm out/target/product/*/*.zip
lunch lineage_h872-userdebug
m bacon

