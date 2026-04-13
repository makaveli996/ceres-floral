# PrestaShop 8 — Quick Reference

## Caching & dev mode

- **Smarty:** Template and compile cache under `var/cache/`. Clear with `make cache-clear` after template/config changes.
- **Symfony:** Container and env cache in `var/cache/prod/` and `var/cache/dev/`. Same `make cache-clear` clears both.
- **Dev mode:** This project runs with `PS_DEV_MODE: 1` in Docker; errors and debug info are more visible. Disable in production.

## Where to change things

- **modules/** — Custom and third-party modules. Prefer new modules + hooks over core edits.
- **themes/** — Theme templates, assets, overrides. Put theme-specific JS/CSS in the active theme.
- **Overrides** — `override/` and `themes/.../modules/`. Use only when hooks are insufficient; document why and what.

## Debugging

- **Docker logs:** `make logs` (follows `web` container) or `docker compose logs -f web`.
- **PrestaShop logs:** `prestashop/var/logs/` (Symfony and app logs).
- **Cache issues:** Run `make cache-clear` after changing services, templates, or config; reload the page.
- **Admin path:** `make admin-path` prints the current admin folder (e.g. `prestashop/admin123`).
