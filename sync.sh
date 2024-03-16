#!/bin/bash
# Set default values for device and command
DEVICE="${1:-all}"  
COMMAND="${2:-build}" 
DELZIP="${3}"
MAKEFILE="${4}" 
VENDOR="${5}" 
COM1="${6}"
COM2="${7}"
CORE="${8:-"$(nproc --all)"}"
echo $PWD
echo $PWD
mkdir -p cc
mkdir -p c
# Update and install ccache
sudo apt-get update -y
sudo apt-get install -y apt-utils
sudo apt-get install -y ccache
export USE_CCACHE=1
ccache -M 100G
export CCACHE_DIR=${PWD}/cc
ccache -s
ccache -o compression=false
ccache --show-config | grep compression
echo $CCACHE_DIR
echo $CCACHE_EXEC
time ls -1 c | xargs -I {} -P 5 -n 1 rsync -au c/{} cc/
ccache -o compression=false
ccache --show-config | grep compression

ccache -s
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
source scripts/clean.sh
repo sync -c -j${CORE} --force-sync --no-clone-bundle --no-tags

if [ -n "$MAKEFILE" ]; then
    # Perform the replacement using sed
    cd device/lge/h872
    sed -i "s/lineage_h872/${MAKEFILE}_h872/g" AndroidProducts.mk
    sed -i "s/lineage_h872/${MAKEFILE}_h872/g" lineage_h872.mk
    sed -i "s#vendor/lineage#vendor/${VENDOR}#g" lineage_h872.mk
    mv lineage_h872.mk "${MAKEFILE}_h872.mk"
    cd ../../../

    cd device/lge/h870
    sed -i "s/lineage_h870/${MAKEFILE}_h870/g" AndroidProducts.mk
    sed -i "s/lineage_h870/${MAKEFILE}_h870/g" lineage_h870.mk
    sed -i "s#vendor/lineage#vendor/${VENDOR}#g" lineage_h870.mk
    mv lineage_h870.mk "${MAKEFILE}_h870.mk"
    cd ../../../

    cd device/lge/us997
    sed -i "s/lineage_us997/${MAKEFILE}_us997/g" AndroidProducts.mk
    sed -i "s/lineage_us997/${MAKEFILE}_us997/g" lineage_us997.mk
    sed -i "s#vendor/lineage#vendor/${VENDOR}#g" lineage_us997.mk
    mv lineage_us997.mk "${MAKEFILE}_us997.mk"
    cd ../../../
fi



source scripts/fixes.sh
source build/envsetup.sh


# Check if command is "clean"
if [ "$COMMAND" == "clean" ]; then
    echo "Cleaning..."
    m clean
fi

# Check if device is set to "all"
if [ "$DEVICE" == "all" ]; then
    echo "Building for all devices..."

    lunch ${MAKEFILE}_us997-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
    lunch ${MAKEFILE}_h870-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
    lunch ${MAKEFILE}_h872-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
 
elif [ "$DEVICE" == "h872" ]; then
    echo "Building for h872..."
export BUILD_DEVICE="h872"
    lunch ${MAKEFILE}_h872-userdebug
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
else
    echo "Building for the specified device: $DEVICE..."
    # Build for the specified device
    lunch "$DEVICE"
    ${COM1} -j16 ${COM2}
fi
time ls -1 cc | xargs -I {} -P 5 -n 1 rsync -au cc/{} c/
ccache -s