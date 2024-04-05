#!/bin/bash
sudo find . -delete
sudo apt-get update
sudo apt-get install python python3-pip wget git 
pip3 install payload_dumper
sudo apt-get install python3-protobuf

mkdir ~/android
mkdir ~/android/system_dump/
cd ~/android/system_dump/
wget -O archive.zip https://bn.d.miui.com/V14.0.5.0.TMAMIXM/miui_ISHTARGlobal_V14.0.5.0.TMAMIXM_6f43e09971_13.0.zip
unzip -j archive.zip  -d .
cd ..
cd ..
git clone https://github.com/LineageOS/android_prebuilts_extract-tools android/prebuilts/extract-tools
git clone https://github.com/LineageOS/android_tools_extract-utils android/tools/extract-utils
git clone https://github.com/LineageOS/android_system_update_engine android/system/update_engine
./android/prebuilts/extract-tools/linux-x86/bin/ota_extractor --payload android/system_dump/payload.bin
mkdir system/
sudo mount -o ro system.img system/
sudo mount -o ro vendor.img system/vendor/
sudo mount -o ro odm.img system/odm/
sudo mount -o ro product.img system/product/
sudo mount -o ro system_ext.img system/system_ext/

