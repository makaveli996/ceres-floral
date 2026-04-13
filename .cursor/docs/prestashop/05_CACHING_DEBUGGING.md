# Caching & debugging — Quick reference

## When to use this

Use when templates or config don’t update, services/routes don’t apply, or you need to trace errors. Aligns with project rule: always consider Symfony + Smarty cache and suggest `make cache-clear` when relevant.

## Cache locations and what they affect

- **Class index (overrides):** `prestashop/var/cache/<env>/class_index.php` — maps class names to files. If you add overrides or new classes and they’re not found, clear cache (or delete this file). Safe to delete for a full class-map rebuild.
- **Symfony:** `prestashop/var/cache/prod/` and `prestashop/var/cache/dev/` — container, routes, config. After changing `services.yml`, routes, or DI, clear cache.
- **Smarty:**  
  - `prestashop/var/cache/<env>/smarty/compile` — compiled templates.  
  - `prestashop/var/cache/<env>/smarty/cache` — template output cache.  
  If the front office doesn’t reflect template changes, clear these (or run a full cache clear).
- **Legacy:** `prestashop/cache/` may still be used in some flows; clearing `var/cache` is usually enough. This project’s `make cache-clear` removes `prestashop/var/cache/*`; use `make cache-clear-hard` to also clear legacy `cache/` if needed.

## Clearing cache (this repo)

- **appParameters.php missing (fatal on page load):** Run **`make fix-cache`**. It runs `make perms-cache` then `php bin/console cache:clear` in the container to regenerate `var/cache/dev/appParameters.php` and prod cache.
- **Recommended:** `make cache-clear` (Symfony cache:clear for prod + dev). Run after config/template/service changes.
- **Hard:** `make cache-clear-hard` (wipes var/cache and legacy cache/, then runs cache:clear).
- **BO:** Advanced Parameters > Performance: Smarty “Template cache” and “Cache” can be disabled for development (do not leave disabled in production).
- **CLI (from PrestaShop root):** `php bin/console cache:clear` if you run commands inside the container.

## Dev mode

- This project uses `PS_DEV_MODE: 1` in Docker. More errors and debug info are shown. **Disable in production.**
- With dev mode, Symfony uses `var/cache/dev/`; still clear cache after service/route/template changes.

## Debugging

- **Docker:** `make logs` (or `docker compose logs -f web`) for web container logs.
- **PrestaShop logs:** `prestashop/var/logs/` (Symfony and application logs).
- **Admin path:** `make admin-path` prints the current admin folder (e.g. `prestashop/admin123`) for correct BO URL.
- **Smarty:** In Performance, enabling “Debug console” can help (dev only). In template, `{debug}` dumps all variables; `{dump($var)}` dumps one. Remove before production.
- **404 or old route:** Clear cache so route and container are rebuilt.
- **Service not found / wrong class:** Clear cache; check service id and that the defining YAML is loaded (e.g. `config/services.yml` or admin/front variants).

## Do's and don'ts

**Do:** Run `make cache-clear` after changing config, services, routes, or templates; use dev mode only locally; check `var/logs/` and container logs when something fails.

**Don’t:** Disable cache or enable Smarty debug on production (performance and security); assume changes are visible without clearing cache when you touched container or templates.

## Overrides and cache

- Class overrides are registered in the class index. After adding/removing overrides, clear cache so the new class map is used.
- Theme overrides (templates): Smarty compile/cache may still serve old output; clear cache and reload.

## Module list (BO) still wrong?

The Module Manager can use **Symfony cache** for module paths/metadata. If an uninstalled module shows the technical name (e.g. `ps_webp`) and empty author/version/description:

1. Run **`make cache-clear`**, then **`make cache-clear-symfony`** (containers must be up).
2. **Browser:** hard refresh (Ctrl+F5) or try an incognito window (module list can be cached by the browser).
3. **Install the module** once; after installation the list reads from the live `Module` instance and usually shows the correct display name.
4. Check **`prestashop/var/logs/`** (or container logs) when opening the Module Manager; a PHP error while loading the module can prevent metadata from being read.

There is no separate JSON or DB table for “uninstalled module list”; it is built from the filesystem and cached by Symfony.

## Summary

| After changing…           | Action                    |
|---------------------------|---------------------------|
| services.yml / routes     | `make cache-clear`        |
| Smarty templates / theme  | `make cache-clear`        |
| Overrides / new classes   | `make cache-clear`        |
| Config (parameters, etc.)  | `make cache-clear`        |
| Module list / metadata    | `make cache-clear-symfony`|

## Source links (devdocs)

https://devdocs.prestashop-project.org/8/development/architecture/
https://devdocs.prestashop-project.org/8/development/architecture/cache/
https://devdocs.prestashop-project.org/8/development/architecture/file-structure/
https://devdocs.prestashop-project.org/8/modules/creation/displaying-content-in-front-office/ (Smarty cache note)
https://devdocs.prestashop-project.org/8/modules/concepts/overrides/ (cache after overrides)
https://devdocs.prestashop-project.org/8/basics/
https://devdocs.prestashop-project.org/8/themes/getting-started/
