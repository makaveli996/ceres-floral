{**
 * Theme override: ps_facetedsearch facets — markup aligned with tcp-sidebar-block (collection PLP / Figma).
 * Used when: listing.rendered_facets is rendered (category, search, etc.). Parent .tcp-collection-detail--category scopes extra CSS.
 * Keeps IDs (#search_filters, facet_*) and data attributes required by ps_facetedsearch JS.
 * Facet labels without magnitude counts. Feature / availability / attribute_group as tcp-sidebar-select (like tc_collectionpages).
 * Krótsze nagłówki dla wybranych grup atrybutów (nazwa techniczna w BO bez zmian w URL q).
 * Bez mobilnego accordionu ze strzałkami — jeden tytuł, treść zawsze widoczna.
 *}
{if $displayedFacets|count}
  <div id="search_filters" class="tcp-faceted-search">
    {block name='facets_title'}{/block}

    {block name='facets_clearall_button'}{/block}

    {foreach from=$displayedFacets item="facet"}
      {assign var=_expand_id value=10|mt_rand:100000}
      {* Tytuł bloku „extras” (Nowy / Przeceniony / …): w PL domyślne tłumaczenie to „Wybory” — pokazujemy „Wyróżnione”. *}
      {if $facet.type == 'extras'}
        {capture assign=_facetBlockTitle}{l s='Wyróżnione' d='Shop.Theme.Catalog'}{/capture}
      {elseif $facet.type == 'attribute_group'}
        {if $facet.label == 'Kolor korpusu'}
          {capture assign=_facetBlockTitle}{l s='Kolor' d='Shop.Theme.Catalog'}{/capture}
        {elseif $facet.label == 'Wymiar(wys. x szer. x gł.)'}
          {capture assign=_facetBlockTitle}{l s='Wymiar' d='Shop.Theme.Catalog'}{/capture}
        {else}
          {assign var=_facetBlockTitle value=$facet.label}
        {/if}
      {else}
        {assign var=_facetBlockTitle value=$facet.label}
      {/if}

      {assign var=_facet_as_select value=false}
      {if in_array($facet.widgetType, ['radio', 'checkbox']) && in_array($facet.type, ['feature', 'availability', 'attribute_group'])}
        {assign var=_facet_as_select value=true}
      {/if}

      {assign var=_facetShell value='tcp-sidebar-block facet'}
      {if in_array($facet.widgetType, ['dropdown', 'slider']) || $_facet_as_select}
        {assign var=_facetShell value='tcp-sidebar-block tcp-sidebar-block--no-bg facet'}
      {/if}

      <section class="{$_facetShell} clearfix" data-type="{$facet.type}" data-name="{$_facetBlockTitle|escape:'html':'UTF-8'}">

        {if $_facet_as_select}
          {assign var=_facet_clear_url value=''}
          {foreach from=$facet.filters item="_sf"}
            {if $_sf.active && $_facet_clear_url == ''}
              {assign var=_facet_clear_url value=$_sf.nextEncodedFacetsURL}
            {/if}
          {/foreach}

          <p class="facet-title tcp-sidebar-block__title">{$_facetBlockTitle}</p>
          <div class="tcp-sidebar-select-wrap">
            <select
              id="facet_select_{$_expand_id}"
              class="tcp-sidebar-select tcp-faceted-select"
              aria-label="{$_facetBlockTitle|escape:'html':'UTF-8'}"
              data-faceted-clear-url="{$_facet_clear_url|escape:'html':'UTF-8'}"
            >
              <option value="">
                {if $facet.type == 'availability'}
                  {l s='Wszystkie' d='Shop.Theme.Catalog'}
                {else}
                  {l s='Wybierz' d='Shop.Theme.Global'}
                {/if}
              </option>
              {foreach from=$facet.filters key=filter_key item="filter"}
                {if !$filter.displayed}
                  {continue}
                {/if}
                <option
                  value="{$filter.nextEncodedFacetsURL|escape:'html':'UTF-8'}"
                  {if $filter.active} selected="selected"{/if}
                >
                  {$filter.label|escape:'html':'UTF-8'}
                </option>
              {/foreach}
            </select>
            <span class="tcp-sidebar-select__arrow" aria-hidden="true"></span>
          </div>

        {else}

          <p class="facet-title tcp-sidebar-block__title">{$_facetBlockTitle}</p>

          {if in_array($facet.widgetType, ['radio', 'checkbox'])}
            {block name='facet_item_other'}
              <ul id="facet_{$_expand_id}" class="tcp-sidebar-block__list tcp-faceted-search__facet-list">
                {foreach from=$facet.filters key=filter_key item="filter"}
                  {if !$filter.displayed}
                    {continue}
                  {/if}

                  <li class="tcp-sidebar-block__check-item">
                    <label class="facet-label tcp-faceted-search__facet-label{if $filter.active} active {/if}" for="facet_input_{$_expand_id}_{$filter_key}">
                      {if $facet.multipleSelectionAllowed}
                        <span class="custom-checkbox tcp-faceted-search__checkbox">
                          <input
                            id="facet_input_{$_expand_id}_{$filter_key}"
                            data-search-url="{$filter.nextEncodedFacetsURL}"
                            type="checkbox"
                            {if $filter.active }checked{/if}
                          >
                          {if isset($filter.properties.color)}
                            <span class="color" style="background-color:{$filter.properties.color}"></span>
                          {elseif isset($filter.properties.texture)}
                            <span class="color texture" style="background-image:url({$filter.properties.texture})"></span>
                          {else}
                            <span {if !$js_enabled} class="ps-shown-by-js" {/if}><i class="material-icons rtl-no-flip checkbox-checked">&#xE5CA;</i></span>
                          {/if}
                        </span>
                      {else}
                        <span class="custom-radio tcp-faceted-search__radio">
                          <input
                            id="facet_input_{$_expand_id}_{$filter_key}"
                            data-search-url="{$filter.nextEncodedFacetsURL}"
                            type="radio"
                            name="filter {$facet.label}"
                            {if $filter.active }checked{/if}
                          >
                          <span {if !$js_enabled} class="ps-shown-by-js" {/if}></span>
                        </span>
                      {/if}

                      <a
                        href="{$filter.nextEncodedFacetsURL}"
                        class="_gray-darker search-link js-search-link tcp-faceted-search__facet-link"
                        rel="nofollow"
                      >
                        {$filter.label}
                      </a>
                    </label>
                  </li>
                {/foreach}
              </ul>
            {/block}

          {elseif $facet.widgetType == 'dropdown'}
            {block name='facet_item_dropdown'}
              <ul id="facet_{$_expand_id}" class="tcp-faceted-search__facet-dropdown">
                <li>
                  <div class="facet-dropdown dropdown tcp-sidebar-select-wrap">
                    <a class="select-title tcp-sidebar-select" rel="nofollow" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                      {$active_found = false}
                      <span>
                        {foreach from=$facet.filters item="filter"}
                          {if $filter.active}
                            {$filter.label}
                            {$active_found = true}
                          {/if}
                        {/foreach}
                        {if !$active_found}
                          {l s='(no filter)' d='Shop.Theme.Global'}
                        {/if}
                      </span>
                      <span class="tcp-sidebar-select__arrow" aria-hidden="true"></span>
                    </a>
                    <div class="dropdown-menu">
                      {foreach from=$facet.filters item="filter"}
                        {if !$filter.active}
                          <a
                            rel="nofollow"
                            href="{$filter.nextEncodedFacetsURL}"
                            class="select-list js-search-link"
                          >
                            {$filter.label}
                          </a>
                        {/if}
                      {/foreach}
                    </div>
                  </div>
                </li>
              </ul>
            {/block}

          {elseif $facet.widgetType == 'slider'}
            {block name='facet_item_slider'}
              {foreach from=$facet.filters item="filter"}
                {if $facet.type == 'price'}
                  {* Jak na stronie kolekcji: dwa pola liczbowe zamiast jQuery UI slider; URL jak ps_facetedsearch slider.js *}
                  <ul id="facet_{$_expand_id}" class="tcp-faceted-search__price">
                    <li>
                      <div
                        class="tcp-sidebar-price"
                        data-tcp-faceted-price="1"
                        data-tcp-price-encoded-url="{$filter.nextEncodedFacetsURL|escape:'html':'UTF-8'}"
                        data-tcp-price-label="{$facet.label|escape:'html':'UTF-8'}"
                        data-tcp-price-unit="{$facet.properties.unit|escape:'html':'UTF-8'}"
                        data-tcp-price-min="{$facet.properties.min}"
                        data-tcp-price-max="{$facet.properties.max}"
                        data-tcp-price-values="{$filter.value|@json_encode}"
                      >
                        <input
                          type="number"
                          id="facet_price_from_{$_expand_id}"
                          class="tcp-sidebar-price__input"
                          placeholder="{l s='Od' d='Shop.Theme.Global'}"
                          min="{$facet.properties.min}"
                          max="{$facet.properties.max}"
                          step="any"
                          data-tcp-faceted-price-from
                          autocomplete="off"
                        >
                        <input
                          type="number"
                          id="facet_price_to_{$_expand_id}"
                          class="tcp-sidebar-price__input"
                          placeholder="{l s='Do' d='Shop.Theme.Global'}"
                          min="{$facet.properties.min}"
                          max="{$facet.properties.max}"
                          step="any"
                          data-tcp-faceted-price-to
                          autocomplete="off"
                        >
                      </div>
                    </li>
                  </ul>
                {else}
                  <ul id="facet_{$_expand_id}"
                    class="faceted-slider tcp-faceted-search__slider"
                    data-slider-min="{$facet.properties.min}"
                    data-slider-max="{$facet.properties.max}"
                    data-slider-id="{$_expand_id}"
                    data-slider-values="{$filter.value|@json_encode}"
                    data-slider-unit="{$facet.properties.unit}"
                    data-slider-label="{$facet.label}"
                    data-slider-specifications="{$facet.properties.specifications|@json_encode}"
                    data-slider-encoded-url="{$filter.nextEncodedFacetsURL}"
                  >
                    <li>
                      <p id="facet_label_{$_expand_id}" class="tcp-faceted-search__slider-label">
                        {$filter.label}
                      </p>

                      <div id="slider-range_{$_expand_id}"></div>
                    </li>
                  </ul>
                {/if}
              {/foreach}
            {/block}
          {/if}

        {/if}
      </section>
    {/foreach}
  </div>
{else}
  <div id="search_filters" class="tcp-faceted-search" style="display:none;">
  </div>
{/if}
