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

added crdroid setting 
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
git cherry-pick 52aa9d6c105f0bdd1f550172f839e205e3ee7f8a 14d8171a9d899bf74c3ab847f0f57085274e60b7
cd ../../../

wget -N -P device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/core/res/res/values/cr_config.xml
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/ https://github.com/crdroidandroid/android_frameworks_base/blob/14.0/packages/SystemUI/res/values/cr_config.xml

