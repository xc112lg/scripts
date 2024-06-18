#!/bin/bash




rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

repo init -u https://github.com/crdroidandroid/android.git -b 13.0 --git-lfs
rm -rf ~/.android-certs

git clone https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps



rm -rf .repo/local_manifests device/lge vendor/lineage-priv frameworks/base  build/tools 

mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests




/opt/crave/resync.sh


source build/envsetup.sh
sed -i '/include $(LOCAL_PATH)\/vendor_prop.mk/a -include vendor/lineage-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk
sed -i '/include $(LOCAL_PATH)\/vendor_prop.mk/a include vendor/gapps/arm64/arm64-vendor.mk' device/lge/msm8996-common/msm8996.mk
cd build/tools
git fetch https://github.com/xc112lg/android_build.git patch-1
git cherry-pick b7b12b875a97eee6e512c74c53a82066e237a31a
cd ../../

cd frameworks/base
git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-19
git cherry-pick 34bfc667283e91110ca1672b413480391b762cf9

git fetch https://github.com/xc112lg/android_frameworks_base-1.git patch-21
git cherry-pick a41aa682ee7edd2b2d44ce70a4f535436fc89345
cd ../../
cd device/lge/h872
git fetch https://github.com/xc112lg/android_device_lge_h872.git patch-1
git cherry-pick 03d20825e951352d519461ec60d98e05fc930c20
cd ../../../

export GH_TOKEN=$(cat gh_token.txt)
git clone https://$GH_TOKEN@github.com/xc112lg/keys -b main vendor/lineage-priv/keys
ls vendor/lineage-priv/keys



#lunch lineage_us997-userdebug
    # lunch lineage_us997-userdebug
    # m installclean
    # m -j$(nproc --all) bacon
    # lunch lineage_h870-userdebug
    # m installclean
    # m -j$(nproc --all) bacon
    lunch lineage_h872-userdebug
    m installclean
    m -j$(nproc --all) bacon


