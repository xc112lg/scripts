#!/bin/bash



# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# remove timekeep
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
git cherry-pick e7fba872e802e245fb22f417f8db4868b60e6836
cd ../../../


cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-2
git cherry-pick 5d75f888abf9325092b7f7a34f055db167957614
cd ../../


