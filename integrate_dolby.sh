#!/bin/bash

# Dolby Atmos Integration Script
# This script integrates the Dolby Atmos fix into the Xiaomi Blossom device tree

set -e

DEVICE_TREE_PATH="${1:-.}"
DOLBY_FIX_PATH="${2:-./DOLBY-ATMOS-FIX}"

echo "=========================================="
echo "Dolby Atmos Integration Script"
echo "=========================================="
echo "Device Tree Path: $DEVICE_TREE_PATH"
echo "Dolby Fix Path: $DOLBY_FIX_PATH"
echo ""

# Verify paths exist
if [ ! -d "$DEVICE_TREE_PATH" ]; then
    echo "ERROR: Device tree path not found: $DEVICE_TREE_PATH"
    exit 1
fi

if [ ! -d "$DOLBY_FIX_PATH" ]; then
    echo "ERROR: Dolby fix path not found: $DOLBY_FIX_PATH"
    exit 1
fi

# Create necessary directories
echo "[1/6] Creating directory structure..."
mkdir -p "$DEVICE_TREE_PATH/proprietary/bin/hw"
mkdir -p "$DEVICE_TREE_PATH/proprietary/lib"
mkdir -p "$DEVICE_TREE_PATH/configs/audio"
mkdir -p "$DEVICE_TREE_PATH/configs/permissions"
mkdir -p "$DEVICE_TREE_PATH/configs/init"

# Copy binaries
echo "[2/6] Copying audio service binary..."
if [ -f "$DOLBY_FIX_PATH/vendor/bin/hw/android.hardware.audio.service.mediatek" ]; then
    cp "$DOLBY_FIX_PATH/vendor/bin/hw/android.hardware.audio.service.mediatek" \
       "$DEVICE_TREE_PATH/proprietary/bin/hw/"
    chmod +x "$DEVICE_TREE_PATH/proprietary/bin/hw/android.hardware.audio.service.mediatek"
    echo "✓ Audio service binary copied"
else
    echo "✗ Audio service binary not found"
fi

# Copy libraries
echo "[3/6] Copying media player service library..."
if [ -f "$DOLBY_FIX_PATH/system/lib/libmediaplayerservice.so" ]; then
    cp "$DOLBY_FIX_PATH/system/lib/libmediaplayerservice.so" \
       "$DEVICE_TREE_PATH/proprietary/lib/"
    echo "✓ Library copied"
else
    echo "✗ Library not found"
fi

# Copy audio configurations
echo "[4/6] Copying audio configurations..."
if [ -f "$DOLBY_FIX_PATH/vendor/etc/audio_policy_configuration.xml" ]; then
    cp "$DOLBY_FIX_PATH/vendor/etc/audio_policy_configuration.xml" \
       "$DEVICE_TREE_PATH/configs/audio/"
    echo "✓ Audio policy configuration copied"
else
    echo "✗ Audio policy configuration not found"
fi

if [ -f "$DOLBY_FIX_PATH/vendor/etc/media_codecs_dolby_audio.xml" ]; then
    cp "$DOLBY_FIX_PATH/vendor/etc/media_codecs_dolby_audio.xml" \
       "$DEVICE_TREE_PATH/configs/audio/"
    echo "✓ Media codecs configuration copied"
else
    echo "✗ Media codecs configuration not found"
fi

# Copy permissions
echo "[5/6] Copying permission files..."
if [ -f "$DOLBY_FIX_PATH/vendor/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml" ]; then
    cp "$DOLBY_FIX_PATH/vendor/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml" \
       "$DEVICE_TREE_PATH/configs/permissions/"
    echo "✓ Permissions file copied"
else
    echo "✗ Permissions file not found"
fi

# Copy init scripts
echo "[6/6] Copying init scripts..."
if [ -f "$DOLBY_FIX_PATH/system/etc/init/mediaextractor.rc" ]; then
    cp "$DOLBY_FIX_PATH/system/etc/init/mediaextractor.rc" \
       "$DEVICE_TREE_PATH/configs/init/"
    echo "✓ Init script copied"
else
    echo "✗ Init script not found"
fi

echo ""
echo "=========================================="
echo "Integration Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review and update BoardConfig.mk"
echo "2. Update Android.mk with new modules"
echo "3. Update device.mk with PRODUCT_PACKAGES"
echo "4. Review INTEGRATION_GUIDE.md for detailed instructions"
echo ""
echo "Files integrated to:"
echo "  - $DEVICE_TREE_PATH/proprietary/bin/hw/"
echo "  - $DEVICE_TREE_PATH/proprietary/lib/"
echo "  - $DEVICE_TREE_PATH/configs/audio/"
echo "  - $DEVICE_TREE_PATH/configs/permissions/"
echo "  - $DEVICE_TREE_PATH/configs/init/"
