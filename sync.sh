#!/bin/bash
# Set default values for device and command
DEVICE="${1:-all}"  # If no value is provided, default to "all"
COMMAND="${2:-build}"  # If no value is provided, default to "build"
DELZIP="${3}"
echo $PWD
echo $PWD
mkdir -p cc
# Update and install ccache
sudo apt-get update -y
sudo apt-get install -y apt-utils
sudo apt-get install -y ccache
export USE_CCACHE=1
ccache -M 100G
export CCACHE_DIR=/tmp/src/android/cc
ccache -o compression=false
ccache --show-config | grep compression
echo $CCACHE_DIR
## Remove existing build artifactsa
if [ "$DELZIP" == "delzip" ]; then
    rm -rf out/target/product/*/*.zip
fi

#git clean -fdX
rm -rf frameworks/base/
rm -rf .repo/local_manifests
rm -rf device/lge/
rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
#wget -O a.py https://raw.githubusercontent.com/xc112lg/crdroid10.1/main/a.py
#chmod +x a.py
chmod +x scripts/export.sh
#python3 a.py
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

    lunch lineage_us997-userdebug
    m installclean
    m -j$(nproc --all) bacon
    lunch lineage_h870-userdebug
    m installclean
    m -j$(nproc --all) bacon
    lunch lineage_h872-userdebug
    m installclean
    m -j$(nproc --all) bacon
 
elif [ "$DEVICE" == "h872" ]; then
    echo "Building for h872..."
export BUILD_DEVICE="h872"
    lunch lineage_h872-userdebug
    m installclean
    m -j$(nproc --all) bacon
else
    echo "Building for the specified device: $DEVICE..."
    # Build for the specified device
    lunch "$DEVICE"
    m -j16 bacon
fi