#!/bin/bash

 #Cam fix for LG G6
cd frameworks/base/
git fetch https://github.com/xc112lg/frameworks_base.git patch-1
git cherry-pick 1b4c75f7870bec9fa9e981c9acd89e76228b972e
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# Mixer: adjust input volume levels
#cd vendor/support
#git fetch https://github.com/xc112lg/vendor_support.git 13
#git cherry-pick d24bdbe5d3908c991a37e6f168de4ad0811df938
cd ../../
cd vendor/derp
git fetch https://github.com/xc112lg/vendor_derp.git 13
git cherry-pick 19b69b9dcaed8c5359150863182c8976e2ca4011
cd ../../

# remove timekeep



