{*
 * Purpose: Back-office configuration form for tc_location module.
 * Used from: tc_location::getContent().
 * Inputs: $conf (array: title, address, maps_url, maps_iframe), $images (array of stored slides), $form_action (string).
 * Side effects: Image uploads saved to views/img/uploads/; config saved as Configuration values.
 *}
<div class="panel tc-location-admin">
  <div class="panel-heading">
    <i class="icon-map-marker"></i>
    {l s='Sekcja lokalizacji — showroom' d='Modules.Tc_location.Admin'}
  </div>

  <form method="post" action="{$form_action|escape:'htmlall':'UTF-8'}"
        enctype="multipart/form-data" class="form-horizontal">

    <div class="panel-body">

      {* ── Scalar fields ── *}
      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Tytuł sekcji' d='Modules.Tc_location.Admin'}</label>
        <div class="col-lg-9">
          <input type="text" class="form-control" name="title"
            value="{$conf.title|escape:'htmlall':'UTF-8'}">
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Adres' d='Modules.Tc_location.Admin'}</label>
        <div class="col-lg-9">
          <input type="text" class="form-control" name="address"
            value="{$conf.address|escape:'htmlall':'UTF-8'}">
          <p class="help-block">{l s='Np. ul. Przykładowa 12, 00-000 Miasto' d='Modules.Tc_location.Admin'}</p>
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Link do Google Maps (nawigacja)' d='Modules.Tc_location.Admin'}</label>
        <div class="col-lg-9">
          <input type="url" class="form-control" name="maps_url"
            value="{$conf.maps_url|escape:'htmlall':'UTF-8'}">
          <p class="help-block">{l s='URL otwarty po kliknięciu „Nawiguj w Google Maps".' d='Modules.Tc_location.Admin'}</p>
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Mapa Google — src iframe' d='Modules.Tc_location.Admin'}</label>
        <div class="col-lg-9">
          <input type="text" class="form-control" name="maps_iframe"
            value="{$conf.maps_iframe|escape:'htmlall':'UTF-8'}">
          <p class="help-block">
            {l s='Wklej wartość atrybutu src z kodu iframe uzyskanego przez: Google Maps → Udostępnij → Umieść mapę.' d='Modules.Tc_location.Admin'}
          </p>
        </div>
      </div>

      <hr>

      {* ── Images repeater ── *}
      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Zdjęcia slidera' d='Modules.Tc_location.Admin'}</label>
        <div class="col-lg-9">
          <p class="help-block">
            {l s='Dodaj zdjęcia wyświetlane w sliderze. Zalecany rozmiar: 400×530 px.' d='Modules.Tc_location.Admin'}
          </p>

          <div class="tc-loc-admin__repeater" data-tc-loc-repeater>
            <div class="tc-loc-admin__items" data-tc-loc-items>

              {foreach from=$images item=img name=imgLoop}
                {assign var=idx value=$smarty.foreach.imgLoop.index}
                <div class="tc-loc-admin__item panel panel-default" data-tc-loc-item>
                  <div class="panel-heading tc-loc-admin__item-header">
                    <strong>{l s='Zdjęcie' d='Modules.Tc_location.Admin'} {$smarty.foreach.imgLoop.iteration}</strong>
                    <div class="tc-loc-admin__item-actions">
                      <button type="button" class="btn btn-default btn-sm" data-tc-loc-move-up>
                        &#8593; {l s='Wyżej' d='Modules.Tc_location.Admin'}
                      </button>
                      <button type="button" class="btn btn-default btn-sm" data-tc-loc-move-down>
                        &#8595; {l s='Niżej' d='Modules.Tc_location.Admin'}
                      </button>
                      <button type="button" class="btn btn-danger btn-sm" data-tc-loc-remove>
                        {l s='Usuń' d='Modules.Tc_location.Admin'}
                      </button>
                    </div>
                  </div>
                  <div class="panel-body">
                    {if $img.image}
                      <div class="tc-loc-admin__preview">
                        <img src="{$img.image|escape:'htmlall':'UTF-8'}" alt="">
                      </div>
                    {/if}
                    <input type="file"
                      class="form-control-file"
                      name="images_file[{$idx}]"
                      data-tc-loc-file
                      accept="image/*">
                    <input type="hidden"
                      name="images[{$idx}][image_keep]"
                      data-tc-loc-name="image_keep"
                      value="{$img.image|escape:'htmlall':'UTF-8'}">
                  </div>
                </div>
              {/foreach}

            </div>{* /data-tc-loc-items *}

            <button type="button" class="btn btn-default" data-tc-loc-add>
              <i class="icon-plus"></i> {l s='Dodaj zdjęcie' d='Modules.Tc_location.Admin'}
            </button>
          </div>{* /data-tc-loc-repeater *}
        </div>
      </div>

    </div>{* /panel-body *}

    <div class="panel-footer">
      <button type="submit" name="submitTcLocation" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Zapisz' d='Modules.Tc_location.Admin'}
      </button>
    </div>

  </form>
</div>

{* Template for new (empty) image row — JS assigns field names with proper index *}
<template id="tc-loc-image-template">
  <div class="tc-loc-admin__item panel panel-default" data-tc-loc-item>
    <div class="panel-heading tc-loc-admin__item-header">
      <strong>{l s='Nowe zdjęcie' d='Modules.Tc_location.Admin'}</strong>
      <div class="tc-loc-admin__item-actions">
        <button type="button" class="btn btn-default btn-sm" data-tc-loc-move-up>
          &#8593; {l s='Wyżej' d='Modules.Tc_location.Admin'}
        </button>
        <button type="button" class="btn btn-default btn-sm" data-tc-loc-move-down>
          &#8595; {l s='Niżej' d='Modules.Tc_location.Admin'}
        </button>
        <button type="button" class="btn btn-danger btn-sm" data-tc-loc-remove>
          {l s='Usuń' d='Modules.Tc_location.Admin'}
        </button>
      </div>
    </div>
    <div class="panel-body">
      <input type="file" class="form-control" data-tc-loc-file accept="image/*">
      <input type="hidden" data-tc-loc-name="image_keep" value="">
    </div>
  </div>
</template>
