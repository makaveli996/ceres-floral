{**
 * Header for ceres-floral — two-bar layout matching Figma.
 * header-bar (dark green, 154px): contact left, logo center, action icons right.
 * header-nav (cream, 80px): full-width main menu only (displayTop → ps_mainmenu).
 * Both bars wrapped in .container-md. Mobile: hamburger + drawer.
 * Hooks: displayNav1 (hours/phone/email), displayNav2 (user/wishlist/cart),
 *         displayTop (ps_mainmenu), displayNavFullWidth (extra modules).
 *}

{block name='header_banner'}
  {hook h='displayBanner'}
{/block}

{* TOP BAR — dark green, desktop only *}
{block name='header_bar'}
  <div class="header-bar desktop">
    <div class="container-md">
      <div class="header-bar__inner">

        {* ── Left: contact info ── *}
        <div class="header-bar__contact" id="_desktop_contact_info">
          {**
           * Configure: displayNav1
           * Recommended: ps_contactinfo or custom tc_* module.
           * Renders: opening hours, phone number, e-mail address.
           *}
          {hook h='displayNav1'}
        </div>

        {* ── Center: logo ── *}
        <div class="header-bar__logo" id="_desktop_logo">
          {if $shop.logo_details}
            {if $page.page_name == 'index'}
              <h1 class="header-bar__logo-title">{renderLogo}</h1>
            {else}
              {renderLogo}
            {/if}
          {/if}
        </div>

        {* ── Right: action icons ── *}
        <div class="header-bar__actions" id="_desktop_actions">
          <div class="header-bar__search" id="_desktop_search_widget">
            {hook h='displaySearch'}
          </div>
          <div class="header-bar__wishlist" id="_desktop_wishlist">
            {hook h='displayCustomerAccount' mod='blockwishlist'}
          </div>
          {**
           * Configure: displayNav2
           * Recommended: ps_customersignin, blockwishlist, ps_shoppingcart.
           * Each styled as a 46 px circle icon (see _header.scss).
           *}
          {hook h='displayNav2'}
        </div>

      </div>
    </div>
  </div>
{/block}

{* NAV BAR — cream, full-width menu *}
{block name='header_nav'}
  <div class="header-nav">
    <div class="container-md">

      {* ── Desktop: menu spans full width ── *}
      <div class="header-nav__inner desktop">
        <nav class="header-nav__menu"
             aria-label="{l s='Main navigation' d='Shop.Theme.Global'}">
          {**
           * Render nested menu module in this exact spot (as in meblowosk).
           * This avoids rendering other displayTop modules inside header-nav__menu.
           *}
          {hook h='displayTop' mod='tc_nestedmenu'}
        </nav>
      </div>

      {* ── Mobile row: hamburger | logo | cart ── *}
      <div class="header-nav__mobile mobile">

        <button class="header-nav__hamburger js-mobile-menu-open"
                aria-label="{l s='Open navigation menu' d='Shop.Theme.Global'}"
                aria-expanded="false"
                aria-controls="mobile_top_menu_wrapper">
          <span class="header-nav__hamburger-bar"></span>
          <span class="header-nav__hamburger-bar"></span>
          <span class="header-nav__hamburger-bar"></span>
        </button>

        <div class="header-nav__mobile-logo top-logo" id="_mobile_logo"></div>

        <div class="header-nav__mobile-actions">
          <div id="_mobile_user_info"></div>
          <div id="_mobile_cart"></div>
        </div>

      </div>

    </div>

    {* ── Mobile drawer ── *}
    <div id="mobile_top_menu_wrapper"
         class="mobile-drawer"
         aria-hidden="true"
         style="display:none;">
      <div class="mobile-drawer__scroll">
        <div class="js-top-menu mobile" id="_mobile_top_menu"></div>
        <div class="js-top-menu-bottom">
          <div id="_mobile_currency_selector"></div>
          <div id="_mobile_language_selector"></div>
          <div id="_mobile_contact_link"></div>
        </div>
      </div>
    </div>

  </div>

  {hook h='displayNavFullWidth'}
{/block}
