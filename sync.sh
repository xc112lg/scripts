#!/bin/bash
#rm -rf .repo/local_manifests
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
#mkdir -p .repo/local_manifests
#cp scripts/roomservice.xml .repo/local_manifests

mkdir -p c
cd c
#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
/opt/crave/resync.sh



#source scripts/clean.sh




# source build/envsetup.sh
# lunch lineage_h872-userdebug
# m installclean
# m -j$(nproc --all) bacon
# chmod +x scripts/generate_certs.sh
# chmod +x scripts/build_and_sign.sh



# #source scripts/generate_certs.sh
# source scripts/build_and_sign.sh
#
