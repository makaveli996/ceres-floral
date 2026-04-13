# Symfony Back Office — Quick reference

## When to use this

Use when adding or changing Back Office features in PrestaShop 8: admin controllers, routes, services, forms, or security. The BO is a mix of Legacy and Symfony; new features should use Symfony (controllers, services, Twig).

## Concepts

- **Symfony** is used for modern BO pages: controllers extend `FrameworkBundleAdminController`, routes live in YAML, views in Twig, services in the container.
- **Legacy** BO still exists; module legacy controllers go in `controllers/admin/`. Prefer Symfony for new code.
- **Module routes** are prefixed by default with `/modules` (e.g. `/admin-dev/modules/your-module/demo`). Can be disabled with `_disable_module_prefix: true`.

## Controllers

- Class in `src/Controller/` (or similar), namespace and PSR-4 autoload via Composer.
- Extend `PrestaShopBundle\Controller\Admin\FrameworkBundleAdminController`.
- Return a `Response` (e.g. `$this->render(...)` or `JsonResponse`).

```php
namespace MyModule\Controller;

use PrestaShopBundle\Controller\Admin\FrameworkBundleAdminController;

class DemoController extends FrameworkBundleAdminController
{
    public function demoAction()
    {
        $svc = $this->get('your_module.your_service');
        return $this->render('@Modules/yourmodule/templates/admin/demo.html.twig', ['data' => $svc->getData()]);
    }
}
```

- For DI: declare controller as a service in `config/services.yml` with the full class name; use `arguments` for dependencies. Or use `$this->get('service_id')` / `$this->container->get(...)`.

## Routing

- File: `config/routes.yml` (or imported from it).

```yaml
your_route_name:
    path: your-module/demo
    methods: [GET]
    defaults:
      _controller: 'MyModule\Controller\DemoController::demoAction'
```

- Use **double colon** `::` between class and method. Path is relative to module prefix (e.g. `/admin-dev/modules/your-module/demo`).
- Generate URL from main module class: get router from `SymfonyContainer::getInstance()->get('router')`, then `$router->generate('your_route_name')`. Include token for security.

## Security

- Use `@AdminSecurity` and routing config for permissions. See devdocs “Controller Security” and migration-guide (controller-routing).

## Services

- Declare in `config/services.yml` (and optionally `config/admin/services.yml`, `config/front/services.yml` for context-specific).
- **Override core:** replace a service by re-declaring it with the same name, or **decorate** with `decorates: original_service_id`. The original becomes `your_service.inner`. Prefer decoration over full override to keep compatibility.
- **Front/Legacy:** services in `config/front/services.yml` are available in FO and legacy BO via the light container; access with `$this->get('your_module.front.your_service')` in ModuleFrontController or hook (front context).

## Forms and grids

- Use Symfony Form and PrestaShop form hooks (e.g. `actionFormNameFormBuilderModifier`) to add fields to BO forms.
- Grids: hooks like `actionDefinitionIdGridDefinitionModifier`, `actionDefinitionIdGridQueryBuilderModifier`, etc.

## Do's and don'ts

**Do:** Use Symfony controllers and Twig for new BO pages; declare routes in YAML; use services and avoid modifying core; secure controllers with permissions.

**Don’t:** Rely on Legacy-only patterns for new features; forget to run `make cache-clear` after changing services or routes; use single colon in `_controller` (use `::`).

## Pitfalls

- Changing `services.yml` or routes without clearing cache — container and route cache are under `var/cache/`; run `make cache-clear`.
- Service name in 8.1+ may be FQCN; override with same FQCN as key if needed.
- Legacy BO pages don’t have the full Symfony container; use `config/admin/services.yml` for services needed there.

## Source links (devdocs)

https://devdocs.prestashop-project.org/8/modules/concepts/symfony/
https://devdocs.prestashop-project.org/8/modules/concepts/controllers/
https://devdocs.prestashop-project.org/8/modules/concepts/controllers/admin-controllers/
https://devdocs.prestashop-project.org/8/modules/concepts/services/
https://devdocs.prestashop-project.org/8/modules/concepts/forms/
https://devdocs.prestashop-project.org/8/development/architecture/
https://devdocs.prestashop-project.org/8/development/architecture/modern/
https://devdocs.prestashop-project.org/8/development/architecture/migration-guide/
https://devdocs.prestashop-project.org/8/development/architecture/migration-guide/controller-routing/
https://devdocs.prestashop-project.org/8/modules/creation/adding-configuration-page-modern/
