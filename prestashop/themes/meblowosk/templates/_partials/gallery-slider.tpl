{**
 * Reusable image gallery Splide slider. BEM block: gallery-slider.
 * Fills 100% of its parent wrapper — wrapper provides aspect-ratio, border-radius, overflow:hidden.
 *
 * Used by: tc_collections.tpl (kolekcje homepage), single_post_inspiration.tpl (post gallery).
 *
 * Required: gs_slides — array of [{image_url|url, title|alt}].
 * Optional:
 *   gs_splide_attr   — data attribute string on the Splide root for JS targeting
 *                      (default: 'data-gallery-slider-splide').
 *   gs_label         — aria-label for the Splide root.
 *   gs_default_alt   — fallback alt text when slide has no title/alt.
 *
 * Styled by: _gallery-slider.scss (.gallery-slider block).
 * Contextual overrides: _collections.scss, _blog-inspiration.scss.
 *}
<div class="gallery-slider">
  <div
    class="gallery-slider__splide splide"
    {if isset($gs_splide_attr) && $gs_splide_attr}{$gs_splide_attr nofilter}{else}data-gallery-slider-splide{/if}
    {if isset($gs_label) && $gs_label}aria-label="{$gs_label|escape:'html':'UTF-8'}"{/if}
  >
    <div class="splide__track">
      <ul class="splide__list">
        {foreach from=$gs_slides item=gs_slide name=gs_loop}
          {* Normalise image URL: support .image_url (tc_collections) and .url (post gallery) *}
          {if isset($gs_slide.image_url) && $gs_slide.image_url}
            {assign var='_gs_img' value=$gs_slide.image_url}
          {elseif isset($gs_slide.url) && $gs_slide.url}
            {assign var='_gs_img' value=$gs_slide.url}
          {else}
            {assign var='_gs_img' value=''}
          {/if}

          {* Normalise alt text *}
          {if isset($gs_slide.title) && $gs_slide.title}
            {assign var='_gs_alt' value=$gs_slide.title}
          {elseif isset($gs_slide.alt) && $gs_slide.alt}
            {assign var='_gs_alt' value=$gs_slide.alt}
          {elseif isset($gs_default_alt) && $gs_default_alt}
            {assign var='_gs_alt' value=$gs_default_alt}
          {else}
            {assign var='_gs_alt' value=''}
          {/if}

          <li class="splide__slide">
            <img
              src="{$_gs_img|escape:'html':'UTF-8'}"
              alt="{$_gs_alt|escape:'html':'UTF-8'}"
              class="gallery-slider__img"
              loading="{if $smarty.foreach.gs_loop.first}eager{else}lazy{/if}"
            />
          </li>
        {/foreach}
      </ul>
    </div>

    {include file='_partials/slider-arrows.tpl'}

    <ul
      class="splide__pagination gallery-slider__pagination"
      aria-label="{l s='Slider navigation' d='Shop.Theme.Catalog'}"
    ></ul>
  </div>
</div>
