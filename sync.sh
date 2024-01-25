#!/bin/bash


rm -rf frameworks/base/
rm -rf device/lge/
rm -rf .repo/local_manifests
repo init -u https://github.com/crdroidandroid/android.git -b 14.0 --git-lfs
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
#repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
source build/envsetup.sh
#mka clean
#make clean
rm out/target/product/*/*.zip
source scripts/fixes.sh
echo $(nproc --all)
lunch lineage_us997-userdebug
m -j$(nproc --all) bacon
lunch lineage_h870-userdebug
m -j$(nproc --all) bacon
lunch lineage_h872-userdebug
m -j$(nproc --all) bacon
