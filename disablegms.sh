#!/bin/bash

set -e

MARKER="# AUTO-GAPPS-GMS-FIX"
DEVICE_MK="device/xiaomi/blossom/device.mk"

GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"

TMP_GAPPS="/tmp/gapps_modules.txt"
TMP_GMS="/tmp/gms_modules.txt"
TMP_DUP="/tmp/duplicate_modules.txt"

echo "========================================"
echo " GApps vs GMS Auto Conflict Resolver"
echo "========================================"

# ✅ Check device.mk exists
if [ ! -f "$DEVICE_MK" ]; then
    echo "❌ device.mk not found at $DEVICE_MK"
    exit 1
fi

echo "📍 Using device mk: $DEVICE_MK"

# ✅ Check if already applied
if grep -q "$MARKER" "$DEVICE_MK"; then
    echo "✅ Fix already applied. Skipping."
    exit 0
fi

# ✅ Check directories exist
if [ ! -d "$GAPPS_DIR" ] || [ ! -d "$GMS_DIR" ]; then
    echo "❌ Missing vendor/gapps or vendor/gms directory"
    exit 1
fi

echo "🔍 Scanning modules..."

# Extract modules (Android.mk + Android.bp)
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GAPPS_DIR 2>/dev/null > $TMP_GAPPS || true
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GAPPS_DIR 2>/dev/null >> $TMP_GAPPS || true

grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GMS_DIR 2>/dev/null > $TMP_GMS || true
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GMS_DIR 2>/dev/null >> $TMP_GMS || true

# Clean lists
sort -u $TMP_GAPPS -o $TMP_GAPPS
sort -u $TMP_GMS -o $TMP_GMS

# Find duplicates
comm -12 $TMP_GAPPS $TMP_GMS > $TMP_DUP

if [ ! -s "$TMP_DUP" ]; then
    echo "✅ No duplicate modules found. Nothing to fix."
    exit 0
fi

echo "⚠️ Found duplicate modules:"
cat $TMP_DUP

echo "🛠 Applying fix (ONE-TIME)..."

# Write to device.mk
{
echo ""
echo "$MARKER"
echo "# Auto-disable GMS duplicates (prefer GApps)"
echo "PRODUCT_PACKAGES_REMOVE += \\"

while read mod; do
    echo "    $mod \\"
done < $TMP_DUP

echo ""
} >> "$DEVICE_MK"

echo "🧼 Cleaning Soong cache..."
rm -rf out/soong

echo "========================================"
echo "✅ Fix applied successfully!"
echo "👉 GApps will now take priority over GMS"
echo "👉 This will NOT run again automatically"
echo "========================================"

echo ""
echo "Next step:"
echo "source build/envsetup.sh"
echo "lunch lineage_blossom-userdebug"
echo "mka bacon"
