#!/bin/bash







rm -rf .repo/local_manifests prebuilts
rm -rf  ~/.android-certs/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
#rm -rf ~/.android-certs

git lfs uninstall

repo init -u https://github.com/LineageOS/android.git -b lineage-21.0
cd kernel/lge/msm8996
git reset --hard
cd -
/opt/crave/resync.sh

# cd build
# git reset --hard
# cd ..
# sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"|' build/envsetup.sh

#sed -i 's/lineageos_h872_defconfig/vendor\/lge\/h872.config/g' device/lge/h872/BoardConfig.mk
#cat device/lge/h872/BoardConfig.mk

cd kernel/lge/msm8996
# Fix LTO
sleep 1 && git fetch https://github.com/xc112lg/android_kernel_lge_msm8996.git patch-2
sleep 1 && git cherry-pick f06b7401fe3b2162387a72c78bde0bbe7f2828dd


sleep 1 && git cherry-pick bc797ee9fba35da3fe56a3ffe185a9404ce04840
cd -


source build/envsetup.sh
# #repopick -p 396073
# lunch lineage_h872-ap2a-eng
# m installclean
# m bacon


breakfast h872
m bacon
# # brunch h872 eng


