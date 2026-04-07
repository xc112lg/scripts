#!/bin/bash

set -e

FILE="packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp"

echo "🔧 Fixing FMR_init safely (structure-aware)..."

# 1. Ensure file exists
if [ ! -f "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
fi

# 2. Restore file first (prevents broken sed damage)
echo "♻️ Restoring clean file..."
git checkout -- "$FILE" 2>/dev/null || true

# 3. Apply safe patch (NO line deletion)
echo "✏️ Applying safe ret fix..."
sed -i 's/int ret = 0;/int ret;/g' "$FILE"

# 4. Verify structure (basic sanity checks)
echo "🔍 Verifying structure..."

if ! grep -q "for (idx=0; idx<FMR_MAX_IDX; idx++)" "$FILE"; then
    echo "❌ Missing for-loop (file likely corrupted)"
    exit 1
fi

if ! grep -q "break;" "$FILE"; then
    echo "❌ Missing break statement"
    exit 1
fi

if ! grep -q "fail:" "$FILE"; then
    echo "❌ Missing fail label"
    exit 1
fi

echo "✅ Structure looks good"

# 5. Clean only this module (fast)
echo "🧹 Cleaning FM intermediates..."
rm -rf out/target/product/*/obj/SHARED_LIBRARIES/libmtkfmjni_intermediates 2>/dev/null || true

echo "🚀 Done! You can now rebuild:"
echo "   mka bacon -j\$(nproc)"
