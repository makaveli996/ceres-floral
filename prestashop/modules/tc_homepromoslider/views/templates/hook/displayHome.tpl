{*
 * Purpose: Render homepage promo slider with right checklist panel.
 * Used from: `tc_homepromoslider` via `hookDisplayHome`.
 * Inputs: `slides`, `list_title`, `list_items`.
 * Outputs: Front-office HTML block wrapped by `container-xl`.
 * Side effects: None.
 *}
<section class="tc-home-promo-slider" data-tc-home-promo-slider>
  <div class="container-xl">
    <div class="tc-home-promo-slider__layout">
      <div class="tc-home-promo-slider__hero">
        <div class="splide tc-home-promo-slider__splide" data-tc-home-promo-splide>
          <div class="splide__track">
            <ul class="splide__list">
              {foreach from=$slides item=slide}
                <li class="splide__slide">
                  <article class="tc-home-promo-slider__slide">
                    <img class="tc-home-promo-slider__image" src="{$slide.image|escape:'htmlall':'UTF-8'}" alt="{$slide.title|escape:'htmlall':'UTF-8'}">
                  </article>
                </li>
              {/foreach}
            </ul>
          </div>

          <ul
            class="splide__pagination hero-slider__pagination"
            aria-label="{l s='Slider navigation' d='Shop.Theme.Catalog'}"
          ></ul>
        </div>
      </div>

      <aside class="tc-home-promo-slider__list">
        <h3 class="tc-home-promo-slider__list-title">{$list_title|escape:'htmlall':'UTF-8'}</h3>
        <ul class="tc-home-promo-slider__list-items">
          {foreach from=$list_items item=list_item}
            <li>
              <span class="tc-home-promo-slider__check" aria-hidden="true">
                <svg width="23" height="23" viewBox="0 0 23 23" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <rect width="23" height="23" rx="11.5" fill="#F8F3DD"/>
                  <path d="M16.7744 9.33753L10.8631 15.2484C10.4253 15.6863 9.71527 15.6863 9.27711 15.2484L6.22565 12.1968C5.78774 11.7589 5.78774 11.0488 6.22565 10.6109C6.66364 10.1729 7.37366 10.1729 7.81146 10.6107L10.0703 12.8696L15.1883 7.75155C15.6263 7.31357 16.3364 7.3139 16.7742 7.75155C17.2121 8.18946 17.2121 8.89938 16.7744 9.33753Z" fill="#79897E"/>
                </svg>              
              </span>
              <span>{$list_item|escape:'htmlall':'UTF-8'}</span>
            </li>
          {/foreach}
        </ul>
      </aside>
    </div>
  </div>
</section>
