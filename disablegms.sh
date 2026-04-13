#!/bin/bash
set -e

MARKER="# AUTO-GAPPS-GMS-FIX"
DEVICE_MK="device/xiaomi/blossom/device.mk"
GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"
TMP_GAPPS="/tmp/gapps_defined.txt"
TMP_GMS="/tmp/gms_defined.txt"
TMP_DUP="/tmp/gms_conflicts.txt"

echo "========================================"
echo " GApps vs GMS Auto Conflict Resolver"
echo "========================================"

# Checks
if [ ! -f "$DEVICE_MK" ]; then
    echo "❌ device.mk not found at $DEVICE_MK"
    exit 1
fi

if [ ! -d "$GAPPS_DIR" ] || [ ! -d "$GMS_DIR" ]; then
    echo "❌ Missing vendor/gapps or vendor/gms"
    exit 1
fi

# Check if already applied
if grep -q "$MARKER" "$DEVICE_MK"; then
    echo "✅ Fix already applied. Skipping."
    echo ""
    echo "📋 Current state in $DEVICE_MK:"
    echo "----------------------------------------"
    grep -A5 "$MARKER" "$DEVICE_MK"
    echo "----------------------------------------"
    exit 0
fi

echo ""
echo "🔍 Scanning module definitions..."
echo ""

# Extract only DEFINED modules (LOCAL_MODULE :=) from .mk files
# This avoids false positives from LOCAL_USES_LIBRARIES, PRODUCT_PACKAGES etc
grep -rhoP '(?<=LOCAL_MODULE\s:=\s)\S+' "$GAPPS_DIR" --include="*.mk" 2>/dev/null \
    | sort -u > "$TMP_GAPPS" || true

grep -rhoP '(?<=LOCAL_MODULE\s:=\s)\S+' "$GMS_DIR" --include="*.mk" 2>/dev/null \
    | sort -u > "$TMP_GMS" || true

# Also catch .bp top-level module definitions
grep -rhoP '^\s*name:\s*"\K[^"]+' "$GAPPS_DIR" --include="*.bp" 2>/dev/null \
    | sort -u >> "$TMP_GAPPS" || true

grep -rhoP '^\s*name:\s*"\K[^"]+' "$GMS_DIR" --include="*.bp" 2>/dev/null \
    | sort -u >> "$TMP_GMS" || true

sort -u "$TMP_GAPPS" -o "$TMP_GAPPS"
sort -u "$TMP_GMS" -o "$TMP_GMS"

# Find modules defined in BOTH vendors
comm -12 "$TMP_GAPPS" "$TMP_GMS" > "$TMP_DUP"

if [ ! -s "$TMP_DUP" ]; then
    echo "✅ No conflicting module definitions found. Nothing to fix."
    exit 0
fi

COUNT=$(wc -l < "$TMP_DUP")
echo "⚠️  Found $COUNT conflicting module(s):"
cat "$TMP_DUP"
echo ""

FIXED_FILES=()
SKIPPED=()
NOT_FOUND=()

while read -r mod; do
    echo "🔧 Processing: $mod"

    # Find .mk files that DEFINE this module in vendor/gms
    FILES=$(grep -rl "LOCAL_MODULE\s*:=\s*${mod}\b" "$GMS_DIR" --include="*.mk" 2>/dev/null || true)

    if [ -z "$FILES" ]; then
        echo "   ↳ ⚠️  Definition not found in vendor/gms .mk files (may be .bp only)"
        NOT_FOUND+=("$mod")
        continue
    fi

    for FILE in $FILES; do
        echo "   ↳ Found in: $FILE"

        # Skip if already guarded
        if grep -B5 "LOCAL_MODULE\s*:=\s*${mod}\b" "$FILE" | grep -q "ifndef GAPPS_BUILD"; then
            echo "   ↳ Already guarded, skipping"
            SKIPPED+=("$mod ($FILE)")
            continue
        fi

        # Find LOCAL_MODULE line number
        MOD_LINE=$(grep -n "LOCAL_MODULE\s*:=\s*${mod}\b" "$FILE" | head -1 | cut -d: -f1)

        # Walk backwards from MOD_LINE to find nearest CLEAR_VARS
        CLEAR_LINE=$(awk "NR<=$MOD_LINE && /include \\\$\(CLEAR_VARS\)/{found=NR} END{print found}" "$FILE")

        # Walk forwards from MOD_LINE to find nearest BUILD_PREBUILT
        BUILD_LINE=$(awk "NR>=$MOD_LINE && /include \\\$\(BUILD_PREBUILT\)/{print NR; exit}" "$FILE")

        if [ -z "$CLEAR_LINE" ] || [ -z "$BUILD_LINE" ]; then
            echo "   ↳ ⚠️  Could not find CLEAR_VARS/BUILD_PREBUILT boundaries, skipping"
            SKIPPED+=("$mod ($FILE) - boundary not found")
            continue
        fi

        echo "   ↳ Block spans lines $CLEAR_LINE–$BUILD_LINE"

        # Insert ifndef before CLEAR_VARS
        sed -i "${CLEAR_LINE}i\\ifndef GAPPS_BUILD" "$FILE"

        # BUILD_PREBUILT shifted down by 1 after above insertion
        BUILD_LINE=$((BUILD_LINE + 1))

        # Insert endif after BUILD_PREBUILT
        sed -i "${BUILD_LINE}a\\endif" "$FILE"

        FIXED_FILES+=("$FILE")
        echo "   ↳ ✅ Guarded"
    done

    # Guard PRODUCT_PACKAGES listings for this module in vendor/gms
    PKG_FILES=$(grep -rl "\b${mod}\b" "$GMS_DIR" --include="*.mk" 2>/dev/null \
        | xargs grep -l "PRODUCT_PACKAGES" 2>/dev/null || true)

    for FILE in $PKG_FILES; do
        # Skip if line already commented or guarded
        if grep -q "# GAPPS_OVERRIDE.*${mod}" "$FILE"; then
            continue
        fi
        sed -i "/PRODUCT_PACKAGES/,/^$/{/\b${mod}\b/s/^/# GAPPS_OVERRIDE: /}" "$FILE"
        echo "   ↳ 📦 Commented out PRODUCT_PACKAGES entry in $FILE"
    done

    echo ""

done < "$TMP_DUP"

# Handle .bp conflicts separately — these need a different approach
if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  The following modules were only found in .bp files:"
    for m in "${NOT_FOUND[@]}"; do
        echo "   • $m"
        # Find the .bp file
        BP_FILE=$(grep -rl "^\s*name:\s*\"${m}\"" "$GMS_DIR" --include="*.bp" 2>/dev/null | head -1 || true)
        if [ -n "$BP_FILE" ]; then
            echo "     → $BP_FILE"
            echo "     → .bp files cannot use ifdef guards — rename or remove manually"
        fi
    done
fi

echo ""
echo "🛠️  Writing GAPPS_BUILD flag to $DEVICE_MK..."
{
    echo ""
    echo "$MARKER"
    echo "# Tell vendor/gms to skip modules already provided by vendor/gapps"
    echo "GAPPS_BUILD := true"
    echo ""
} >> "$DEVICE_MK"

echo ""
echo "🧼 Cleaning Soong cache..."
rm -rf out/soong

echo ""
echo "========================================"
echo "✅ Done!"
echo "========================================"
echo ""

echo "📋 Modules fixed (guarded in vendor/gms):"
for f in "${FIXED_FILES[@]}"; do
    echo "   ✅ $f"
done

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo ""
    echo "📋 Modules skipped (already guarded or boundary not found):"
    for s in "${SKIPPED[@]}"; do
        echo "   ⏭️  $s"
    done
fi

if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    echo ""
    echo "📋 Modules needing manual attention (.bp only):"
    for n in "${NOT_FOUND[@]}"; do
        echo "   ⚠️  $n"
    done
fi

echo ""
echo "📋 Written to $DEVICE_MK:"
echo "----------------------------------------"
grep -A3 "$MARKER" "$DEVICE_MK"
echo "----------------------------------------"
echo ""
echo "Next steps:"
echo "  source build/envsetup.sh"
echo "  lunch lineage_blossom-userdebug"
echo "  mka bacon -j4"
