{**
 * Category listing — PLP jak kolekcja (bez hero jak na /kolekcje): sidebar + grid product-tile.
 * Extends product-list.tpl for microdata; overrides `content` to match tcp-collection-detail layout.
 * AJAX: preserves #js-product-list, #search_filters, #js-active-search-filters selectors for ps_facetedsearch.
 *}
{extends file='catalog/listing/product-list.tpl'}

{block name='content'}
<section id="main">
  <div class="tcp-collection-detail tcp-collection-detail--category" data-tc-category-plp>

    {hook h="displayHeaderCategory"}

    <div class="tcp-collection-detail__layout container-lg">

      <aside class="tcp-collection-detail__sidebar" aria-label="{l s='Filter' d='Shop.Theme.Actions'}">
        {* tcp-sidebar-filters: nawigacja podkategorii (ID 18) z modułu tc_collectionpages + ps_facetedsearch *}
        <div class="tcp-sidebar-filters">
          {hook h='displayLeftColumn' mod='tc_collectionpages'}
          {if isset($listing.rendered_facets)}
            <div id="search_filters_wrapper" class="tcp-category-plp__facets-wrapper">
              {$listing.rendered_facets nofilter}
            </div>
          {/if}
        </div>
      </aside>

      <div class="tcp-collection-detail__main tcp-category-plp__main">

        {include file='catalog/_partials/products-top.tpl' listing=$listing}

        <section id="products">
          {if $listing.products|count}
            {include file='catalog/_partials/products.tpl' listing=$listing productClass=""}
            {include file='catalog/_partials/products-bottom.tpl' listing=$listing}
          {else}
            <div id="js-product-list-top"></div>

            <div id="js-product-list">
              {capture assign="errorContent"}
                <h4>{l s='No products available yet' d='Shop.Theme.Catalog'}</h4>
                <p>{l s='Stay tuned! More products will be shown here as they are added.' d='Shop.Theme.Catalog'}</p>
              {/capture}

              {include file='errors/not-found.tpl' errorContent=$errorContent notFoundHideSearch=1}
            </div>

            <div id="js-product-list-bottom"></div>
          {/if}
        </section>
      </div>
    </div>
  </div>

  {if isset($listing.tcp_inspiration_posts) && $listing.tcp_inspiration_posts}
    <section class="post-insp__related">
      {include file='_partials/inspirations-slider.tpl'
        is_title={l s='Inspirujące aranżacje' d='Modules.Tc_collectionpages.Shop'}
        is_posts=$listing.tcp_inspiration_posts
        is_cta_label={l s='Zobacz aranżację' d='Modules.Tc_collectionpages.Shop'}}
    </section>
  {/if}

  {capture name='tcpCollectionDescHook'}{hook h='displayListingDescriptionBottom' category=$category}{/capture}
  {assign var='tcp_has_category_desc' value=isset($category.description) && $category.description|strip_tags|trim ne ''}
  {if $tcp_has_category_desc || ($smarty.capture.tcpCollectionDescHook|default:''|strip ne '')}
    <section class="tcp-collection-description">
      <div class="container-lg">
        {if $tcp_has_category_desc}
          <div class="tcp-collection-description__body">
            {$category.description nofilter}
          </div>
        {/if}
        {if $smarty.capture.tcpCollectionDescHook|default:''|strip ne ''}
          <div class="tcp-collection-description__hook">
            {$smarty.capture.tcpCollectionDescHook nofilter}
          </div>
        {/if}
      </div>
    </section>
  {/if}

  {include file='catalog/_partials/category-footer.tpl' listing=$listing category=$category}

  {hook h="displayFooterCategory"}

</section>
{/block}
