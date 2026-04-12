#!/bin/bash

echo "🔍 Auto-detecting GApps vs GMS conflicts..."

GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"

TMP_GAPPS="/tmp/gapps_modules.txt"
TMP_GMS="/tmp/gms_modules.txt"
TMP_DUP="/tmp/duplicate_modules.txt"

# 1. Extract module names from Android.mk / Android.bp
echo "📦 Scanning GApps modules..."
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GAPPS_DIR 2>/dev/null > $TMP_GAPPS
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GAPPS_DIR 2>/dev/null >> $TMP_GAPPS

echo "📦 Scanning GMS modules..."
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GMS_DIR 2>/dev/null > $TMP_GMS
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GMS_DIR 2>/dev/null >> $TMP_GMS

# Clean duplicates
sort -u $TMP_GAPPS -o $TMP_GAPPS
sort -u $TMP_GMS -o $TMP_GMS

# 2. Find duplicates
comm -12 $TMP_GAPPS $TMP_GMS > $TMP_DUP

echo "⚠️ Found duplicate modules:"
cat $TMP_DUP

# 3. Disable duplicates from GMS using PRODUCT_PACKAGES_REMOVE
DEVICE_MK=$(find device -name "*.mk" | head -n1)

echo "🛠 Writing removal list to $DEVICE_MK"

echo -e "\n# AUTO-GENERATED: Disable GMS duplicates (prefer GApps)" >> $DEVICE_MK
echo "PRODUCT_PACKAGES_REMOVE += \\" >> $DEVICE_MK

while read mod; do
    echo "    $mod \\" >> $DEVICE_MK
done < $TMP_DUP

echo "" >> $DEVICE_MK

# 4. Clean build cache
echo "🧼 Cleaning Soong..."
rm -rf out/soong

echo "✅ Done! Rebuild now:"
echo "source build/envsetup.sh && lunch lineage_blossom-userdebug && mka bacon"
