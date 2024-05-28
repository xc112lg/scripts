#!/bin/bash
sudo apt update
sudo apt install -y git python-is-python3 bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
#source scripts/extras.sh


repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
#repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
/opt/crave/resync.sh
#source scripts/clean.sh
