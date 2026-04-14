{**
 * Category PLP product grid — product tiles + optional promo video at slot 5 (page 1 only).
 * Used by: catalog/_partials/products.tpl when $listing.tcp_category_plp is set (CategoryController).
 * Variables: $listing (products, pagination, tcp_category_video_url).
 *}
{if $listing.products}
  <ul class="tcp-product-grid__list">
    {foreach from=$listing.products item=product name=productLoop}
      {if $smarty.foreach.productLoop.index == 4
        && isset($listing.tcp_category_video_url)
        && $listing.tcp_category_video_url
        && isset($listing.pagination.items_shown_from)
        && $listing.pagination.items_shown_from == 1}
        <li class="tcp-product-grid__item tcp-product-grid__item--video">
          <div class="tcp-video-card" data-tcp-video-card>
            <video
              class="tcp-video-card__player"
              src="{$listing.tcp_category_video_url|escape:'html':'UTF-8'}"
              playsinline
              preload="metadata"
            ></video>
            <button
              type="button"
              class="tcp-video-card__play"
              data-tcp-video-play
              data-label-play="{l s='Odtwórz film' d='Modules.Tc_collectionpages.Shop'|escape:'html':'UTF-8'}"
              data-label-pause="{l s='Wstrzymaj film' d='Modules.Tc_collectionpages.Shop'|escape:'html':'UTF-8'}"
              aria-pressed="false"
            >
              <span class="tcp-video-card__play-icon" aria-hidden="true"></span>
              <span class="tcp-video-card__pause-icon" aria-hidden="true">
                <span class="tcp-video-card__pause-bar"></span>
                <span class="tcp-video-card__pause-bar"></span>
              </span>
            </button>
          </div>
        </li>
      {/if}
      <li class="tcp-product-grid__item" data-tcp-product-item>
        {include file='_partials/product-tile.tpl' product=$product}
      </li>
    {/foreach}
  </ul>
{else}
  <p class="tcp-product-grid__empty">
    {l s='No products available yet' d='Shop.Theme.Catalog'}
  </p>
{/if}
