# lomi. Plugins Monorepo

Welcome to the central repository for **lomi.** payment plugins.

This repository is the entry point for e-commerce integrations (WooCommerce, PrestaShop, Magento, Shopify, etc.) and reference apps that demonstrate the lomi. API.

## Repository layout

### Platform plugins (Git submodules)

Each directory is a submodule pointing at its own repository:

| Directory | Platform | Submodule repo | Access |
| --- | --- | --- | --- |
| [woo](./woo) | WooCommerce | [lomiafrica/woo](https://github.com/lomiafrica/woo) | Public |
| [prestashop](./prestashop) | PrestaShop | [lomiafrica/prestashop](https://github.com/lomiafrica/prestashop) | Public |
| [magento](./magento) | Adobe Commerce (Magento 2) | [lomiafrica/magento](https://github.com/lomiafrica/magento) | Public |
| [shopify](./shopify) | Shopify | [lomiafrica/shopify](https://github.com/lomiafrica/shopify) | Private (org access required) |
| [bubble](./bubble) | Bubble.io | [lomiafrica/bubble](https://github.com/lomiafrica/bubble) | Private (org access required) |
| [odoo](./odoo) | Odoo ERP | [lomiafrica/odoo](https://github.com/lomiafrica/odoo) | Private (org access required) |

### Integration references (in this repo)

These live at the repository root (not submodules). Use them as copy-paste examples for merchants and partners:

- **[direct-charge-integration-reference](./direct-charge-integration-reference)**: Direct charges (`POST /charge/*`) with Payment Elements for cards.
- **[lomi-edupay-connector](./lomi-edupay-connector)**: EduPay (Yele Group) partner connector — direct charges with normal → Network migration path.
- **[payment-integration-reference](./payment-integration-reference)**: Hosted checkout sessions via the raw HTTP API.
- **[payment-integration-sdk-reference](./payment-integration-sdk-reference)**: Hosted checkout sessions with `@lomi./sdk` and `@lomi./embed`.

## Installation and cloning

Use `--recursive` when cloning so submodule checkouts are initialized:

```bash
git clone --recursive https://github.com/lomiafrica/plugins.git
cd plugins
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

If a submodule fails with "repository not found", that platform repo is private — request access from the lomi. team. WooCommerce, PrestaShop, and Magento submodules are public.

## End-to-end tests and scripts

- **[E2E.md](./E2E.md)**: Manual smoke matrix per platform (checkout, webhooks, abandon flows, release tags).
- **[scripts/verify-lomi-plugins.sh](./scripts/verify-lomi-plugins.sh)**: Static compliance gate (API contract, `integration_source`, XOF amounts, legacy brand checks, webhook patterns).
- **[scripts/scan_broken_images.py](./scripts/scan_broken_images.py)**: Scans Magento, PrestaShop, and Woo trees for broken image path references.

Run the static gate from the repository root:

```bash
./scripts/verify-lomi-plugins.sh
```

## Contributing

Pull requests and issue reports are welcome.

- **Platform plugin changes**: work inside the relevant submodule, push to that submodule's repo, then update the submodule pointer here if needed.
- **Reference app or shared script changes**: edit files directly in this repository (`direct-charge-integration-reference`, `payment-integration-reference`, `payment-integration-sdk-reference`, `scripts/`, `E2E.md`).
- Run `./scripts/verify-lomi-plugins.sh` before opening a PR.

## License

Licensing is per platform. Check each submodule's README and license files (for example, Magento includes a root `LICENSE`). Reference projects in this repo follow the license stated in their respective directories.
