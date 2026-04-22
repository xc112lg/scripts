#!/bin/bash

echo "[*] Using ripgrep to find duplicates..."

TMP=$(mktemp)

rg "ro\.vendor\." device vendor -n 2>/dev/null \
| grep property_contexts > "$TMP"

# Extract property keys
cut -d':' -f3 "$TMP" | awk '{print $1}' | sort | uniq -d > duplicates.txt

if [ ! -s duplicates.txt ]; then
    echo "[✓] No duplicates found"
    exit 0
fi

echo "[!] Duplicates:"
cat duplicates.txt
echo

while read prop; do
    echo "[*] Fixing $prop"

    matches=$(rg "$prop" device vendor -n 2>/dev/null | grep property_contexts)

    # Prefer MTK
    keep=$(echo "$matches" | grep -i "mediatek" | head -n1)

    if [ -z "$keep" ]; then
        keep=$(echo "$matches" | head -n1)
    fi

    echo "    -> Keeping: $keep"

    echo "$matches" | while read line; do
        if [[ "$line" != "$keep" ]]; then
            file=$(echo "$line" | cut -d':' -f1)
            echo "    -> Removing from $file"

            sed -i "\|$prop|d" "$file"
        fi
    done

done < duplicates.txt

echo "[✓] Done"
