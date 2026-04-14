{**
 * Listing header: sort. Category PLP: tcp-sort-bar (bez przycisku „Filtr” — fasety w sidebarze, AJAX na input).
 * Inne listingi: klasyczny wiersz + sort + przycisk filtra na mobile jeśli są fasety.
 *}
{if isset($listing.tcp_category_plp) && $listing.tcp_category_plp}
  <div id="js-product-list-top" class="tcp-category-plp__products-top">
    <div class="tcp-sort-bar">
      <span class="tcp-sort-bar__label">{l s='Sortuj' d='Modules.Tc_collectionpages.Shop'}</span>
      <div class="tcp-sort-bar__select-wrap">
        <select
          name="order"
          class="tcp-sort-bar__select"
          data-tcp-category-sort-select
          aria-label="{l s='Sort by selection' d='Shop.Theme.Global'}"
        >
          {foreach from=$listing.sort_orders item=sort_order}
            <option
              value="{$sort_order.url|escape:'html':'UTF-8'}"
              {if !empty($sort_order.current)}selected="selected"{/if}
            >
              {$sort_order.label|escape:'html':'UTF-8'}
            </option>
          {/foreach}
        </select>
        <span class="tcp-sort-bar__arrow" aria-hidden="true"></span>
      </div>
    </div>
  </div>
{else}
  <div id="js-product-list-top" class="row products-selection">
    <div class="col-lg-5 hidden-sm-down total-products">
      {if $listing.pagination.total_items > 1}
        <p>{l s='There are %product_count% products.' d='Shop.Theme.Catalog' sprintf=['%product_count%' => $listing.pagination.total_items]}</p>
      {elseif $listing.pagination.total_items > 0}
        <p>{l s='There is 1 product.' d='Shop.Theme.Catalog'}</p>
      {/if}
    </div>
    <div class="col-lg-7">
      <div class="row sort-by-row">
        {block name='sort_by'}
          {include file='catalog/_partials/sort-orders.tpl' sort_orders=$listing.sort_orders}
        {/block}
        {if !empty($listing.rendered_facets)}
          <div class="col-xs-4 col-sm-3 hidden-md-up filter-button">
            <button id="search_filter_toggler" class="btn btn-secondary js-search-toggler">
              {l s='Filter' d='Shop.Theme.Actions'}
            </button>
          </div>
        {/if}
      </div>
    </div>
    <div class="col-sm-12 hidden-md-up text-sm-center showing">
      {l s='Showing %from%-%to% of %total% item(s)' d='Shop.Theme.Catalog' sprintf=[
        '%from%' => $listing.pagination.items_shown_from ,
        '%to%' => $listing.pagination.items_shown_to,
        '%total%' => $listing.pagination.total_items
      ]}
    </div>
  </div>
{/if}
