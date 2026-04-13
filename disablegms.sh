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

# Check device.mk exists
if [ ! -f "$DEVICE_MK" ]; then
    echo "❌ device.mk not found at $DEVICE_MK"
    exit 1
fi
echo "📍 Using device mk: $DEVICE_MK"

# Check if already applied
if grep -q "$MARKER" "$DEVICE_MK"; then
    echo "✅ Fix already applied. Skipping."
    exit 0
fi

# Check directories exist
if [ ! -d "$GAPPS_DIR" ] || [ ! -d "$GMS_DIR" ]; then
    echo "❌ Missing vendor/gapps or vendor/gms directory"
    exit 1
fi

echo "🔍 Scanning modules..."

# Extract LOCAL_MODULE from .mk files only (avoids bp false positives)
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K\S+' "$GAPPS_DIR" --include="*.mk" 2>/dev/null \
    | sort -u > "$TMP_GAPPS" || true

grep -rhoP 'LOCAL_MODULE\s*:=\s*\K\S+' "$GMS_DIR" --include="*.mk" 2>/dev/null \
    | sort -u > "$TMP_GMS" || true

# Extract module names from .bp files (top-level name fields only)
grep -rhoP '^\s*name:\s*"\K[^"]+' "$GAPPS_DIR" --include="*.bp" 2>/dev/null \
    | sort -u >> "$TMP_GAPPS" || true

grep -rhoP '^\s*name:\s*"\K[^"]+' "$GMS_DIR" --include="*.bp" 2>/dev/null \
    | sort -u >> "$TMP_GMS" || true

# Re-sort after appending bp results
sort -u "$TMP_GAPPS" -o "$TMP_GAPPS"
sort -u "$TMP_GMS" -o "$TMP_GMS"

# Find duplicates
comm -12 "$TMP_GAPPS" "$TMP_GMS" > "$TMP_DUP"

if [ ! -s "$TMP_DUP" ]; then
    echo "✅ No duplicate modules found. Nothing to fix."
    exit 0
fi

COUNT=$(wc -l < "$TMP_DUP")
echo "⚠️  Found $COUNT duplicate module(s):"
cat "$TMP_DUP"
echo ""

echo "🛠️  Applying fix to $DEVICE_MK..."

# Build the blocklist block with correct trailing backslash handling
{
    echo ""
    echo "$MARKER"
    echo "# Auto-generated: disable GMS duplicates and prefer GApps versions"
    echo "PRODUCT_PACKAGES_BLOCKLIST += \\"

    # Print all but last line with trailing backslash
    head -n -1 "$TMP_DUP" | while read -r mod; do
        echo "    $mod \\"
    done

    # Last line without trailing backslash
    tail -n 1 "$TMP_DUP" | while read -r mod; do
        echo "    $mod"
    done

    echo ""
} >> "$DEVICE_MK"

echo "🧼 Cleaning Soong cache..."
rm -rf out/soong

echo "========================================"
echo "✅ Fix applied successfully!"
echo "👉 GApps will now take priority over GMS"
echo "👉 This will NOT run again (marker set)"
echo "========================================"
echo ""
echo "Next steps:"
echo "  source build/envsetup.sh"
echo "  lunch lineage_blossom-userdebug"
echo "  mka bacon"
