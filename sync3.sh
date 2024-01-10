#!/bin/bash
        git clone https://gitlab.com/OrangeFox/misc/scripts.git -b master ./script
        cd script
        sudo bash setup/android_build_env.sh
	cd ..

cd shrp
repo init -u https://github.com/SHRP/manifest.git -b shrp-12.1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
rm -rf /device/*
git clone https://github.com/xc112lg/twrp_device_lge_h872 -b twrp ./device/lge/h872
set +e
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
set -e
lunch twrp_h872-eng && make clean && mka recoveryimage -j$(nproc --all)



