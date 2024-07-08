


#!/bin/bash

rm -rf lineage_build_unified lineage_patches_unified frameworks/base
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs

git clone https://github.com/xc112lg/lineage_build_unified lineage_build_unified -b lineage-21-td
git clone https://github.com/xc112lg/lineage_patches_unified lineage_patches_unified -b patch-3

bash lineage_build_unified/buildbot_unified.sh treble A64GN
