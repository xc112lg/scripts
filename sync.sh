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
lineage_h872-userdebug
m bacon

count=1
for file in out/target/product/*/*.zip; do
    mv "$file" "out/target/product/*/new_filename$count.zip"
    ((count++))
done
source scripts/fixes2.sh
lineage_h872-userdebug
m bacon

