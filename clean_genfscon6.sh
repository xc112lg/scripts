#!/bin/bash
# fix_genfscon.sh — Auto-fix genfscon conflict:
#   Platform: proc_dirty  <-- owner of /sys/vm/dirty_writeback_centisecs in 202504
#   Vendor:   proc_vm_dirty  <-- stale BSP type, causes secilc conflict
#
# Usage (from Android build root):
#   bash fix_genfscon.sh [--dry-run]

set -euo pipefail

CONFLICT_PATH="/sys/vm/dirty_writeback_centisecs"
CONFLICT_TYPE="proc_vm_dirty"
PLATFORM_TYPE="proc_dirty"
DRY_RUN=0

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; BLU='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${BLU}[INFO]${NC}  $*"; }
ok()   { echo -e "${GRN}[OK]${NC}    $*"; }
warn() { echo -e "${YLW}[WARN]${NC}  $*"; }
err()  { echo -e "${RED}[ERR]${NC}   $*"; }
die()  { err "$*"; exit 1; }

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1 && log "Dry-run mode — no files will be modified."

# ── 0. Sanity check ──────────────────────────────────────────────────────────
[[ -f "build/make/core/main.mk" ]] || \
  die "Run from Android build root (build/make/core/main.mk not found)"

VENDOR_RAW=$(find out/soong/.intermediates/system/sepolicy \
  -name "vendor_sepolicy.cil.raw" 2>/dev/null | grep blossom | head -1)
VENDOR_CIL=$(find out/soong/.intermediates/system/sepolicy \
  -name "vendor_sepolicy.cil" 2>/dev/null | grep blossom | grep -v raw | head -1)
PLAT_CIL=$(find out/soong/.intermediates/system/sepolicy \
  -name "plat_sepolicy.cil" 2>/dev/null | head -1)

# ── 1. Confirm conflict exists ───────────────────────────────────────────────
echo ""
log "=== Conflict verification ==="

if [[ -z "$PLAT_CIL" || -z "$VENDOR_CIL" ]]; then
  warn "Compiled CIL files not found. Run 'm vendor_sepolicy.cil' first to generate them, then re-run this script."
  exit 1
fi

PLAT_RULE=$(grep "genfscon.*dirty_writeback_centisecs" "$PLAT_CIL" 2>/dev/null || true)
VENDOR_RULE=$(grep "genfscon.*dirty_writeback_centisecs" "$VENDOR_CIL" 2>/dev/null || true)

if [[ -z "$VENDOR_RULE" ]]; then
  ok "No conflicting rule found in vendor_sepolicy.cil — nothing to fix."
  exit 0
fi

log "Platform rule : $PLAT_RULE"
log "Vendor rule   : $VENDOR_RULE"

# ── 2. Find source files ─────────────────────────────────────────────────────
echo ""
log "=== Searching for source of '$CONFLICT_TYPE' ==="

SOURCE_FILES=()
while IFS= read -r -d '' f; do
  SOURCE_FILES+=("$f")
done < <(grep -rZl "$CONFLICT_TYPE\|dirty_writeback_centisecs" \
  device/ vendor/ \
  --include="*.te" \
  --include="genfs_contexts" \
  --include="*.cil" \
  2>/dev/null || true)

if [[ ${#SOURCE_FILES[@]} -gt 0 ]]; then
  log "Found ${#SOURCE_FILES[@]} source file(s):"
  for f in "${SOURCE_FILES[@]}"; do
    log "  $f"
    grep -n "$CONFLICT_TYPE\|dirty_writeback_centisecs" "$f" | while read -r line; do
      log "    $line"
    done
  done
else
  warn "No source files found — rule is from a prebuilt CIL blob."
fi

# ── 3. Patch source files ────────────────────────────────────────────────────
if [[ ${#SOURCE_FILES[@]} -gt 0 ]]; then
  echo ""
  log "=== Patching source files ==="
  for f in "${SOURCE_FILES[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
      log "[dry-run] Would patch: $f"
      continue
    fi
    cp "$f" "${f}.bak_genfscon"
    # Remove genfscon lines with the conflicting path+type
    sed -i "/genfscon.*dirty_writeback_centisecs.*${CONFLICT_TYPE}/d" "$f"
    # Also remove standalone type declarations only if they only referenced this path
    # (safe: if proc_vm_dirty is used elsewhere it stays)
    REMAINING=$(grep -c "$CONFLICT_TYPE" "$f" || true)
    ok "Patched $f (backup: ${f}.bak_genfscon) — $CONFLICT_TYPE refs remaining: $REMAINING"
  done
fi

# ── 4. Patch raw vendor CIL (covers prebuilt blobs) ─────────────────────────
echo ""
log "=== Patching compiled vendor CIL ==="

for cil_file in "$VENDOR_RAW" "$VENDOR_CIL"; do
  [[ -z "$cil_file" || ! -f "$cil_file" ]] && continue
  if grep -q "dirty_writeback_centisecs" "$cil_file" 2>/dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "[dry-run] Would patch: $cil_file"
      continue
    fi
    cp "$cil_file" "${cil_file}.bak_genfscon"
    sed -i "/dirty_writeback_centisecs.*${CONFLICT_TYPE}/d" "$cil_file"
    # Verify removal
    if grep -q "dirty_writeback_centisecs.*${CONFLICT_TYPE}" "$cil_file"; then
      err "Failed to remove rule from $cil_file"
    else
      ok "Patched $cil_file"
    fi
  else
    log "No conflicting rule in $cil_file — skipping."
  fi
done

# ── 5. Check if proc_vm_dirty type itself needs a mapping ───────────────────
echo ""
log "=== Checking if proc_vm_dirty type needs mapping ==="

MAPPING_CIL=$(find out/soong/.intermediates/system/sepolicy \
  -name "202504.cil" 2>/dev/null | head -1)

if [[ -n "$MAPPING_CIL" ]]; then
  if grep -q "$CONFLICT_TYPE" "$MAPPING_CIL"; then
    ok "proc_vm_dirty already in mapping file — type remapping handled."
  else
    warn "proc_vm_dirty NOT in 202504.cil mapping."
    warn "If vendor processes or file_contexts still reference proc_vm_dirty,"
    warn "add a typealias or mapping. Usually safe to ignore if only genfscon used it."
  fi
else
  warn "202504.cil not found — skipping mapping check."
fi

# ── 6. Suggest permanent BoardConfig fix ────────────────────────────────────
echo ""
log "=== Permanent fix recommendation ==="

BOARD_CONFIG=$(find device/ -name "BoardConfig.mk" 2>/dev/null | \
  xargs grep -l "BOARD_SEPOLICY\|sepolicy" 2>/dev/null | head -1 || true)

if [[ -n "$BOARD_CONFIG" ]]; then
  SEPOLICY_DIR=$(dirname "$BOARD_CONFIG")/sepolicy
  HOOK_SCRIPT="$SEPOLICY_DIR/fix_genfscon_permanent.sh"
  log "Detected BoardConfig: $BOARD_CONFIG"
  log "Suggested hook script path: $HOOK_SCRIPT"

  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$SEPOLICY_DIR"
    cat > "$HOOK_SCRIPT" << 'HOOK'
#!/bin/bash
# Permanent genfscon fix — called as BOARD_SEPOLICY_POST_PROCESS_SCRIPT
# Removes vendor proc_vm_dirty rule for dirty_writeback_centisecs
# which conflicts with platform proc_dirty in 202504+
VENDOR_RAW="$1"
if [[ -z "$VENDOR_RAW" || ! -f "$VENDOR_RAW" ]]; then
  echo "[fix_genfscon] No raw CIL passed or file not found, skipping."
  exit 0
fi
if grep -q "dirty_writeback_centisecs.*proc_vm_dirty" "$VENDOR_RAW"; then
  sed -i '/dirty_writeback_centisecs.*proc_vm_dirty/d' "$VENDOR_RAW"
  echo "[fix_genfscon] Stripped conflicting proc_vm_dirty genfscon rule."
else
  echo "[fix_genfscon] No conflict found — nothing to strip."
fi
HOOK
    chmod +x "$HOOK_SCRIPT"
    ok "Created permanent hook: $HOOK_SCRIPT"
    echo ""
    log "Add this to $BOARD_CONFIG if not already present:"
    echo ""
    echo "    BOARD_SEPOLICY_POST_PROCESS_SCRIPT := $HOOK_SCRIPT"
    echo ""
  fi
fi

# ── 7. Final verification ────────────────────────────────────────────────────
echo ""
log "=== Final verification ==="

if [[ $DRY_RUN -eq 0 ]]; then
  REMAINING_VENDOR=$(grep -c "dirty_writeback_centisecs.*${CONFLICT_TYPE}" \
    "$VENDOR_CIL" 2>/dev/null || true)
  REMAINING_RAW=$(grep -c "dirty_writeback_centisecs.*${CONFLICT_TYPE}" \
    "$VENDOR_RAW" 2>/dev/null || true)

  if [[ "$REMAINING_VENDOR" -eq 0 && "$REMAINING_RAW" -eq 0 ]]; then
    ok "Conflict cleared from all CIL files."
    echo ""
    ok "=== Fix complete. Run: m vendor_sepolicy.cil ==="
  else
    err "Conflicting rule still present (vendor_cil=$REMAINING_VENDOR raw=$REMAINING_RAW)"
    err "Manual inspection required."
    exit 1
  fi
else
  log "[dry-run] No changes made. Remove --dry-run to apply."
fi
