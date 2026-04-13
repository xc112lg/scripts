#!/bin/bash

set -e

MARKER="# AUTO-GMS-DISABLED"
GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"

echo "========================================"
echo " Proper GMS Duplicate Module Fixer"
echo "========================================"

# Skip if already done
if grep -r "$MARKER" $GMS_DIR >/dev/null 2>&1; then
    echo "✅ GMS modules already patched. Skipping."
    exit 0
fi

TMP_GAPPS="/tmp/gapps.txt"
TMP_GMS="/tmp/gms.txt"
TMP_DUP="/tmp/dup.txt"

# Extract modules
grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GAPPS_DIR 2>/dev/null > $TMP_GAPPS || true
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GAPPS_DIR 2>/dev/null >> $TMP_GAPPS || true

grep -rhoP 'LOCAL_MODULE\s*:=\s*\K.*' $GMS_DIR 2>/dev/null > $TMP_GMS || true
grep -rhoP 'name\s*:\s*"\K.*(?=")' $GMS_DIR 2>/dev/null >> $TMP_GMS || true

sort -u $TMP_GAPPS -o $TMP_GAPPS
sort -u $TMP_GMS -o $TMP_GMS

comm -12 $TMP_GAPPS $TMP_GMS > $TMP_DUP

if [ ! -s "$TMP_DUP" ]; then
    echo "✅ No duplicates found."
    exit 0
fi

echo "⚠️ Found duplicates:"
cat $TMP_DUP

echo "🔧 Disabling duplicates inside vendor/gms..."

while read mod; do
    echo "➡️ Processing $mod"

    FILES=$(grep -rl "$mod" $GMS_DIR 2>/dev/null)

    for f in $FILES; do
        echo "   📄 $f"

        # Backup
        cp "$f" "$f.bak"

        # Disable LOCAL_MODULE
        sed -i "s/^\(\s*LOCAL_MODULE\s*:=\s*$mod\)/$MARKER \1/" "$f"

        # Disable Soong module
        sed -i "s/name:\s*\"$mod\"/$MARKER name: \"$mod\"/" "$f"
    done

done < $TMP_DUP

echo "🧼 Cleaning Soong..."
rm -rf out/soong

echo "========================================"
echo "✅ GMS duplicates disabled successfully!"
echo "👉 GApps will now be used"
echo "========================================"
