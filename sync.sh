#!/bin/bash

rm -rf build/make/
rm -rf frameworks/base/
rm -rf device/lge/
rm -rf hardware/lge
rm -rf kernel/lge/msm8996/
rm -rf vendor/lge/
rm -rf vendor/lineage/

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh

source scripts/fixes.sh
lunch lineage_h870-userdebug
m bacon
lunch lineage_us997-userdebug
m bacon
lunch lineage_h872-userdebug
m bacon


