#!/usr/bin/env bash
set -euo pipefail

LOMI_BASE_URL="${LOMI_BASE_URL:-https://sandbox.api.lomi.africa}"
LOMI_API_KEY="${LOMI_API_KEY:?Set LOMI_API_KEY}"
PAYMENT_INTENT_ID="${PAYMENT_INTENT_ID:?Set PAYMENT_INTENT_ID (pi_...)}"

curl -sS -X GET "${LOMI_BASE_URL}/charge/card/${PAYMENT_INTENT_ID}" \
  -H "X-API-KEY: ${LOMI_API_KEY}" | jq
