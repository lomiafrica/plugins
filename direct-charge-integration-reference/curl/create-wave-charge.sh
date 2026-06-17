#!/usr/bin/env bash
set -euo pipefail

LOMI_BASE_URL="${LOMI_BASE_URL:-https://sandbox.api.lomi.africa}"
LOMI_API_KEY="${LOMI_API_KEY:?Set LOMI_API_KEY}"

curl -sS -X POST "${LOMI_BASE_URL}/charge/wave" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: ${LOMI_API_KEY}" \
  -d '{
    "amount": 1000,
    "currency": "XOF",
    "customer": {
      "name": "Jane Doe",
      "email": "jane@example.com",
      "phoneNumber": "+2250707070707"
    },
    "description": "Direct Wave charge via curl",
    "successUrl": "https://example.com/success",
    "errorUrl": "https://example.com/error"
  }' | jq
