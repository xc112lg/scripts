#!/bin/bash

rm -rf build/make/
rm -rf frameworks/base/
rm -rf device/lge/
rm -rf hardware/lge
rm -rf kernel/lge/msm8996/
rm -rf vendor/lge/
rm -rf vendor/lineage/

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
#repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
source build/envsetup.sh
#mka clean
#make clean
rm out/target/product/*/*.zip
source scripts/fixes.sh
#lunch lineage_h872-userdebug
#m bacon
lunch lineage_us997-userdebug
m bacon
lunch lineage_h870-userdebug
m bacon
