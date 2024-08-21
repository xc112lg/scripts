#!/bin/bash

rm -rf .repo/local_manifests device/lge/msm8996-common
rm -rf  ~/.android-certs/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
#rm -rf ~/.android-certs

repo init --git-lfs
rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

repo init -u https://github.com/LineageOS/android.git -b lineage-21.0

/opt/crave/resync.sh

# cd build
# git reset --hard
# cd ..
# sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"|' build/envsetup.sh

#sed -i 's/lineageos_h872_defconfig/vendor\/lge\/h872.config/g' device/lge/h872/BoardConfig.mk
#cat device/lge/h872/BoardConfig.mk

# cd kernel/lge/msm8996
# # Fix LTO
# sleep 1 && git fetch https://github.com/xc112lg/android_kernel_lge_msm8996.git patch-2
# sleep 1 && git cherry-pick f06b7401fe3b2162387a72c78bde0bbe7f2828dd


# sleep 1 && git cherry-pick bc797ee9fba35da3fe56a3ffe185a9404ce04840
# cd -

#sed -i '/^TARGET_KERNEL_CONFIG := vendor\/lge\/lge_msm8996_defconfig$/d' device/lge/msm8996-common/BoardConfigCommon.mk

#sed -i '/select SND_SOC_MSM_HDMI_CODEC_RX if ARCH_MSM8996/d' kernel/lge/msm8996/sound/soc/msm/Kconfig
#cat  kernel/lge/msm8996/sound/soc/msm/Kconfig
source build/envsetup.sh



repopick -p 399942
repopick -p 399943
repopick -p 399944
repopick -p 399959
repopick -p 399960
repopick -p 399961
# lunch lineage_h872-ap2a-eng

# m bacon


breakfast h872 eng 
m installclean
m bacon

# # brunch h872 eng


