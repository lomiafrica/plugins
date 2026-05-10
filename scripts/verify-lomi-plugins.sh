#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_RUNTIME=0
MAGENTO_ROOT=""

usage() {
  cat <<'EOF'
Usage:
  ./verify-lomi-plugins.sh [--run-runtime] [--magento-root /path/to/magento]

What it does:
  1) Verifies zero legacy brand remnants in this repository.
  2) Verifies Magento/Prestashop/Woo plugin code references Lomi API contract.
  3) Verifies plugin source string-literal image paths resolve to real files.
  4) Checks Magento rename targets are present.
  5) Optionally runs Magento runtime checks if --run-runtime is provided.

Notes:
  - --run-runtime requires a valid Magento installation path via --magento-root.
  - Prestashop/Woo runtime checks are environment-specific and are printed as next-step commands.
EOF
}

log() {
  printf "\n[%s] %s\n" "$(date +'%H:%M:%S')" "$1"
}

SEARCH_TOOL=""
LEGACY_BRAND_PATTERN='pay'"stack"'|Pay'"stack"'|P'"stk"

search_has_matches() {
  local pattern="$1"
  local path="$2"
  if [[ "$SEARCH_TOOL" == "rg" ]]; then
    rg -n --hidden -S \
      --glob '!**/node_modules/**' \
      --glob '!**/dist/**' \
      --glob '!**/.next/**' \
      --glob '!**/build/**' \
      --glob '!**/coverage/**' \
      --glob '!**/.cursor/**' \
      --glob '!verify-lomi-plugins.sh' \
      "$pattern" "$path"
  else
    grep -RInE \
      --exclude-dir=.git \
      --exclude-dir=node_modules \
      --exclude-dir=dist \
      --exclude-dir=.next \
      --exclude-dir=build \
      --exclude-dir=coverage \
      --exclude-dir=.cursor \
      --exclude=verify-lomi-plugins.sh \
      "$pattern" "$path"
  fi
}

search_must_exist() {
  local pattern="$1"
  local path="$2"
  if [[ "$SEARCH_TOOL" == "rg" ]]; then
    rg -n \
      --glob '!**/node_modules/**' \
      --glob '!**/dist/**' \
      --glob '!**/.next/**' \
      --glob '!**/build/**' \
      --glob '!**/coverage/**' \
      --glob '!**/.cursor/**' \
      --glob '!verify-lomi-plugins.sh' \
      "$pattern" "$path" >/dev/null
  else
    grep -RInE \
      --exclude-dir=.git \
      --exclude-dir=node_modules \
      --exclude-dir=dist \
      --exclude-dir=.next \
      --exclude-dir=build \
      --exclude-dir=coverage \
      --exclude-dir=.cursor \
      --exclude=verify-lomi-plugins.sh \
      "$pattern" "$path" >/dev/null
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-runtime)
      RUN_RUNTIME=1
      shift
      ;;
    --magento-root)
      MAGENTO_ROOT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if command -v rg >/dev/null 2>&1; then
  SEARCH_TOOL="rg"
elif command -v grep >/dev/null 2>&1; then
  SEARCH_TOOL="grep"
else
  echo "Missing search tools: need rg or grep"
  exit 1
fi

cd "$ROOT_DIR"

log "1/5 Checking for legacy brand remnants in repo"
if search_has_matches "$LEGACY_BRAND_PATTERN" .; then
  echo
  echo "FAIL: Found remaining legacy brand references."
  exit 1
fi
echo "PASS: No legacy brand references found."

log "2/5 Validating Lomi API contract references in plugins"

echo "- Magento"
search_must_exist "POST.*checkout-sessions|/checkout-sessions|X-API-Key|X-Lomi-Signature|X-Lomi-Event|api\.lomi\.africa|sandbox\.api\.lomi\.africa" \
  "$ROOT_DIR/apps/plugins/magento"
echo "  PASS"

echo "- Prestashop"
search_must_exist "/checkout-sessions|X-API-Key|X-Lomi-Signature|X-Lomi-Event|api\.lomi\.africa|sandbox\.api\.lomi\.africa" \
  "$ROOT_DIR/apps/plugins/prestashop"
echo "  PASS"

echo "- Woo"
search_must_exist "/checkout-sessions|X-API-Key|X-Lomi-Signature|X-Lomi-Event|api\.lomi\.africa|sandbox\.api\.lomi\.africa" \
  "$ROOT_DIR/apps/plugins/woo"
echo "  PASS"

log "3/5 Scanning plugin trees for broken image path references"
python3 "$ROOT_DIR/apps/plugins/scripts/scan_broken_images.py"

log "4/5 Checking Magento rename targets are present"
search_must_exist "Lomi_Payments|Lomi\\\\Payments|payment/lomi|/lomi/payment/" \
  "$ROOT_DIR/apps/plugins/magento"
echo "PASS: Magento rename targets detected."

if [[ "$RUN_RUNTIME" -eq 1 ]]; then
  log "5/5 Running Magento runtime commands"
  if [[ -z "$MAGENTO_ROOT" ]]; then
    echo "FAIL: --run-runtime requires --magento-root /path/to/magento"
    exit 1
  fi
  if [[ ! -f "$MAGENTO_ROOT/bin/magento" ]]; then
    echo "FAIL: Magento binary not found at: $MAGENTO_ROOT/bin/magento"
    exit 1
  fi
  if ! command -v php >/dev/null 2>&1; then
    echo "FAIL: php is required for Magento runtime checks."
    exit 1
  fi

  php "$MAGENTO_ROOT/bin/magento" module:status | grep -E "Lomi_Payments" || true
  php "$MAGENTO_ROOT/bin/magento" setup:upgrade
  php "$MAGENTO_ROOT/bin/magento" setup:di:compile
  php "$MAGENTO_ROOT/bin/magento" cache:flush
  echo "PASS: Magento runtime commands completed."
else
  log "5/5 Runtime checks skipped"
  cat <<'EOF'
Run with runtime checks when ready:
  ./verify-lomi-plugins.sh --run-runtime --magento-root /absolute/path/to/magento

Then do plugin-specific end-to-end tests:
  - Magento: place order -> hosted redirect -> callback -> webhook replay.
  - Prestashop: same flow in Presta environment.
  - Woo: same flow in Woo environment.
EOF
fi

log "All automated checks passed."
