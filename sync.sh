#!/bin/bash
#sudo apt-get update
#sudo apt-get install -y ccache

#export USE_CCACHE=1
rm -rf .repo/local_manifests
#rm -rf frameworks/base/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

repo init --depth 1 -u https://github.com/LineageOS/android.git -b lineage-22.1 --git-lfs

/opt/crave/resync.sh



#source scripts/changes.sh
source scripts/signed.sh

source build/envsetup.sh
breakfast vayu
brunch vayu


