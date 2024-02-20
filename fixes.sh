## Cam fix for LG G6 and delete some line cause im stupid.
cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-17
git cherry-pick a245af744209ccb9cb6ad6981f181fa8a9ba65c5
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

#some fixes will be push to source fter testing
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
git cherry-pick aef6632c220ec671b69ed3564d37f74cca295ce2 7ac9890a15cbf0be818fa00c8374620fb5c737c1
cd ../../../
#added crdroid setting 
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/core/res/res/values/cr_config.xml
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/packages/SystemUI/res/values/cr_config.xml

