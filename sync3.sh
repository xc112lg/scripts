#!/bin/bash
        #rm -rf script
	#git clone https://gitlab.com/dtiven13/scripts.git -b master script
        #cd script
        #sudo bash setup/android_build_env.sh
	#cd ../
	cd shrp
	rm -rf device/*
	rm -rf out/.module_paths
	repo init -u https://github.com/SHRP/manifest.git -b shrp-12.1
  
	repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
	rm -rf device/*
      cd system/core/
        git fetch https://github.com/xc112lg/android_system_core.git patch-1
        git cherry-pick 76072abd225ba5d05006d8c45a50f42da202813e
        cd ../../
	git clone https://github.com/xc112lg/twrp_device_lge_h872 -b tr2 ./device/lge/h872
	source build/envsetup.sh
	export ALLOW_MISSING_DEPENDENCIES=true
	lunch twrp_h872-eng && make clean && mka recoveryimage -j$(nproc --all)



