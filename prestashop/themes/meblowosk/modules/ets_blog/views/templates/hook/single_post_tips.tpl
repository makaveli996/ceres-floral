{*
 * Tips single post layout — 3-column editorial: share sidebar | content | products sidebar + related articles.
 * Used by: single_post.tpl dispatcher when post belongs to 'porady' category.
 * Inputs: $blog_post (id_post, title, image, description, short_description, categories, tags, related_posts, date_add, link),
 *         $show_date, $show_categories, $date_format,
 *         $tc_post_accordion_items (array, injected by ets_blog override controller),
 *         $tc_post_products (array of assembled products, injected by override controller).
 * Side effects: none — rendering only.
 *}
<script type="text/javascript">
    ets_blog_report_url = '{$report_url nofilter}';
</script>

{assign var='date_format' value='d.m.Y'}
{assign var='_post_url' value=$blog_post.link|escape:'html':'UTF-8'}
{assign var='_post_url_enc' value=$blog_post.link|urlencode}
{assign var='_post_title_enc' value=$blog_post.title|urlencode}
{assign var='_has_products' value=false}
{if isset($tc_post_products) && $tc_post_products}{assign var='_has_products' value=true}{/if}

<div class="post-tips">
  <div class="container-lg">
      <div class="post-tips__layout{if $_has_products} post-tips__layout--has-products{/if}">

        {* ── LEFT: Sticky share sidebar ── *}
        <aside class="post-tips__share-col" aria-label="Udostępnij">
          <div class="post-tips__share" data-post-share>
            <p class="post-tips__share-label">Udostępnij</p>
            <a
              class="post-tips__share-btn post-tips__share-btn--fb"
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
              class="post-tips__share-btn post-tips__share-btn--li"
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
              class="post-tips__share-btn post-tips__share-btn--mail"
              href="mailto:?subject={$_post_title_enc}&amp;body={$_post_url_enc}"
              title="Wyślij pocztą"
              aria-label="Wyślij pocztą"
            >
              <svg width="21" height="17" viewBox="0 0 21 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M18.9 0H2.1C0.945 0 0.0105 0.95625 0.0105 2.125L0 14.875C0 16.0438 0.945 17 2.1 17H18.9C20.055 17 21 16.0438 21 14.875V2.125C21 0.95625 20.055 0 18.9 0ZM18.9 4.25L10.5 9.5625L2.1 4.25V2.125L10.5 7.4375L18.9 2.125V4.25Z" fill="#8D8D8D"/>
              </svg>          
            </a>
          </div>
        </aside>

        {* ── CENTER: Main article content ── *}
        <main class="post-tips__main" itemprop="articleBody">

          {* Meta: subcategory badges (non-clickable) + date — root categories (porady/inspiracje) skipped *}
          <div class="post-tips__meta">
            {if $show_categories && $blog_post.categories}
              {foreach from=$blog_post.categories item='cat'}
                {if $cat.url_alias == 'porady' || $cat.url_alias == 'inspiracje'}{continue}{/if}
                <span class="post-tips__meta-cat">{$cat.title|escape:'html':'UTF-8'}</span>
              {/foreach}
            {/if}
            {if $show_date}
              <span class="post-tips__meta-date">
                {date($date_format, strtotime($blog_post.date_add))|escape:'html':'UTF-8'}
              </span>
            {/if}
          </div>

          {* Title *}
          <h1 class="post-tips__title" itemprop="headline">
            {$blog_post.title|escape:'html':'UTF-8'}
          </h1>

          {* Featured image *}
          {if $blog_post.image}
            <div class="post-tips__featured-img-wrap">
              <img
                src="{$blog_post.image|escape:'html':'UTF-8'}"
                alt="{$blog_post.title|escape:'html':'UTF-8'}"
                class="post-tips__featured-img"
                itemprop="url"
              />
            </div>
          {/if}

          {* Post content *}
          <div class="post-tips__content blog_description">
            {if $blog_post.description}
              {$blog_post.description nofilter}
            {else}
              {$blog_post.short_description nofilter}
            {/if}
          </div>

          {* Accordion summary *}
          {if isset($tc_post_accordion_items) && $tc_post_accordion_items}
            <div class="post-tips__accordion" data-tc-faq>
              <h2 class="post-tips__accordion-title">Podsumowanie artykułu</h2>
              <div class="tc-faq__list">
                {foreach from=$tc_post_accordion_items item='aitem' name='aloop'}
                  {assign var='aidx' value=$smarty.foreach.aloop.index}
                  <article class="tc-faq__item" data-tc-faq-item>
                    <button
                      class="tc-faq__trigger"
                      type="button"
                      data-tc-faq-trigger
                      aria-expanded="false"
                      aria-controls="post-faq-panel-{$aidx}"
                      id="post-faq-trigger-{$aidx}"
                    >
                      <span class="tc-faq__question">{$aitem.question|escape:'html':'UTF-8'}</span>
                      <span class="tc-faq__icon" aria-hidden="true">
                        <svg width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <path d="M10.5 4.58969e-07C16.299 7.12451e-07 21 4.70101 21 10.5C21 16.299 16.299 21 10.5 21C4.70101 21 2.05488e-07 16.299 4.5897e-07 10.5C7.12451e-07 4.70101 4.70101 2.05487e-07 10.5 4.58969e-07Z" fill="#F7A626"/>
                          <path d="M10.9231 12.8119C10.7133 13.0975 10.2867 13.0975 10.0769 12.8119L7.93155 9.89232C7.67678 9.5456 7.92436 9.05645 8.35462 9.05645L12.6454 9.05645C13.0756 9.05645 13.3232 9.5456 13.0684 9.89232L10.9231 12.8119Z" fill="#1E1E1E"/>
                        </svg>
                      </span>
                    </button>
                    <div
                      class="tc-faq__panel"
                      id="post-faq-panel-{$aidx}"
                      data-tc-faq-panel
                      role="region"
                      aria-labelledby="post-faq-trigger-{$aidx}"
                    >
                      <div class="tc-faq__answer">
                        {if $aitem.answer}{$aitem.answer nofilter}{/if}
                      </div>
                    </div>
                  </article>
                {/foreach}
              </div>
            </div>
          {/if}

        </main>{* /.post-tips__main *}

        {* ── RIGHT: Recommended products sidebar ── *}
        {if isset($tc_post_products) && $tc_post_products}
          <aside class="post-tips__products-col">
            <div class="post-tips__products-col-inner">
              <h2 class="post-tips__products-title">Polecane produkty</h2>
              <div class="post-tips__products-list">
                {foreach from=$tc_post_products item='product'}
                  {include file='_partials/product-tile.tpl' product=$product}
                {/foreach}
              </div>
            </div>
          </aside>
        {/if}

      </div>{* /.post-tips__layout *}
  </div>
</div>{* /.post-tips *}

{* ── BOTTOM: Related articles (full-width bg) ── *}
{if isset($blog_post.related_posts) && $blog_post.related_posts}
  <section class="post-tips__related-section">
    <div class="container-lg">
      <h2 class="post-tips__related-title">Polecane inne artykuły</h2>
      <ul class="post-tips__related-grid">
        {foreach from=$blog_post.related_posts item='rpost'}
          {assign var='_rpost_image' value=''}
          {if $rpost.thumb}
            {assign var='_rpost_image' value=$rpost.thumb}
          {elseif $rpost.image}
            {assign var='_rpost_image' value=$rpost.image}
          {/if}
          {assign var='_rpost_cat' value=''}
          {if isset($rpost.categories) && $rpost.categories}
            {assign var='_rpost_cat' value=$rpost.categories[0].title}
          {/if}
          {capture assign='_rpost_date_disp'}{date($date_format, strtotime($rpost.date_add))}{/capture}
          {assign var='_rpost_iso' value=$rpost.date_add|date_format:'%Y-%m-%d'}
          {include file='_partials/post-card.tpl'
            post_card_url=$rpost.link
            post_card_title=$rpost.title
            post_card_image=$_rpost_image
            post_card_category=$_rpost_cat
            post_card_date=$_rpost_date_disp
            post_card_datetime=$_rpost_iso}
        {/foreach}
      </ul>
    </div>
  </section>
{/if}
