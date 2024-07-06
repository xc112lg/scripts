


#!/bin/bash


repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs

git clone https://github.com/AndyCGYan/lineage_build_unified lineage_build_unified -b lineage-21-light
git clone https://github.com/AndyCGYan/lineage_patches_unified lineage_patches_unified -b lineage-21-light

bash lineage_build_unified/buildbot_unified.sh treble 64VN
