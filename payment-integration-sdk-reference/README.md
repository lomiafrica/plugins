# lomi Payment Integration Reference (SDK)

Minimal Node + Express example for integrating lomi checkout sessions and webhooks using official SDKs.

## What is included

- Backend checkout session creation with `@lomi./sdk`
- Frontend embed helper with `@lomi./embed`
- Dynamic amount, price-based, and line-items checkout routes
- Webhook signature verification (`X-Lomi-Signature`, HMAC SHA256)

## Quick start

From `payment-integration-sdk-reference/`:

```bash
pnpm install
cp .env.example .env
pnpm run dev
```

Open `http://localhost:3001`.

## Required env vars

```env
LOMI_BASE_URL=https://api.lomi.africa
LOMI_API_KEY=your-lomi-api-key
LOMI_WEBHOOK_SECRET=whsec_your_webhook_signing_secret
LOMI_PUBLIC_KEY=lomi_pk_your_publishable_key
```

`LOMI_WEBHOOK_SECRET` is preferred; `LOMI_WEBHOOK_VERIFICATION_TOKEN` is still accepted for backward compatibility.

## API routes

- `GET /api/health`
- `GET /api/config`
- `POST /api/checkout/dynamic`
- `POST /api/checkout/price`
- `POST /api/checkout/line-items`
- `POST /api/webhooks/lomi`
- `GET /api/webhooks/events`

## Key implementation detail

The server serves `@lomi./embed` from:

- `GET /vendor/lomi-embed.js`

Use this local route from the demo frontend instead of hardcoding external script URLs.

## Production notes

- Keep `LOMI_API_KEY` server-side only
- Verify webhook signatures before processing
- Persist + dedupe webhook events by ID in your database
