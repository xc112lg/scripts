#!/bin/bash






cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-10
git cherry-pick 53f9d4676c9d38c53d88942c201ec9283a439533
cd ../../


