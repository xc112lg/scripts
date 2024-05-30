cd device/lge/msm8996-common
git fetch https://github.com/LineageOS/android_device_lge_msm8996-common refs/changes/28/388128/3 && git reset --hard FETCH_HEAD
git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-3
git cherry-pick ea02d8efb0593566ca649281bf793caf5da3fb88
cd ../../../
