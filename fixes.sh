## Cam fix for LG G6 and delete some line cause im stupid.
# cd frameworks/base/
# git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-17
# git cherry-pick a245af744209ccb9cb6ad6981f181fa8a9ba65c5
# cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# cd kernel/lge/msm8996
# # Fix LTO
# sleep 1 && git fetch https://github.com/xc112lg/msm8996_lge_kernel.git patch-1
# sleep 1 && git cherry-pick 581d1240a1ac99ebbf172ec95b8d7f4f40ca4d21
# cd ../../../

#some fixes will be push to source fter testingg
cd device/lge/msm8996-common
sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
sleep 1 &&git cherry-pick aef6632c220ec671b69ed3564d37f74cca295ce2 
sleep 1 &&git cherry-pick 7ac9890a15cbf0be818fa00c8374620fb5c737c1
sleep 1 &&git cherry-pick c6c8c172e3f92b628465b5888c13b6a29fbc4383
cd ../../../



# cd device/lge/msm8996-common
# sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
# sleep 1 &&git cherry-pick 7ef8ee92f398052a9d6351e4d7157e8474401f5b
# sleep 1 &&git cherry-pick 3732dcb95ded45faca1f37792fd3ed47a5cae39b

# cd ../../../

# cd packages/apps/Updater
# sleep 1 &&git fetch https://github.com/xc112lg/android_packages_apps_Updater.git patch-1
# sleep 1 &&git cherry-pick af70aa09ee94e7db085cd5777229b82f3abca313
# cd ../../../

# cd vendor/lineage/
# sleep 1 &&git fetch https://github.com/xc112lg/android_vendor_crdroid.git patch-1
# sleep 1 &&git cherry-pick be2f71d81e21608f82376fd5266ce95d3266a411
# cd ../../


cd vendor/lge/msm8996-common/

#sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-2
#sleep 1 && git cherry-pick b7ae264df1d799c5d635bada6afbc3714df75cdb 
#sleep 1 && git cherry-pick 1efc7fd60e02b78c0ce03b184b1c0f485100cd18
cd ../../../


#added crdroid setting 
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/core/res/res/values/cr_config.xml
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/packages/SystemUI/res/values/cr_config.xml

