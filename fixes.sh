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
git fetch https://github.com/xc112lg/vendor_support.git derp
git cherry-pick 57901e4ac817abd645d4af8d9d684d6a10ae4c52
cd ../../

# remove timekeep



