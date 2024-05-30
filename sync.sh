#!/bin/bash

#git clean -fdX
#rm -rf frameworks/base/
rm -rf .repo/local_manifests
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests


/opt/crave/resync.sh

source build/envsetup.sh

lunch lineage_h872-userdebug
m installclean
m bacon
  #  mka target-files-package otatools
echo "2nd run"
repo forall -c "git lfs install && git lfs pull && git lfs checkout"
/opt/crave/resync.sh
source scripts/clean.sh
source scripts/extras.sh

lunch lineage_h872-userdebug
m installclean
m bacon
echo "3rd run"
    
repo forall -c "git lfs install && git lfs pull && git lfs checkout"
/opt/crave/resync.sh
source scripts/clean.sh
source scripts/extras.sh

lunch lineage_h872-userdebug
m installclean
m bacon






