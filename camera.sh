CAMERA_HAL="vendor/xiaomi/blossom/proprietary/vendor/bin/hw/camerahalserver"

SHIM_NAME="libshim_utils.so"

if [ ! -f "$CAMERA_HAL" ]; then
    echo "Error: $CAMERA_HAL not found!"
    exit 1
fi

if ! command -v patchelf &> /dev/null; then
    echo "Error: patchelf is not installed!"
    exit 1
fi

if patchelf --print-needed "$CAMERA_HAL" | grep -q "$SHIM_NAME"; then
    echo "Shim already added to camerahalserver."
else
    echo "Patching camerahalserver to add $SHIM_NAME..."
    patchelf --add-needed "$SHIM_NAME" "$CAMERA_HAL"
    echo "Patched successfully."
fi
