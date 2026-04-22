{**
 * Mobile drawer search for ceres-floral.
 * Purpose: always-visible search field in the mobile menu drawer.
 *}
{assign var='mobile_search_value' value=$search_string|default:''}
{assign var='mobile_search_url' value=$link->getPageLink('search', null, null, null, false, null, true)}
<div class="mobile-drawer-search"
     aria-label="{l s='Search' d='Shop.Theme.Catalog'}"
     data-search-controller-url="{$mobile_search_url|escape:'html':'UTF-8'}">
  <form class="mobile-drawer-search__form" method="get" action="{$mobile_search_url|escape:'html':'UTF-8'}">
    <input type="hidden" name="controller" value="search">
    <input
      class="mobile-drawer-search__input"
      type="text"
      name="s"
      value="{$mobile_search_value|escape:'html':'UTF-8'}"
      placeholder="{l s='Search our catalog' d='Shop.Theme.Catalog'}"
      aria-label="{l s='Search' d='Shop.Theme.Catalog'}"
      autocomplete="off"
    >
  </form>
</div>
