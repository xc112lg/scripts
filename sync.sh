#can cause issue with other rom if they change it repo init
#cp scripts/local_manifests.xml .repo/local_manifests/

# source scripts/resync.sh



# source build/envsetup.sh
# make installclean
# ls  out/target/product
# lunch lineage_ysl-ap1a-userdebug
# m bacon
# breakfast gsi_arm64 userdebug

# time mka
# source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests/

source scripts/resync.sh


cd device/lge/msm8996-common
sleep 1 &&git fetch https://github.com/xc112lg/android_device_lge_msm8996-common.git patch-1
sleep 1 &&git cherry-pick 7ef8ee92f398052a9d6351e4d7157e8474401f5b

cd ../../../

cd vendor/lge/msm8996-common/

sleep 1 && git fetch https://github.com/xc112lg/proprietary_vendor_lge_msm8996-common.git patch-2
sleep 1 && git cherry-pick b7ae264df1d799c5d635bada6afbc3714df75cdb 
sleep 1 && git cherry-pick 1efc7fd60e02b78c0ce03b184b1c0f485100cd18
cd ../../../




# source build/envsetup.sh
# lunch lineage_h872-ap1a-userdebug
# make installclean
# time m bacon
# source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/eureka_deps.xml .repo/local_manifests/

source scripts/resync.sh
# source build/envsetup.sh
# lunch lineage_a10-ap1a-userdebug
# make installclean
# time m bacon


# source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/x.xml .repo/local_manifests/

source scripts/resync.sh


# source build/envsetup.sh
# lunch lineage_X00TD-ap1a-userdebug
# make installclean
# time m bacon



# source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests
mkdir .repo/local_manifests
cp scripts/X01BD.xml .repo/local_manifests/

source scripts/resync.sh
source build/envsetup.sh
# lunch lineage_X01BD-ap1a-userdebug
# make installclean
# time m bacon

# source scripts/cleanmanifest.sh
# source scripts/resync.sh 
