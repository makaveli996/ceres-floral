{**
 * Universal product slider component (Splide). Reusable for any product listing slider.
 * Required : $title (string), $products (array).
 * Optional : $subtitle (string) — subtitle below title.
 *            $section_class (string) — BEM block name; default: tc-product-slider.
 *            $container    (string) — container class; default: container-lg.
 *            $show_pagination (bool) — render pagination dots; default: false.
 *            $cta_url + $cta_label — CTA button below slider.
 * JS   : data-tc-product-slider → ProductSlider.js (binds [data-slider-prev/next]).
 * SCSS : _dev/css/custom/parts/_product-slider.scss (tc-product-slider default styles).
 *}
{assign var='blk' value=$section_class|default:'tc-product-slider'}
{if $products|count > 0}
<section class="{$blk}" data-tc-product-slider>
  <div class="{$container|default:'container-lg'}">

    {* Head: title (+ subtitle) left — custom arrows right *}
    <div class="{$blk}__head">
      <div class="{$blk}__head-text">
        <h2 class="{$blk}__title">{$title|escape:'html':'UTF-8'}</h2>
        {if !empty($subtitle)}
          <p class="{$blk}__subtitle">{$subtitle|escape:'html':'UTF-8'}</p>
        {/if}
      </div>
      <div class="{$blk}__arrows">
        {include file='_partials/slider-arrows.tpl'}
      </div>
    </div>

    {* Splide *}
    <div class="splide {$blk}__splide" aria-label="{$title|escape:'html':'UTF-8'}">
      <div class="splide__track">
        <ul class="splide__list">
          {foreach from=$products item=product}
            <li class="splide__slide">
              {include file='_partials/product-tile.tpl' product=$product}
            </li>
          {/foreach}
        </ul>
      </div>
      {if !empty($show_pagination) && $show_pagination}
        <ul
          class="splide__pagination tc-slider-pagination {$blk}__pagination"
          aria-label="{l s='Nawigacja slidera' d='Shop.Theme.Catalog'}"
        ></ul>
      {/if}
    </div>

    {if isset($cta_url) && $cta_url != ''}
      {assign var='_btn_cls' value=$blk|cat:'__btn'}
      <div class="{$blk}__cta">
        {include file='_partials/button.tpl' url=$cta_url label=$cta_label|default:'' btn_class=$_btn_cls}
      </div>
    {/if}

  </div>
</section>
{/if}
