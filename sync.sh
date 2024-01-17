#!/bin/bash

rm -rf hardware/xiaomi

rm out/target/product/*/*.zip
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
source  build/envsetup.sh

lunch afterlife_miatoll-userdebug
mka afterlife
