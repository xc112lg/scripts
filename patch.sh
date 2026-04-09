#!/usr/bin/env bash
set -e

echo "🔧 Fixing ALL sepolicy neverallow violations..."

# ==============================
# MEDIATEK FIX (sys_module)
# ==============================
MTK_SYS="device/mediatek/sepolicy_vndr/basic/non_plat/system_server.te"

if [ -f "$MTK_SYS" ]; then
    echo "➡️ Removing forbidden sys_module from system_server..."
    sed -i '/sys_module/d' "$MTK_SYS"
fi

# ==============================
# XIAOMI FIX (vendor_init)
# ==============================
BASE="device/xiaomi/blossom/sepolicy/vendor"
VENDOR_INIT="$BASE/vendor_init.te"
PROP_TE="$BASE/property.te"
PROP_CTX="$BASE/property_contexts"

if [ -f "$VENDOR_INIT" ]; then
    echo "➡️ Cleaning vendor_init illegal rules..."

    sed -i '/default_prop:property_service set/d' "$VENDOR_INIT"
    sed -i '/system_prop:property_service set/d' "$VENDOR_INIT"

    if ! grep -q "vendor_prop:property_service set" "$VENDOR_INIT"; then
        echo "➡️ Adding safe vendor_prop rule..."
        echo "allow vendor_init vendor_prop:property_service set;" >> "$VENDOR_INIT"
    fi
fi

# ==============================
# Ensure vendor_prop exists
# ==============================
mkdir -p "$BASE"

if [ ! -f "$PROP_TE" ]; then
    echo "➡️ Creating property.te..."
    echo "type vendor_prop, property_type;" > "$PROP_TE"
else
    if ! grep -q "vendor_prop" "$PROP_TE"; then
        echo "type vendor_prop, property_type;" >> "$PROP_TE"
    fi
fi

# ==============================
# Ensure property_contexts
# ==============================
if [ ! -f "$PROP_CTX" ]; then
    echo "vendor.blossom.fix   u:object_r:vendor_prop:s0" > "$PROP_CTX"
else
    if ! grep -q "vendor_prop" "$PROP_CTX"; then
        echo "vendor.blossom.fix   u:object_r:vendor_prop:s0" >> "$PROP_CTX"
    fi
fi

echo "✅ ALL sepolicy issues fixed!"
echo "👉 Now rebuild:"
echo "   m clean && make -j\$(nproc)"
