# Cam fix for LG G6 and delete some line cause im stupid
cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-17
git cherry-pick a245af744209ccb9cb6ad6981f181fa8a9ba65c5
cd ../../

# Mixer: adjust input volume levels
cd device/lge/g6-common
git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
cd ../../../

# added crdroid setting 
cd device/lge/msm8996-common
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git cd10
git cherry-pick 775580322aec4c7556e389878323f85a02135263 023c8bd064969797364a903caf47c599beb1c4f5
cd ../../../

