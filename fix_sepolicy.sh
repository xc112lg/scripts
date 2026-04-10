#!/usr/bin/env bash
# =============================================================================
# fix_sepolicy.sh
# Fixes SELinux neverallow violations for Xiaomi blossom (MediaTek) AOSP build
#
# Errors fixed:
#   [1] system_server self:capability sys_module
#       -> device/mediatek/sepolicy_vndr/basic/non_plat/system_server.te
#   [2] vendor_init default_prop:property_service set
#       -> device/xiaomi/blossom/sepolicy/vendor/vendor_init.te
#   [3] vendor_init system_prop:property_service set
#       -> device/xiaomi/blossom/sepolicy/vendor/vendor_init.te
#
# Usage:
#   bash fix_sepolicy.sh           # apply fixes
#   bash fix_sepolicy.sh --revert  # restore original files from .bak
#
# Run from your AOSP root directory.
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()   { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()     { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()    { echo -e "${RED}[ERR ]${NC}  $*"; }
die()    { err "$*"; exit 1; }
header() { echo -e "\n${BOLD}$*${NC}"; }

# ── Sanity check ─────────────────────────────────────────────────────────────
[[ -f "build/envsetup.sh" ]] || die "Must be run from the AOSP root (build/envsetup.sh not found)."

# ── File targets ─────────────────────────────────────────────────────────────
MTK_SS="device/mediatek/sepolicy_vndr/basic/non_plat/system_server.te"
BLOSSOM_VI="device/xiaomi/blossom/sepolicy/vendor/vendor_init.te"

# ── Revert mode ──────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--revert" ]]; then
  header "Reverting changes..."
  reverted=0
  for f in "$MTK_SS" "$BLOSSOM_VI"; do
    if [[ -f "${f}.bak" ]]; then
      cp "${f}.bak" "$f"
      ok "Restored: $f"
      reverted=$((reverted + 1))
    else
      warn "No backup found, skipping: $f"
    fi
  done
  echo ""
  [[ $reverted -gt 0 ]] && ok "Reverted $reverted file(s)." || warn "Nothing was reverted."
  exit 0
fi

# ── Helpers ──────────────────────────────────────────────────────────────────
FIXES_APPLIED=0

backup_file() {
  local file="$1"
  if [[ ! -f "${file}.bak" ]]; then
    cp "$file" "${file}.bak"
    info "Backed up → ${file}.bak"
  else
    warn "Backup already exists, skipping: ${file}.bak"
  fi
}

# Comment out one exact literal line in a file.
# Args: <file> <exact_line> <description>
comment_line() {
  local file="$1"
  local line="$2"
  local desc="$3"

  if [[ ! -f "$file" ]]; then
    warn "File not found — skipping [$desc]: $file"
    return
  fi

  # Already commented out?
  if ! grep -qF "$line" "$file"; then
    warn "Line not found (already fixed or absent) — skipping [$desc]"
    return
  fi

  backup_file "$file"

  # Escape special sed characters in the search string
  local escaped
  escaped=$(printf '%s' "$line" | sed 's/[[\.*^$()+?{|]/\\&/g')

  sed -i "s|^${escaped}$|# [SEPFIX] $line|" "$file"

  if grep -qF "# [SEPFIX] $line" "$file"; then
    ok "Fixed [$desc]"
    FIXES_APPLIED=$((FIXES_APPLIED + 1))
  else
    err "Pattern matched but sed substitution failed — check manually: $file"
  fi
}

# ── Apply fixes ──────────────────────────────────────────────────────────────
header "Applying SELinux neverallow fixes..."

# Fix 1 — system_server must not have sys_module capability
comment_line \
  "$MTK_SS" \
  "allow system_server self:capability sys_module;" \
  "system_server self:capability sys_module"

# Fix 2 — vendor_init must not write default_prop
comment_line \
  "$BLOSSOM_VI" \
  "allow vendor_init default_prop:property_service set;" \
  "vendor_init default_prop:property_service set"

# Fix 3 — vendor_init must not write system_prop
comment_line \
  "$BLOSSOM_VI" \
  "allow vendor_init system_prop:property_service set;" \
  "vendor_init system_prop:property_service set"

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
if [[ $FIXES_APPLIED -eq 0 ]]; then
  warn "No changes applied. Files may already be fixed or targets were not found."
else
  ok "$FIXES_APPLIED fix(es) applied successfully."
  echo ""
  info "To revert all changes:  bash fix_sepolicy.sh --revert"
  echo ""
  info "To rebuild sepolicy only, run from AOSP root:"
  echo "      rm -rf out/soong/.intermediates/system/sepolicy"
  echo "      m"
fi
