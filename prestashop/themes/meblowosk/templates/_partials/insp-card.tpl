{**
 * Inspiration editorial card (.insp-card): full-bleed image, gradient overlay, title, optional CTA.
 * Used by: modules/ets_blog/.../blog_list_inspiration.tpl, modules/tc_inspirationsslider/.../tc_inspirationsslider.tpl.
 * Required: $insp_card_url, $insp_card_title. Optional: $insp_card_image (URL string), $insp_card_show_button (bool),
 *            $insp_card_button_label (string, when show_button — e.g. translated "Zobacz aranżację").
 * CTA uses _partials/button.tpl with no_url_as_span when nested inside the card link.
 *}
<a href="{$insp_card_url|escape:'html':'UTF-8'}" class="insp-card">
  {if isset($insp_card_image) && $insp_card_image}
    <span class="insp-card__media">
      <img
        src="{$insp_card_image|escape:'html':'UTF-8'}"
        alt="{$insp_card_title|escape:'html':'UTF-8'}"
        class="insp-card__img"
        loading="lazy"
      />
    </span>
  {/if}
  <span class="insp-card__overlay"></span>
  <div class="insp-card__content">
    <span class="insp-card__title">{$insp_card_title|escape:'html':'UTF-8'}</span>
    {if isset($insp_card_show_button) && $insp_card_show_button && isset($insp_card_button_label) && $insp_card_button_label}
      {include file='_partials/button.tpl'
        label=$insp_card_button_label
        btn_class='insp-card__button button--empty button--white'
        no_url_as_span=1}
    {/if}
  </div>
</a>
