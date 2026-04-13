# PrestaShop 8 — Documentation pack overview

## When to use this

Use this pack when working on PrestaShop 8 in this repo: building or changing modules, hooks, Back Office (Symfony), themes, or debugging. It summarises devdocs so AI and developers can follow patterns without copying core.

## Project rules (from this repo)

- **Do not modify PrestaShop core.** Use modules, hooks, and Symfony services.
- **Overrides** only when unavoidable; document why. Prefer service decoration over class overrides.
- **Cache:** Symfony container + Smarty both cache; run `make cache-clear` after config/template/service changes.
- **Makefile:** Prefer `make init`, `make up`, `make down`, `make perms`, `make cache-clear`, `make admin-path`, etc.

## Files in this pack

| File | Use when |
|------|----------|
| **01_MODULES_QUICKREF.md** | Creating or editing a module (structure, install/uninstall, config, best practices). |
| **02_HOOKS_QUICKREF.md** | Registering hooks, implementing hook methods, calling hooks from templates or controllers. |
| **03_SYMFONY_BO_QUICKREF.md** | Back Office: Symfony controllers, routing, services, security. |
| **04_THEME_SMARTY_ASSETS.md** | Theme/front: Smarty templates, asset registration, media (CSS/JS). |
| **05_CACHING_DEBUGGING.md** | Cache locations, dev mode, debugging, common pitfalls. |
| **06_WYSIWYG_FIELDS.md** | Rich text in BO: single key (3rd param `true`) vs repeater/JSON (entity-encode, 2 params, decode on read); form, FO; **Why: PrestaShop behaviour** (strip_tags vs purifyHTML). |
| **07_REPEATER_IN_MODULES.md** | Repeater in BO (list of items): JSON storage, form, POST, JS add/remove/reorder. Reference: tc_collections. |

## Key concepts

- **Modules** live in `modules/<modulename>/`. Main file: `modulename.php`; optional `config/`, `src/`, `views/`, `controllers/`.
- **Hooks** = event/display points. Register in `install()`, implement `hookDisplayX()` / `hookActionX()`, call via `Hook::exec()` or `{hook h='name'}`.
- **Back Office** mixes Legacy and Symfony. New features: Symfony controllers + services + Twig; routes in `config/routes.yml`.
- **Themes** use Smarty (`.tpl`), `theme.yml` for assets, template inheritance. FO still mostly Smarty; some Twig in BO.
- **Overrides** (classes/controllers) are exclusive and fragile; prefer hooks and service decoration.

## Source

Curated from PrestaShop 8 Developer Documentation:

https://devdocs.prestashop-project.org/8/
https://devdocs.prestashop-project.org/8/basics/
https://devdocs.prestashop-project.org/8/modules/
https://devdocs.prestashop-project.org/8/modules/introduction/
https://devdocs.prestashop-project.org/8/modules/concepts/
https://devdocs.prestashop-project.org/8/themes/
https://devdocs.prestashop-project.org/8/development/
https://devdocs.prestashop-project.org/8/development/architecture/
https://devdocs.prestashop-project.org/8/development/architecture/introduction/
https://devdocs.prestashop-project.org/8/development/architecture/legacy/
https://devdocs.prestashop-project.org/8/development/architecture/modern/
