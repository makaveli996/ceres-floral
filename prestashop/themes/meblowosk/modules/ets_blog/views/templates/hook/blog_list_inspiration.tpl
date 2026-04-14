{*
 * Inspiration category archive layout — filter tabs + 2-col insp-card grid + pagination.
 * Used by: blog_list.tpl (dispatcher) when $blog_category.url_alias == 'inspiracje'.
 * Card markup: themes/meblowosk/templates/_partials/insp-card.tpl (include per post).
 * Inputs: $blog_posts (array), $blog_category (array), $blog_paggination (→ _partials/blog-pagination.tpl),
 *         $blog_insp_child_cats (array, injected by tc_blog_inspirations_filter module),
 *         $blog_insp_ajax_url (string).
 * Side effects: none — rendering only.
 *}
{if !$date_format}{assign var='date_format' value='d.m.Y'}{/if}
{capture assign='tc_insp_card_cta_label'}{l s='Zobacz aranżację' d='Modules.Tcinspirationsslider.Shop'}{/capture}

<div class="container-lg">
  <div class="blog-inspiration"
    {if isset($blog_insp_ajax_url) && $blog_insp_ajax_url|trim ne ''}
      data-ajax-url="{$blog_insp_ajax_url|escape:'html':'UTF-8'}"
    {else}
      data-ajax-url="{$link->getModuleLink('tc_blog_inspirations_filter','filter')|escape:'html':'UTF-8'}"
    {/if}
    data-insp-card-cta="{$tc_insp_card_cta_label|escape:'html':'UTF-8'}"
  >

    {* Category header *}
    <div class="blog-inspiration__header">
      <h1 class="blog-inspiration__title">{$blog_category.title|escape:'html':'UTF-8'}</h1>
    </div>

    {* ── Filter tabs ── *}
    <ul class="blog-inspiration__filter-bar" role="tablist"
      {if isset($blog_insp_cat_id)}data-insp-cat="{$blog_insp_cat_id|intval}"{/if}
    >
      <li class="blog-inspiration__filter-item">
        <button type="button" class="blog-inspiration__filter-btn blog-inspiration__filter-btn--active"
          data-filter="all" role="tab" aria-selected="true">
          {l s='Wszystkie' mod='ets_blog'}
        </button>
      </li>
      {if isset($blog_insp_child_cats) && $blog_insp_child_cats}
        {foreach from=$blog_insp_child_cats item='cat'}
          <li class="blog-inspiration__filter-item">
            <button type="button" class="blog-inspiration__filter-btn"
              data-filter="cat" data-cat-id="{$cat.id|intval}" role="tab" aria-selected="false">
              {$cat.title|escape:'html':'UTF-8'}
            </button>
          </li>
        {/foreach}
      {/if}
    </ul>

    {if isset($blog_posts) && $blog_posts}

      {* ── Inspiration grid ── *}
      <div class="blog-inspiration__grid-wrap" id="blog-insp-grid-wrap">
        <div class="blog-inspiration__loading" id="blog-insp-loading" aria-hidden="true">
          <div class="blog-inspiration__spinner"></div>
        </div>
        <ul class="blog-inspiration__grid" id="blog-insp-grid">
          {foreach from=$blog_posts item='post'}
            <li>
              {assign var='_insp_card_image' value=''}
              {if $post.image}
                {assign var='_insp_card_image' value=$post.image}
              {elseif $post.thumb}
                {assign var='_insp_card_image' value=$post.thumb}
              {/if}
              {include file='_partials/insp-card.tpl'
                insp_card_url=$post.link
                insp_card_title=$post.title
                insp_card_image=$_insp_card_image
                insp_card_show_button=true
                insp_card_button_label=$tc_insp_card_cta_label}
            </li>
          {/foreach}
        </ul>
      </div>

      {* ── Pagination (shared partial) ── *}
      {if $blog_paggination}
        {include file='_partials/blog-pagination.tpl' pagination_html=$blog_paggination pagination_id='blog-insp-pagination'}
      {/if}

    {else}
      <p class="blog-inspiration__empty">{l s='Brak inspiracji.' mod='ets_blog'}</p>
    {/if}

  </div>
</div>