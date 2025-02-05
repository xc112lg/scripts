#!/bin/bash


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




if [ "$RELEASETYPE" == "none" ]; then
    RELEASETYPE1=""
else 
    RELEASETYPE1="$RELEASETYPE"
fi



source scripts/fixes.sh
source scripts/signed.sh
export USE_CCACHE=1
source build/envsetup.sh


# Check if command is "clean"
if [ "$COMMAND" == "clean" ]; then
    echo "Cleaning..."
    m clean
fi

# Check if device is set to "all"
if [ "$DEVICE" == "all" ]; then
    echo "Building for all devices..."

    lunch ${MAKEFILE}_us997${RELEASETYPE1}-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
    lunch ${MAKEFILE}_h870${RELEASETYPE1}-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
    lunch ${MAKEFILE}_h872${RELEASETYPE1}-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
 
elif [ "$DEVICE" == "h872" ]; then
    echo "Building for h872..."
export BUILD_DEVICE="h872"
	echo "${MAKEFILE}_h872${RELEASETYPE1}-userdebug"

    lunch ${MAKEFILE}_h872${RELEASETYPE1}-eng
# Check if command is "clean"
if [ "$COMMAND" == "clean" ]; then
    echo "Cleaning..."
    m clean
fi
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
else
    echo "Building for the specified device: $DEVICE..."
    # Build for the specified device
    lunch "$DEVICE"
    ${COM1} -j16 ${COM2}
fi





