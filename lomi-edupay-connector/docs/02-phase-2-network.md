# Phase 2 — lomi. Network

When EduPay is approved as a **Network Operator**, each school becomes a **Member Account** (`acct_...`). The connector adds `Lomi-Account` automatically — no API route changes.

## Prerequisites

- Operator approval (invite-only) — contact lomi.
- Per-school KYC as Member Accounts.
- Operator **secret** API key (test, then live).

See [Network onboarding journey](https://docs.lomi.africa/resources/network/onboarding-journey).

## School registry

Update `data/schools.json`:

```json
{
  "schools": {
    "school_lycee_abidjan": {
      "name": "Lycée Example",
      "use_network_settlement": true,
      "member_account_id": "acct_sandbox_member_id"
    }
  }
}
```

- `use_network_settlement: false` → Phase 1 (no header).
- `use_network_settlement: true` → sends `Lomi-Account: acct_...` on every charge.

## Capabilities (per school, per environment)

| Capability | Used for |
| --- | --- |
| `payment.create` | `POST /charge/*` |
| `transaction.read_own` | `GET /transactions/{id}` |
| `refund.create` | `POST /refunds` |

## Progressive rollout

Migrate school-by-school in EduPay:

1. School completes Member onboarding → receive `acct_...`.
2. Set `use_network_settlement: true` in registry.
3. New fees for that school settle to the school’s lomi balance.
4. Legacy in-flight fees on Phase 1 complete under the central merchant.

## Test Network charge

```bash
LOMI_API_KEY=lomi_sk_test_operator_... \
LOMI_ACCOUNT=acct_... \
./curl/charge-fee-network.sh
```

## Operator fees (optional)

Configure operator fee rules in the lomi Network dashboard for EduPay platform revenue. Fee entries are recorded separately from school settlement.

## Related

- [lomi. Network reference](https://docs.lomi.africa/resources/network)
- [Direct charges + Network](https://docs.lomi.africa/build/direct-charges)
