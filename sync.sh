#!/bin/bash
rm -rf .repo/local_manifests
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
# cd frameworks/base
# git log 

#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
#repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
#/opt/crave/resync.sh



source scripts/clean.sh
# source scripts/extras.sh

#source build/envsetup.sh
# chmod +x scripts/generate_certs.sh
# chmod +x scripts/build_and_sign.sh



# #source scripts/generate_certs.sh
# source scripts/build_and_sign.sh
#
