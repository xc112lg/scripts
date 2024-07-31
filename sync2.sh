#!/bin/bash


USERNAME="${1}"
MANIFEST="${2}"  
BRANCH="${3}" 
DEVICE="${4}"
BUILD_TYPE="${5}"
#rm -rf hardware vendor  kernel
# rm -rf external/chromium-webview/prebuilt/*
# rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
# rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

repo init -u https://github.com/accupara/los21-exp.git -b lineage-21.0 --git-lfs
#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs


source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests


echo "building $DEVICE for $USERNAME"

git clone --depth=1 $MANIFEST -b $BRANCH .repo/local_manifests

cd build/make
ls
git reset --hard


cd -


/opt/crave/resync.sh

#sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"|' build/make/envsetup.sh

. build/envsetup.sh
brunch $DEVICE $BUILD_TYPE






