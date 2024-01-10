#!/bin/bash

sudo apt install aria2 -y
git clone https://gitlab.com/OrangeFox/misc/scripts.git -b master
cd scripts
sudo bash setup/android_build_env.sh
mkdir -p $HOME/OrangeFox
cd $HOME/OrangeFox
git clone https://gitlab.com/OrangeFox/sync.git -b master
cd sync
./orangefox_sync.sh --branch 12.1 --path $HOME/OrangeFox/fox_12.1
cd $HOME/OrangeFox/fox_12.1
git clone https://github.com/xc112lg/twrp_device_lge_h872 -b twrp ./device/lge/h872
cd $HOME/OrangeFox/fox_12.1
set +e
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
set -e
lunch twrp_h872-eng && make clean && mka adbd recoveryimage



