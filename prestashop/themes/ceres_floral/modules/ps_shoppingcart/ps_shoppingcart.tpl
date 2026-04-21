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
    <div class="header">
      {if $cart.products_count > 0}
        <a rel="nofollow" aria-label="{l s='Shopping cart link containing %nbProducts% product(s)' sprintf=['%nbProducts%' => $cart.products_count] d='Shop.Theme.Checkout'}" href="{$cart_url}">
      {/if}
        <svg width="23" height="24" viewBox="0 0 23 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M6.87707 19.6488C7.96224 19.6488 8.84196 20.5285 8.84196 21.6137C8.84196 22.6988 7.96224 23.5786 6.87707 23.5786C5.7919 23.5786 4.91222 22.6988 4.91222 21.6137C4.91223 20.5285 5.79191 19.6488 6.87707 19.6488Z" fill="#414F42"/>
          <path d="M16.7015 19.6488C17.7867 19.6488 18.6663 20.5285 18.6664 21.6137C18.6664 22.6988 17.7867 23.5786 16.7015 23.5786C15.6163 23.5786 14.7366 22.6988 14.7366 21.6137C14.7366 20.5285 15.6163 19.6488 16.7015 19.6488Z" fill="#414F42"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M1.20054 0C1.92227 0.000335812 2.61881 0.265469 3.15806 0.74515C3.69731 1.22483 4.04179 1.88571 4.12623 2.60247L4.16752 2.94732H20.0516C20.4833 2.94679 20.9098 3.04131 21.3008 3.22417C21.6918 3.40704 22.0378 3.67376 22.3142 4.00539C22.591 4.33616 22.7917 4.72379 22.9021 5.14077C23.0124 5.55774 23.0298 5.9939 22.9528 6.4183L22.1815 10.6958C21.9772 11.8293 21.3811 12.8549 20.4975 13.5935C19.6138 14.3321 18.4986 14.7367 17.3469 14.7366H5.63628C5.83897 15.3099 6.214 15.8065 6.71 16.1583C7.20599 16.51 7.79869 16.6998 8.40676 16.7015H18.6664C18.9269 16.7015 19.1768 16.805 19.361 16.9892C19.5453 17.1735 19.6488 17.4234 19.6488 17.6839C19.6488 17.9445 19.5453 18.1944 19.361 18.3786C19.1768 18.5629 18.9269 18.6664 18.6664 18.6664H8.40676C7.20313 18.6664 6.04134 18.2245 5.14198 17.4246C4.24264 16.6246 3.66831 15.5224 3.52796 14.327L2.17609 2.83237C2.14793 2.59339 2.03305 2.37304 1.85323 2.21314C1.67341 2.05325 1.44117 1.96493 1.20054 1.9649H0.982425C0.721871 1.96489 0.471974 1.86136 0.287734 1.67712C0.1035 1.49287 0 1.24298 0 0.982425C3.97784e-06 0.721871 0.103495 0.471974 0.287734 0.287734C0.471974 0.103495 0.721871 3.97774e-06 0.982425 0H1.20054ZM5.32385 12.7717H17.3469C18.0387 12.7728 18.7089 12.5304 19.24 12.0871C19.7711 11.6439 20.1294 11.0279 20.252 10.3471L21.0242 6.0695C21.0499 5.92748 21.044 5.78154 21.0069 5.64208C20.9698 5.50261 20.9024 5.37304 20.8096 5.26255C20.7167 5.15207 20.6007 5.06339 20.4697 5.00284C20.3387 4.94229 20.1959 4.91136 20.0516 4.91222H4.39935L5.32385 12.7717Z" fill="#414F42"/>
        </svg>      
        <span class="cart-products-count">{$cart.products_count}</span>
      {if $cart.products_count > 0}
        </a>
      {/if}
    </div>
  </div>
</div>
