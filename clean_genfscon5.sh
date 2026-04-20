#!/bin/bash
set -e

VENDOR_CIL="out/soong/.intermediates/system/sepolicy/vendor_sepolicy.cil/android_common/blossom/vendor_sepolicy.cil"
PLAT_CIL="out/soong/.intermediates/system/sepolicy/plat_sepolicy.cil/android_common/plat_sepolicy.cil"

VENDOR_RULE=$(sed -n '31p' "$VENDOR_CIL")
PLAT_RULE=$(sed -n '141p' "$PLAT_CIL")

echo "[INFO] Platform rule: $PLAT_RULE"
echo "[INFO] Vendor rule:   $VENDOR_RULE"

CONFLICT_FS=$(echo "$VENDOR_RULE" | grep -oP '(?<=genfscon )\S+')
CONFLICT_PATH=$(echo "$VENDOR_RULE" | grep -oP '(?<=genfscon \S{1,64} )\S+')

echo "[INFO] Conflicting: fs=$CONFLICT_FS path=$CONFLICT_PATH"

FILES=$(grep -rln "genfscon.*$CONFLICT_PATH" \
  device/ vendor/ \
  --include="*.te" \
  --include="genfs_contexts" \
  --include="*.cil" 2>/dev/null || true)

if [ -z "$FILES" ]; then
  echo "[WARN] No source files found. Check device/vendor dirs manually."
  exit 1
fi

for f in $FILES; do
  echo "[FIX] Processing: $f"
  cp "$f" "${f}.bak"
  grep -v "genfscon.*${CONFLICT_PATH}" "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
  echo "      Backup saved: ${f}.bak"
done

echo ""
echo "[DONE] Re-run your build to verify the fix."
echo "       To restore: for f in \$(find . -name '*.bak'); do mv \$f \${f%.bak}; done"
