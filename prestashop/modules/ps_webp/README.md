# ps_webp — Global WebP delivery

Serves images as WebP when the browser sends `Accept: image/webp`. Covers:

- **PrestaShop core images**: product, category, manufacturer, supplier images under `img/`
- **Module uploads**: e.g. `ps_imageslider/images/`, `ps_banner/img/`, `blockreassurance` custom icons under `modules/*/img/` or `modules/*/images/`

No theme or template changes required. Browsers that do not send `Accept: image/webp` receive the original file (Apache serves it as usual).

## How it works

1. Apache rewrites image requests (for paths under `img/` or `modules/*/img|images/`) to `modules/ps_webp/webp.php` when `Accept: image/webp` is present.
2. `webp.php` resolves the path, converts the source (JPEG/PNG/GIF) to WebP (GD or Imagick), optionally caches under `var/cache/webp/`, and outputs the WebP response.

## Requirements

- PHP with GD (preferred) or Imagick and WebP support
- Apache with `mod_rewrite` and `AllowOverride` so the included fragment is applied

## Installation

1. Install the module in Back Office → Modules → Module Manager (click **Instaluj** on the module). In the "Other" list it may appear as `ps_webp` with empty details; after installation it appears in the installed list as **Global WebP delivery**.
2. Configure quality and cache in **Configure** → **Global WebP delivery**.
3. Add the Apache fragment so WebP is actually served:
   - Open the shop root `.htaccess` (e.g. `prestashop/.htaccess`).
   - Right after `RewriteEngine on` (and the `RewriteRule . - [E=REWRITEBASE:...]` line), add:
     ```apache
     IncludeOptional /absolute/path/to/prestashop/modules/ps_webp/config/htaccess-webp.conf
     ```
   - Use the exact path shown in the module’s **Apache configuration** panel.

If PrestaShop regenerates `.htaccess`, re-add this `IncludeOptional` line.

## Configuration

- **Enable WebP delivery**: turn the module logic on/off (Apache still needs the Include).
- **WebP quality**: 1–100 (default 82).
- **Cache converted WebP files**: when enabled, converted images are stored under `var/cache/webp/` for faster subsequent responses.

Settings are stored in the database and written to `config/webp_config.json` for use by the standalone `webp.php` script.
