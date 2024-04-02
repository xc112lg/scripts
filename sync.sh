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
mkdir -p cc
mkdir -p c
# Set default values for device and commandd
wget https://github.com/ccache/ccache/releases/download/v4.9.1/ccache-4.9.1-linux-x86_64.tar.xz
tar -xf ccache-4.9.1-linux-x86_64.tar.xz
cd ccache-4.9.1-linux-x86_64
sudo make install
ccache --version
sudo cp ccache /usr/bin/
sudo ln -sf ccache /usr/bin/gcc
sudo ln -sf ccache /usr/bin/g++
cd ..
ccache --version

export USE_CCACHE=1
sleep 1
export CCACHE_DIR=$PWD/cc
sleep 1 
ccache -s
ccache -F 0
ccache -M 0
echo $CCACHE_DIR
ccache -s


if [ -z "$(ls -A c)" ]; then
  echo "Folder c is empty. Skipping the rsync command.."
else
  # If folder c is not empty, execute the rsync command
time ls -1 c | xargs -I {} -P 10 -n 1 rsync -au c/{} cc/
cp -f c/ccache.conf cc
fi

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

#!/bin/bash

main() {
    # Run repo sync command and capture the output
    repo sync -c -j${CORE} --force-sync --no-clone-bundle --no-tags 2>&1 | tee /tmp/output.txt

    # Check if there are any failing repositories
    if grep -q "Failing repos:" /tmp/output.txt ; then
        echo "Deleting failing repositories..."
        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Echo the deletion path
            echo "Deleted repository: $repo_info"
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" > deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
        done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"

        # Re-sync all repositories after deletion
        echo "Re-syncing all repositories..."
        repo sync -c -j${CORE} --force-sync --no-clone-bundle --no-tags
    else
        echo "All repositories synchronized successfully."
    fi
}

main $*




if [ "$RELEASETYPE" == "none" ]; then
    RELEASETYPE1=""
else 
    RELEASETYPE1="$RELEASETYPE"
fi



source scripts/fixes.sh
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
    m clean
    lunch ${MAKEFILE}_h872${RELEASETYPE1}-eng
    m installclean
    ${COM1} -j$(nproc --all) ${COM2}
else
    echo "Building for the specified device: $DEVICE..."
    # Build for the specified device
    lunch "$DEVICE"
    ${COM1} -j16 ${COM2}
fi



time ls -1 cc | xargs -I {} -P 10 -n 1 rsync -au cc/{} c/
cp -f cc/ccache.conf c
ccache -s


