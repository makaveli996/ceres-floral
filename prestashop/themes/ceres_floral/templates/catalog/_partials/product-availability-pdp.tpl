{**
 * PDP availability pill: Duża (≥100), Średnia (10–99), Mała (1–9), Niedostępny (0).
 * Used by: catalog/product.tpl (initial render). JS syncs after combination change via data-stock / data-product.
 * Input: $product (quantity). Output: .pdp__availability-row + #product-availability.
 * Side effects: none (markup only).
 *}
{assign var='pdp_stock_qty' value=$product.quantity|intval}
{if $pdp_stock_qty >= 100}
  {assign var='pdp_stock_modifier' value='stock-large'}
{elseif $pdp_stock_qty >= 10}
  {assign var='pdp_stock_modifier' value='stock-medium'}
{elseif $pdp_stock_qty > 0}
  {assign var='pdp_stock_modifier' value='stock-small'}
{else}
  {assign var='pdp_stock_modifier' value='unavailable'}
{/if}
{capture name='pdp_lbl_large'}{l s='Duża' d='Shop.Theme.Catalog'}{/capture}
{capture name='pdp_lbl_medium'}{l s='Średnia' d='Shop.Theme.Catalog'}{/capture}
{capture name='pdp_lbl_small'}{l s='Mała' d='Shop.Theme.Catalog'}{/capture}
{capture name='pdp_lbl_unavailable'}{l s='Niedostępny' d='Shop.Theme.Catalog'}{/capture}
<div
  class="pdp__availability-row"
  data-pdp-availability-labels="1"
  data-label-stock-large="{$smarty.capture.pdp_lbl_large|escape:'html':'UTF-8'}"
  data-label-stock-medium="{$smarty.capture.pdp_lbl_medium|escape:'html':'UTF-8'}"
  data-label-stock-small="{$smarty.capture.pdp_lbl_small|escape:'html':'UTF-8'}"
  data-label-unavailable="{$smarty.capture.pdp_lbl_unavailable|escape:'html':'UTF-8'}"
>
  <span class="pdp__availability-label">{l s='Dostępność:' d='Shop.Theme.Catalog'}</span>
  <span
    id="product-availability"
    class="pdp__availability-tag pdp__availability-tag--{$pdp_stock_modifier} js-product-availability"
    data-pdp-stock-qty="{$pdp_stock_qty}"
    aria-hidden="false"
  >{if $pdp_stock_qty >= 100}{l s='Duża' d='Shop.Theme.Catalog'}{elseif $pdp_stock_qty >= 10}{l s='Średnia' d='Shop.Theme.Catalog'}{elseif $pdp_stock_qty > 0}{l s='Mała' d='Shop.Theme.Catalog'}{else}{l s='Niedostępny' d='Shop.Theme.Catalog'}{/if}</span>
</div>
