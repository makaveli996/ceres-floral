{**
 * Category PLP pagination — same markup as collection (blog-pagination + #tcp-pagination) for parity with Figma.
 * Inputs: $pagination from $listing.pagination (ProductListingFrontController). Prev/next may be omitted on first/last page.
 *}
{if isset($pagination.should_be_displayed) && $pagination.should_be_displayed && isset($pagination.pages_count) && $pagination.pages_count > 1}
  <div id="tcp-pagination" data-tcp-pagination>
    <nav class="blog-pagination" aria-label="{l s='Paginacja' d='Shop.Theme.Catalog'}">
      <div class="links">
        {* Poprzednia — na stronie 1 wpis jest usuwany z tablicy; pokazujemy wyłączony stan jak w kolekcji *}
        {if isset($pagination.current_page) && $pagination.current_page <= 1}
          <span class="prev" aria-disabled="true">
            <span>{l s='Poprzednia strona' d='Modules.Tc_collectionpages.Shop'}</span>
          </span>
        {/if}

        {foreach from=$pagination.pages item=pg}
          {if $pg.type == 'previous'}
            <a
              href="{$pg.url|escape:'html':'UTF-8'}"
              class="prev js-search-link"
              rel="nofollow"
              title="{l s='Poprzednia strona' d='Modules.Tc_collectionpages.Shop'}"
            >
              <span>{l s='Poprzednia strona' d='Modules.Tc_collectionpages.Shop'}</span>
            </a>
          {elseif $pg.type == 'next'}
            <a
              href="{$pg.url|escape:'html':'UTF-8'}"
              class="next js-search-link"
              rel="nofollow"
              title="{l s='Następna strona' d='Modules.Tc_collectionpages.Shop'}"
            >
              <span>{l s='Następna strona' d='Modules.Tc_collectionpages.Shop'}</span>
            </a>
          {elseif $pg.type == 'spacer'}
            <p class="paginration_vv" aria-hidden="true">…</p>
          {elseif $pg.type == 'page'}
            {if !empty($pg.current)}
              <b>{$pg.page|intval}</b>
            {else}
              <a href="{$pg.url|escape:'html':'UTF-8'}" class="js-search-link" rel="nofollow">{$pg.page|intval}</a>
            {/if}
          {/if}
        {/foreach}

        {* Następna — na ostatniej stronie wpis usuwany z tablicy *}
        {if isset($pagination.current_page) && isset($pagination.pages_count) && $pagination.current_page >= $pagination.pages_count}
          <span class="next" aria-disabled="true">
            <span>{l s='Następna strona' d='Modules.Tc_collectionpages.Shop'}</span>
          </span>
        {/if}
      </div>
    </nav>
  </div>
{/if}
