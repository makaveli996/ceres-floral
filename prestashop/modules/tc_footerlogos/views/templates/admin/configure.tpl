{*
 * Purpose: BO form for tc_footerlogos module with 2 repeaters (payments and delivery).
 * Used from: tc_footerlogos::getContent().
 * Inputs: $form_action, $payment_logos, $delivery_logos.
 * Side effects: Uploads images and stores JSON config.
 *}
<div class="panel tc-footerlogos-admin">
  <div class="panel-heading">
    <i class="icon-picture"></i>
    {l s='Stopka — logotypy płatności i dostawy' d='Modules.Tc_footerlogos.Admin'}
  </div>

  <form method="post" action="{$form_action|escape:'htmlall':'UTF-8'}" enctype="multipart/form-data">
    <div class="panel-body">
      <div class="row">
        <div class="col-lg-6">
          <h4>{l s='Dostępne płatności' d='Modules.Tc_footerlogos.Admin'}</h4>
          <div class="tc-footerlogos-admin__repeater" data-tc-fl-repeater="payment">
            <div class="tc-footerlogos-admin__items" data-tc-fl-items="payment">
              {foreach from=$payment_logos item=item name=paymentLoop}
                {assign var=idx value=$smarty.foreach.paymentLoop.index}
                <div class="tc-footerlogos-admin__item panel panel-default" data-tc-fl-item>
                  <div class="panel-heading tc-footerlogos-admin__item-header">
                    <strong>{l s='Logo' d='Modules.Tc_footerlogos.Admin'} {$smarty.foreach.paymentLoop.iteration}</strong>
                    <div class="tc-footerlogos-admin__item-actions">
                      <button type="button" class="btn btn-default btn-sm" data-tc-fl-remove>
                        {l s='Usuń' d='Modules.Tc_footerlogos.Admin'}
                      </button>
                    </div>
                  </div>
                  <div class="panel-body">
                    {if $item.image}
                      <div class="tc-footerlogos-admin__preview">
                        <img src="{$item.image|escape:'htmlall':'UTF-8'}" alt="">
                      </div>
                    {/if}
                    <input type="file" class="form-control" name="payment_logo[{$idx}]" data-tc-fl-file="payment" accept="image/*">
                    <input type="hidden" name="payment_logos[{$idx}][image_keep]" data-tc-fl-name="image_keep" value="{$item.image|escape:'htmlall':'UTF-8'}">
                    <div class="form-group">
                      <label class="control-label">{l s='Alt' d='Modules.Tc_footerlogos.Admin'}</label>
                      <input type="text" class="form-control" name="payment_logos[{$idx}][alt]" data-tc-fl-name="alt" value="{$item.alt|escape:'htmlall':'UTF-8'}">
                    </div>
                  </div>
                </div>
              {/foreach}
            </div>
            <button type="button" class="btn btn-default" data-tc-fl-add="payment">
              <i class="icon-plus"></i> {l s='Dodaj logo' d='Modules.Tc_footerlogos.Admin'}
            </button>
          </div>
        </div>

        <div class="col-lg-6">
          <h4>{l s='Dostawa' d='Modules.Tc_footerlogos.Admin'}</h4>
          <div class="tc-footerlogos-admin__repeater" data-tc-fl-repeater="delivery">
            <div class="tc-footerlogos-admin__items" data-tc-fl-items="delivery">
              {foreach from=$delivery_logos item=item name=deliveryLoop}
                {assign var=idx value=$smarty.foreach.deliveryLoop.index}
                <div class="tc-footerlogos-admin__item panel panel-default" data-tc-fl-item>
                  <div class="panel-heading tc-footerlogos-admin__item-header">
                    <strong>{l s='Logo' d='Modules.Tc_footerlogos.Admin'} {$smarty.foreach.deliveryLoop.iteration}</strong>
                    <div class="tc-footerlogos-admin__item-actions">
                      <button type="button" class="btn btn-default btn-sm" data-tc-fl-remove>
                        {l s='Usuń' d='Modules.Tc_footerlogos.Admin'}
                      </button>
                    </div>
                  </div>
                  <div class="panel-body">
                    {if $item.image}
                      <div class="tc-footerlogos-admin__preview">
                        <img src="{$item.image|escape:'htmlall':'UTF-8'}" alt="">
                      </div>
                    {/if}
                    <input type="file" class="form-control" name="delivery_logo[{$idx}]" data-tc-fl-file="delivery" accept="image/*">
                    <input type="hidden" name="delivery_logos[{$idx}][image_keep]" data-tc-fl-name="image_keep" value="{$item.image|escape:'htmlall':'UTF-8'}">
                    <div class="form-group">
                      <label class="control-label">{l s='Alt' d='Modules.Tc_footerlogos.Admin'}</label>
                      <input type="text" class="form-control" name="delivery_logos[{$idx}][alt]" data-tc-fl-name="alt" value="{$item.alt|escape:'htmlall':'UTF-8'}">
                    </div>
                  </div>
                </div>
              {/foreach}
            </div>
            <button type="button" class="btn btn-default" data-tc-fl-add="delivery">
              <i class="icon-plus"></i> {l s='Dodaj logo' d='Modules.Tc_footerlogos.Admin'}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="panel-footer">
      <button type="submit" name="submitTcFooterLogos" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Zapisz' d='Modules.Tc_footerlogos.Admin'}
      </button>
    </div>
  </form>
</div>

<template id="tc-fl-item-template">
  <div class="tc-footerlogos-admin__item panel panel-default" data-tc-fl-item>
    <div class="panel-heading tc-footerlogos-admin__item-header">
      <strong>{l s='Nowe logo' d='Modules.Tc_footerlogos.Admin'}</strong>
      <div class="tc-footerlogos-admin__item-actions">
        <button type="button" class="btn btn-default btn-sm" data-tc-fl-remove>
          {l s='Usuń' d='Modules.Tc_footerlogos.Admin'}
        </button>
      </div>
    </div>
    <div class="panel-body">
      <input type="file" class="form-control" data-tc-fl-file accept="image/*">
      <input type="hidden" data-tc-fl-name="image_keep" value="">
      <div class="form-group">
        <label class="control-label">{l s='Alt' d='Modules.Tc_footerlogos.Admin'}</label>
        <input type="text" class="form-control" data-tc-fl-name="alt" value="">
      </div>
    </div>
  </div>
</template>
