{**
 * Bestsellers slider — "Najczęściej kupowane" section. Figma node 240:2772.
 * Layout: container-md → header row (title+subtitle left, arrows right) → Splide → pagination.
 * Components: slider-arrows.tpl (prev/next circles), product-tile.tpl (cards), hero-slider__pagination.
 * JS: data-tc-bestsellers-slider → BestsellersSlider.js (arrows bound via data-slider-prev/next).
 * SCSS: _dev/css/custom/sections/_bestsellers-slider.scss.
 * Inputs: $tc_bestsellersslider_products, $tc_bestsellersslider_title, $tc_bestsellersslider_subtitle.
 *}
{if $tc_bestsellersslider_products|count > 0}
<section class="tc-bestsellers-slider" data-tc-bestsellers-slider>
  <div class="container-md">

    {* ── Section header: title+subtitle left, arrows right ── *}
    <div class="tc-bestsellers-slider__head">
      <div class="tc-bestsellers-slider__head-text">
        <h2 class="tc-bestsellers-slider__title">
          {$tc_bestsellersslider_title|escape:'html':'UTF-8'}
        </h2>
        {if !empty($tc_bestsellersslider_subtitle)}
          <p class="tc-bestsellers-slider__subtitle">
            {$tc_bestsellersslider_subtitle|escape:'html':'UTF-8'}
          </p>
        {/if}
      </div>

      {* Arrow component — JS connects [data-slider-prev/next] to Splide *}
      <div class="tc-bestsellers-slider__arrows">
        {include file='_partials/slider-arrows.tpl'}
      </div>
    </div>

    {* ── Splide slider ── *}
    <div
      class="splide tc-bestsellers-slider__splide"
      data-tc-bestsellers-splide
      aria-label="{$tc_bestsellersslider_title|escape:'html':'UTF-8'}"
    >
      <div class="splide__track">
        <ul class="splide__list">
          {foreach from=$tc_bestsellersslider_products item=product}
            <li class="splide__slide">
              {include file='_partials/product-tile.tpl' product=$product}
            </li>
          {/foreach}
        </ul>
      </div>

      {* Pagination — reuses hero-slider__pagination component *}
      <ul
        class="splide__pagination hero-slider__pagination tc-bestsellers-slider__pagination"
        aria-label="{l s='Nawigacja slidera' d='Shop.Theme.Catalog'}"
      ></ul>
    </div>

  </div>
</section>
{/if}
