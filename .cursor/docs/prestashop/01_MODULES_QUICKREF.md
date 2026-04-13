# Modules — Quick reference

## When to use this

Use when creating a new module, changing install/uninstall logic, adding a configuration page, or following module best practices. Do not modify core; implement behaviour in `modules/<yourmodule>/`.

## Module structure (PS 8)

- **Root:** `modules/<modulename>/` — folder name = technical name (lowercase, no spaces; avoid underscores for translation).
- **Main file:** `modulename.php` (same name as folder). Declares class extending `Module`, metadata, `install()`, `uninstall()`, hook methods.
- **config/** — `services.yml` (Symfony), `admin/services.yml`, `front/services.yml`, routes.
- **controllers/** — Legacy: `front/`, `admin/`.
- **src/** — Symfony-style classes (controllers, services, entities).
- **views/** — `templates/hook/`, `templates/front/`, `templates/admin/`, plus `css/`, `js/`, `img/`.
- **translations/**, **upgrade/** (scripts for version bumps). Optional: **vendor/** (Composer).

## Install / uninstall

- In `install()`: create own tables (`IF NOT EXISTS`), call `registerHook()` for every hook you use, save config with `Configuration::updateValue()`. Return `true` only if all steps succeed.
- In `uninstall()`: drop your tables (`IF EXISTS`), delete your config keys, remove hooks. Clean up so reinstalling is safe.
- Do **not** alter PrestaShop core tables. Use your own tables and Configuration keys (prefix with module name).

## Configuration

- Store settings with `Configuration::updateValue('MYMODULE_KEY', $value)` / `Configuration::get('MYMODULE_KEY')`.
- Config page: Legacy (getContent() + helpers) or **modern** (Symfony form + controller). Prefer modern for new modules.
- Prefix all config keys, DB table names, and CSS/JS IDs with your module name to avoid collisions.

## Do's and don'ts

**Do:**

- Use PrestaShop constants for paths (e.g. `_PS_CONFIG_DIR_`), develop in English and use translation system, create own DB tables, follow coding standards, prefix your assets and config.
- Restrict BO hooks (e.g. `actionBackOfficeHeader`) with `Tools::getValue('configure') === $this->name` so scripts load only on your module page.
- Put cache/temp in `var/cache/<modulename>/` or `var/modules/<modulename>/`; avoid writing in `modules/` for portability.

**Don't:**

- Edit core files or core SQL structure; use global variables; obfuscate code; use relative paths like `dirname(__FILE__).'/../../config/config.inc.php'`; use external AJAX endpoints without token protection.
- Overrides: use only when no hook/service alternative exists; document and minimise (2–3 max for distributable modules).

## Module class attributes (main file)

- Required: `$this->name`, `$this->version`, `$this->author`, `$this->tab`, `$this->displayName`.
- Useful: `$this->description`, `$this->ps_versions_compliancy = ['min' => '8.0', 'max' => '8.99.99']`, `$this->bootstrap = true`, `$this->confirmUninstall`, `$this->dependencies`.

## Common pitfalls

- Forgetting to register a hook in `install()` while implementing its method — the hook won’t run.
- Not clearing cache after changing services or config — run `make cache-clear`.
- Overriding core classes from a module: breaks other modules and upgrades; prefer hooks and Symfony service decoration.

## Minimal hook + template pattern

```php
// install
$this->registerHook('displayLeftColumn');
$this->registerHook('actionFrontControllerSetMedia');

// In main module file
public function hookDisplayLeftColumn(array $params)
{
    $this->context->smarty->assign(['my_var' => Configuration::get('MYMODULE_VAR')]);
    return $this->display(__FILE__, 'views/templates/hook/mytemplate.tpl');
}

public function hookActionFrontControllerSetMedia(array $params)
{
    $this->context->controller->registerStylesheet('mod-mymodule-css', 'modules/'.$this->name.'/views/css/style.css', ['media' => 'all']);
    $this->context->controller->registerJavascript('mod-mymodule-js', 'modules/'.$this->name.'/views/js/script.js', ['position' => 'bottom']);
}
```

Template: `views/templates/hook/mytemplate.tpl` (Smarty). Use `{l s='Text' mod='mymodule'}` for translations.

## Source links (devdocs)

https://devdocs.prestashop-project.org/8/modules/
https://devdocs.prestashop-project.org/8/modules/introduction/
https://devdocs.prestashop-project.org/8/modules/creation/
https://devdocs.prestashop-project.org/8/modules/creation/module-file-structure/
https://devdocs.prestashop-project.org/8/modules/creation/good-practices/
https://devdocs.prestashop-project.org/8/modules/creation/displaying-content-in-front-office/
https://devdocs.prestashop-project.org/8/modules/creation/adding-configuration-page-modern/
https://devdocs.prestashop-project.org/8/modules/concepts/module-class/
https://devdocs.prestashop-project.org/8/modules/concepts/overrides/
https://devdocs.prestashop-project.org/8/modules/concepts/services/
https://devdocs.prestashop-project.org/8/modules/sample-modules/
