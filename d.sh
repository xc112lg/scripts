#!/bin/bash
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
 repo sync -c -j32 --force-sync --no-clone-bundle --no-tags 
