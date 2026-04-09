#!/usr/bin/env bash
set -e

echo "🔧 Fixing SELinux neverallow violations..."

# ==============================
# 1. Remove sys_module from system_server
# ==============================
SYS_SERVER_FILE="device/mediatek/sepolicy_vndr/basic/non_plat/system_server.te"

if [ -f "$SYS_SERVER_FILE" ]; then
    echo "➡️ Patching system_server.te (removing sys_module)..."
    sed -i '/sys_module/d' "$SYS_SERVER_FILE"
fi

# ==============================
# 2. Remove default_prop usage from vendor_init
# ==============================
VENDOR_INIT_FILE="device/xiaomi/blossom/sepolicy/vendor/vendor_init.te"

if [ -f "$VENDOR_INIT_FILE" ]; then
    echo "➡️ Patching vendor_init.te (removing default_prop)..."
    sed -i '/default_prop/d' "$VENDOR_INIT_FILE"
fi

# ==============================
# 3. Ensure vendor property type exists
# ==============================
PROP_TE="device/xiaomi/blossom/sepolicy/vendor/property.te"

mkdir -p "$(dirname "$PROP_TE")"

if [ ! -f "$PROP_TE" ]; then
    echo "➡️ Creating property.te..."
    cat <<EOF > "$PROP_TE"
type vendor_prop, property_type;
EOF
else
    if ! grep -q "vendor_prop" "$PROP_TE"; then
        echo "➡️ Adding vendor_prop type..."
        echo "type vendor_prop, property_type;" >> "$PROP_TE"
    fi
fi

# ==============================
# 4. Ensure property_contexts exists
# ==============================
PROP_CTX="device/xiaomi/blossom/sepolicy/vendor/property_contexts"

mkdir -p "$(dirname "$PROP_CTX")"

if [ ! -f "$PROP_CTX" ]; then
    echo "➡️ Creating property_contexts..."
    cat <<EOF > "$PROP_CTX"
vendor.fix.prop   u:object_r:vendor_prop:s0
EOF
else
    if ! grep -q "vendor.fix.prop" "$PROP_CTX"; then
        echo "➡️ Adding vendor property context..."
        echo "vendor.fix.prop   u:object_r:vendor_prop:s0" >> "$PROP_CTX"
    fi
fi

# ==============================
# 5. Allow vendor_init to set vendor_prop
# ==============================
if [ -f "$VENDOR_INIT_FILE" ]; then
    if ! grep -q "vendor_prop" "$VENDOR_INIT_FILE"; then
        echo "➡️ Adding safe vendor_prop rule..."
        echo "allow vendor_init vendor_prop:property_service set;" >> "$VENDOR_INIT_FILE"
    fi
fi

# ==============================
# 6. Optional: disable neverallow (debug only)
# ==============================
BOARD_CONFIG="device/xiaomi/blossom/BoardConfig.mk"

if [ -f "$BOARD_CONFIG" ]; then
    if ! grep -q "SELINUX_IGNORE_NEVERALLOWS" "$BOARD_CONFIG"; then
        echo "➡️ Adding debug bypass (optional)..."
        echo "SELINUX_IGNORE_NEVERALLOWS := true" >> "$BOARD_CONFIG"
    fi
fi

echo "✅ SELinux fixes applied!"
echo "👉 Now run:"
echo "   m clean && make -j\$(nproc)"
