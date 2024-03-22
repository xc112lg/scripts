## Cam fix for LG G6 and delete some line cause im stupid.
cd frameworks/base/
git fetch https://github.com/xc112lg/frameworks_base.git AOSP
git cherry-pick e52c414a96d35fb32e585310edb557abac18beb5
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

cd kernel/lge/msm8996
# Fix LTO
sleep 1 && git fetch https://github.com/xc112lg/msm8996_lge_kernel.git patch-1
sleep 1 && git cherry-pick 581d1240a1ac99ebbf172ec95b8d7f4f40ca4d21
cd ../../../

cd vendor/lge/msm8996-common/

sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-1
sleep 1 && git cherry-pick bb7e1512b25af2aa66773fd9138b63b560af254c
cd ../../../