## Cam fix for LG G6 and delete some line cause im stupid.
cd frameworks/base/

git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-22
git cherry-pick 3a0afde4ba85ed085bb777babe888a0a2c80c69d
cd ../../
