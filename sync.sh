#!/bin/bash

rm -rf device/lge/msm8996-common
git clone https://github.com/LineageOS/android_device_lge_msm8996-common -b lineage-21 device/lge/msm8996-common
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-3
git cherry-pick ea7b7426154f1af5073ab1fb16ee7d3521408d7a

cd ../../../


#repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
source build/envsetup.sh
#mka clean
#make clean
rm out/target/product/*/*.zip
source scripts/fixes.sh
lunch lineage_h872-userdebug
m bacon
#lunch lineage_us997-userdebug
#m bacon
#lunch lineage_h870-userdebug
#m bacon
