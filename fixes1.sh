#!/bin/bash






cd frameworks/base/
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-2
git cherry-pick 5d75f888abf9325092b7f7a34f055db167957614
cd ../../


