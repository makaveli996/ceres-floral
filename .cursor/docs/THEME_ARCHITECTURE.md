# Theme build architecture (meblowosk)

## Layout

- **Source (only place to edit SCSS/JS):** `_dev/`
  - `_dev/css/` – SCSS (theme.scss, base/, components/, pages/, sections/, utils/)
  - `_dev/js/` – JS (theme.js, Components/, Sections/)
  - Design system: use tokens and mixins from `_dev/css/base/` and `_dev/css/utils/`; do not add one-off styles in templates.
- **Build tooling:** repo root – `package.json`, `webpack.config.js`, `bs-config.js`
- **Dependencies:** repo root – `node_modules/` (not versioned)
- **Compiled output:** `prestashop/themes/meblowosk/assets/` (css/, js/, img/ as needed)
- **PrestaShop theme:** `prestashop/themes/meblowosk/` (config/, templates/, assets/) – portable; no _dev or node_modules.

## Commands (run from repo root)

- `npm run build` – production build → theme assets
- `npm run watch` – watch _dev + rebuild + clear PS cache on change
- `npm run serve` – BrowserSync proxy to shop (use DOMAIN:WEB_PORT from .env)
- `make theme-build` / `make theme-watch` – same via Makefile

## Excluded from repo / indexing

- `node_modules/` – .gitignore + .cursorignore
- `dist/`, `build/` – .gitignore + .cursorignore
