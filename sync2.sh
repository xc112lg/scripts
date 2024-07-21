#!/bin/bash


USERNAME="${1}"
MANIFEST="${2}"  
BRANCH="${3}" 
DEVICE="${4}"

rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

repo init -u https://github.com/accupara/los21-exp.git -b lineage-21.0 --git-lfs

echo "building $DEVICE for $USERNAME"

git clone --depth=1 $MANIFEST -b $BRANCH .repo/local_manifests

/opt/crave/resync.sh





