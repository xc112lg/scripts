#!/bin/bash
rm -rf frameworks/base/
rm -rf .repo/local_manifests
# Clone local_manifests repository
git clone https://github.com/krishnaspeace/local_manifests --depth 1 -b main .repo/local_manifests
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags
# removing non working fingerprint
rm -rf vendor/fingerprint/opensource/interfaces
# adding working fingerprint
git clone https://github.com/aneeshsvha/vendor_fingerprint_opensource_interfaces vendor/fingerprint/opensource/interfaces
# Set up build environment
source build/envsetup.sh
# Lunch configuration
lunch lineage_ysl-userdebug
# Build confriguration
m 15 bacon


