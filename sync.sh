#!/bin/bash
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests/
#cp scripts/local_manifests.xml .repo/local_manifests/
cp scripts/eureka_deps.xml .repo/local_manifests/
cp scripts/x.xml .repo/local_manifests/
cp scripts/X01BD.xml .repo/local_manifests/



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
        repo sync -c -j${CORE} --force-sync --no-clone-bundle --no-tags
    else
        echo "All repositories synchronized successfully."
    fi
}

main $*



source build/envsetup.sh
#lunch lineage_ysl-ap1a-userdebug
#m bacon
breakfast gsi_arm64 userdebug
mka
cd device/lge/msm8996-common
sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
sleep 1 &&git cherry-pick 7ef8ee92f398052a9d6351e4d7157e8474401f5b

cd ../../../

cd vendor/lge/msm8996-common/

sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-2
sleep 1 && git cherry-pick b7ae264df1d799c5d635bada6afbc3714df75cdb 
sleep 1 && git cherry-pick 1efc7fd60e02b78c0ce03b184b1c0f485100cd18
cd ../../../
lunch lineage_h872-ap1a-userdebug
m bacon
lunch lineage_a10-ap1a-userdebug
m bacon
lunch lineage_X00TD-ap1a-userdebug
m bacon
lunch lineage_X01BD-ap1a-userdebug
m bacon
