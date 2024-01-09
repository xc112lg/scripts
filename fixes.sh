#!/bin/bash

# Cam fix for LG G6
#cd frameworks/base/
#git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-6
#git cherry-pick 270f82014a595cfcdf7cd131e8836e77497bf4d6
#cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# Mixer: adjust input volume levels
cd vendor/support
git fetch https://github.com/xc112lg/vendor_support.git 13
git cherry-pick d24bdbe5d3908c991a37e6f168de4ad0811df938
cd ../../

# remove timekeep



