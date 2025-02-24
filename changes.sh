## Cam fix for LG G6 and delete some line cause im stupid.
cd frameworks/base/

git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-24
git cherry-pick 06942a5f31c83cae39a877c0c1fab7c9e4daf040
cd ../../


cd system/core/

git fetch https://github.com/xc112lg/android_system_core.git patch-2
git cherry-pick 0af0d0611b2a58ba0e8950d396f7ef222377f29d
cd -
