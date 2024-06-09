#!/bin/bash

rm -rf build/make/
rm -rf frameworks/base/
rm -rf device/lge/
rm -rf hardware/lge
rm -rf kernel/lge/msm8996/
rm -rf vendor/lge/
rm -rf vendor/lineage/
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs

rm -rf .repo/local_manifests

mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

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



source build/envsetup.sh

source scripts/fixes.sh
source scripts/extras.sh


sed -i '/include $(LOCAL_PATH)\/vendor_prop.mk/a -include vendor/extra/product.mk' device/lge/msm8996-common/msm8996.mk
cd build/tools
git fetch https://github.com/xc112lg/android_build.git patch-1
git cherry-pick b7b12b875a97eee6e512c74c53a82066e237a31a
cd ../../

subject='/C=PH/ST=Philippines/L=Manila/O=xc112lg/OU=xc112lg/CN=xc112lg/emailAddress=dtiven13@gmail.com'
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do \
 yes "" |   ./development/tools/make_key ~/.android-certs/$x "$subject"; \
done

mkdir vendor/extra
mkdir vendor/lineage-priv
cp -r ~/.android-certs vendor/extra/keys

cp -r ~/.android-certs vendor/lineage-priv/keys
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/extra/keys/releasekey" > vendor/extra/product.mk



    lunch lineage_us997-userdebug
    m installclean
    m -j$(nproc --all) bacon
    lunch lineage_h870-userdebug
    m installclean
    m -j$(nproc --all) bacon
    lunch lineage_h872-userdebug
    m installclean
    m -j$(nproc --all) bacon


