{**
 * Reusable inspirations Splide slider component. BEM block: inspirations-slider.
 * Used by: tc_inspirationsslider.tpl (homepage), single_post_inspiration.tpl (related posts).
 * Required: is_posts — array of [{url|link, title, image|thumb}].
 * Optional: is_title (string), is_btn_text + is_btn_url (header CTA button),
 *           is_cta_label (per-card label, default "Zobacz aranżację").
 * Initialised by: TcInspirationsSlider.js ([data-inspirations-slider] → [data-inspirations-slider-splide]).
 * Styled by: _inspirations-slider.scss (.inspirations-slider block).
 *}
<div class="inspirations-slider" data-inspirations-slider>

  {if isset($is_title) && $is_title}
    <div class="container-lg">
      <div class="inspirations-slider__header">
        <h2 class="inspirations-slider__title">{$is_title|escape:'html':'UTF-8'}</h2>
        {if isset($is_btn_text) && $is_btn_text && isset($is_btn_url) && $is_btn_url}
          {include file='_partials/button.tpl'
            url=$is_btn_url
            label=$is_btn_text
            btn_class='inspirations-slider__btn button--empty'}
        {/if}
      </div>
    </div>
  {/if}

  <div class="inspirations-slider__wrapper">
    {if isset($is_cta_label) && $is_cta_label}
      {assign var='_is_cta' value=$is_cta_label}
    {else}
      {assign var='_is_cta' value='Zobacz aranżację'}
    {/if}
    <div class="inspirations-slider__splide splide" data-inspirations-slider-splide>
      <div class="splide__track">
        <ul class="splide__list">
          {foreach from=$is_posts item=is_post}
            {* Normalise URL: support both .url (tc_inspirationsslider) and .link (ets_blog related posts) *}
            {if isset($is_post.url) && $is_post.url}
              {assign var='_is_url' value=$is_post.url}
            {else}
              {assign var='_is_url' value=$is_post.link}
            {/if}
            {* Normalise image: support .image and .thumb *}
            {if isset($is_post.image) && $is_post.image}
              {assign var='_is_img' value=$is_post.image}
            {elseif isset($is_post.thumb) && $is_post.thumb}
              {assign var='_is_img' value=$is_post.thumb}
            {else}
              {assign var='_is_img' value=''}
            {/if}
            <li class="splide__slide">
              {include file='_partials/insp-card.tpl'
                insp_card_url=$_is_url
                insp_card_title=$is_post.title
                insp_card_image=$_is_img
                insp_card_show_button=true
                insp_card_button_label=$_is_cta}
            </li>
          {/foreach}
        </ul>
      </div>
      {include file='_partials/slider-arrows.tpl'}
      <ul class="splide__pagination inspirations-slider__pagination"
          aria-label="{l s='Slider navigation' d='Shop.Theme.Catalog'}"></ul>
    </div>
  </div>

</div>
