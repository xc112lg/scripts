#!/bin/bash

echo "[*] Scanning for duplicate property prefixes..."

TMP_FILE=$(mktemp)

# Collect all property_contexts entries
grep -R "ro.vendor." device/ vendor/ 2>/dev/null | grep property_contexts > "$TMP_FILE"

# Extract only property keys
cut -d':' -f2- "$TMP_FILE" | awk '{print $1}' | sort | uniq -d > duplicates.txt

if [ ! -s duplicates.txt ]; then
    echo "[✓] No duplicate prefixes found"
    exit 0
fi

echo "[!] Duplicates found:"
cat duplicates.txt
echo

# Process each duplicate
while read prop; do
    echo "[*] Fixing $prop"

    # Find all occurrences
    matches=$(grep -R "$prop" device/ vendor/ 2>/dev/null | grep property_contexts)

    # Prefer MTK version
    keep=$(echo "$matches" | grep -i "mediatek" | head -n1)

    if [ -z "$keep" ]; then
        keep=$(echo "$matches" | head -n1)
    fi

    echo "    -> Keeping: $keep"

    # Remove others
    echo "$matches" | while read line; do
        if [[ "$line" != "$keep" ]]; then
            file=$(echo "$line" | cut -d':' -f1)
            echo "    -> Removing from $file"

            sed -i "\|$prop|d" "$file"
        fi
    done

done < duplicates.txt

echo
echo "[✓] Cleanup done"

# Optional: clean build intermediates
echo "[*] Cleaning sepolicy intermediates..."
rm -rf out/soong/.intermediates/system/sepolicy
rm -rf out/target/product/*/obj/ETC/*property_contexts*

echo "[✓] Done. Rebuild now."
