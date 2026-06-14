# lomi. Plugins Monorepo

Welcome to the central repository for **lomi.** payment plugins.

This repository serves as the entry point for all e-commerce integrations (WooCommerce, PrestaShop, Magento, Shopify, etc.) that enable secure payments via the lomi. API.

## Supported Platforms

The plugins are organized as Git submodules. Each directory corresponds to a specific integration:

- **[WooCommerce](./woo)**: Payment plugin for WordPress/WooCommerce stores.
- **[PrestaShop](./prestashop)**: Official payment module for PrestaShop.
- **[Magento](./magento)**: Integration for Adobe Commerce (Magento 2).
- **[Shopify](./shopify)**: Shopify payment application.
- **[Odoo](./odoo)**: Payment module for the Odoo ERP.
- **[Bubble](./bubble)**: Integration for Bubble no-code applications.

## Installation and Cloning

Because this repository uses submodules for each integration, ensure you use the `--recursive` flag when cloning to fetch the source code for all available platforms.

```bash
git clone --recursive https://github.com/lomiafrica/plugins-lomiafrica.git
```

If you have already cloned the repository without the recursive flag, you can initialize the submodules with:

```bash
git submodule update --init --recursive
```

*(Note: If you encounter a "repository not found" error on certain submodules, those specific repositories might currently be private or under development.)*

## End-to-End (E2E) Tests and Scripts

This repository also includes shared scripts to ensure the quality and compliance of the plugins:

- **`E2E.md`**: Contains the matrix and checklist for manual or automated tests to validate payment behaviors, webhooks, and cart recovery across platforms.
- **`scripts/verify-lomi-plugins.sh`**: A Bash script acting as a static gate to validate the codebase compliance of the different plugins (endpoint verification, legacy brand reference checks, XOF currency handling, etc.).
- **`scripts/scan_broken_images.py`**: A Python script that scans the plugin directories to detect dead or broken image links.

To run the static verification checks, execute:

```bash
./scripts/verify-lomi-plugins.sh
```

## Contributing

Contributions, bug reports, and Pull Requests are welcome.
- For platform-specific modifications, please navigate to the corresponding submodule directory and apply your changes there.
- Ensure that all verification scripts in the `./scripts` directory pass before submitting a Pull Request.

## License

Please review the `LICENSE` file within each submodule for platform-specific licensing information (for example, GPL-2.0+ for WooCommerce).
