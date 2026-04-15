{**
 * Slider prev/next arrow buttons — reusable circle icon pair component.
 * Used by: product-slider.tpl (section header, JS-connected to Splide).
 * CSS: _dev/css/custom/components/_slider-arrows.scss
 * JS: caller connects [data-slider-prev] / [data-slider-next] to splide.go('<') / splide.go('>').
 *}
<div class="tc-slider-arrows" role="group" aria-label="{l s='Nawigacja slidera' d='Shop.Theme.Catalog'}">
  <button
    class="tc-slider-arrows__btn tc-slider-arrows__btn--prev"
    type="button"
    data-slider-prev
    aria-label="{l s='Poprzedni slajd' d='Shop.Theme.Catalog'}"
  >
    <span class="tc-slider-arrows__icon" aria-hidden="true">
      {include file='_partials/icon-chevron.tpl' direction='left'}
    </span>
  </button>
  <button
    class="tc-slider-arrows__btn tc-slider-arrows__btn--next"
    type="button"
    data-slider-next
    aria-label="{l s='Następny slajd' d='Shop.Theme.Catalog'}"
  >
    <span class="tc-slider-arrows__icon" aria-hidden="true">
      {include file='_partials/icon-chevron.tpl' direction='right'}
    </span>
  </button>
</div>
