# Theme, Smarty & assets — Quick reference

## When to use this

Use when working on the front office theme: Smarty templates (`.tpl`), template inheritance, registering or unregistering CSS/JS, or adding assets per page. Applies to both theme files and module views that render in the FO.

## Smarty (FO templates)

- Front office uses **Smarty** (`.tpl`). Variables are set in PHP with `$this->context->smarty->assign('key', $value)` (or in controllers). In template: `{$key}`, `{if}...{/if}`, `{l s='Text' mod='mymodule'}` for translation.
- **Template inheritance:** `{extends file='page.tpl'}` and `{block name='page_content'}...{/block}`. Override blocks from parent instead of copying full layout.
- **Hooks in templates:** `{hook h='displayLeftColumn'}`. Optional: `mod='mymodule'` (only that module), `excl='module1,module2'` (exclude).
- Prefix your Smarty variables (e.g. `mymodule_products`) to avoid clashing with core/other modules. See devdocs “Global variables for templates”.

## Where templates live

- **Theme:** `themes/<theme>/templates/`, with overrides in `themes/<theme>/templates/` mirroring core structure. Child themes inherit from parent.
- **Module (hook):** `modules/<modulename>/views/templates/hook/`. Called via `$this->display(__FILE__, 'views/templates/hook/name.tpl')`.
- **Module (front controller):** `views/templates/front/`. Set in controller with `$this->setTemplate('module:mymodule/views/templates/front/display.tpl')`.
- **Module (BO):** `views/templates/admin/` (Smarty or Twig for modern BO).

## Asset registration (CSS / JS)

- **Preferred:** `registerStylesheet()` and `registerJavascript()` with a unique **id**, path, and options (priority, position, media, async/defer, etc.). Path from theme root or `modules/modulename/...` for modules.
- **Theme:** In `theme.yml`, under `assets.css` and `assets.js`, list assets per page (e.g. `all`, `product`, `index`). Page keys match controller `php_self`.
- **Module (no front controller):** Use hook `actionFrontControllerSetMedia` and call `$this->context->controller->registerStylesheet()` / `registerJavascript()` there. Restrict by controller if needed: `if ($this->context->controller->php_self === 'product') { ... }`.
- **Module (front controller):** Override `setMedia()` and call `$this->registerStylesheet()` / `$this->registerJavascript()` after `parent::setMedia()`.

Options (short): **priority** (0 = highest), **position** (head | bottom for JS), **media** (all, screen, …), **attributes** (async, defer), **server** (local | remote). Avoid generic IDs; prefix with theme or module name.

## Unregistering assets

- By **id**: `$this->context->controller->unregisterJavascript('id')` or `unregisterStylesheet('id')`. In theme, overriding with an empty file at the same path can effectively “remove” a module asset.

## Core assets loaded by default

- theme.css (theme-main), custom.css (theme-custom), core.js (corejs), theme.js (theme-main), custom.js (theme-custom). RTL: rtl.css when applicable. See devdocs “Asset management” for IDs and priorities.

## Do's and don'ts

**Do:** Use theme.yml for theme-wide assets; use `registerStylesheet`/`registerJavascript` in modules; prefix variable and asset IDs; use `{l s='...' mod='mymodule'}` in module templates; extend parent template and override blocks.

**Don’t:** Put theme-only CSS/JS inside a module (keep in theme files); modify core theme files — use theme overrides or child theme; forget cache: after template/asset changes run `make cache-clear` and refresh.

## Pitfalls

- Smarty cache: if template changes don’t show, clear `var/cache/` (e.g. `make cache-clear`) and/or disable Smarty cache in Performance (dev only).
- Wrong path: module assets must be relative to shop root, e.g. `modules/mymodule/views/css/file.css`.
- Overriding a module template from theme: place file in `themes/<theme>/modules/<modulename>/views/...` (see “Overriding modules” in theme reference).

## Source links (devdocs)

https://devdocs.prestashop-project.org/8/themes/
https://devdocs.prestashop-project.org/8/themes/getting-started/
https://devdocs.prestashop-project.org/8/themes/getting-started/asset-management/
https://devdocs.prestashop-project.org/8/themes/getting-started/theme-yml/
https://devdocs.prestashop-project.org/8/themes/reference/
https://devdocs.prestashop-project.org/8/themes/reference/templates/
https://devdocs.prestashop-project.org/8/themes/reference/template-inheritance/
https://devdocs.prestashop-project.org/8/themes/reference/templates/variables/
https://devdocs.prestashop-project.org/8/themes/reference/templates/head/
https://devdocs.prestashop-project.org/8/themes/reference/overriding-modules/
https://devdocs.prestashop-project.org/8/themes/reference/smarty-helpers/
https://devdocs.prestashop-project.org/8/modules/concepts/templating/
https://devdocs.prestashop-project.org/8/modules/creation/displaying-content-in-front-office/
