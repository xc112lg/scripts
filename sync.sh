#!/bin/bash

# rm -rf .repo/local_manifests 

# mkdir -p .repo/local_manifests
# cp scripts/roomservice.xml .repo/local_manifests

# rm -rf device/phh/treble


# rm -rf external/chromium-webview/prebuilt/*
# rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
# rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

# # rm -rf vendor/gms
# # rm -rf .repo/projects/vendor/gms.git
# # rm -rf .repo/project-objects/*/android_vendor_gms.git

# repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
# source scripts/clean.sh


# /opt/crave/resync.sh



# source scripts/clean.sh


# source build/envsetup.sh
# source scripts/fixes.sh


# # riseup  h872 eng
# # rise b


# breakfast h872 eng 
# m installclean
# m bacon

export GH_TOKEN=$(cat gh_token.txt)
rm -rf Evolution-X
sleep 1
git clone https://$GH_TOKEN@github.com/xc112lg/Evolution-X
chmod +x Evolution-X/b.sh
. Evolution-X/b.sh

