{**
 * Copyright since 2007 PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License 3.0 (AFL-3.0)
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to https://devdocs.prestashop.com/ for more information.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright Since 2007 PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 *}
<div id="_desktop_cart">
  <div class="blockcart cart-preview {if $cart.products_count > 0}active{else}inactive{/if}" data-refresh-url="{$refresh_url}">
    {if $cart.products_count > 0}
      <a rel="nofollow" aria-label="{l s='Shopping cart link containing %nbProducts% product(s)' sprintf=['%nbProducts%' => $cart.products_count] d='Shop.Theme.Checkout'}" href="{$cart_url}">
    {/if}
      <div class="header">
          <svg width="19" height="20" viewBox="0 0 19 20" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M5.61811 16.0518C6.50462 16.0518 7.22329 16.7704 7.2233 17.6569C7.2233 18.5435 6.50462 19.2621 5.61811 19.2621C4.7316 19.2621 4.01296 18.5435 4.01296 17.6569C4.01296 16.7704 4.7316 16.0518 5.61811 16.0518Z" fill="white"/>
            <path d="M13.644 16.0518C14.5305 16.0518 15.2492 16.7704 15.2492 17.6569C15.2492 18.5434 14.5305 19.2621 13.644 19.2621C12.7575 19.2621 12.0388 18.5435 12.0388 17.6569C12.0388 16.7704 12.7575 16.0518 13.644 16.0518Z" fill="white"/>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M0.980763 0C1.57037 0.000274336 2.13939 0.216871 2.57993 0.608738C3.02046 1.0006 3.30187 1.5405 3.37086 2.12605L3.40458 2.40777H16.3808C16.7335 2.40734 17.0819 2.48455 17.4013 2.63393C17.7208 2.78332 18.0034 3.00122 18.2292 3.27214C18.4554 3.54235 18.6193 3.85902 18.7095 4.19967C18.7996 4.5403 18.8138 4.89662 18.7509 5.24333L18.1208 8.73778C17.9539 9.66372 17.467 10.5016 16.7451 11.105C16.0231 11.7084 15.1122 12.0389 14.1713 12.0388H4.60446C4.77005 12.5072 5.07642 12.9129 5.48162 13.2002C5.88682 13.4876 6.37101 13.6426 6.86777 13.644H15.2492C15.462 13.644 15.6662 13.7286 15.8167 13.8791C15.9672 14.0296 16.0518 14.2337 16.0518 14.4466C16.0518 14.6595 15.9672 14.8636 15.8167 15.0141C15.6662 15.1646 15.462 15.2492 15.2492 15.2492H6.86777C5.88448 15.2492 4.93537 14.8882 4.20066 14.2347C3.46596 13.5812 2.99677 12.6807 2.88211 11.7042L1.77772 2.31386C1.75472 2.11863 1.66087 1.93862 1.51397 1.80799C1.36707 1.67737 1.17734 1.60522 0.980763 1.60519H0.802576C0.589721 1.60519 0.385572 1.5206 0.23506 1.37009C0.084553 1.21958 0 1.01543 0 0.802576C3.24964e-06 0.589721 0.0845482 0.385572 0.23506 0.23506C0.385572 0.0845482 0.589721 3.24955e-06 0.802576 0H0.980763ZM4.34923 10.4336H14.1713C14.7365 10.4345 15.2839 10.2365 15.7178 9.87439C16.1517 9.51226 16.4444 9.00905 16.5446 8.45286L17.1754 4.95838C17.1964 4.84236 17.1916 4.72314 17.1612 4.6092C17.1309 4.49527 17.0759 4.38941 17 4.29916C16.9242 4.2089 16.8294 4.13645 16.7224 4.08699C16.6153 4.03752 16.4987 4.01225 16.3808 4.01296H3.59398L4.34923 10.4336Z" fill="white"/>
          </svg>
          <span class="cart-products-count">{$cart.products_count}</span>
      </div>
    {if $cart.products_count > 0}
      </a>
    {/if}
  </div>
</div>
