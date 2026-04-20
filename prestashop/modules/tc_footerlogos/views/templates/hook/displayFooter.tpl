{*
 * Purpose: Renders dynamic payment/delivery logo groups in footer.
 * Used from: tc_footerlogos::renderWidget().
 * Inputs: $tc_footerlogos_payment_logos, $tc_footerlogos_delivery_logos.
 *}
{if $tc_footerlogos_payment_logos|@count || $tc_footerlogos_delivery_logos|@count}
  <div class="tc-footer__brands">
    {if $tc_footerlogos_payment_logos|@count}
      <div class="tc-footer__brand-group">
        <p class="tc-footer__brand-title">{l s='Dostępne płatności' d='Shop.Theme.Global'}</p>
        <ul class="tc-footer__brand-list">
          {foreach from=$tc_footerlogos_payment_logos item=item}
            <li class="tc-footer__brand-item tc-footer__brand-item--logo">
              <img src="{$item.image|escape:'htmlall':'UTF-8'}" alt="{$item.alt|escape:'htmlall':'UTF-8'}" loading="lazy">
            </li>
          {/foreach}
        </ul>
      </div>
    {/if}

    {if $tc_footerlogos_delivery_logos|@count}
      <div class="tc-footer__brand-group tc-footer__brand-group--delivery">
        <p class="tc-footer__brand-title">{l s='Dostawa' d='Shop.Theme.Global'}</p>
        <ul class="tc-footer__brand-list">
          {foreach from=$tc_footerlogos_delivery_logos item=item}
            <li class="tc-footer__brand-item tc-footer__brand-item--logo">
              <img src="{$item.image|escape:'htmlall':'UTF-8'}" alt="{$item.alt|escape:'htmlall':'UTF-8'}" loading="lazy">
            </li>
          {/foreach}
        </ul>
      </div>
    {/if}
  </div>
{/if}
