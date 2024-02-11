#!/bin/bash

# Set the device and command
DEVICE="all"  # Change to "h872" or another device if needed
COMMAND="clean"  # Change to "build" or another command if needed

# Function to wait for 1 second
wait_one_second() {
    sleep 1
}

# Remove existing build artifacts
wait_one_second && rm -rf out/target/product/*/*.zip device/lge/msm8996-common

# Update and install ccache
wait_one_second && sudo apt-get update -y
wait_one_second && sudo apt-get install -y ccache
wait_one_second && export USE_CCACHE=1
wait_one_second && ccache -M 100G
wait_one_second && export CCACHE_DIR=/tmp/src/android/cc
echo $CCACHE_DIR

rm -rf frameworks/base/
rm -rf device/lge
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
source scripts/fixes.sh

# Check if command is "clean"
if [ "$COMMAND" == "clean" ]; then
    m clean
fi

# Check if device is set to "all"
if [ "$DEVICE" == "all" ]; then
    lunch lineage_us997-userdebug
    m -j15 bacon
    lunch lineage_h870-userdebug
    m -j15 bacon
    lunch lineage_h872-userdebug
    m -j15 bacon
elif [ "$DEVICE" == "h872" ]; then
    lunch lineage_h872-userdebug

    # Build if the command is not "clean"
    if [ "$COMMAND" != "clean" ]; then
        m -j15 bacon
    fi
else
    # Build for the specified device
    lunch "$DEVICE"

    # Build if the command is not "clean"
    if [ "$COMMAND" != "clean" ]; then
        m -j15 bacon
    fi
fi

# Additional build commands if needed
