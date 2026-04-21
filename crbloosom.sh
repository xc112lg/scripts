sudo apt update
sudo apt install patchelf -y

rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf device/xiaomi/blossom-kernel
rm -rf vendor/xiaomi
rm -rf vendor/xiaomi/miuicamera
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf vendor

#rm -rf build/soong
# Cleanup previous changelog to make it always fresh
rm -rf out/target/product/*/system/etc/Changelog.txt \
       out/target/product/*/obj/ETC/Changelog.txt_intermediates \
       out/target/product/*/gen/ETC/Changelog.txt_intermediates


repo init -u https://github.com/Evolution-X/manifest -b bq2 --depth=1 --git-lfs
#Temp Fix Repo tool
#cd .repo/repo;git pull -r;cd ../..;


# Clone local_manifests repository
#git clone https://github.com/0kaarun/Blossom_local_mainfest --depth 1 -b A16 .repo/local_manifests

git clone https://github.com/xc112lg/local_manifests --depth 1 -b crb .repo/local_manifests
# if [ ! 0 == 0 ]
#  then   curl -o .repo/local_manifests https://github.com/bagaskara815/local_manifests.git
#  fi
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# repo sync
/opt/crave/resync.sh

CAMERA_HAL="vendor/xiaomi/blossom/proprietary/vendor/bin/hw/camerahalserver"

SHIM_NAME="libshim_utils.so"

if [ ! -f "$CAMERA_HAL" ]; then
    echo "Error: $CAMERA_HAL not found!"
    exit 1
fi

if ! command -v patchelf &> /dev/null; then
    echo "Error: patchelf is not installed!"
    exit 1
fi

if patchelf --print-needed "$CAMERA_HAL" | grep -q "$SHIM_NAME"; then
    echo "Shim already added to camerahalserver."
else
    echo "Patching camerahalserver to add $SHIM_NAME..."
    patchelf --add-needed "$SHIM_NAME" "$CAMERA_HAL"
    echo "Patched successfully."
fi




# grep -q '"com.lazada.android"' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java || \
# sed -i '/"com.android.chrome",/a\        "com.lazada.android",\n        "com.shopee.ph",' frameworks/base/core/java/com/android/internal/util/evolution/PixelPropsUtils.java


# cd device/xiaomi/blossom
# git fetch https://github.com/xc112lg/device_xiaomi_blossom.git patch-3
# sleep 5
# git cherry-pick 27f6bcc191aaaeb66a424b591218418250cec4c6
# cd -
# sed -i 's/name: "android.hardware.sensors@2.0-subhal-impl-1.0"/name: "android.hardware.sensors@2.0-subhal-impl-1.0-mtk"/' hardware/mediatek/sensors/Android.bp
curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/clean_genfscon6.sh | bash

sed -i '/\/fpsgo/d' $(grep -rl fpsgo device/ vendor/)
sed -i '/\/mtkfb/d' $(grep -rl mtkfb device/ vendor/)
sed -i '/\/ion\//d' $(grep -rl 'genfscon debugfs "/ion' device/ vendor/)
sed -i '/dynamic_debug/d' $(grep -rl dynamic_debug device/ vendor/)
sed -i '/kmemleak/d' $(grep -rl kmemleak device/ vendor/)
sed -i '/dirty_writeback_centisecs/d' device/mediatek/sepolicy_vndr/basic/non_plat/genfs_contexts
rm -rf out/soong/.intermediates/system/sepolicy
# tr -d '\000' < packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml > /tmp/fixed.xml
# mv /tmp/fixed.xml packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml

# # Verify the fix
# echo "Line 39 should now look normal:"
# sed -n '39p' packages/apps/Settings/Evolver/res/xml/evolution_settings_miscellaneous.xml

#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom-evo/fixvolte.sh | bash

#############################################


##########################################33
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

# git clone https://github.com/Evolution-X/vendor_evolution-priv_keys-template vendor/evolution-priv/keys
# cd vendor/evolution-priv/keys
# ./keys.sh
# cd -


echo "======================================"
echo "  Android SELinux Auto Cleaner (A16)"
echo "======================================"

# Paths
SEARCH_DIRS="device vendor"

echo "[*] Removing forbidden capabilities..."

# 1. sys_module (STRICT NEVERALLOW)
grep -rl "sys_module" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning sys_module in $file"
    sed -i '/sys_module/d' "$file"
done

# 2. mounton on exec_type (VERY COMMON MTK ISSUE)
grep -rl "mounton" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning mounton in $file"
    sed -i '/mounton/d' "$file"
done

# 3. ptrace (sometimes forbidden depending on domain)
grep -rl "ptrace" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning ptrace in $file"
    sed -i '/ptrace/d' "$file"
done

# 4. sys_rawio (dangerous capability)
grep -rl "sys_rawio" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning sys_rawio in $file"
    sed -i '/sys_rawio/d' "$file"
done

# 5. vendor trying to touch system_file (common violation)
grep -rl "system_file" $SEARCH_DIRS | while read -r file; do
    echo "  -> Checking system_file rules in $file"
    sed -i '/system_file.*write/d' "$file"
    sed -i '/system_file.*append/d' "$file"
done

# 6. debugfs access (often blocked)
grep -rl "debugfs" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning debugfs in $file"
    sed -i '/debugfs/d' "$file"
done

# 7. proc/kmsg access (restricted)
grep -rl "kmsg" $SEARCH_DIRS | while read -r file; do
    echo "  -> Cleaning kmsg in $file"
    sed -i '/kmsg/d' "$file"
done

# 8. Remove permissive domains (not allowed in user builds)
grep -rl "permissive" $SEARCH_DIRS | while read -r file; do
    echo "  -> Removing permissive domain in $file"
    sed -i '/permissive/d' "$file"
done

echo "[*] Cleaning intermediate sepolicy cache..."
rm -rf out/soong/.intermediates/system/sepolicy

echo "[✓] Done. Now rebuild."


git clone https://github.com/xc112lg/v30 prebuilts/vndk/v30
sed -i '\|$(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)|d' device/xiaomi/blossom/lineage_blossom.mk
sed -i '/# FM Radio/,+2d' device/xiaomi/blossom/device.mk
sed -i '/<<<<<<< HEAD/d;/=======/d;/>>>>>>>/d' device/xiaomi/blossom/rootdir/etc/fstab.mt6765
lunch lineage_blossom-bp4a-eng

sed -i '/\/fpsgo/d' $(grep -rl fpsgo device/ vendor/)
sed -i '/\/mtkfb/d' $(grep -rl mtkfb device/ vendor/)
sed -i '/\/ion\//d' $(grep -rl 'genfscon debugfs "/ion' device/ vendor/)
sed -i '/dynamic_debug/d' $(grep -rl dynamic_debug device/ vendor/)
sed -i '/kmemleak/d' $(grep -rl kmemleak device/ vendor/)
rm -rf out/soong/.intermediates/system/sepolicy





m evolution 2>&1 | tee build.log
curl -F "file=@build.log" https://temp.sh/upload
