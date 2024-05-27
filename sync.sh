#!/bin/bash


git lfs
cd external/chromium-webview/prebuilt/arm64
git lfs install
git rev-parse --git-dir
git config --global --add safe.directory external/chromium-webview/prebuilt/arm64/
git lfs pull
cd ../../../..

#repo init --depth 1 -u https://github.com/PixelOS-AOSP/manifest.git -b fourteen --git-lfs
#repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
#/opt/crave/resync.sh
#source scripts/clean.sh
