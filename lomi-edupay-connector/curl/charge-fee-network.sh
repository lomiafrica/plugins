#!/usr/bin/env bash
# Phase 2 — Network: school in registry with use_network_settlement + acct_...
set -euo pipefail

LOMI_BASE_URL="${LOMI_BASE_URL:-https://sandbox.api.lomi.africa}"
LOMI_API_KEY="${LOMI_API_KEY:?Set LOMI_API_KEY (Operator secret key)}"
LOMI_ACCOUNT="${LOMI_ACCOUNT:?Set LOMI_ACCOUNT e.g. acct_...}"

curl -sS -X POST "${LOMI_BASE_URL}/charge/mtn" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: ${LOMI_API_KEY}" \
  -H "Lomi-Account: ${LOMI_ACCOUNT}" \
  -H "Idempotency-Key: edupay_FEE-NETWORK-PILOT-001" \
  -d '{
    "amount": 25000,
    "currency": "XOF",
    "customer": {
      "name": "Aminata Diallo",
      "email": "parent@example.com",
      "phoneNumber": "+2250707070707"
    },
    "description": "EduPay fee FEE-NETWORK-PILOT-001 school=school_network_001 student=STU-8842 fee=TUITION_TERM1 term=2026-T1",
    "countryCode": "CI",
    "quantity": 1
  }' | jq
