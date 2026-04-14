{**
 * PDP Splide gallery with synced thumbnails, replacing Classic cover+thumb list.
 * Used by: catalog/product.tpl in product_cover_thumbnails block.
 * Inputs: $product.images, $product.default_image, $product.name.
 * Output: .js-images-container with Splide main slider and thumbnail navigation.
 * Side effects: none (front-end only); initialized by _dev/js/custom/Sections/PdpGallery.js.
 *}
<div class="pdp-gallery images-container js-images-container" data-pdp-gallery>
  <div class="pdp-gallery__main splide" data-pdp-gallery-main aria-label="{l s='Product gallery' d='Shop.Theme.Catalog'}">
    <div class="splide__track">
      <ul class="splide__list">
        {foreach from=$product.images item=image name=pdp_gallery}
          <li class="splide__slide pdp-gallery__slide">
            <picture>
              {if !empty($image.bySize.large_default.sources.avif)}<source srcset="{$image.bySize.large_default.sources.avif}" type="image/avif">{/if}
              {if !empty($image.bySize.large_default.sources.webp)}<source srcset="{$image.bySize.large_default.sources.webp}" type="image/webp">{/if}
              <img
                class="pdp-gallery__image"
                src="{$image.bySize.large_default.url}"
                {if !empty($image.legend)}
                  alt="{$image.legend}"
                  title="{$image.legend}"
                {else}
                  alt="{$product.name}"
                {/if}
                loading="{if $smarty.foreach.pdp_gallery.first}eager{else}lazy{/if}"
                width="{$image.bySize.large_default.width}"
                height="{$image.bySize.large_default.height}"
              >
            </picture>
          </li>
        {/foreach}
        {* tc_productvideo: video slides appended after product images *}
        {if isset($tc_product_videos) && $tc_product_videos|@count > 0}
          {foreach from=$tc_product_videos item=tc_video}
            <li class="splide__slide pdp-gallery__slide pdp-gallery__slide--video"
                data-video-src="{$tc_video.url|escape:'html':'UTF-8'}">
              <video
                class="pdp-gallery__video"
                src="{$tc_video.url|escape:'html':'UTF-8'}"
                preload="metadata"
                playsinline
                muted
              ></video>
            </li>
          {/foreach}
        {/if}
      </ul>
    </div>

    {assign var='tc_total_slides' value=$product.images|@count + ($tc_product_videos|default:[]|@count)}
    {if $tc_total_slides > 1}
      {include file='_partials/slider-arrows.tpl'}
    {/if}
  </div>

  {assign var='tc_total_slides' value=$product.images|@count + ($tc_product_videos|default:[]|@count)}
  {if $tc_total_slides > 1}
  <div class="pdp-gallery__thumbs splide" data-pdp-gallery-thumbs aria-label="{l s='Product thumbnails' d='Shop.Theme.Catalog'}">
    <div class="splide__track">
      <ul class="splide__list">
        {foreach from=$product.images item=image}
          <li class="splide__slide pdp-gallery__thumb-slide">
            <picture>
              {if !empty($image.bySize.small_default.sources.avif)}<source srcset="{$image.bySize.small_default.sources.avif}" type="image/avif">{/if}
              {if !empty($image.bySize.small_default.sources.webp)}<source srcset="{$image.bySize.small_default.sources.webp}" type="image/webp">{/if}
              <img
                class="pdp-gallery__thumb-image"
                src="{$image.bySize.small_default.url}"
                {if !empty($image.legend)}
                  alt="{$image.legend}"
                  title="{$image.legend}"
                {else}
                  alt="{$product.name}"
                {/if}
                loading="lazy"
                width="{$image.bySize.small_default.width}"
                height="{$image.bySize.small_default.height}"
              >
            </picture>
          </li>
        {/foreach}
        {* tc_productvideo: video thumbnails (poster image + play icon overlay) *}
        {if isset($tc_product_videos) && $tc_product_videos|@count > 0}
          {foreach from=$tc_product_videos item=tc_video}
            <li class="splide__slide pdp-gallery__thumb-slide pdp-gallery__thumb-slide--video">
              {if isset($tc_video.thumbnail_url) && $tc_video.thumbnail_url}
                <img
                  class="pdp-gallery__thumb-image pdp-gallery__thumb-video-cover"
                  src="{$tc_video.thumbnail_url|escape:'html':'UTF-8'}"
                  alt=""
                  loading="lazy"
                >
              {/if}
              <span class="pdp-gallery__thumb-play" aria-hidden="true"></span>
            </li>
          {/foreach}
        {/if}
      </ul>
    </div>
  </div>
  {/if}

  {hook h='displayAfterProductThumbs' product=$product}
</div>
