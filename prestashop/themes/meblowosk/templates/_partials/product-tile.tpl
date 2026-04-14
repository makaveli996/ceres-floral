{**
 * Global product tile (card: image, flags, name, price, link). Standalone component.
 * Used by: product-slider, product listings, any template that needs a product card. Pass $product.
 * Example: {include file='_partials/product-tile.tpl' product=$product}
 *}
<article class="product-tile">
  {assign var='product_name_safe' value=''}
  {if isset($product.name)}
    {if is_array($product.name)}
      {foreach from=$product.name item='product_name_i' name='product_name_loop'}
        {if $smarty.foreach.product_name_loop.first}
          {assign var='product_name_safe' value=$product_name_i}
        {/if}
      {/foreach}
    {else}
      {assign var='product_name_safe' value=$product.name}
    {/if}
  {/if}
  <a href="{$product.url|escape:'html':'UTF-8'}" class="product-tile__link">
    <div class="product-tile__image-wrap">
      {* Main (cover) image — always visible *}
      {if $product.cover}
        <picture class="product-tile__picture product-tile__picture--main">
          {if !empty($product.cover.bySize.home_default.sources.avif)}<source srcset="{$product.cover.bySize.home_default.sources.avif|escape:'html':'UTF-8'}" type="image/avif">{/if}
          {if !empty($product.cover.bySize.home_default.sources.webp)}<source srcset="{$product.cover.bySize.home_default.sources.webp|escape:'html':'UTF-8'}" type="image/webp">{/if}
          <img
            src="{$product.cover.bySize.home_default.url|escape:'html':'UTF-8'}"
            alt="{if !empty($product.cover.legend)}{$product.cover.legend|escape:'html':'UTF-8'}{else}{$product_name_safe|escape:'html':'UTF-8'|truncate:60:'...'}{/if}"
            loading="lazy"
            class="product-tile__image"
            width="{$product.cover.bySize.home_default.width|intval}"
            height="{$product.cover.bySize.home_default.height|intval}"
          />
        </picture>
      {else}
        <img
          src="{$urls.no_picture_image.bySize.home_default.url|escape:'html':'UTF-8'}"
          alt=""
          loading="lazy"
          class="product-tile__image product-tile__picture--main"
          width="{$urls.no_picture_image.bySize.home_default.width|intval}"
          height="{$urls.no_picture_image.bySize.home_default.height|intval}"
        />
      {/if}
      {* Second gallery image — visible on hover when available *}
      {if !empty($product.second_image.bySize.home_default.url)}
        <picture class="product-tile__picture product-tile__picture--hover" aria-hidden="true">
          {if !empty($product.second_image.bySize.home_default.sources.avif)}<source srcset="{$product.second_image.bySize.home_default.sources.avif|escape:'html':'UTF-8'}" type="image/avif">{/if}
          {if !empty($product.second_image.bySize.home_default.sources.webp)}<source srcset="{$product.second_image.bySize.home_default.sources.webp|escape:'html':'UTF-8'}" type="image/webp">{/if}
          <img
            src="{$product.second_image.bySize.home_default.url|escape:'html':'UTF-8'}"
            alt=""
            loading="lazy"
            class="product-tile__image"
            width="{$product.second_image.bySize.home_default.width|intval}"
            height="{$product.second_image.bySize.home_default.height|intval}"
          />
        </picture>
      {/if}
      {if !empty($product.flags)}
        <div class="product-tile__flags">
          {foreach from=$product.flags item=flag}
            <span class="product-tile__flag product-tile__flag--{$flag.type|escape:'html':'UTF-8'}">
              {if $flag.type == 'discount' || $flag.type == 'on-sale'}{l s='Sale' d='Shop.Theme.Catalog'}{else}{$flag.label|escape:'html':'UTF-8'}{/if}
            </span>
          {/foreach}
        </div>
      {/if}
    </div>
    <div class="product-tile__body">
      <p class="product-tile__name">{$product_name_safe|escape:'html':'UTF-8'|truncate:50:'...'}</p>
      {if isset($product.show_price) && $product.show_price}
        <div class="product-tile__price-row">
          <span class="product-tile__price">{$product.price|escape:'html':'UTF-8'}</span>
          <div class="product-tile__arrow" aria-hidden="true">
            <svg class="product-tile__arrow-icon" width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M0 10.5C0 4.70101 4.70101 0 10.5 0C16.299 0 21 4.70101 21 10.5C21 16.299 16.299 21 10.5 21C4.70101 21 0 16.299 0 10.5Z" fill="#F7A626"/>
              <path d="M12.8117 10.0769C13.0972 10.2867 13.0972 10.7133 12.8117 10.9231L9.89207 13.0684C9.54535 13.3232 9.0562 13.0756 9.0562 12.6454L9.0562 8.35464C9.0562 7.92438 9.54536 7.6768 9.89207 7.93158L12.8117 10.0769Z" fill="#1E1E1E"/>
            </svg>
          </div>
        </div>
      {/if}
    </div>
  </a>
</article>
