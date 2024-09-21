#!/bin/bash

rm -rf .repo/local_manifests prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9

mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

rm -rf device/phh/treble


rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

# rm -rf vendor/gms
# rm -rf .repo/projects/vendor/gms.git
# rm -rf .repo/project-objects/*/android_vendor_gms.git
repo init -u https://github.com/yaap/manifest.git -b fifteen --git-lfs
#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
source scripts/clean.sh


#/opt/crave/resync.sh



find .repo -name '*.lock' -delete
    repo sync -c -j32 --force-sync --no-clone-bundle --no-tags --prune 2>&1 | tee /tmp/output.txt

    if ! grep -qe "Failing repos:\|error" /tmp/output.txt ; then
         echo "All repositories synchronized successfully."
         exit 0
    else
        rm -f deleted_repositories.txt
    fi

    # Check if there are any failing repositories
    if grep -q "Failing repos:" /tmp/output.txt ; then
        echo "Deleting failing repositories..."
        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
            rm -rf ".repo/project/$repo_path/$repo_name"*.git
        done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"
    fi

    # Check if there are any failing repositories due to uncommitted changes
    if grep -q "uncommitted changes are present" /tmp/output.txt ; then
        echo "Deleting repositories with uncommitted changes..."

        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $2}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
            rm -rf ".repo/project/$repo_path/$repo_name"*.git
        done <<< "$(cat /tmp/output.txt | grep 'uncommitted changes are present')"
    fi

    # Re-sync all repositories after deletion
    echo "Re-syncing all repositories..."
    find .repo -name '*.lock' -delete
    repo sync -c -j32 --force-sync --no-clone-bundle --no-tags --prune



source build/envsetup.sh
source scripts/fixes.sh


# # # riseup  h872 eng
# # # rise b


breakfast h872 eng 
m installclean
m yaap


#export GH_TOKEN=$(cat gh_token.txt)
rm -rf Evolution-X
sleep 1
git clone https://$GH_TOKEN@github.com/xc112lg/Evolution-X
chmod +x Evolution-X/a.sh
. Evolution-X/a.sh

