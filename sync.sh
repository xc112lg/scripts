#!/bin/bash

rm -rf build/make/
rm -rf frameworks/base/
rm -rf vendor/lineage/

rm out/target/product/*/*.zip
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh

lunch afterlifee_miatoll-userdebug
m afterlife
