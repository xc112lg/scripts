sudo apt update
sudo apt install patchelf -y

rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf device/xiaomi/blossom-kernel
rm -rf vendor/xiaomi
rm -rf vendor/gms
rm -rf vendor/xiaomi/miuicamera
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf hardware/dolby
rm -rf hardware/
rm -rf packages/apps/RevampedFMRadio
rm -rf packages/apps/Settings/

#rm -rf build/soong
# Cleanup previous changelog to make it always fresh
rm -rf out/target/product/*/system/etc/Changelog.txt \
       out/target/product/*/obj/ETC/Changelog.txt_intermediates \
       out/target/product/*/gen/ETC/Changelog.txt_intermediates


repo init -u https://github.com/Evolution-X/manifest -b bka --depth=1 --git-lfs
#Temp Fix Repo tool
#cd .repo/repo;git pull -r;cd ../..;


# Clone local_manifests repository
#git clone https://github.com/0kaarun/Blossom_local_mainfest --depth 1 -b A16 .repo/local_manifests

git clone https://github.com/xc112lg/local_manifests --depth 1 -b crblossom .repo/local_manifests
# if [ ! 0 == 0 ]
#  then   curl -o .repo/local_manifests https://github.com/bagaskara815/local_manifests.git
#  fi
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# repo sync
/opt/crave/resync.sh
# grep -q '"com.lazada.android"' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java || \
# sed -i '/"com.android.chrome",/a\        "com.lazada.android",\n        "com.shopee.ph",' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java


# cd device/xiaomi/blossom
# git fetch https://github.com/xc112lg/device_xiaomi_blossom.git patch-3
# sleep 5
# git cherry-pick 27f6bcc191aaaeb66a424b591218418250cec4c6
# cd -
# sed -i 's/name: "android.hardware.sensors@2.0-subhal-impl-1.0"/name: "android.hardware.sensors@2.0-subhal-impl-1.0-mtk"/' hardware/mediatek/sensors/Android.bp
# curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/extras.sh | bash

# tr -d '\000' < packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml > /tmp/fixed.xml
# mv /tmp/fixed.xml packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml

# # Verify the fix
# echo "Line 39 should now look normal:"
# sed -n '39p' packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml

#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/fix_sepolicy.sh | bash
curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/fixvolte.sh | bash


#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/test.sh  | bash
rm -rf hardware/mediatek/interfaces/hardware/bluetooth
#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/disablegms1.sh  | bash
source build/envsetup.sh

export TARGET_USES_PICO_GAPPS=true
rm -rf hardware/interfaces/biometrics/fingerprint/2.1/default
# Fix ThemeUtils.getInstance() syntax errors
# echo "Fixing ThemeUtils.getInstance() syntax errors..."

# FILES=(
#     "packages/apps/Settings/Evolver/src/org/evolution/settings/fragments/themes/IconShapes.java"
#     "packages/apps/Settings/Evolver/src/org/evolution/settings/fragments/themes/NavigationBarIcons.java"
#     "packages/apps/Settings/Evolver/src/org/evolution/settings/fragments/themes/Themes.java"
# )

# for file in "${FILES[@]}"; do
#     if [ -f "$file" ]; then
#         echo "Processing: $file"
#         sed -i 's/new ThemeUtils\.getInstance(/ThemeUtils.getInstance(/g' "$file"
#     else
#         echo "Warning: $file not found"
#     fi
# done

# echo "Done! Re-run your build."

git clone https://github.com/Evolution-X/vendor_evolution-priv_keys-template vendor/evolution-priv/keys
cd vendor/evolution-priv/keys
./keys.sh
cd -



sed -i '\|$(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)|d' device/xiaomi/blossom/lineage_blossom.mk
sed -i '/# FM Radio/,+2d' device/xiaomi/blossom/device.mk
sed -i '/<<<<<<< HEAD/d;/=======/d;/>>>>>>>/d' device/xiaomi/blossom/rootdir/etc/fstab.mt6765
lunch lineage_blossom-bp3a-eng







m evolution 2>&1 | tee build.log
curl -F "file=@build.log" https://temp.sh/upload

