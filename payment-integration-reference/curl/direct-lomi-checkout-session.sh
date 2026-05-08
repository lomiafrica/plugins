#!/usr/bin/env bash
set -euo pipefail

LOMI_BASE_URL="${LOMI_BASE_URL:-https://api.lomi.africa}"
LOMI_API_KEY="${LOMI_API_KEY:-}"

if [[ -z "${LOMI_API_KEY}" ]]; then
  echo "LOMI_API_KEY is required"
  exit 1
fi

curl -sS -X POST "${LOMI_BASE_URL}/checkout-sessions" \
  -H "x-api-key: ${LOMI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 10000,
    "currency_code": "XOF",
    "customer_email": "customer@example.com",
    "title": "Direct lomi API call",
    "success_url": "https://example.com/success",
    "cancel_url": "https://example.com/cancel"
  }' | jq
