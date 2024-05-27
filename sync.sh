#!/bin/bash


#source scripts/extras.sh


repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
#repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
/opt/crave/resync.sh
#source scripts/clean.sh
