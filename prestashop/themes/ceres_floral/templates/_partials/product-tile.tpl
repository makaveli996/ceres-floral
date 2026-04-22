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
    {* Current language — do not use foreach.first (random / wrong locale). *}
    {if isset($product.name[$language.id])}
      {assign var='product_name_safe' value=$product.name[$language.id]}
    {else}
      {foreach from=$product.name item='pn' name='pn_loop'}{if $smarty.foreach.pn_loop.first}{assign var='product_name_safe' value=$pn}{/if}{/foreach}
    {/if}
  {else}
    {assign var='product_name_safe' value=$product.name}
  {/if}
{/if}

<article class="product-tile">

  {* ── Image area — overflow:hidden tutaj umożliwia wyjeżdżanie ikon znad górnej krawędzi ── *}
  <div class="product-tile__image-area">

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

      </div>
    </a>

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

    {* Hover action icons — product_tile_hide_hover_actions: cały blok; product_tile_hide_wishlist: tylko serce (np. widok listy życzeń) *}
    {if empty($product_tile_hide_hover_actions)}
    <div class="product-tile__actions" aria-hidden="true">
      {if empty($product_tile_hide_wishlist)}
      <button
        type="button"
        class="product-tile__action-btn product-tile__action-btn--wishlist js-tile-wishlist"
        data-product-id="{$product.id_product}"
        title="{l s='Dodaj do ulubionych' d='Shop.Theme.Catalog'}"
        aria-label="{l s='Dodaj do ulubionych' d='Shop.Theme.Catalog'}"
        aria-pressed="false"
      >
        <svg width="20" height="18" viewBox="0 0 20 18" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
          <path d="M14.2246 0C13.3096 0.0142328 12.4145 0.269667 11.6298 0.740509C10.845 1.21135 10.1984 1.88092 9.75526 2.68162C9.3121 1.88092 8.6655 1.21135 7.88076 0.740509C7.09603 0.269667 6.20094 0.0142328 5.2859 0C3.82722 0.0633761 2.4529 0.70149 1.46321 1.77493C0.473509 2.84837 -0.0511209 4.26988 0.00393393 5.72891C0.00393393 9.42385 3.89309 13.4593 7.15491 16.1953C7.88318 16.8073 8.80398 17.1429 9.75526 17.1429C10.7065 17.1429 11.6273 16.8073 12.3556 16.1953C15.6174 13.4593 19.5066 9.42385 19.5066 5.72891C19.5616 4.26988 19.037 2.84837 18.0473 1.77493C17.0576 0.70149 15.6833 0.0633761 14.2246 0ZM11.3114 14.952C10.8758 15.3188 10.3247 15.52 9.75526 15.52C9.18582 15.52 8.63468 15.3188 8.19911 14.952C4.02392 11.4489 1.62916 8.08792 1.62916 5.72891C1.57361 4.70072 1.92687 3.69228 2.6119 2.92353C3.29693 2.15478 4.25814 1.68808 5.2859 1.62522C6.31367 1.68808 7.27488 2.15478 7.95991 2.92353C8.64494 3.69228 8.9982 4.70072 8.94265 5.72891C8.94265 5.94442 9.02826 6.15111 9.18066 6.30351C9.33305 6.4559 9.53974 6.54152 9.75526 6.54152C9.97078 6.54152 10.1775 6.4559 10.3299 6.30351C10.4823 6.15111 10.5679 5.94442 10.5679 5.72891C10.5123 4.70072 10.8656 3.69228 11.5506 2.92353C12.2356 2.15478 13.1969 1.68808 14.2246 1.62522C15.2524 1.68808 16.2136 2.15478 16.8986 2.92353C17.5837 3.69228 17.9369 4.70072 17.8814 5.72891C17.8814 8.08792 15.4866 11.4489 11.3114 14.9488V14.952Z"/>
        </svg>
      </button>
      {/if}

      <button
        type="button"
        class="product-tile__action-btn product-tile__action-btn--cart js-tile-quick-add"
        data-product-id="{$product.id_product}"
        data-product-url="{$product.url|escape:'html':'UTF-8'}"
        data-product-name="{$product_name_safe|escape:'html':'UTF-8'}"
        title="{l s='Dodaj do koszyka' d='Shop.Theme.Actions'}"
        aria-label="{l s='Dodaj do koszyka' d='Shop.Theme.Actions'}"
      >
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
          <path d="M19.95 5.49166L19.2166 9.14999C18.825 11.0917 17.1083 12.5 15.1333 12.5H5.60833C5.95833 13.4833 6.88333 14.1666 7.96666 14.1666H15.8333C16.2916 14.1666 16.6666 14.5416 16.6666 15C16.6666 15.4583 16.2916 15.8333 15.8333 15.8333H7.96666C5.85833 15.8333 4.075 14.25 3.825 12.15L2.675 2.4C2.625 1.98333 2.26666 1.66666 1.85 1.66666H0.833332C0.375 1.66666 0 1.29167 0 0.833332C0 0.375 0.375 0 0.833332 0H1.85C3.11666 0 4.18333 0.949999 4.33333 2.20833L4.36666 2.5H7.49999C7.95832 2.5 8.33332 2.875 8.33332 3.33333C8.33332 3.79166 7.95832 4.16666 7.49999 4.16666H4.56666L5.34999 10.8333H15.1333C16.3166 10.8333 17.35 9.99165 17.5833 8.82499L18.3166 5.16666C18.3666 4.92499 18.3 4.66666 18.1416 4.47499C17.9833 4.28333 17.75 4.16666 17.5 4.16666H14.1666C13.7083 4.16666 13.3333 3.79166 13.3333 3.33333C13.3333 2.875 13.7083 2.5 14.1666 2.5H17.5C18.25 2.5 18.9583 2.83333 19.4333 3.41666C19.9083 3.99999 20.1 4.75833 19.95 5.49166ZM5.83333 16.6666C4.91666 16.6666 4.16666 17.4166 4.16666 18.3333C4.16666 19.25 4.91666 20 5.83333 20C6.74999 20 7.49999 19.25 7.49999 18.3333C7.49999 17.4166 6.74999 16.6666 5.83333 16.6666ZM14.1666 16.6666C13.25 16.6666 12.5 17.4166 12.5 18.3333C12.5 19.25 13.25 20 14.1666 20C15.0833 20 15.8333 19.25 15.8333 18.3333C15.8333 17.4166 15.0833 16.6666 14.1666 16.6666ZM7.72499 6.04166C7.40832 6.37499 7.43332 6.90832 7.76666 7.21666L9.06666 8.43332C9.55832 8.92499 10.2 9.16666 10.8417 9.16666C11.4833 9.16666 12.1083 8.92499 12.5833 8.44999L13.9083 7.21666C14.2416 6.89999 14.2583 6.37499 13.95 6.04166C13.6333 5.70833 13.1083 5.68333 12.775 5.99999L11.675 7.02499V0.833332C11.675 0.375 11.3 0 10.8417 0C10.3833 0 10.0083 0.375 10.0083 0.833332V7.02499L8.90832 5.99999C8.57499 5.68333 8.04166 5.70833 7.73332 6.04166H7.72499Z"/>
        </svg>
      </button>
    </div>
    {/if}

  </div>

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
