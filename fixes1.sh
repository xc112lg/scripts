#!/bin/bash






cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-3
git cherry-pick 61723d6220ad417008c50565bc9212e9cec96450
cd ../../


