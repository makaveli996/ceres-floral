{**
 * Single row in checkout cart summary — thumb + name, qty, price. Theme override.
 * Variables: $product, $urls.
 *}
{block name='cart_summary_product_line'}
  <div class="cart-summary-product">
    <a class="cart-summary-product__thumb" href="{$product.url}" title="{$product.name|escape:'html':'UTF-8'}">
      {if $product.default_image}
        <picture>
          {if !empty($product.default_image.small.sources.avif)}<source srcset="{$product.default_image.small.sources.avif}" type="image/avif">{/if}
          {if !empty($product.default_image.small.sources.webp)}<source srcset="{$product.default_image.small.sources.webp}" type="image/webp">{/if}
          <img class="cart-summary-product__img" src="{$product.default_image.small.url}" alt="{$product.name|escape:'html':'UTF-8'}" loading="lazy">
        </picture>
      {else}
        <picture>
          {if !empty($urls.no_picture_image.bySize.small_default.sources.avif)}<source srcset="{$urls.no_picture_image.bySize.small_default.sources.avif}" type="image/avif">{/if}
          {if !empty($urls.no_picture_image.bySize.small_default.sources.webp)}<source srcset="{$urls.no_picture_image.bySize.small_default.sources.webp}" type="image/webp">{/if}
          <img class="cart-summary-product__img" src="{$urls.no_picture_image.bySize.small_default.url}" alt="{$product.name|escape:'html':'UTF-8'}" loading="lazy">
        </picture>
      {/if}
    </a>
    <div class="cart-summary-product__body">
      <div class="cart-summary-product__row">
        <a class="cart-summary-product__name" href="{$product.url}" target="_blank" rel="noopener noreferrer nofollow">{$product.name}</a>
        <span class="cart-summary-product__meta">
          <span class="cart-summary-product__qty">×{$product.quantity}</span>
          <span class="cart-summary-product__price">{$product.price}</span>
        </span>
      </div>
      {hook h='displayProductPriceBlock' product=$product type="unit_price"}
      {foreach from=$product.attributes key="attribute" item="value"}
        <div class="cart-summary-product__attr text-muted">
          <span class="cart-summary-product__attr-label">{$attribute}:</span>
          <span class="cart-summary-product__attr-value">{$value}</span>
        </div>
      {/foreach}
    </div>
  </div>
{/block}
