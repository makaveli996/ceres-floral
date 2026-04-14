{*
 * Tips category archive layout — 2 featured hero cards + filter bar + 4-col post grid + pagination.
 * Used by: blog_list.tpl (dispatcher) when $blog_category.url_alias == 'porady'.
 * Grid cards: themes/meblowosk/templates/_partials/post-card.tpl (include per post).
 * Inputs: $blog_posts (array), $blog_category (array), $blog_paggination (→ _partials/blog-pagination.tpl),
 *         $blog_tips_child_cats (array, injected by tc_blog_tips_filter module),
 *         $blog_tips_ajax_url (string), $blog_tips_popular_threshold (int).
 * Side effects: none — rendering only.
 *}
{assign var='date_format' value='d.m.Y'}

<div class="container-lg">
  <div class="blog-tips"
    {if isset($blog_tips_ajax_url) && $blog_tips_ajax_url|trim ne ''}
      data-ajax-url="{$blog_tips_ajax_url|escape:'html':'UTF-8'}"
    {else}
      data-ajax-url="{$link->getModuleLink('tc_blog_tips_filter','filter')|escape:'html':'UTF-8'}"
    {/if}
  >

    {* ── Category header (title) ── *}
    <div class="blog-tips__header">
      <h1 class="blog-tips__title">{$blog_category.title|escape:'html':'UTF-8'}</h1>
    </div>

    {if isset($blog_posts) && $blog_posts}

      {* ── Featured hero cards — first 2 posts ── *}
      {assign var='_has_featured' value=false}
      {foreach from=$blog_posts item='_fp' name='_fpc'}
        {if $smarty.foreach._fpc.index == 0}{assign var='_has_featured' value=true}{/if}
        {if $smarty.foreach._fpc.index >= 2}{break}{/if}
      {/foreach}

      {if $_has_featured}
        <div class="blog-tips__featured">
          {foreach from=$blog_posts item='post' name='feat'}
            {if $smarty.foreach.feat.index >= 2}{break}{/if}
            <a href="{$post.link|escape:'html':'UTF-8'}" class="blog-tips__featured-card">
              {if $post.categories}
                <span class="blog-tips__badge">{$post.categories[0].title|escape:'html':'UTF-8'}</span>
              {/if}
              {if $post.image || $post.thumb}
                <div class="blog-tips__featured-img">
                  <img
                    src="{if $post.image}{$post.image|escape:'html':'UTF-8'}{else}{$post.thumb|escape:'html':'UTF-8'}{/if}"
                    alt="{$post.title|escape:'html':'UTF-8'}"
                    loading="lazy"
                  />
                </div>
              {/if}
              <div class="blog-tips__featured-content-wrapper">
                <div class="blog-tips__featured-content">
                  <div class="blog-tips__featured-meta">
                    <span class="blog-tips__featured-date">{date($date_format, strtotime($post.date_add))|escape:'html':'UTF-8'}</span>
                  </div>
                  <h2 class="blog-tips__featured-title">{$post.title|escape:'html':'UTF-8'}</h2>
                </div>
                <div class="blog-tips__arrow" aria-hidden="true">
                  <svg class="blog-tips__arrow-icon" width="34" height="34" viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M0 17C0 7.61116 7.61116 0 17 0C26.3888 0 34 7.61116 34 17C34 26.3888 26.3888 34 17 34C7.61116 34 0 26.3888 0 17Z" fill="#F7A626"/>
                    <path d="M19.6418 16.5165C19.9681 16.7562 19.9681 17.2437 19.6418 17.4835L16.3051 19.9353C15.9088 20.2265 15.3498 19.9436 15.3498 19.4518L15.3498 14.5481C15.3498 14.0564 15.9088 13.7735 16.3051 14.0646L19.6418 16.5165Z" fill="#1E1E1E"/>
                  </svg>
                </div>
              </div>
            </a>
          {/foreach}
        </div>
      {/if}

      {* ── Section header: title + filter tabs ── *}
      {assign var='_remaining' value=false}
      {foreach from=$blog_posts item='_r' name='_rc'}
        {if $smarty.foreach._rc.index >= 2}{assign var='_remaining' value=true}{break}{/if}
      {/foreach}

      {if $_remaining || $_has_featured}
        <div class="blog-tips__section-header">
          <h2 class="blog-tips__section-title">{l s='Pozostałe artykuły' mod='ets_blog'}</h2>

          <ul class="blog-tips__filters" role="tablist"
            {if isset($blog_tips_porady_cat_id)}data-porady-cat="{$blog_tips_porady_cat_id|intval}"{/if}
            {if isset($blog_tips_popular_threshold)}data-popular-threshold="{$blog_tips_popular_threshold|intval}"{/if}
          >
            <li class="blog-tips__filter-item">
              <button type="button" class="blog-tips__filter-btn blog-tips__filter-btn--active"
                data-filter="all" role="tab" aria-selected="true">
                {l s='Wszystkie' mod='ets_blog'}
              </button>
            </li>
            <li class="blog-tips__filter-item">
              <button type="button" class="blog-tips__filter-btn"
                data-filter="popular" role="tab" aria-selected="false">
                {l s='Najpopularniejsze' mod='ets_blog'}
              </button>
            </li>
            {if isset($blog_tips_child_cats) && $blog_tips_child_cats}
              {foreach from=$blog_tips_child_cats item='cat'}
                <li class="blog-tips__filter-item">
                  <button type="button" class="blog-tips__filter-btn"
                    data-filter="cat" data-cat-id="{$cat.id|intval}" role="tab" aria-selected="false">
                    {$cat.title|escape:'html':'UTF-8'}
                  </button>
                </li>
              {/foreach}
            {/if}
          </ul>
        </div>
      {/if}

      {* ── Post grid ── *}
      {if $_remaining}
        <div class="blog-tips__grid-wrap" id="blog-tips-grid-wrap">
          <div class="blog-tips__loading" id="blog-tips-loading" aria-hidden="true">
            <div class="blog-tips__spinner"></div>
          </div>
          <ul class="blog-tips__grid" id="blog-tips-grid">
            {foreach from=$blog_posts item='post' name='grid'}
              {if $smarty.foreach.grid.index < 2}{continue}{/if}
              {assign var='_post_card_image' value=''}
              {if $post.thumb}
                {assign var='_post_card_image' value=$post.thumb}
              {elseif $post.image}
                {assign var='_post_card_image' value=$post.image}
              {/if}
              {assign var='_post_card_cat' value=''}
              {if $post.categories}
                {assign var='_post_card_cat' value=$post.categories[0].title}
              {/if}
              {capture assign='_post_card_date_disp'}{date($date_format, strtotime($post.date_add))}{/capture}
              {assign var='_post_card_iso' value=$post.date_add|date_format:'%Y-%m-%d'}
              {include file='_partials/post-card.tpl'
                post_card_url=$post.link
                post_card_title=$post.title
                post_card_image=$_post_card_image
                post_card_category=$_post_card_cat
                post_card_date=$_post_card_date_disp
                post_card_datetime=$_post_card_iso}
            {/foreach}
          </ul>
        </div>
      {elseif !$_has_featured}
        <p class="blog-tips__empty">{l s='Brak artykułów.' mod='ets_blog'}</p>
      {/if}

    {else}
      <p class="blog-tips__empty">{l s='Brak artykułów.' mod='ets_blog'}</p>
    {/if}

    {* ── Pagination (shared partial) ── *}
    {if $blog_paggination}
      {include file='_partials/blog-pagination.tpl' pagination_html=$blog_paggination pagination_id='blog-tips-pagination'}
    {/if}

  </div>
</div>