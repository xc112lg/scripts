#!/bin/bash




# mkdir -p cc
# mkdir -p c
# # Set default values for device and commandd
# wget https://github.com/ccache/ccache/releases/download/v4.9.1/ccache-4.9.1-linux-x86_64.tar.xz
# tar -xf ccache-4.9.1-linux-x86_64.tar.xz
# cd ccache-4.9.1-linux-x86_64
# #sudo make install
# #ccache --version
# sudo cp ccache /usr/bin/
# sudo ln -sf ccache /usr/bin/gcc
# sudo ln -sf ccache /usr/bin/g++
# cd ..
# ccache --version

# export USE_CCACHE=1
# sleep 1
# export CCACHE_DIR=$PWD/cc
# sleep 1 
# ccache -s
# ccache -F 0
# ccache -M 0
# echo $CCACHE_DIR
# ccache -s


# if [ -z "$(ls -A c)" ]; then
#   echo "Folder c is empty. Skipping the rsync command.."
# else
#   # If folder c is not empty, execute the rsync command
# time ls -1 c | xargs -I {} -P 10 -n 1 rsync -au c/{} cc/
# cp -f c/ccache.conf cc
# fi




repo init -u https://github.com/crdroidandroid/android.git -b 14.0 --git-lfs




#git clean -fdX
#rm -rf frameworks/base/
rm -rf .repo/local_manifests device/lge vendor/extra mkdir vendor/lineage-priv
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

source scripts/clean.sh
repo init --git-lfs
rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

main() {
    # Run repo sync command and capture the output
    repo sync -c -j64 --force-sync --no-clone-bundle --no-tags 2>&1 | tee /tmp/output.txt

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
        repo sync -c -j64 --force-sync --no-clone-bundle --no-tags
    else
        echo "All repositories synchronized successfully."
    fi
}

main $*

