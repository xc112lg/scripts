#!/bin/bash
rm -rf .repo/local_manifests device/asus/X00TD
#cp scripts/local_manifests.xml .repo/local_manifests/










source build/envsetup.sh
make installclean
 ls  out/target/product
#lunch lineage_ysl-ap1a-userdebug
#m bacon
# breakfast gsi_arm64 userdebug
# mka
# cd device/lge/msm8996-common
# sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
# sleep 1 &&git cherry-pick 7ef8ee92f398052a9d6351e4d7157e8474401f5b

# cd ../../../

# cd vendor/lge/msm8996-common/

# sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-2
# sleep 1 && git cherry-pick b7ae264df1d799c5d635bada6afbc3714df75cdb 
# sleep 1 && git cherry-pick 1efc7fd60e02b78c0ce03b184b1c0f485100cd18
# cd ../../../


# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests
# cp scripts/roomservice.xml .repo/local_manifests/
#  source scripts/resync.sh


# lunch lineage_h872-ap1a-userdebug
# m bacon

# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests
# cp scripts/eureka_deps.xml .repo/local_manifests/
#  source scripts/resync.sh

# lunch lineage_a10-ap1a-userdebug
# m bacon

# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests

# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests
# cp scripts/x.xml .repo/local_manifests/
#  source scripts/resync.sh



# lunch lineage_X00TD-ap1a-userdebug
# m bacon




# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests
# cp scripts/X01BD.xml .repo/local_manifests/
#  source scripts/resync.sh
# lunch lineage_X01BD-ap1a-userdebug
# m bacon


# rm -rf .repo/local_manifests
# mkdir .repo/local_manifests

# cp scripts/lge_sdm845.xml .repo/local_manifests/
# cp scripts/setup.sh  .repo/local_manifests/
# cp scripts/rom.sh .repo/local_manifests/



# bash .repo/local_manifests/setup.sh && source scripts/resync.sh && bash .repo/local_manifests/rom.sh && 
# # Set up build environment
# export BUILD_USERNAME=EAZYBLACK 
#  export BUILD_HOSTNAME=crave 
#  source build/envsetup.sh && 
# echo Repository: EAZYBLACK/crave_aosp_builder
#  echo Run ID: 8846867174
 
# # Build the ROM
# lunch lineage_judypn-ap1a-eng && make installclean && mka bacon
