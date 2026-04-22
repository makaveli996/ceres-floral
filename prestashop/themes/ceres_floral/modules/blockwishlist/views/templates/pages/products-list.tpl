{**
 * Copyright since 2007 PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License version 3.0
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright Since 2007 PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License version 3.0
 *}
{extends file='customer/page.tpl'}

{block name='page_header_container'}
{/block}

{block name='page_content_container'}
  <section id="content" class="page-content">
    <div
      class="wishlist-products-container"
      data-url="{$url}"
      data-delete-product-url="{$deleteProductUrl|escape:'html':'UTF-8'}"
      data-list-id="{$id}"
      data-default-sort="{l s='Last added' d='Modules.Blockwishlist.Shop'}"
      data-add-to-cart="{l s='Add to cart' d='Shop.Theme.Actions'}"
      data-share="{if $isGuest}true{else}false{/if}"
      data-customize-text="{l s='Customize' d='Modules.Blockwishlist.Shop'}"
      data-quantity-text="{l s='Quantity' d='Shop.Theme.Catalog'}"
      data-title="{$wishlistName}"
      data-no-products-message="{l s='No products found' d='Modules.Blockwishlist.Shop'}"
      data-filter="{l s='Sort by:' d='Shop.Theme.Global'}"
      data-remove-from-list="{l s='Usuń z listy' d='Modules.Blockwishlist.Shop'}"
    >
    </div>

    {include file="module:blockwishlist/views/templates/components/pagination.tpl"}
  </section>
{/block}

{block name='page_footer_container'}
  <div class="wishlist-footer-links">
    <a href="{$wishlistsLink}"><i class="material-icons">chevron_left</i>{l s='Return to wishlists' d='Modules.Blockwishlist.Shop'}</a>
    <a href="{$urls.base_url}"><i class="material-icons">home</i>{l s='Home' d='Shop.Theme.Global'}</a>
  </div>
{/block}
