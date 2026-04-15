{**
 * Global product tile — card: image, flags badge, name, price, omnibus, link.
 * Figma: "Karta_produktu" — bg #fffdf6, border #f8f3dd, 1:1 image, 30 px padding.
 * Used by: product-slider, tc_bestsellersslider, listings. Pass $product.
 * Omnibus: rendered via displayProductPriceBlock hook (omnibuseufree module).
 * CSS: _dev/css/custom/components/_product-tile.scss
 *}
{assign var='product_name_safe' value=''}
{if isset($product.name)}
  {if is_array($product.name)}
    {foreach from=$product.name item='pn' name='pn_loop'}{if $smarty.foreach.pn_loop.first}{assign var='product_name_safe' value=$pn}{/if}{/foreach}
  {else}
    {assign var='product_name_safe' value=$product.name}
  {/if}
{/if}

<article class="product-tile">

  {* ── Image area ── *}
  <a href="{$product.url|escape:'html':'UTF-8'}" class="product-tile__image-link" tabindex="-1" aria-hidden="true">
    <div class="product-tile__image-wrap">

      {* Main image *}
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

      {* Hover image *}
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

      {* "PROMOCJA" / sale badge — top-left overlay *}
      {if !empty($product.flags)}
        {foreach from=$product.flags item=flag}
          {if $flag.type == 'discount' || $flag.type == 'on-sale'}
            <span class="product-tile__badge product-tile__badge--sale" aria-label="{l s='Promocja' d='Shop.Theme.Catalog'}">
              {l s='PROMOCJA' d='Shop.Theme.Catalog'}
            </span>
            {break}
          {elseif $flag.type == 'new'}
            <span class="product-tile__badge product-tile__badge--new">
              {$flag.label|escape:'html':'UTF-8'}
            </span>
            {break}
          {elseif $flag.type == 'last_units'}
            <span class="product-tile__badge product-tile__badge--last">
              {$flag.label|escape:'html':'UTF-8'}
            </span>
            {break}
          {/if}
        {/foreach}
      {/if}

    </div>
  </a>

  {* ── Content area ── *}
  <div class="product-tile__body">

    <a href="{$product.url|escape:'html':'UTF-8'}" class="product-tile__name-link">
      <p class="product-tile__name">{$product_name_safe|escape:'html':'UTF-8'|truncate:60:'...'}</p>
    </a>

    {if isset($product.show_price) && $product.show_price}
      <div class="product-tile__price-row">
        <span class="product-tile__price">{$product.price|escape:'html':'UTF-8'}</span>
        {if !empty($product.has_discount) && $product.has_discount}
          <span class="product-tile__discount-badge">
            {if !empty($product.discount_amount_to_display)}
              {$product.discount_amount_to_display|escape:'html':'UTF-8'}
            {elseif !empty($product.discount_percentage)}
              {$product.discount_percentage|escape:'html':'UTF-8'}
            {/if}
          </span>
        {/if}
      </div>
    {/if}

    {* Omnibus — lowest price in 30 days via omnibuseufree module hook (EU directive) *}
    <div class="product-tile__omnibus-wrap">
      {hook h='displayProductPriceBlock' product=$product type='after_price'}
    </div>

  </div>

</article>
