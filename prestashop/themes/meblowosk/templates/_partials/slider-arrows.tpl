{**
 * Global slider arrows component. Used by product-slider and any Splide slider that needs arrow nav.
 * Must be placed inside the .splide element. Splide binds to .splide__arrows and .splide__arrow--prev/next.
 * Styled by _dev/css/custom/components/_slider-arrows.scss.
 *}
<div class="splide__arrows tc-slider-arrows" aria-label="{l s='Slider navigation' d='Shop.Theme.Catalog'}">
  <button type="button" class="splide__arrow splide__arrow--prev tc-slider-arrows__btn tc-slider-arrows__btn--prev" aria-label="{l s='Previous' d='Shop.Theme.Catalog'}">
    <span class="tc-slider-arrows__icon tc-slider-arrows__icon--prev" aria-hidden="true">
      <svg width="10" height="19" viewBox="0 0 10 19" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9.16662 18.3332C8.9535 18.3332 8.74017 18.2517 8.57746 18.089L0.244216 9.75578C-0.0814054 9.43016 -0.0814054 8.90288 0.244216 8.57746L8.57746 0.244216C8.90308 -0.0814054 9.43037 -0.0814054 9.75578 0.244216C10.0812 0.569838 10.0814 1.09712 9.75578 1.42254L2.0117 9.16662L9.75578 16.9107C10.0814 17.2363 10.0814 17.7636 9.75578 18.089C9.59308 18.2517 9.37975 18.3332 9.16662 18.3332Z" fill="#1E1E1E"/>
      </svg>
    </span>
  </button>
  <button type="button" class="splide__arrow splide__arrow--next tc-slider-arrows__btn tc-slider-arrows__btn--next" aria-label="{l s='Next' d='Shop.Theme.Catalog'}">
    <span class="tc-slider-arrows__icon tc-slider-arrows__icon--next" aria-hidden="true">
      <svg width="10" height="19" viewBox="0 0 10 19" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M0.833379 5.64191e-05C1.0465 5.64377e-05 1.25983 0.0815136 1.42254 0.24422L9.75578 8.57747C10.0814 8.90309 10.0814 9.43038 9.75578 9.75579L1.42254 18.089C1.09692 18.4147 0.56963 18.4147 0.244217 18.089C-0.0811967 17.7634 -0.0814046 17.2361 0.244217 16.9107L7.9883 9.16663L0.244218 1.42254C-0.0814032 1.09692 -0.0814031 0.569633 0.244219 0.24422C0.406925 0.0815135 0.620256 5.64005e-05 0.833379 5.64191e-05Z" fill="#1E1E1E"/>
      </svg>
    </span>
  </button>
</div>
