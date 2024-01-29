#!/bin/bash

rm -rf kernel/Xiaomi/sm6250

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh


lunch banana_miatoll-userdebug
m banana
