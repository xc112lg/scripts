#!/bin/bash

set -e

DEVICE_DIR="device/xiaomi/blossom/sepolicy/vendor"
FILE="$DEVICE_DIR/init.te"

echo "[*] Fixing sepolicy neverallow (mounton)..."

if [ ! -f "$FILE" ]; then
    echo "[!] File not found: $FILE"
    exit 1
fi

# Backup
cp "$FILE" "$FILE.bak"

# 1. Remove illegal mounton rules
sed -i '/volte_.*_exec.*mounton/d' "$FILE"

# 2. Add safe rules if not already present
grep -q "volte_imcb_exec:file" "$FILE" || cat >> "$FILE" <<EOF

# Auto-added safe VoLTE rules
allow init volte_imcb_exec:file { read open execute getattr };
allow init volte_stack_exec:file { read open execute getattr };
allow init volte_ua_exec:file { read open execute getattr };
EOF

echo "[✓] mounton rules removed and safe rules added"
