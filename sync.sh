#!/bin/bash



rm -rf .repo/local_manifests
rm -rf frameworks/base/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth 1
/opt/crave/resync.sh 
/opt/crave/resync.sh 
/opt/crave/resync.sh 
/opt/crave/resync.sh 
source scripts/changes.sh
source scripts/signed.sh

source build/envsetup.sh
breakfast vayu
brunch vayu


