#!/bin/bash

# Function to wait for 1 second
wait_one_second() {
    sleep 1
}

# Remove existing build artifacts
wait_one_second && rm -rf out/target/product/*/*.zip device/lge/msm8996-common

# Update and install ccache
wait_one_second && sudo apt-get update -y
wait_one_second && sudo apt-get install -y ccache
wait_one_second && export USE_CCACHE=1
wait_one_second && export CCACHE_DIR=/tmp/src/android/cc
wait_one_second && ccache -M 100G

rm -rf frameworks/base/
rm -rf device/lge
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags
#repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
#git clone https://github.com/xc112lg/msm8996_lge_kernel -b patch-1 kernel/lge/msm8996
source build/envsetup.sh
#mka clean
#make clean
#rm out/target/product/*/*.zip
source scripts/fixes.sh
lunch lineage_us997-userdebug
m -j15 bacon
lunch lineage_h870-userdebug
m -j15 bacon
lunch lineage_h872-userdebug
m -j15 bacon
