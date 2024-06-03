#!/bin/bash
git lfs install
repo init -u https://github.com/crdroidandroid/android.git -b 13.0 --git-lfs
git lfs install


rm -rf .repo/local_manifests device/lge build/tools 

mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests


repo init --git-lfs
rm -rf external/chromium-webview/prebuilt/*
rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

/opt/crave/resync.sh


source build/envsetup.sh
sed -i '/include $(LOCAL_PATH)\/vendor_prop.mk/a -include vendor/extra/product.mk' device/lge/msm8996-common/msm8996.mk
cd build/tools
git fetch https://github.com/xc112lg/android_build.git patch-1
git cherry-pick b7b12b875a97eee6e512c74c53a82066e237a31a
cd ../../

subject='/C=DE/ST=Germany/L=Berlin/O=Max Mustermann/OU=Max Mustermann/CN=Max Mustermann/emailAddress=max@mustermann.de'
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do \
 yes "" |   ./development/tools/make_key ~/.android-certs/$x "$subject"; \
done

mkdir vendor/extra
mkdir vendor/lineage-priv
cp -r ~/.android-certs vendor/extra/keys

cp -r ~/.android-certs vendor/lineage-priv/keys
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/extra/keys/releasekey" > vendor/extra/product.mk
# cat << 'EOF' >  vendor/lineage-priv/keys/BUILD.bazel
# filegroup(
#     name = "android_certificate_directory",
#     srcs = glob([
#         "*.pk8",
#         "*.pem",
#     ]),
#     visibility = ["//visibility:public"],
# )
# EOF





#lunch lineage_us997-userdebug
lunch lineage_h872-userdebug
m installclean
m bacon

# rm -rf .repo/local_manifests device/lge/msm8996-common build/tools

# mkdir -p .repo/local_manifests
# cp scripts/roomservice.xml .repo/local_manifests


# repo init --git-lfs
# rm -rf external/chromium-webview/prebuilt/*
# rm -rf .repo/projects/external/chromium-webview/prebuilt/*.git
# rm -rf .repo/project-objects/LineageOS/android_external_chromium-webview_prebuilt_*.git

# /opt/crave/resync.sh


# source build/envsetup.sh
# cd device/lge/msm8996-common
# # git fetch https://github.com/LineageOS/android_device_lge_msm8996-common.git lineage-21
# # git cherry-pick 202b7b2a91cd8cf3816f93f90942f1fdf5ebb92f
# # sed -i 's/$(call inherit-product, $(SRC_TARGET_DIR)\/product\/non_ab_device\.mk)//g' msm8996.mk
# sed -i '/BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true/a\BUILD_BROKEN_INCORRECT_PARTITION_IMAGES := true' BoardConfigCommon.mk

# # git fetch https://github.com/LineageOS/android_device_lge_msm8996-common.git lineage-21
# # git cherry-pick bc3eabcf8adca63c5bd17d61a3066b5d40bdf72f
# cd ../../../
# sed -i '/-include device\/lge\/msm8996-common\/BoardConfigCommon.mk/a\-include vendor/lineage-priv/keys/keys.mk' device/lge/g6-common/BoardConfigCommon.mk
# cd build/tools
# git fetch https://github.com/xc112lg/android_build.git patch-1
# git cherry-pick b7b12b875a97eee6e512c74c53a82066e237a31a
# cd ../../

# subject='/C=DE/ST=Germany/L=Berlin/O=Max Mustermann/OU=Max Mustermann/CN=Max Mustermann/emailAddress=max@mustermann.de'
# mkdir ~/.android-certs

# for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do \
#  yes "" |   ./development/tools/make_key ~/.android-certs/$x "$subject"; \
# done




# #lunch lineage_us997-userdebug
# lunch lineage_h872-userdebug
# m installclean
# m target-files-package otatools

# croot 

# # Sign the target files and APKs
# sign_target_files_apks -o -d ~/.android-certs \
#     --extra_apks AdServicesApk.apk=$HOME/.android-certs/releasekey \
#     --extra_apks HalfSheetUX.apk=$HOME/.android-certs/releasekey \
#     --extra_apks OsuLogin.apk=$HOME/.android-certs/releasekey \
#     --extra_apks SafetyCenterResources.apk=$HOME/.android-certs/releasekey \
#     --extra_apks ServiceConnectivityResources.apk=$HOME/.android-certs/releasekey \
#     --extra_apks ServiceUwbResources.apk=$HOME/.android-certs/releasekey \
#     --extra_apks ServiceWifiResources.apk=$HOME/.android-certs/releasekey \
#     --extra_apks WifiDialog.apk=$HOME/.android-certs/releasekey \
#     --extra_apks com.android.adbd.apex=$HOME/.android-certs/com.android.adbd \
#     --extra_apks com.android.adservices.apex=$HOME/.android-certs/com.android.adservices \
#     --extra_apks com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api \
#     --extra_apks com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch \
#     --extra_apks com.android.art.apex=$HOME/.android-certs/com.android.art \
#     --extra_apks com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth \
#     --extra_apks com.android.btservices.apex=$HOME/.android-certs/com.android.btservices \
#     --extra_apks com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast \
#     --extra_apks com.android.compos.apex=$HOME/.android-certs/com.android.compos \
#     --extra_apks com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure \
#     --extra_apks com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources \
#     --extra_apks com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt \
#     --extra_apks com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock \
#     --extra_apks com.android.extservices.apex=$HOME/.android-certs/com.android.extservices \
#     --extra_apks com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf \
#     --extra_apks com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual \
#     --extra_apks com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual \
#     --extra_apks com.android.hardware.boot.apex=$HOME/.android-certs/com.android.hardware.boot \
#     --extra_apks com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas \
#     --extra_apks com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi \
#     --extra_apks com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness \
#     --extra_apks com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin \
#     --extra_apks com.android.i18n.apex=$HOME/.android-certs/com.android.i18n \
#     --extra_apks com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec \
#     --extra_apks com.android.media.apex=$HOME/.android-certs/com.android.media \
#     --extra_apks com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec \
#     --extra_apks com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider \
#     --extra_apks com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet \
#     --extra_apks com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering \
#     --extra_apks com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks \
#     --extra_apks com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization \
#     --extra_apks com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd \
#     --extra_apks com.android.permission.apex=$HOME/.android-certs/com.android.permission \
#     --extra_apks com.android.resolv.apex=$HOME/.android-certs/com.android.resolv \
#     --extra_apks com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd \
#     --extra_apks com.android.runtime.apex=$HOME/.android-certs/com.android.runtime \
#     --extra_apks com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources \
#     --extra_apks com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling \
#     --extra_apks com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext \
#     --extra_apks com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer \
#     --extra_apks com.android.telephony.apex=$HOME/.android-certs/com.android.telephony \
#     --extra_apks com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules \
#     --extra_apks com.android.tethering.apex=$HOME/.android-certs/com.android.tethering \
#     --extra_apks com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata \
#     --extra_apks com.android.uwb.apex=$HOME/.android-certs/com.android.uwb \
#     --extra_apks com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources \
#     --extra_apks com.android.virt.apex=$HOME/.android-certs/com.android.virt \
#     --extra_apks com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current \
#     --extra_apks com.android.vndk.current.on_vendor.apex=$HOME/.android-certs/com.android.vndk.current.on_vendor \
#     --extra_apks com.android.wifi.apex=$HOME/.android-certs/com.android.wifi \
#     --extra_apks com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog \
#     --extra_apks com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources \
#     --extra_apks com.google.pixel.camera.hal.apex=$HOME/.android-certs/com.google.pixel.camera.hal \
#     --extra_apks com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal \
#     --extra_apex_payload_key com.android.adbd.apex=$HOME/.android-certs/com.android.adbd.pem \
#     --extra_apex_payload_key com.android.adservices.apex=$HOME/.android-certs/com.android.adservices.pem \
#     --extra_apex_payload_key com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api.pem \
#     --extra_apex_payload_key com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch.pem \
#     --extra_apex_payload_key com.android.art.apex=$HOME/.android-certs/com.android.art.pem \
#     --extra_apex_payload_key com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth.pem \
#     --extra_apex_payload_key com.android.btservices.apex=$HOME/.android-certs/com.android.btservices.pem \
#     --extra_apex_payload_key com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast.pem \
#     --extra_apex_payload_key com.android.compos.apex=$HOME/.android-certs/com.android.compos.pem \
#     --extra_apex_payload_key com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure.pem \
#     --extra_apex_payload_key com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources.pem \
#     --extra_apex_payload_key com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt.pem \
#     --extra_apex_payload_key com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock.pem \
#     --extra_apex_payload_key com.android.extservices.apex=$HOME/.android-certs/com.android.extservices.pem \
#     --extra_apex_payload_key com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf.pem \
#     --extra_apex_payload_key com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual.pem \
#     --extra_apex_payload_key com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual.pem \
#     --extra_apex_payload_key com.android.hardware.boot.apex=$HOME/.android-certs/com.android.hardware.boot.pem \
#     --extra_apex_payload_key com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas.pem \
#     --extra_apex_payload_key com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi.pem \
#     --extra_apex_payload_key com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness.pem \
#     --extra_apex_payload_key com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin.pem \
#     --extra_apex_payload_key com.android.i18n.apex=$HOME/.android-certs/com.android.i18n.pem \
#     --extra_apex_payload_key com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec.pem \
#     --extra_apex_payload_key com.android.media.apex=$HOME/.android-certs/com.android.media.pem \
#     --extra_apex_payload_key com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec.pem \
#     --extra_apex_payload_key com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider.pem \
#     --extra_apex_payload_key com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet.pem \
#     --extra_apex_payload_key com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering.pem \
#     --extra_apex_payload_key com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks.pem \
#     --extra_apex_payload_key com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization.pem \
#     --extra_apex_payload_key com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd.pem \
#     --extra_apex_payload_key com.android.permission.apex=$HOME/.android-certs/com.android.permission.pem \
#     --extra_apex_payload_key com.android.resolv.apex=$HOME/.android-certs/com.android.resolv.pem \
#     --extra_apex_payload_key com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd.pem \
#     --extra_apex_payload_key com.android.runtime.apex=$HOME/.android-certs/com.android.runtime.pem \
#     --extra_apex_payload_key com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources.pem \
#     --extra_apex_payload_key com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling.pem \
#     --extra_apex_payload_key com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext.pem \
#     --extra_apex_payload_key com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer.pem \
#     --extra_apex_payload_key com.android.telephony.apex=$HOME/.android-certs/com.android.telephony.pem \
#     --extra_apex_payload_key com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules.pem \
#     --extra_apex_payload_key com.android.tethering.apex=$HOME/.android-certs/com.android.tethering.pem \
#     --extra_apex_payload_key com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata.pem \
#     --extra_apex_payload_key com.android.uwb.apex=$HOME/.android-certs/com.android.uwb.pem \
#     --extra_apex_payload_key com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources.pem \
#     --extra_apex_payload_key com.android.virt.apex=$HOME/.android-certs/com.android.virt.pem \
#     --extra_apex_payload_key com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current.pem \
#     --extra_apex_payload_key com.android.vndk.current.on_vendor.apex=$HOME/.android-certs/com.android.vndk.current.on_vendor.pem \
#     --extra_apex_payload_key com.android.wifi.apex=$HOME/.android-certs/com.android.wifi.pem \
#     --extra_apex_payload_key com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog.pem \
#     --extra_apex_payload_key com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources.pem \
#     --extra_apex_payload_key com.google.pixel.camera.hal.apex=$HOME/.android-certs/com.google.pixel.camera.hal.pem \
#     --extra_apex_payload_key com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal.pem \
#     --extra_apex_payload_key com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb.pem \
#     $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
#     signed-target_files.zip

# # Create OTA update package from signed target files
# ota_from_target_files -k ~/.android-certs/releasekey \
#     --block --backup=true \
#     signed-target_files.zip \
#     signed-ota_update.zip


