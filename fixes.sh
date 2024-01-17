# Cam fix for LG G6 and delete some line cause im stupid
cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git cd10
git cherry-pick 5e769f677008161357a8855ed2d606f8a6198de7
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# added crdroid setting
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
git cherry-pick 2b2f692beb7e7b23abc5ec45ab1afd3391bafe67
cd ../../../

# trying to fix time
cd device/lge/msm8996-common
#git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-3
#git cherry-pick 382a3e30279dc13f6a75d8c20009f826b8727f4f 078eea6548009859abe60680aa595c67c8e4fcbc
# set selinux to permissive
#git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-6
#git cherry-pick 23f21ced92db1e80dbaf24a78223b918469aa23b b7e99d2fc48112ab23449d282480d834750aed27

git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-3
git cherry-pick ea7b7426154f1af5073ab1fb16ee7d3521408d7a

cd ../../../

##repopick -f 375818

