{**
 * Slider prev/next arrow buttons — reusable circle icon pair component.
 * Used by: tc_bestsellersslider (placed in section header, JS-connected to Splide).
 * Wraps two circle buttons with chevron SVGs.
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
      <svg width="9" height="15" viewBox="0 0 9 15" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M0.466203 8.64241L6.27306 14.5253C6.89779 15.1582 7.90672 15.1582 8.53145 14.5253C9.15618 13.8924 9.15618 12.8703 8.53145 12.2373L3.85223 7.5L8.53145 2.76266C9.15618 2.12975 9.15618 1.1076 8.53145 0.474685C7.90673 -0.158226 6.89779 -0.158226 6.27306 0.474684L0.466203 6.35759C-0.155401 6.98734 -0.155402 8.01266 0.466203 8.64241Z" fill="#79897E"/>
      </svg>    
    </span>
  </button>
  <button
    class="tc-slider-arrows__btn tc-slider-arrows__btn--next"
    type="button"
    data-slider-next
    aria-label="{l s='Następny slajd' d='Shop.Theme.Catalog'}"
  >
    <span class="tc-slider-arrows__icon" aria-hidden="true">
      <svg width="9" height="15" viewBox="0 0 9 15" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.5338 6.3576L2.72694 0.474684C2.10221 -0.158227 1.09328 -0.158228 0.468547 0.474684C-0.156182 1.10759 -0.156183 2.12975 0.468546 2.76266L5.14777 7.5L0.468545 12.2373C-0.156184 12.8703 -0.156185 13.8924 0.468544 14.5253C1.09327 15.1582 2.10221 15.1582 2.72694 14.5253L8.5338 8.64241C9.1554 8.01266 9.1554 6.98734 8.5338 6.3576Z" fill="#79897E"/>
      </svg>
    </span>
  </button>
</div>
