#!/bin/bash

# Set default values for device and command
DEVICE="${1:-all}"  # If no value is provided, default to "all"
COMMAND="${2:-build}"  # If no value is provided, default to "build"
DELZIP="${3}"
# Function to wait for 1 second
wait_one_second() {
    sleep 1
}
# Update and install ccache
wait_one_second && sudo apt-get update -y
wait_one_second && sudo apt-get install -y apt-utils
wait_one_second && sudo apt-get install -y ccache
wait_one_second && export USE_CCACHE=1
wait_one_second && ccache -M 100G
wait_one_second && export CCACHE_DIR=/tmp/src/manifest/cc
echo $CCACHE_DIR
## Remove existing build artifacts
if [ "$DELZIP" == "delzip" ]; then
    wait_one_second && rm -rf out/target/product/*/*.zip
fi


repo forall -c 'git reset --hard ; git clean -fdx'
rm -rf .repo/local_manifests
#rm -rf kernel/lge/msm8996
#rm -rf .repo/manifests/snippets/crdroid.xml
#rm -rf .repo/manifests/snippets/lineage.xml
mkdir -p .repo/local_manifests
#cp scripts/crdroid.xml .repo/manifests/snippets
#cp scripts/lineage.xml .repo/manifests/snippets
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
source scripts/fixes.sh

# Check if command is "clean"
if [ "$COMMAND" == "clean" ]; then
    echo "Cleaning..."
    m clean
fi

# Check if device is set to "all"
if [ "$DEVICE" == "all" ]; then
    echo "Building for all devices..."
m installclean
    lunch lineage_us997-userdebug
    m -j16 bacon
    lunch lineage_h870-userdebug
    m -j16 bacon
    lunch lineage_h872-userdebug
    m -j16 bacon
 
elif [ "$DEVICE" == "h872" ]; then
    echo "Building for h872..."
    lunch lineage_h872-userdebug
    m -j16 bacon
else
    echo "Building for the specified device: $DEVICE..."
    # Build for the specified device
    lunch "$DEVICE"
    m -j16 bacon
fi