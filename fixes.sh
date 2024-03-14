## Cam fix for LG G6 and delete some line cause im stupid.

#some fixes will be push to source fter testingg
cd device/lge/msm8996-common
sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
sleep 1 &&git cherry-pick aef6632c220ec671b69ed3564d37f74cca295ce2 
sleep 1 &&git cherry-pick 7ac9890a15cbf0be818fa00c8374620fb5c737c1
sleep 1 &&git cherry-pick c6c8c172e3f92b628465b5888c13b6a29fbc4383
cd ../../../




#added crdroid setting 
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/core/res/res/values/cr_config.xml
wget -N -P device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/ https://github.com/crdroidandroid/android_frameworks_base/raw/14.0/packages/SystemUI/res/values/cr_config.xml

