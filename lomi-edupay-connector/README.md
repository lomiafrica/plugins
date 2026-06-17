# EduPay × lomi. Connector

Partner integration for [Yele Group](https://www.yelegroup.africa/) **EduPay** — school fee collection via lomi. **direct charges**, with a progressive path from **normal merchant** (Phase 1) to **lomi. Network** (Phase 2).

Built on the same patterns as [`direct-charge-integration-reference`](../direct-charge-integration-reference).

## Architecture

```
EduPay backend  →  connector-api  →  @edupay/lomi-client  →  lomi. API
                         ↑
                   webhooks (PAYMENT_SUCCEEDED)
```

| Phase | lomi role | Routing |
| --- | --- | --- |
| **1 — Normal** | Single merchant API key | `school_id` in metadata only |
| **2 — Network** | EduPay = Operator, schools = `acct_...` | `Lomi-Account` header per school registry |

Same charge endpoints in both phases. Phase 2 is a **per-school feature flag** in `data/schools.json`, not a rewrite.

## Quick start

```bash
cd apps/plugins/lomi-edupay-connector
pnpm install
cp .env.example .env
# Edit .env — sandbox keys from dashboard.lomi.africa
cp data/schools.example.json data/schools.json
pnpm run dev
```

Open **http://localhost:3010** for the sandbox UI.

```bash
chmod +x curl/*.sh
./curl/charge-fee-phase1.sh
```

## API (EduPay-facing)

### `POST /api/v1/fees/charge`

| Field | Required | Description |
| --- | --- | --- |
| `rail` | Yes | `mtn`, `wave`, or `card` |
| `amount` | Yes | XOF amount |
| `payment_reference` | Yes | EduPay fee / invoice ID |
| `school_id` | Yes | School identifier |
| `student_id` | Yes | Student identifier |
| `fee_code` | Yes | Fee type code |
| `term_id` | No | Academic term |
| `customer_name` | Yes | Parent / guardian |
| `customer_phone` | Yes | E.164 phone |
| `customer_email` | Card only | Required for card rail |

Response includes `edupay.lomi_mode` (`merchant` | `network`) and `member_account_id` when applicable.

### `POST /api/webhooks/lomi`

lomi webhook receiver with signature verification. Set `EDUPAY_WEBHOOK_FORWARD_URL` to proxy events to EduPay core.

### `GET /api/schools`

Lists schools from the registry and their Network status.

## Packages

| Path | Purpose |
| --- | --- |
| `packages/lomi-client` | Shared client — idempotency, metadata, `Lomi-Account` resolution |
| `server/` | Connector API (BFF) — never expose `LOMI_API_KEY` to browsers |
| `data/schools.json` | `school_id` → `acct_...` mapping for Phase 2 |
| `docs/` | Phase guides, metadata contract, webhooks |

## Documentation

- [Phase 1 — Normal merchant](./docs/01-phase-1-normal.md)
- [Phase 2 — Network](./docs/02-phase-2-network.md)
- [Metadata contract](./docs/metadata-contract.md)
- [Webhook events](./docs/webhook-events.md)

## External references

- [Direct charges](https://docs.lomi.africa/build/direct-charges)
- [lomi. Network](https://docs.lomi.africa/resources/network)
- [Network onboarding journey](https://docs.lomi.africa/resources/network/onboarding-journey)

## Extracting to a standalone repo

This directory is self-contained. To publish under Yele Group:

```bash
cp -R apps/plugins/lomi-edupay-connector /path/to/lomi-edupay-connector
cd /path/to/lomi-edupay-connector && git init
```

No monorepo dependencies beyond `@lomi./sdk` on npm.

## License

Reference / partner integration — align with lomi. partner terms. Not a production EduPay deployment by itself; deploy `connector-api` to Yele infrastructure with secrets in a vault.
