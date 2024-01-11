#!/bin/bash
        #rm -rf script
	#git clone https://gitlab.com/dtiven13/scripts.git -b master script
        #cd script
        #sudo bash setup/android_build_env.sh
	#cd ../
	cd shrp
	rm -rf device/*
	rm -rf out/.module_paths
	rm -rf bootable/*
	repo init -u https://github.com/xc112lg/platform_manifest_twrp_aosp.git.git -b patch-1
	repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
	rm -rf device/*

	git clone https://github.com/xc112lg/twrp_device_lge_h872 -b twrp ./device/lge/h872
	source build/envsetup.sh
	export ALLOW_MISSING_DEPENDENCIES=true
	lunch twrp_h872-eng && make clean && mka recoveryimage -j$(nproc --all)



