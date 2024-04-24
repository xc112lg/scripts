#!/bin/bash
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests/
#cp scripts/local_manifests.xml .repo/local_manifests/
cp scripts/eureka_deps.xml .repo/local_manifests/
cp scripts/x.xml .repo/local_manifests/
/opt/crave/resync.sh
#git clone https://github.com/krishnaspeace/local_manifests.git --depth 1 -b main .repo/local_manifests
#rm -rf vendor/fingerprint/opensource/interfaces
#git clone https://github.com/xiaomi-msm8953-devs/android_vendor_fingerprint_opensource_interfaces vendor/fingerprint/opensource/interfaces



source build/envsetup.sh
#lunch lineage_ysl-ap1a-userdebug
#m bacon
lunch lineage_h872-ap1a-userdebug
m bacon
lunch lineage_a10-ap1a-userdebug
m bacon
lunch lineage_X00TD-ap1a-userdebug
m bacon
