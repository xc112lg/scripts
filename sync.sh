#!/bin/bash
#sudo apt-get update
#sudo apt-get install -y ccache

#export USE_CCACHE=1
rm -rf .repo/local_manifests
#rm -rf frameworks/base/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs

#!/bin/bash
# Copyright (c) 2016-2025 Crave.io Inc. All rights reserved

repo --version
cd .repo/repo
git pull -r
cd -
repo --version


main() {
    # Run repo sync command and capture the output
    find .repo -name '*.lock' -delete
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --prune 2>&1 | tee /tmp/output.txt

 if ! grep -qe "Failing repos:\|uncommitted changes are present" /tmp/output.txt ; then
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
            rm -rf ".repo/project/$repo_path/$repo_name"/*.git
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
            rm -rf ".repo/project/$repo_path/$repo_name"/*.git
        done <<< "$(cat /tmp/output.txt | grep 'uncommitted changes are present')"
    fi

    # Re-sync all repositories after deletion
    echo "Re-syncing all repositories..."
    find .repo -name '*.lock' -delete
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --prune
}

main $*



#source scripts/changes.sh
source scripts/signed.sh

source build/envsetup.sh
breakfast vayu
brunch vayu


