{*
 * Inspiracje single post — 2-column layout: content column + sticky sidebar with banners.
 * Used by: single_post.tpl dispatcher when post belongs to 'inspiracje' category.
 * Inputs: $blog_post, $show_date, $show_categories, $date_format,
 *         $tc_post_gallery (injected by override), $tc_arrangement_products (injected),
 *         $tc_post_author (injected by override), $tc_sidebar_banners_html (injected by override).
 * Side effects: none — rendering only.
 *}
<script type="text/javascript">
    ets_blog_report_url = '{$report_url nofilter}';
</script>

{assign var='date_format' value='d.m.Y'}
{assign var='_post_url' value=$blog_post.link|escape:'html':'UTF-8'}
{assign var='_post_url_enc' value=$blog_post.link|urlencode}
{assign var='_post_title_enc' value=$blog_post.title|urlencode}

<div class="post-insp">
  <div class="container-lg">
    <div class="post-insp__layout">

      {* ── MAIN COLUMN ── *}
      <main class="post-insp__main">

        {* Meta: subcategories (non-clickable, skip root) + date *}
        <div class="post-insp__meta">
          {if $show_categories && $blog_post.categories}
            {foreach from=$blog_post.categories item='cat'}
              {if $cat.url_alias == 'porady' || $cat.url_alias == 'inspiracje'}{continue}{/if}
              <span class="post-insp__meta-cat">{$cat.title|escape:'html':'UTF-8'}</span>
            {/foreach}
          {/if}
          {if $show_date}
            <span class="post-insp__meta-date">
              {date($date_format, strtotime($blog_post.date_add))|escape:'html':'UTF-8'}
            </span>
          {/if}
        </div>

        {* Title *}
        <h1 class="post-insp__title" itemprop="headline">
          {$blog_post.title|escape:'html':'UTF-8'}
        </h1>

        {* Short description — bold lead text *}
        {if isset($blog_post.short_description) && $blog_post.short_description}
          <div class="post-insp__lead">{$blog_post.short_description nofilter}</div>
        {/if}

        {* ── Gallery slider (replaces featured image) ── *}
        {if isset($tc_post_gallery) && $tc_post_gallery}
          <div class="post-insp__gallery-wrap">
            {include file='_partials/gallery-slider.tpl'
              gs_slides=$tc_post_gallery
              gs_splide_attr='data-post-insp-splide'
              gs_label=$blog_post.title
              gs_default_alt=$blog_post.title}
          </div>
        {elseif $blog_post.image}
          {* Fallback: featured image if no gallery *}
          <div class="post-insp__featured-img-wrap">
            <img
              src="{$blog_post.image|escape:'html':'UTF-8'}"
              alt="{$blog_post.title|escape:'html':'UTF-8'}"
              class="post-insp__featured-img"
              itemprop="url"
            />
          </div>
        {/if}

        {* Content *}
        <div class="post-insp__content blog_description" itemprop="articleBody">
          {if $blog_post.description}
            {$blog_post.description nofilter}
          {else}
            {$blog_post.short_description nofilter}
          {/if}
        </div>

        {* Tags *}
        {if isset($blog_post.tags) && $blog_post.tags}
          <div class="post-insp__tags">
            {foreach from=$blog_post.tags item='tag'}
              <a href="{$tag.link|escape:'html':'UTF-8'}" class="post-insp__tag">
                {ucfirst($tag.tag)|escape:'html':'UTF-8'}
              </a>
            {/foreach}
          </div>
        {/if}

        {* ── Meble użyte w aranżacji ── *}
        {if isset($tc_arrangement_products) && $tc_arrangement_products}
          <section class="post-insp__furniture">
            <h2 class="post-insp__section-title">Meble użyte w aranżacji</h2>
            <div class="post-insp__furniture-grid">
              {foreach from=$tc_arrangement_products item='product'}
                {include file='_partials/product-tile.tpl' product=$product}
              {/foreach}
            </div>
          </section>
        {/if}

        {* ── Author + Share bar ── *}
        <div class="post-insp__author-bar">
          {if isset($tc_post_author) && $tc_post_author.author_name}
            <div class="post-insp__author">
              {if $tc_post_author.author_photo_url}
                <img
                  src="{$tc_post_author.author_photo_url|escape:'html':'UTF-8'}"
                  alt="{$tc_post_author.author_name|escape:'html':'UTF-8'}"
                  class="post-insp__author-avatar"
                />
              {else}
                <span class="post-insp__author-avatar post-insp__author-avatar--placeholder" aria-hidden="true">
                  <svg width="36" height="36" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="12" cy="8" r="4" fill="currentColor"/>
                    <path d="M4 20c0-4 3.582-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.5" fill="none"/>
                  </svg>
                </span>
              {/if}
              <div class="post-insp__author-info">
                <span class="post-insp__author-label">Autor aranżacji</span>
                <strong class="post-insp__author-name">{$tc_post_author.author_name|escape:'html':'UTF-8'}</strong>
              </div>
            </div>
          {/if}

          <div class="post-insp__share">
            <span class="post-insp__share-label">Podoba Ci się? Podziel się</span>
            <div class="post-insp__share-btns">
              <a
                class="post-insp__share-btn post-insp__share-btn--fb"
                href="https://www.facebook.com/sharer/sharer.php?u={$_post_url_enc}"
                target="_blank"
                rel="noopener noreferrer"
                title="Udostępnij na Facebook"
                aria-label="Udostępnij na Facebook"
              >
                <svg width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20.16 0H0.84C0.375375 0 0 0.375375 0 0.84V20.16C0 20.6246 0.375375 21 0.84 21H20.16C20.6246 21 21 20.6246 21 20.16V0.84C21 0.375375 20.6246 0 20.16 0ZM17.7345 6.12937H16.0571C14.742 6.12937 14.4874 6.75412 14.4874 7.67287V9.69675H17.6269L17.2174 12.8651H14.4874V21H11.214V12.8678H8.47612V9.69675H11.214V7.3605C11.214 4.64887 12.8704 3.171 15.2906 3.171C16.4509 3.171 17.4457 3.25763 17.7371 3.297V6.12937H17.7345Z" fill="#8D8D8D"/>
                </svg>
              </a>
              <a
                class="post-insp__share-btn post-insp__share-btn--li"
                href="https://www.linkedin.com/sharing/share-offsite/?url={$_post_url_enc}"
                target="_blank"
                rel="noopener noreferrer"
                title="Udostępnij na LinkedIn"
                aria-label="Udostępnij na LinkedIn"
              >
                <svg width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20.16 0H0.84C0.375375 0 0 0.375375 0 0.84V20.16C0 20.6246 0.375375 21 0.84 21H20.16C20.6246 21 21 20.6246 21 20.16V0.84C21 0.375375 20.6246 0 20.16 0ZM6.22912 17.8946H3.11325V7.87237H6.22912V17.8946ZM4.6725 6.50213C4.31531 6.50213 3.96614 6.3962 3.66914 6.19776C3.37214 5.99931 3.14067 5.71725 3.00397 5.38725C2.86728 5.05725 2.83152 4.69412 2.9012 4.34379C2.97089 3.99346 3.14289 3.67166 3.39547 3.41909C3.64804 3.16652 3.96984 2.99451 4.32017 2.92483C4.6705 2.85514 5.03362 2.89091 5.36363 3.0276C5.69363 3.16429 5.97569 3.39577 6.17413 3.69277C6.37258 3.98976 6.4785 4.33893 6.4785 4.69612C6.47587 5.69362 5.66738 6.50213 4.6725 6.50213ZM17.8946 17.8946H14.7814V13.02C14.7814 11.8571 14.7604 10.3635 13.1617 10.3635C11.5421 10.3635 11.2928 11.6287 11.2928 12.936V17.8946H8.18213V7.87237H11.1694V9.24263H11.2114C11.6261 8.45512 12.642 7.623 14.1593 7.623C17.3145 7.623 17.8946 9.69937 17.8946 12.3979V17.8946Z" fill="#8D8D8D"/>
                </svg>
              </a>
              <a
                class="post-insp__share-btn post-insp__share-btn--mail"
                href="mailto:?subject={$_post_title_enc}&amp;body={$_post_url_enc}"
                title="Wyślij pocztą"
                aria-label="Wyślij pocztą"
              >
                <svg width="21" height="17" viewBox="0 0 21 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M18.9 0H2.1C0.945 0 0.0105 0.95625 0.0105 2.125L0 14.875C0 16.0438 0.945 17 2.1 17H18.9C20.055 17 21 16.0438 21 14.875V2.125C21 0.95625 20.055 0 18.9 0ZM18.9 4.25L10.5 9.5625L2.1 4.25V2.125L10.5 7.4375L18.9 2.125V4.25Z" fill="#8D8D8D"/>
                </svg>
              </a>
            </div>
          </div>
        </div>

      </main>{* /.post-insp__main *}

      {* ── RIGHT SIDEBAR — sticky banners ── *}
      <aside class="post-insp__sidebar" aria-label="Sidebar">
        <div class="post-insp__sidebar-inner">
          {if isset($tc_sidebar_banners_html) && $tc_sidebar_banners_html}
            {$tc_sidebar_banners_html nofilter}
          {/if}
        </div>
      </aside>

    </div>{* /.post-insp__layout *}
  </div>{* /.container-lg *}
</div>{* /.post-insp *}

{* ── RELATED POSTS — full-width "Zobacz inne podobne inspiracje" ── *}
{* Uses _partials/inspirations-slider.tpl (BEM component). Section provides bg colour + padding. *}
{if isset($blog_post.related_posts) && $blog_post.related_posts}
  <section class="post-insp__related">
    {include file='_partials/inspirations-slider.tpl'
      is_title={l s='Zobacz inne podobne inspiracje' mod='ets_blog'}
      is_posts=$blog_post.related_posts
      is_cta_label={l s='Zobacz aranżację' mod='ets_blog'}}
  </section>
{/if}
