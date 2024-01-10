#!/bin/bash



mkdir -p $HOME/OrangeFox
cd $HOME/OrangeFox
repo init -u https://github.com/SHRP/manifest.git -b shrp-12.1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
cd $HOME/OrangeFox
rm -rf /device/lge/h872
git clone https://github.com/xc112lg/twrp_device_lge_h872 -b android-7.1 ./device/lge/h872
cd $HOME/OrangeFox
set +e
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
set -e
lunch twrp_h872-eng && make clean && mka recoveryimage -jX



