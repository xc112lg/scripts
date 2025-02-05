#!/bin/bash
rm -rf kernel/lge/msm8996 frameworks/base

DEVICE="${1:-all}"  
COMMAND="${2:-build}" 
DELZIP="${3}"
MAKEFILE="${4}" 
RELEASETYPE="${5}" 
VENDOR="${6}" 
COM1="${7}"
COM2="${8}"
CORE="${9:-"$(nproc --all)"}"


## Remove existing build artifactsa
if [ "$DELZIP" == "delzip" ]; then
    rm -rf out/target/product/*/*.zip
fi

#git clean -fdX
#rm -rf frameworks/base/
rm -rf .repo/local_manifests
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

/opt/crave/resync.sh





# source scripts/fixes.sh
# source scripts/signed.sh
export USE_CCACHE=1
source build/envsetup.sh
brunch h872




