#!/bin/bash
git clone https://github.com/xc112lg/rbe1 >/dev/null 2>&1

# rm -rf .repo/local_manifests 
# git clone https://github.com/LG-G6/scripts.git -b lineage-21 
# mkdir .repo/local_manifests 
# cp scripts/roomservice.xml .repo/local_manifests/ 
#repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
#/opt/crave/resync.sh

export CLANG_TARGET_ARM32="--target=arm-linux-android"
source build/envsetup.sh
#make clean
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe5.sh)

#export WITH_GMS=false
#rm -rf hardware/interfaces/biometrics/fingerprint/2.1/default


    
breakfast h872
brunch h872
