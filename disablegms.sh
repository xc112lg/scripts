#!/bin/bash

MARKER="# AUTO-GAPPS-GMS-FIX"

DEVICE_MK=$(find device -name "*.mk" | head -n1)

if [ -z "$DEVICE_MK" ]; then
    echo "❌ Could not find device .mk file"
    exit 1
fi

# ✅ Check if already applied
if grep -q "$MARKER" "$DEVICE_MK"; then
    echo "✅ GApps vs GMS fix already applied. Skipping."
    exit 0
fi

echo "🔍 Running ONE-TIME GApps vs GMS conflict resolver..."

GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"

TMP_GAPPS="/tmp/gapps_modules.txt"
TMP_GMS="/tmp/gms_modules.txt"
TMP_DUP="/tmp/duplicate_modules.txt"

# 1. Extract module names
echo "📦 Scanning GApps..."
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GAPPS_DIR 2>/dev/null > $TMP_GAPPS
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GAPPS_DIR 2>/dev/null >> $TMP_GAPPS

echo "📦 Scanning GMS..."
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GMS_DIR 2>/dev/null > $TMP_GMS
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GMS_DIR 2>/dev/null >> $TMP_GMS

sort -u $TMP_GAPPS -o $TMP_GAPPS
sort -u $TMP_GMS -o $TMP_GMS

# 2. Find duplicates
comm -12 $TMP_GAPPS $TMP_GMS > $TMP_DUP

if [ ! -s "$TMP_DUP" ]; then
    echo "✅ No duplicates found. Nothing to do."
    exit 0
fi

echo "⚠️ Found duplicates:"
cat $TMP_DUP

# 3. Apply fix ONCE
{
echo ""
echo "$MARKER"
echo "# Disable GMS duplicates (prefer GApps)"
echo "PRODUCT_PACKAGES_REMOVE += \\"

while read mod; do
    echo "    $mod \\"
done < $TMP_DUP

echo ""
} >> "$DEVICE_MK"

echo "🧼 Cleaning Soong..."
rm -rf out/soong

echo "✅ Fix applied successfully (ONE-TIME)."
echo "Next runs will skip automatically."
