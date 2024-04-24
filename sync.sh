#!/bin/bash
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests/
cp scripts/local_manifests.xml .repo/local_manifests/


#git clone https://github.com/krishnaspeace/local_manifests.git --depth 1 -b main .repo/local_manifests
rm -rf vendor/fingerprint/opensource/interfaces
git clone https://github.com/xiaomi-msm8953-devs/android_vendor_fingerprint_opensource_interfaces vendor/fingerprint/opensource/interfaces


/opt/crave/resync.sh
source build/envsetup.sh
lunch
# lunch lineage_ysl-ap1a-userdebug
# m bacon
# lunch lineage_h872-ap1a-userdebug
# m bacon
