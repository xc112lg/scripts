#!/bin/bash

echo "🔍 Fixing MTK HAL partition conflicts..."

# List of problematic MTK HAL paths
PATHS=(
"hardware/mediatek/interfaces/hardware/bluetooth/audio/2.1"
)

for p in "${PATHS[@]}"; do
    if [ -d "$p" ]; then
        echo "❌ Found conflicting source HAL: $p"
        echo "🧹 Removing..."
        rm -rf "$p"
    else
        echo "✅ Already clean: $p"
    fi
done

echo "🔎 Checking for duplicate module definitions..."

grep -r "vendor.mediatek.hardware.bluetooth.audio@2.1" . 2>/dev/null | grep -v vendor

echo "🧼 Cleaning build cache..."
rm -rf out/soong
