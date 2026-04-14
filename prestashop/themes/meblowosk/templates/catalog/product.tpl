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
{extends file=$layout}

{block name='head' append}
  <meta property="og:type" content="product">
  {if $product.cover}
    <meta property="og:image" content="{$product.cover.large.url}">
  {/if}

  {if $product.show_price}
    <meta property="product:pretax_price:amount" content="{$product.price_tax_exc}">
    <meta property="product:pretax_price:currency" content="{$currency.iso_code}">
    <meta property="product:price:amount" content="{$product.price_amount}">
    <meta property="product:price:currency" content="{$currency.iso_code}">
  {/if}
  {if isset($product.weight) && ($product.weight != 0)}
  <meta property="product:weight:value" content="{$product.weight}">
  <meta property="product:weight:units" content="{$product.weight_unit}">
  {/if}
{/block}

{block name='head_microdata_special'}
  {include file='_partials/microdata/product-jsonld.tpl'}
{/block}

{block name='content'}

  <section id="main">
    <meta content="{$product.url}">

    <div class="container-lg">
      <div class="pdp">
        <div class="pdp__layout product-container js-product-container">
          <div class="pdp__media">
            {block name='page_content_container'}
              <section class="pdp__media-content page-content">
                {block name='page_content'}
                  {block name='product_cover_thumbnails'}
                    {include file='catalog/_partials/product-gallery-splide.tpl'}
                  {/block}
                  {block name='hook_display_product_pdp_highlights'}
                    <div class="pdp__highlights-wrap">
                      {hook h='displayProductPdpHighlights' product=$product}
                    </div>
                  {/block}
                  {block name='hook_display_product_pdp_tabs'}
                    <div class="pdp__tabs-wrap">
                      {hook h='displayProductPdpTabs' product=$product}
                    </div>
                  {/block}

                {/block}
              </section>
            {/block}
          </div>
          <div class="pdp__aside">
            <div class="pdp__price-card">
              {block name='product_availability'}
                {include file='catalog/_partials/product-availability-pdp.tpl'}
              {/block}

              {block name='page_header_container'}
                {block name='page_header'}
                  <h1 class="pdp__title">{block name='page_title'}{$product.name}{/block}</h1>
                {/block}
              {/block}

              {* Mobile: CSS reorder (display:contents + order) puts .pdp__price-card-body below gallery; desktop: normal flow inside .pdp__price-card. *}
              <div class="pdp__price-card-body">
              {block name='product_prices'}
                {include file='catalog/_partials/product-prices.tpl'}
              {/block}

              {block name='pdp_installments'}
                {* Editable here: months divisor, copy via {l}, PayU markup. Not a BO setting. *}
                {assign var='pdp_installments_months' value=12}
                {if $product.show_price && isset($product.price_amount) && $product.price_amount > 0}
                  {assign var='pdp_installment_price' value=($product.price_amount / $pdp_installments_months)}
                  {capture name='pdp_installment_price_html'}{pdp_display_price price=$pdp_installment_price}{/capture}
                  <div class="pdp__installments">
                    <p class="pdp__installments-text">
                      <span class="pdp__installments-lead">{l s='KUP NA RATY' d='Shop.Theme.Catalog'}</span>
                      <span class="pdp__installments-from"> {l s='już od:' d='Shop.Theme.Catalog'} </span><span class="pdp__installments-amount">{$smarty.capture.pdp_installment_price_html nofilter}</span>
                    </p>
                    <img
                    class="pdp__installments-logo"
                    src="{$urls.img_url}payunoweprodukt_1.png"
                    alt="PayU"
                    width="64"
                    height="28"
                    loading="lazy">
                  </div>
                {/if}
              {/block}

              <hr class="pdp__divider" role="presentation">

              <div class="pdp__information product-information">
                {if $product.is_customizable && count($product.customizations.fields)}
                  {block name='product_customization'}
                    {include file="catalog/_partials/product-customization.tpl" customizations=$product.customizations}
                  {/block}
                {/if}

                <div class="pdp__actions product-actions js-product-actions">
                  {block name='product_buy'}
                    <form action="{$urls.pages.cart}" method="post" id="add-to-cart-or-refresh">
                      <input type="hidden" name="token" value="{$static_token}">
                      <input type="hidden" name="id_product" value="{$product.id}" id="product_page_product_id">
                      <input type="hidden" name="id_customization" value="{$product.id_customization}" id="product_customization_id" class="js-product-customization-id">

                      {block name='product_variants'}
                        {include file='catalog/_partials/product-variants.tpl'}
                      {/block}

                      {block name='product_pack'}
                        {if $packItems}
                          <section class="product-pack">
                            <p class="h4">{l s='This pack contains' d='Shop.Theme.Catalog'}</p>
                            {foreach from=$packItems item="product_pack"}
                              {block name='product_miniature'}
                                {include file='catalog/_partials/miniatures/pack-product.tpl' product=$product_pack showPackProductsPrice=$product.show_price}
                              {/block}
                            {/foreach}
                          </section>
                        {/if}
                      {/block}

                      <hr class="pdp__divider" role="presentation">

                      {block name='product_discounts'}
                        {include file='catalog/_partials/product-discounts.tpl'}
                      {/block}

                      {block name='product_add_to_cart'}
                        {include file='catalog/_partials/product-add-to-cart.tpl'}
                      {/block}

                      {block name='product_additional_info'}
                        {include file='catalog/_partials/product-additional-info.tpl'}
                      {/block}

                      {* Input to refresh product HTML removed, block kept for compatibility with themes *}
                      {block name='product_refresh'}{/block}
                    </form>
                  {/block}
                </div>
              </div>

              {block name='pdp_custom_size'}
                <div class="pdp__custom-size">
                  <p>
                    {l s='Potrzebujesz innego wymiaru?' d='Shop.Theme.Catalog'}
                    <a href="{$urls.pages.contact}">{l s='Zapytaj o swój wymiar' d='Shop.Theme.Catalog'}</a>
                  </p>
                </div>
              {/block}
              </div>
            </div>

            {block name='hook_display_product_pdp_before_reassurance'}
              <div class="pdp__before-reassurance">
                {hook h='displayProductPdpBeforeReassurance' product=$product}
              </div>
            {/block}
            {block name='hook_display_product_pdp_support'}
              {* Hook displayProductPdpSupport — np. tc_pdpsupport (tresc globalna: ustawienia modulu / sklep). *}
              <div class="pdp__support-wrap">
                {hook h='displayProductPdpSupport' product=$product}
              </div>
            {/block}

          </div>
        </div>
      </div>
    </div>

    {**
     * Full-width zone below the main PDP grid (outside container-lg). Hook: displayProductPdpFullWidth.
     * Przyklady: tc_pdpdelivery, tc_pdppayments, tc_pdptiles, tc_furniture_comparison, tc_pdprelatedslider, tc_pdpcollectionslider — PDP.
     *}
    {block name='hook_display_product_pdp_full_width'}
      <div class="pdp__full-width">
        {hook h='displayProductPdpFullWidth' product=$product}
      </div>
    {/block}

    {block name='product_footer'}
      {* $category is omitted from Smarty when default category is invalid; modules fall back to id_category_default *}
      {if isset($category)}
        {hook h='displayFooterProduct' product=$product category=$category}
      {else}
        {hook h='displayFooterProduct' product=$product}
      {/if}
    {/block}

    {block name='product_images_modal'}
      {include file='catalog/_partials/product-images-modal.tpl'}
    {/block}

    {block name='page_footer_container'}
      <footer class="page-footer">
        {block name='page_footer'}
          <!-- Footer content -->
        {/block}
      </footer>
    {/block}
  </section>

{/block}
