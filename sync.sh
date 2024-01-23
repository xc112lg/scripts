#!/bin/bash


rm -rf .repo/local_manifests
repo init -u https://github.com/DerpFest-AOSP/manifest.git -b 14
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)
source build/envsetup.sh
#mka clean
#make clean
rm out/target/product/*/*.zip
source scripts/fixes.sh
lunch derp_h872-userdebug
m -j$(nproc --all) derp
#lunch lineage_us997-userdebug
#m -j$(nproc --all) bacon
#lunch lineage_h870-userdebug
#m -j$(nproc --all) bacon
