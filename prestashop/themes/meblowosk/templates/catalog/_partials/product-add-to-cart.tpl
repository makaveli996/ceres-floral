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
<div class="pdp-add-to-cart product-add-to-cart js-product-add-to-cart">
  {if !$configuration.is_catalog}
    {block name='product_quantity'}
      <div class="pdp-add-to-cart__row">
        <div class="pdp-add-to-cart__qty-wrap">
          <span class="pdp-add-to-cart__qty-label">{l s='Ilość' d='Shop.Theme.Catalog'}</span>
          <div class="pdp-add-to-cart__quantity product-quantity clearfix">
            <div class="pdp-add-to-cart__qty-input qty">
              <input
                type="number"
                name="qty"
                id="quantity_wanted"
                inputmode="numeric"
                pattern="[0-9]*"
                {if $product.quantity_wanted}
                  value="{$product.quantity_wanted}"
                  min="{$product.minimal_quantity}"
                {else}
                  value="1"
                  min="1"
                {/if}
                class="input-group"
                aria-label="{l s='Quantity' d='Shop.Theme.Actions'}"
              >
            </div>
          </div>
        </div>

        <div class="pdp-add-to-cart__submit add">
          <button
            class="pdp-add-to-cart__button add-to-cart button"
            data-button-action="add-to-cart"
            type="submit"
            {if !$product.add_to_cart_url}
              disabled
            {/if}
          >
            <span class="button__text">
            {l s='Dodaj do koszyka' d='Shop.Theme.Actions'}
            </span>
            <span class="button__icon">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M5.25 15C6.07843 15 6.75 15.6716 6.75 16.5C6.75 17.3284 6.07843 18 5.25 18C4.42157 18 3.75 17.3284 3.75 16.5C3.75 15.6716 4.42157 15 5.25 15ZM12.75 15C13.5784 15 14.25 15.6716 14.25 16.5C14.25 17.3284 13.5784 18 12.75 18C11.9216 18 11.25 17.3284 11.25 16.5C11.25 15.6716 11.9216 15 12.75 15ZM0.916016 0C1.4667 0.000234555 1.99856 0.202535 2.41016 0.568359C2.82181 0.934397 3.08576 1.43928 3.15039 1.98633L3.18164 2.25H9.75C9.94891 2.25 10.1396 2.32907 10.2803 2.46973C10.4209 2.61038 10.5 2.80109 10.5 3C10.5 3.19891 10.4209 3.38962 10.2803 3.53027C10.1396 3.67093 9.94891 3.75 9.75 3.75H3.3584L4.06348 9.75H13.2432C13.7704 9.74982 14.281 9.56469 14.6855 9.22656C15.0901 8.88831 15.3634 8.41839 15.457 7.89941C15.474 7.80235 15.5095 7.70903 15.5625 7.62598C15.6156 7.54285 15.6855 7.47127 15.7666 7.41504C15.8476 7.35885 15.9387 7.31848 16.0352 7.29785C16.1316 7.27723 16.2312 7.27679 16.3281 7.29492C16.425 7.31236 16.5177 7.34819 16.6006 7.40137C16.6834 7.45457 16.7553 7.52364 16.8115 7.60449C16.8677 7.68539 16.9078 7.77681 16.9287 7.87305C16.9496 7.96933 16.9511 8.06905 16.9336 8.16602C16.7775 9.03115 16.3221 9.81423 15.6475 10.3779C14.973 10.9414 14.122 11.25 13.2432 11.25H4.2959C4.45097 11.6886 4.73835 12.0683 5.11816 12.3369C5.49816 12.6056 5.95261 12.7501 6.41797 12.75H14.25C14.4489 12.75 14.6396 12.8291 14.7803 12.9697C14.9209 13.1104 15 13.3011 15 13.5C15 13.6989 14.9209 13.8896 14.7803 14.0303C14.6396 14.1709 14.4489 14.25 14.25 14.25H6.41797C5.49914 14.25 4.61234 13.9124 3.92578 13.3018C3.23927 12.6911 2.80055 11.85 2.69336 10.9375L1.66113 2.16211C1.63961 1.97978 1.55222 1.81148 1.41504 1.68945C1.27776 1.56738 1.09972 1.50002 0.916016 1.5H0.75C0.551088 1.5 0.360379 1.42093 0.219727 1.28027C0.0790743 1.13962 0 0.948912 0 0.75C0 0.551088 0.0790743 0.360379 0.219727 0.219727C0.360379 0.0790743 0.551088 0 0.75 0H0.916016ZM15 0C15.1989 7.5769e-07 15.3896 0.079075 15.5303 0.219727C15.6709 0.360379 15.75 0.551088 15.75 0.75V2.25H17.25C17.4489 2.25 17.6396 2.32907 17.7803 2.46973C17.9209 2.61038 18 2.80109 18 3C18 3.19891 17.9209 3.38962 17.7803 3.53027C17.6396 3.67093 17.4489 3.75 17.25 3.75H15.75V5.25C15.75 5.44891 15.6709 5.63962 15.5303 5.78027C15.3896 5.92093 15.1989 6 15 6C14.8011 6 14.6104 5.92092 14.4697 5.78027C14.3291 5.63962 14.25 5.44891 14.25 5.25V3.75H12.75C12.5511 3.75 12.3604 3.67092 12.2197 3.53027C12.0791 3.38962 12 3.19891 12 3C12 2.80109 12.0791 2.61038 12.2197 2.46973C12.3604 2.32908 12.5511 2.25 12.75 2.25H14.25V0.75C14.25 0.551088 14.3291 0.360379 14.4697 0.219727C14.6104 0.0790754 14.8011 0 15 0Z" fill="black"/>
              </svg>
            </span>
          </button>
        </div>

        {hook h='displayProductActions' product=$product}
      </div>
    {/block}

    {block name='product_minimal_quantity'}
      <p class="pdp-add-to-cart__minimal-quantity product-minimal-quantity js-product-minimal-quantity">
        {if $product.minimal_quantity > 1}
          {l
          s='The minimum purchase order quantity for the product is %quantity%.'
          d='Shop.Theme.Checkout'
          sprintf=['%quantity%' => $product.minimal_quantity]
          }
        {/if}
      </p>
    {/block}
  {/if}
</div>
