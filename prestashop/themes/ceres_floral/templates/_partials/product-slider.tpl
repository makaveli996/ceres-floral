{**
 * Global product slider component (Splide). Reusable for bestsellers, new products, custom queries, etc.
 * Variables: $title, $products; $cta_url + $cta_label (opcjonalne — brak = bez bloku tc-product-slider__cta, np. tc_pdprelatedslider).
 * JS: data-tc-product-slider → ProductSlider.js (autoplay, loop). Styled by _dev/css/custom/sections/_product-slider.scss.
 *}
{if $products|count > 0}
<div class="tc-product-slider" data-tc-product-slider>
  <div class="container-lg">
    <h2 class="tc-product-slider__title">{$title|escape:'html':'UTF-8'}</h2>

    <div class="splide tc-product-slider__splide" aria-label="{$title|escape:'html':'UTF-8'}">
      <div class="splide__track">
        <ul class="splide__list">
          {foreach from=$products item=product}
            <li class="splide__slide">
              {include file='_partials/product-tile.tpl' product=$product}
            </li>
          {/foreach}
        </ul>
      </div>
      {include file='_partials/slider-arrows.tpl'}
    </div>

    {if isset($cta_url) && $cta_url != ''}
    <div class="tc-product-slider__cta">
      {include file='_partials/button.tpl' url=$cta_url label=$cta_label|default:'' btn_class='tc-product-slider__btn'}
    </div>
    {/if}
  </div>
</div>
{/if}
