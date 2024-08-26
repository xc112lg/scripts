# ## Cam fix for LG G6 and delete some line cause im stupid.
# cd frameworks/base/
# git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-17
# git cherry-pick a245af744209ccb9cb6ad6981f181fa8a9ba65c5
# cd ../../

# # Mixer: adjust input volume levels
# cd device/lge/g6-common
# git fetch https://github.com/LG-G6/android_device_lge_g6-common.git dev/lineage-19.1
# git cherry-pick b3edeba5ac6500c145fec7222ffc696c9b819af0
# cd ../../../

cd kernel/lge/msm8996
# Fix LTO
sleep 1 && git fetch https://github.com/xc112lg/android_kernel_lge_msm8996.git aosp14
sleep 1 && git cherry-pick e386c76fdf14604b22f86cb6ce642fd1c6c2eff0
sleep 1 && git cherry-pick a9b2d47299267762cf2f64cc0e79606fc3b52301
cd -

# #some fixes will be push to source fter testingg
# cd hardware/lge
# sleep 1 &&git fetch https://github.com/xc112lg/android_hardware_lge.git aosp14
# sleep 1 &&git cherry-pick 72583c8caff8932487b7be015ff8f4eb73a3f5a0 
# cd -

