#!/bin/bash

# Set default values for device and command
DEVICE="${1:-all}"  # If no value is provided, default to "all"
COMMAND="${2:-build}"  # If no value is provided, default to "build"
DELZIP="${3}"
# Function to wait for 1 second
wait_one_second() {
    sleep 1
}

## Remove existing build artifacts
if [ "$DELZIP" == "delzip" ]; then
    wait_one_second && rm -rf out/target/product/*/*.zip
fi

echo $CCACHE_DIR
rm -rf frameworks/base/
rm -rf device/lge
rm -rf .repo/local_manifests
rm -rf kernel/lge/msm8996
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