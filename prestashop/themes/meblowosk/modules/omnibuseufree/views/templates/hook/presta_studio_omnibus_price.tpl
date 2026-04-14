{**
 * Omnibus price history output override for PDP price card.
 * Used by: hook displayProductPriceBlock type="after_price" in product-prices.tpl.
 * Inputs from omnibuseufree: $OmnibuseufreeProductDiscount, $OmnibuseufreeInfoVersion,
 * $OmnibuseufreeNumberOfDays, $OmnibuseufreeProductPriceMin, $OmnibuseufreeProductPriceCurrent.
 * Note: module assigns discount from $product.has_discount — without promotion the original
 * template is empty. We also show a line when only $OmnibuseufreeProductPriceMin is set (e.g. v1 data).
 * {l} strings use English sources to match module translations (pl.php).
 * Side effects: none (render only).
 *}
{if $OmnibuseufreeProductDiscount == true}
  <div class="presta-studio-price-history pdp-prices__omnibus">
    <p class="presta-studio-price-history-text">
      {if $OmnibuseufreeInfoVersion == 2}
        {if $OmnibuseufreeProductPriceMin != null}
          {l s='Lowest price in %d days before discount: ' sprintf=[$OmnibuseufreeNumberOfDays] mod='omnibuseufree'}<span class="presta-studio-price-history-price">{$OmnibuseufreeProductPriceMin}</span>
        {else}
          {l s='Lowest price in %d days before discount: ' sprintf=[$OmnibuseufreeNumberOfDays] mod='omnibuseufree'}<span class="presta-studio-price-history-price">{if isset($product.regular_price) && $product.regular_price}{$product.regular_price}{else}{$OmnibuseufreeProductPriceCurrent}{/if}</span>
        {/if}
      {else}
        {l s='Lowest price in %d days: ' sprintf=[$OmnibuseufreeNumberOfDays] mod='omnibuseufree'}<span class="presta-studio-price-history-price">{if $OmnibuseufreeProductPriceMin != null}{$OmnibuseufreeProductPriceMin}{elseif isset($product.regular_price) && $product.regular_price}{$product.regular_price}{else}{$OmnibuseufreeProductPriceCurrent}{/if}</span>
      {/if}
    </p>
  </div>
{elseif isset($OmnibuseufreeProductPriceMin) && $OmnibuseufreeProductPriceMin != null}
  <div class="presta-studio-price-history pdp-prices__omnibus pdp-prices__omnibus--no-promo">
    <p class="presta-studio-price-history-text">
      {l s='Lowest price in %d days: ' sprintf=[$OmnibuseufreeNumberOfDays] mod='omnibuseufree'}<span class="presta-studio-price-history-price">{$OmnibuseufreeProductPriceMin}</span>
    </p>
  </div>
{/if}
