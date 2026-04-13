# Hooks — Quick reference

## When to use this

Use when a module must react to an event (action hook) or inject content at a position (display hook). Prefer hooks over overrides. You need to register hooks in `install()` and implement the corresponding methods.

## Hook types

- **display** — Inject content (e.g. header, footer, columns). Names often start with `display` (e.g. `displayHeader`, `displayLeftColumn`).
- **action** — React to events (e.g. order created, product save). Names often start with `action` (e.g. `actionOrderConfirmation`).

One hook = one extension point. Many modules can register to the same hook; execution order is configurable in Back Office > Design > Positions.

## Registration

Register every hook you use in `install()`:

```php
public function install()
{
    return parent::install()
        && $this->registerHook('displayHeader')
        && $this->registerHook('displayFooter')
        && $this->registerHook('actionFrontControllerSetMedia');
}
```

If the hook name does not exist in the DB, PrestaShop can create it when you register (but prefer using existing hooks from the list).

## Implementing hook methods

- Method name = `hook` + HookName (e.g. `displayHeader` → `hookDisplayHeader`).
- Single argument: `array $params` (context data; contents depend on the hook).
- Return: for **display** hooks, return a string (HTML or rendered template); for **action** hooks, return is often ignored.

```php
public function hookDisplayHeader(array $params)
{
    $this->context->smarty->assign('my_var', 'value');
    return $this->display(__FILE__, 'views/templates/hook/header.tpl');
}

public function hookActionOrderConfirmation(array $params)
{
    $order = $params['order'] ?? null;
    // side effects only, e.g. send mail, log
}
```

## Calling hooks

**In PHP (Legacy controller):**

```php
$this->context->smarty->assign('HOOK_LEFT_COLUMN', Hook::exec('displayLeftColumn'));
```

**In Symfony controller:**

```php
$this->dispatchHook($hookName, $parameters);
```

**In Smarty template:**

```smarty
{hook h='displayLeftColumn'}
{hook h='displayFooter' mod='mymodule'}
{hook h='displayFooter' excl='othermodule'}
```

**In Twig (modern FO/BO):**

```twig
{{ renderHook('displayLeftColumn', { params }) }}
```

## Frequently used hooks (examples)

- **displayHeader** — Head: meta, CSS. Use **actionFrontControllerSetMedia** to register CSS/JS.
- **displayFooter**, **displayLeftColumn**, **displayRightColumn** — Layout blocks.
- **displayHome**, **displayProductAdditionalInfo** — Page-specific.
- **actionFrontControllerSetMedia** — Register stylesheets and JavaScript (no HTML output).
- **actionOrderConfirmation**, **actionProductSave** — Events for side effects or integration.

Full list (many BO/FO): devdocs “List of hooks”. Search by name or by “display” / “action”.

## Creating a custom hook (theme or module)

- **Theme:** declare in `theme.yml` under `global_settings.hooks.custom_hooks` (name, title, description).
- **Module:** create record in `Hook` table or use `Hook::register('DisplayMyPlace')` and call `Hook::exec('DisplayMyPlace')` where the content should appear.

Registering makes the hook visible in Design > Positions so merchants can transplant modules.

## Do's and don'ts

**Do:** Register each hook in `install()` and unregister/clean in `uninstall()`; use existing hooks when they fit; return HTML only from display hooks; use `actionFrontControllerSetMedia` for assets.

**Don’t:** Rely on a hook without registering it; modify core just to add a hook (prefer contributing a new hook to core); assume hook order — use Positions or priority if order matters.

## Pitfalls

- Implementing `hookDisplayX` but never calling `registerHook('displayX')` in `install()` — hook will not run.
- After adding/changing hooks, clear cache: `make cache-clear`.
- In BO, restrict asset hooks to your module page: `if (Tools::getValue('configure') === $this->name) { ... }`.

## Source links (devdocs)

https://devdocs.prestashop-project.org/8/development/components/hook/
https://devdocs.prestashop-project.org/8/modules/concepts/hooks/
https://devdocs.prestashop-project.org/8/modules/concepts/hooks/list-of-hooks/
https://devdocs.prestashop-project.org/8/modules/concepts/hooks/use-hooks-on-modern-pages/
https://devdocs.prestashop-project.org/8/themes/reference/hooks/
https://devdocs.prestashop-project.org/8/development/components/hook/dispatching-hook/
https://devdocs.prestashop-project.org/8/development/components/hook/subscribing-to-hook/
https://devdocs.prestashop-project.org/8/development/components/hook/register-new-hook/
https://devdocs.prestashop-project.org/8/development/components/hook/symfony-bridge/
