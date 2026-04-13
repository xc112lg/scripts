#!/bin/bash
set -e

MARKER="# AUTO-GAPPS-GMS-FIX"
DEVICE_MK="device/xiaomi/blossom/device.mk"
GAPPS_DIR="vendor/gapps"
GMS_DIR="vendor/gms"
TMP_GAPPS="/tmp/gapps_defined.txt"
TMP_GMS="/tmp/gms_defined.txt"
TMP_DUP="/tmp/gms_conflicts.txt"
BUILD_LOG="build1.log"
CHANGES_LOG="/tmp/gms_changes.log"

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

# Start changes log
{
    echo "========================================"
    echo " GApps vs GMS Changes Report"
    echo " Generated: $(date)"
    echo "========================================"
    echo ""
    echo "Conflicting modules found ($COUNT):"
    cat "$TMP_DUP"
    echo ""
    echo "Changes made:"
    echo "----------------------------------------"
} > "$CHANGES_LOG"

while read -r mod; do
    echo "🔧 Processing: $mod"
    echo "" >> "$CHANGES_LOG"
    echo "MODULE: $mod" >> "$CHANGES_LOG"

    # Find .mk files that DEFINE this module in vendor/gms
    FILES=$(grep -rl "LOCAL_MODULE\s*:=\s*${mod}\b" "$GMS_DIR" --include="*.mk" 2>/dev/null || true)

    if [ -z "$FILES" ]; then
        echo "   ↳ ⚠️  Definition not found in vendor/gms .mk files (may be .bp only)"
        echo "  ⚠️  Not found in .mk files (may be .bp only)" >> "$CHANGES_LOG"
        NOT_FOUND+=("$mod")
        continue
    fi

    for FILE in $FILES; do
        echo "   ↳ Found in: $FILE"
        echo "  File: $FILE" >> "$CHANGES_LOG"

        # Skip if already guarded
        if grep -B5 "LOCAL_MODULE\s*:=\s*${mod}\b" "$FILE" | grep -q "ifndef GAPPS_BUILD"; then
            echo "   ↳ Already guarded, skipping"
            echo "  Status: Already guarded, skipped" >> "$CHANGES_LOG"
            SKIPPED+=("$mod ($FILE)")
            continue
        fi

        # Snapshot before
        echo "  Before:" >> "$CHANGES_LOG"
        grep -n "LOCAL_MODULE\s*:=\s*${mod}\b" "$FILE" | head -3 >> "$CHANGES_LOG"

        # Find LOCAL_MODULE line number
        MOD_LINE=$(grep -n "LOCAL_MODULE\s*:=\s*${mod}\b" "$FILE" | head -1 | cut -d: -f1)

        # Walk backwards from MOD_LINE to find nearest CLEAR_VARS
        CLEAR_LINE=$(awk "NR<=$MOD_LINE && /include \\\$\(CLEAR_VARS\)/{found=NR} END{print found}" "$FILE")

        # Walk forwards from MOD_LINE to find nearest BUILD_PREBUILT
        BUILD_LINE=$(awk "NR>=$MOD_LINE && /include \\\$\(BUILD_PREBUILT\)/{print NR; exit}" "$FILE")

        if [ -z "$CLEAR_LINE" ] || [ -z "$BUILD_LINE" ]; then
            echo "   ↳ ⚠️  Could not find CLEAR_VARS/BUILD_PREBUILT boundaries, skipping"
            echo "  Status: Skipped - boundary not found" >> "$CHANGES_LOG"
            SKIPPED+=("$mod ($FILE) - boundary not found")
            continue
        fi

        echo "   ↳ Block spans lines $CLEAR_LINE–$BUILD_LINE"
        echo "  Block: lines $CLEAR_LINE to $BUILD_LINE" >> "$CHANGES_LOG"

        # Insert ifndef before CLEAR_VARS
        sed -i "${CLEAR_LINE}i\\ifndef GAPPS_BUILD" "$FILE"

        # BUILD_PREBUILT shifted down by 1 after above insertion
        BUILD_LINE=$((BUILD_LINE + 1))

        # Insert endif after BUILD_PREBUILT
        sed -i "${BUILD_LINE}a\\endif" "$FILE"

        FIXED_FILES+=("$FILE")

        # Snapshot after
        echo "  After (guarded block):" >> "$CHANGES_LOG"
        sed -n "$((CLEAR_LINE - 1)),$((BUILD_LINE + 1))p" "$FILE" >> "$CHANGES_LOG"
        echo "  Status: ✅ Guarded successfully" >> "$CHANGES_LOG"
        echo "" >> "$CHANGES_LOG"

        echo "   ↳ ✅ Guarded"
    done

    # Guard PRODUCT_PACKAGES listings for this module in vendor/gms
    PKG_FILES=$(grep -rl "\b${mod}\b" "$GMS_DIR" --include="*.mk" 2>/dev/null \
        | xargs grep -l "PRODUCT_PACKAGES" 2>/dev/null || true)

    for FILE in $PKG_FILES; do
        if grep -q "# GAPPS_OVERRIDE.*${mod}" "$FILE"; then
            continue
        fi
        sed -i "/PRODUCT_PACKAGES/,/^$/{/\b${mod}\b/s/^/# GAPPS_OVERRIDE: /}" "$FILE"
        echo "   ↳ 📦 Commented out PRODUCT_PACKAGES entry in $FILE"
        echo "  PRODUCT_PACKAGES entry commented in: $FILE" >> "$CHANGES_LOG"
    done

    echo ""

done < "$TMP_DUP"

# Handle .bp conflicts
if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    echo "" >> "$CHANGES_LOG"
    echo "Modules needing manual attention (.bp only):" >> "$CHANGES_LOG"
    for m in "${NOT_FOUND[@]}"; do
        BP_FILE=$(grep -rl "^\s*name:\s*\"${m}\"" "$GMS_DIR" --include="*.bp" 2>/dev/null | head -1 || true)
        echo "  • $m → ${BP_FILE:-not found}" >> "$CHANGES_LOG"
    done
fi

echo ""
echo "========================================"
echo " Verifying Changes"
echo "========================================"
echo ""

VERIFY_PASS=()
VERIFY_FAIL=()

{
    echo ""
    echo "========================================"
    echo " Verification Report"
    echo "========================================"
    echo ""
} >> "$CHANGES_LOG"

# Get unique list of files that were modified
UNIQUE_FIXED=($(echo "${FIXED_FILES[@]}" | tr ' ' '\n' | sort -u))

for FILE in "${UNIQUE_FIXED[@]}"; do
    echo "🔍 Verifying: $FILE"
    echo "Verifying: $FILE" >> "$CHANGES_LOG"

    FILE_PASS=true

    # Get line numbers of all 'ifndef GAPPS_BUILD' in this file
    GUARD_LINES=$(grep -n "ifndef GAPPS_BUILD" "$FILE" | cut -d: -f1)

    if [ -z "$GUARD_LINES" ]; then
        echo "   ↳ ❌ No guards found in file!"
        echo "  ❌ No guards found in file!" >> "$CHANGES_LOG"
        VERIFY_FAIL+=("$FILE — no guards found")
        continue
    fi

    while read -r GLINE; do
        # Get the module name inside this guard block
        MOD_IN_BLOCK=$(awk "NR>$GLINE && /LOCAL_MODULE\s*:=/{print \$NF; exit}" "$FILE")

        # Get the endif line after this guard
        ENDIF_LINE=$(awk "NR>$GLINE && /^endif/{print NR; exit}" "$FILE")

        # Get the CLEAR_VARS line immediately after ifndef
        CLEAR_LINE=$(awk "NR>=$GLINE && NR<=$((GLINE+2)) && /include \\\$\(CLEAR_VARS\)/{print NR; exit}" "$FILE")

        # Get the BUILD_PREBUILT line inside this block
        BUILD_LINE=$(awk "NR>$GLINE && NR<${ENDIF_LINE:-9999} && /include \\\$\(BUILD_PREBUILT\)/{print NR; exit}" "$FILE")

        echo "   ↳ Block for '$MOD_IN_BLOCK':"
        echo "  Block for '$MOD_IN_BLOCK':" >> "$CHANGES_LOG"

        # Check 1: ifndef GAPPS_BUILD exists
        if [ -n "$GLINE" ]; then
            echo "      ✅ ifndef GAPPS_BUILD found at line $GLINE"
            echo "    ✅ ifndef GAPPS_BUILD at line $GLINE" >> "$CHANGES_LOG"
        else
            echo "      ❌ ifndef GAPPS_BUILD missing!"
            echo "    ❌ ifndef GAPPS_BUILD missing!" >> "$CHANGES_LOG"
            FILE_PASS=false
        fi

        # Check 2: ifndef comes before CLEAR_VARS
        if [ -n "$CLEAR_LINE" ] && [ "$GLINE" -lt "$CLEAR_LINE" ]; then
            echo "      ✅ ifndef is before CLEAR_VARS (line $CLEAR_LINE)"
            echo "    ✅ ifndef before CLEAR_VARS at line $CLEAR_LINE" >> "$CHANGES_LOG"
        else
            echo "      ❌ ifndef is NOT before CLEAR_VARS!"
            echo "    ❌ ifndef NOT before CLEAR_VARS!" >> "$CHANGES_LOG"
            FILE_PASS=false
        fi

        # Check 3: endif comes after BUILD_PREBUILT
        if [ -n "$BUILD_LINE" ] && [ -n "$ENDIF_LINE" ] && [ "$ENDIF_LINE" -gt "$BUILD_LINE" ]; then
            echo "      ✅ endif is after BUILD_PREBUILT (line $ENDIF_LINE)"
            echo "    ✅ endif after BUILD_PREBUILT at line $ENDIF_LINE" >> "$CHANGES_LOG"
        else
            echo "      ❌ endif is NOT after BUILD_PREBUILT!"
            echo "    ❌ endif NOT after BUILD_PREBUILT!" >> "$CHANGES_LOG"
            FILE_PASS=false
        fi

        # Check 4: ifndef is directly adjacent to CLEAR_VARS
        if [ -n "$CLEAR_LINE" ]; then
            LINES_BETWEEN=$((CLEAR_LINE - GLINE - 1))
            if [ "$LINES_BETWEEN" -eq 0 ]; then
                echo "      ✅ ifndef directly before CLEAR_VARS"
                echo "    ✅ ifndef directly before CLEAR_VARS" >> "$CHANGES_LOG"
            else
                echo "      ⚠️  $LINES_BETWEEN line(s) between ifndef and CLEAR_VARS"
                echo "    ⚠️  $LINES_BETWEEN line(s) between ifndef and CLEAR_VARS" >> "$CHANGES_LOG"
            fi
        fi

        # Print actual guarded block for visual confirmation
        echo "      📄 Actual block in file:"
        echo "    📄 Actual block:" >> "$CHANGES_LOG"
        if [ -n "$GLINE" ] && [ -n "$ENDIF_LINE" ]; then
            sed -n "${GLINE},${ENDIF_LINE}p" "$FILE" | while read -r line; do
                echo "         $line"
                echo "      $line" >> "$CHANGES_LOG"
            done
        fi

        echo ""
        echo "" >> "$CHANGES_LOG"

    done <<< "$GUARD_LINES"

    if [ "$FILE_PASS" = true ]; then
        VERIFY_PASS+=("$FILE")
        echo "   ↳ ✅ All checks passed"
        echo "  Result: ✅ PASS" >> "$CHANGES_LOG"
    else
        VERIFY_FAIL+=("$FILE")
        echo "   ↳ ❌ Some checks failed — manual review needed"
        echo "  Result: ❌ FAIL" >> "$CHANGES_LOG"
    fi

    echo ""
    echo "" >> "$CHANGES_LOG"

done

# Verification summary
echo "========================================"
echo " Verification Summary"
echo "========================================"
{
    echo "========================================"
    echo " Verification Summary"
    echo "========================================"
} >> "$CHANGES_LOG"

echo "✅ Passed: ${#VERIFY_PASS[@]}"
echo "Passed: ${#VERIFY_PASS[@]}" >> "$CHANGES_LOG"
for f in "${VERIFY_PASS[@]}"; do
    echo "   • $f"
    echo "  • $f" >> "$CHANGES_LOG"
done

if [ ${#VERIFY_FAIL[@]} -gt 0 ]; then
    echo "❌ Failed: ${#VERIFY_FAIL[@]}"
    echo "Failed: ${#VERIFY_FAIL[@]}" >> "$CHANGES_LOG"
    for f in "${VERIFY_FAIL[@]}"; do
        echo "   • $f"
        echo "  • $f" >> "$CHANGES_LOG"
    done
    echo ""
    echo "❌ Verification failed — fix the above files before building"
    echo "❌ Verification failed" >> "$CHANGES_LOG"
    # Merge changes into build log and upload before exiting
    cat "$CHANGES_LOG" >> "$BUILD_LOG"
    echo "📤 Uploading log..."
    curl -s -F "file=@${BUILD_LOG}" https://temp.sh/upload
    echo ""
    exit 1
fi

echo ""
echo "✅ All verifications passed — proceeding to build"
echo ""

# Write GAPPS_BUILD flag to device.mk
echo "🛠️  Writing GAPPS_BUILD flag to $DEVICE_MK..."
{
    echo ""
    echo "$MARKER"
    echo "# Tell vendor/gms to skip modules already provided by vendor/gapps"
    echo "GAPPS_BUILD := true"
    echo ""
} >> "$DEVICE_MK"

echo "" >> "$CHANGES_LOG"
echo "device.mk addition:" >> "$CHANGES_LOG"
grep -A3 "$MARKER" "$DEVICE_MK" >> "$CHANGES_LOG"

echo ""
echo "🧼 Cleaning Soong cache..."
rm -rf out/soong

# Merge changes report into build log
{
    echo "========================================"
    echo " Changes + Verification Report"
    echo "========================================"
    cat "$CHANGES_LOG"
    echo ""
} > "$BUILD_LOG"

echo ""
echo "========================================"
echo " Starting Build"
echo "========================================"
echo ""

source build/envsetup.sh
lunch lineage_blossom-userdebug

{
    echo "========================================"
    echo " Build Log"
    echo " Started: $(date)"
    echo "========================================"
    echo ""
    echo "--- soong.variables (pre-build) ---"
    cat out/soong/soong.variables 2>/dev/null || echo "soong.variables not found yet"
    echo ""
    echo "--- Build Output ---"
} >> "$BUILD_LOG"

set +e
mka bacon -j4 2>&1 | tee -a "$BUILD_LOG"
BUILD_EXIT=$?
set -e

{
    echo ""
    echo "========================================"
    echo " Build Finished"
    echo " Completed: $(date)"
    echo " Exit code: $BUILD_EXIT"
    echo "========================================"
    echo ""
    echo "--- soong.variables (post-build) ---"
    cat out/soong/soong.variables 2>/dev/null || echo "not found"
} >> "$BUILD_LOG"

echo ""
echo "📤 Uploading full log (changes + verification + build)..."
curl -s -F "file=@${BUILD_LOG}" https://temp.sh/upload
echo ""

if [ $BUILD_EXIT -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ Build completed successfully!"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "❌ Build failed — check the uploaded log"
    echo "========================================"
    exit 1
fi
