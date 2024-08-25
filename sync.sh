#!/bin/bash

rm -rf .repo/local_manifests 

mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests



rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

rm -rf vendor/gms
rm -rf .repo/projects/vendor/gms.git
rm -rf .repo/project-objects/*/android_vendor_gms.git

repo init -u https://github.com/RisingTechOSS/android -b fourteen --git-lfs


/opt/crave/resync.sh




source build/envsetup.sh



riseup  h872 eng
rise b

