{**
 * Category Slider — displayHome hook output. Figma nodes 240:2789 / 240:2809 / 240:2828.
 * Iterates $tc_categoryslider_segments and renders each as a full-width split segment:
 *   left panel  — background image + gradient + category title + CTA button
 *   right panel — Splide product slider (3 tiles per page, next arrow, pagination)
 * JS: data-tc-category-slider → _dev/js/custom/Sections/CategorySlider.js
 * SCSS: _dev/css/custom/sections/_category-slider.scss (tc-category-slider block)
 *}
<div class="tc-category-slider">
  <div class="container-xl">

{foreach from=$tc_categoryslider_segments item=segment}
  {if $segment.products|count > 0}
    <section
      class="tc-category-slider__segment"
      data-tc-category-slider
      aria-label="{$segment.category_name|escape:'html':'UTF-8'}"
    >

      {* Left panel — image + gradient overlay + text + CTA *}
      <div
        class="tc-category-slider__panel"
        style="background-image: url('{$segment.image|escape:'html':'UTF-8'}')"
        aria-hidden="true"
      >
        <div class="tc-category-slider__panel-overlay"></div>
        <div class="tc-category-slider__panel-content">
          <h2 class="tc-category-slider__panel-title">{$segment.category_name|escape:'html':'UTF-8'}</h2>
          {if !empty($segment.category_description)}
            <p class="tc-category-slider__panel-desc">{$segment.category_description|escape:'html':'UTF-8'}</p>
          {/if}
          {include file='_partials/button.tpl'
            url=$segment.category_url
            label={l s='Zobacz wszystkie' d='Modules.Tc_categoryslider.Shop'}
            btn_class='tc-category-slider__panel-btn'
            icon_type='arrow-right'
          }
        </div>
      </div>

      {* Right panel — product slider *}
      <div class="tc-category-slider__slider-wrap">

        <div
          class="splide tc-category-slider__splide"
          aria-label="{$segment.category_name|escape:'html':'UTF-8'}"
        >
          <div class="splide__track">
            <ul class="splide__list">
              {foreach from=$segment.products item=product}
                <li class="splide__slide">
                  {include file='_partials/product-tile.tpl' product=$product}
                </li>
              {/foreach}
            </ul>
          </div>
          <ul
            class="splide__pagination tc-slider-pagination tc-category-slider__pagination"
            aria-label="{l s='Nawigacja slidera' d='Shop.Theme.Catalog'}"
          ></ul>
        </div>

        {* Single "next" arrow — positioned absolutely at slider right edge *}
        <button
          class="tc-slider-arrows__btn tc-category-slider__arrow"
          type="button"
          data-slider-next
          aria-label="{l s='Następny slajd' d='Shop.Theme.Catalog'}"
        >
          <span class="tc-slider-arrows__icon" aria-hidden="true">
            <svg width="9" height="15" viewBox="0 0 9 15" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M8.5338 6.3576L2.72694 0.474684C2.10221 -0.158227 1.09328 -0.158228 0.468547 0.474684C-0.156182 1.10759 -0.156183 2.12975 0.468546 2.76266L5.14777 7.5L0.468545 12.2373C-0.156184 12.8703 -0.156185 13.8924 0.468544 14.5253C1.09327 15.1582 2.10221 15.1582 2.72694 14.5253L8.5338 8.64241C9.1554 8.01266 9.1554 6.98734 8.5338 6.3576Z" fill="currentColor"/>
            </svg>
          </span>
        </button>

      </div>{* /tc-category-slider__slider-wrap *}

    </section>
  {/if}
{/foreach}

  </div>{* /container-xl *}
</div>{* /tc-category-slider *}
