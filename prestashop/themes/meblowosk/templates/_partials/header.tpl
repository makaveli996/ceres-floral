{**
 * Theme header: banner, then main overlay block (logo, search, utils, primary nav).
 * Data: logo from shop, displayNav1/Nav2 (contact, lang, currency, signin, cart), displayTop (stickybar, menu, search).
 * Used by: layout-both-columns.tpl. Styling: _dev/css/custom/components/_header.scss.
 *}
{block name='header_banner'}
  <div class="header-banner">
    {hook h='displayBanner'}
  </div>
{/block}

{block name='header_main'}
  <div class="header-main">
    {* Mobile only: displayTop so sticky bar is visible; menu/search hidden via CSS *}
    <div class="header-main__top-mobile hidden-lg-up">
      {hook h='displayTop'}
    </div>
    <div class="container-lg-right">
      {* Desktop: one row = logo | displayTop (stickybar, menu, search) | utils; second row = menu via CSS grid; hidden below 992px *}
      <div class="header-main__row header-main__row--desktop hidden-md-down">
        <div class="header-main__logo" id="_desktop_logo">
          {if $shop.logo_details}
            {if $page.page_name == 'index'}
              <h1 class="header-main__logo-title">
                {renderLogo}
              </h1>
            {else}
              {renderLogo}
            {/if}
          {/if}
        </div>
        <div class="header-main__center">
          {hook h='displayTop'}
        </div>
        <div class="header-main__utils">
          {hook h='displayNav1'}
          {hook h='displayNav2'}
        </div>
      </div>
      {* Mobile: classic top bar (menu icon, cart, user, logo); visible below 992px *}
      <div class="header-main__row header-main__row--mobile hidden-lg-up text-sm-center mobile">
        <div class="float-xs-left" id="menu-icon">
          <i class="material-icons d-inline">&#xE5D2;</i>
        </div>
        <div class="float-xs-right" id="_mobile_cart"></div>
        <div class="float-xs-right" id="_mobile_user_info"></div>
        <div class="top-logo" id="_mobile_logo"></div>
        <div class="clearfix"></div>
      </div>
    </div>
    {* Mobile dropdown menu (drawer) *}
    <div id="mobile_top_menu_wrapper" class="hidden-lg-up" style="display:none;">
      <div class="js-top-menu mobile" id="_mobile_top_menu"></div>
      <div class="js-top-menu-bottom">
        <div id="_mobile_currency_selector"></div>
        <div id="_mobile_language_selector"></div>
        <div id="_mobile_contact_link"></div>
      </div>
      <div id="mobile_drawer_search" class="mobile-drawer-search" aria-label="{l s='Search' d='Shop.Theme.Catalog'}"></div>
    </div>
  </div>
  {* displayTop jest wywołany 2× (top-mobile + center), więc w DOM są 2× #search_widget.
     Moduł ps_searchbar wiąże autocomplete tylko z pierwszym; na desktopie pierwszy jest ukryty.
     Zamieniamy id tak, by #search_widget był widoczny: na desktopie = ten w center. *}
  <script>
  (function() {
    var widgets = document.querySelectorAll('#search_widget');
    if (widgets.length < 2) return;
    var desktop = window.matchMedia('(min-width: 992px)').matches;
    if (desktop) {
      widgets[0].id = 'search_widget_placeholder';
    } else {
      widgets[1].id = 'search_widget_desktop';
    }
  })();
  </script>
  {hook h='displayNavFullWidth'}
{/block}
