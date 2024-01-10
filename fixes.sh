#!/bin/bash

# Cam fix for LG G6
cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git cr9
git cherry-pick 47d7418b2c1d11ce03f5ea99582ae77908be9ac7
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# remove timekeep
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
git cherry-pick 060a0a00e2954ac27b04e217390a78133c4484dc
cd ../../../

# change vendor
cd device/lge/h870
git fetch https://github.com/xc112lg/android_device_lge_h870.git cr9
git cherry-pick fce1972cd6a4f40b216dbb65295e2d2975e29fdd
cd ../../../

# change vendor
cd device/lge/h872
git fetch https://github.com/xc112lg/android_device_lge_h872.git cr9
git cherry-pick 43752795285591c333b54994b7b2fa60585c7454
cd ../../../

# change vendor
cd device/lge/us997
git fetch https://github.com/xc112lg/android_device_lge_us997.git cr9
git cherry-pick abcf317c7c8a505c9ed14dbd59ff2dee9e5edd4a
cd ../../../



