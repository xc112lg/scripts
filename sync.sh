#!/bin/bash
# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests
# cp scripts/roomservice.xml .repo/local_manifests/
# #cp scripts/local_manifests.xml .repo/local_manifests/
# cp scripts/eureka_deps.xml .repo/local_manifests/
# cp scripts/x.xml .repo/local_manifests/
# /opt/crave/resync.sh
#git clone https://github.com/krishnaspeace/local_manifests.git --depth 1 -b main .repo/local_manifests
#rm -rf vendor/fingerprint/opensource/interfaces
#git clone https://github.com/xiaomi-msm8953-devs/android_vendor_fingerprint_opensource_interfaces vendor/fingerprint/opensource/interfaces



source build/envsetup.sh
#lunch lineage_ysl-ap1a-userdebug
#m bacon
breakfast gsi_arm64 userdebug
mka
# cd device/lge/msm8996-common
# sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
# sleep 1 &&git cherry-pick 7ef8ee92f398052a9d6351e4d7157e8474401f5b

# cd ../../../

# cd vendor/lge/msm8996-common/

# sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-2
# sleep 1 && git cherry-pick b7ae264df1d799c5d635bada6afbc3714df75cdb 
# sleep 1 && git cherry-pick 1efc7fd60e02b78c0ce03b184b1c0f485100cd18
# cd ../../../
# lunch lineage_h872-ap1a-userdebug
# m bacon
# lunch lineage_a10-ap1a-userdebug
# m bacon
# lunch lineage_X00TD-ap1a-userdebug
# m bacon
