{*
 * Purpose: Back-office repeater form for tc_contentrows content rows.
 * Used from: tc_contentrows::getContent().
 * Inputs: $rows (array), $form_action (string).
 * Side effects: Image uploads saved to views/img/uploads/; config saved as JSON in Configuration.
 *}
<div class="panel tc-cr-admin">
  <h3>{l s='Wiersze treści' d='Modules.Tc_contentrows.Admin'}</h3>
  <p class="help-block">
    {l s='Każdy wiersz wyświetla treść (tytuł, opis, przycisk) naprzemiennie ze zdjęciem. Parzyste wiersze mają zdjęcie po lewej, nieparzyste po prawej.' d='Modules.Tc_contentrows.Admin'}
  </p>

  <form method="post" action="{$form_action|escape:'htmlall':'UTF-8'}" enctype="multipart/form-data" data-tc-cr-form>

    <div class="tc-cr-admin__repeater" data-tc-cr-repeater>
      <div class="tc-cr-admin__items" data-tc-cr-items>

        {foreach from=$rows item=row name=rowsLoop}
          {assign var=idx value=$smarty.foreach.rowsLoop.index}
          <div class="tc-cr-admin__item panel panel-default" data-tc-cr-item>
            <div class="panel-heading tc-cr-admin__item-header">
              <strong>{l s='Wiersz' d='Modules.Tc_contentrows.Admin'} {$smarty.foreach.rowsLoop.iteration}</strong>
              <div class="tc-cr-admin__item-actions">
                <button type="button" class="btn btn-default btn-sm" data-tc-cr-move-up>
                  &#8593; {l s='Wyżej' d='Modules.Tc_contentrows.Admin'}
                </button>
                <button type="button" class="btn btn-default btn-sm" data-tc-cr-move-down>
                  &#8595; {l s='Niżej' d='Modules.Tc_contentrows.Admin'}
                </button>
                <button type="button" class="btn btn-danger btn-sm" data-tc-cr-remove>
                  {l s='Usuń' d='Modules.Tc_contentrows.Admin'}
                </button>
              </div>
            </div>
            <div class="panel-body">
              <div class="row">
                <div class="col-lg-8">
                  <div class="form-group">
                    <label class="control-label">{l s='Tytuł' d='Modules.Tc_contentrows.Admin'}</label>
                    <input type="text"
                      class="form-control"
                      name="rows[{$idx}][title]"
                      data-tc-cr-name="title"
                      value="{$row.title|escape:'htmlall':'UTF-8'}">
                  </div>
                  <div class="form-group">
                    <label class="control-label">{l s='Opis' d='Modules.Tc_contentrows.Admin'}</label>
                    <textarea
                      class="form-control autoload_rte"
                      name="rows[{$idx}][description]"
                      data-tc-cr-name="description"
                      rows="6">{$row.description|escape:'htmlall':'UTF-8'}</textarea>
                  </div>
                  <div class="row">
                    <div class="col-lg-6">
                      <div class="form-group">
                        <label class="control-label">{l s='Etykieta przycisku' d='Modules.Tc_contentrows.Admin'}</label>
                        <input type="text"
                          class="form-control"
                          name="rows[{$idx}][button_label]"
                          data-tc-cr-name="button_label"
                          value="{$row.button_label|escape:'htmlall':'UTF-8'}">
                      </div>
                    </div>
                    <div class="col-lg-6">
                      <div class="form-group">
                        <label class="control-label">{l s='URL przycisku' d='Modules.Tc_contentrows.Admin'}</label>
                        <input type="text"
                          class="form-control"
                          name="rows[{$idx}][button_url]"
                          data-tc-cr-name="button_url"
                          value="{$row.button_url|escape:'htmlall':'UTF-8'}">
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-lg-4">
                  <div class="form-group">
                    <label class="control-label">{l s='Zdjęcie' d='Modules.Tc_contentrows.Admin'}</label>
                    {if $row.image}
                      <div class="tc-cr-admin__preview">
                        <img src="{$row.image|escape:'htmlall':'UTF-8'}" alt="">
                      </div>
                    {/if}
                    <input type="file"
                      class="form-control"
                      name="rows_image[{$idx}]"
                      data-tc-cr-file
                      accept="image/*">
                    <input type="hidden"
                      name="rows[{$idx}][image_keep]"
                      data-tc-cr-name="image_keep"
                      value="{$row.image|escape:'htmlall':'UTF-8'}">
                    <p class="help-block">{l s='Zalecany rozmiar: 640×800 px.' d='Modules.Tc_contentrows.Admin'}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        {/foreach}

      </div>{* /data-tc-cr-items *}

      <button type="button" class="btn btn-default" data-tc-cr-add>
        <i class="icon-plus"></i> {l s='Dodaj wiersz' d='Modules.Tc_contentrows.Admin'}
      </button>
    </div>{* /data-tc-cr-repeater *}

    <div class="panel-footer">
      <button type="submit" name="submitTcContentRows" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Zapisz' d='Modules.Tc_contentrows.Admin'}
      </button>
    </div>

  </form>
</div>

{* Template for a new (empty) row — field names without index; JS assigns them via reindex() *}
<template id="tc-cr-row-template">
  <div class="tc-cr-admin__item panel panel-default" data-tc-cr-item>
    <div class="panel-heading tc-cr-admin__item-header">
      <strong>{l s='Nowy wiersz' d='Modules.Tc_contentrows.Admin'}</strong>
      <div class="tc-cr-admin__item-actions">
        <button type="button" class="btn btn-default btn-sm" data-tc-cr-move-up>
          &#8593; {l s='Wyżej' d='Modules.Tc_contentrows.Admin'}
        </button>
        <button type="button" class="btn btn-default btn-sm" data-tc-cr-move-down>
          &#8595; {l s='Niżej' d='Modules.Tc_contentrows.Admin'}
        </button>
        <button type="button" class="btn btn-danger btn-sm" data-tc-cr-remove>
          {l s='Usuń' d='Modules.Tc_contentrows.Admin'}
        </button>
      </div>
    </div>
    <div class="panel-body">
      <div class="row">
        <div class="col-lg-8">
          <div class="form-group">
            <label class="control-label">{l s='Tytuł' d='Modules.Tc_contentrows.Admin'}</label>
            <input type="text" class="form-control" data-tc-cr-name="title" value="">
          </div>
          <div class="form-group">
            <label class="control-label">{l s='Opis' d='Modules.Tc_contentrows.Admin'}</label>
            <textarea class="form-control autoload_rte" data-tc-cr-name="description" rows="6"></textarea>
          </div>
          <div class="row">
            <div class="col-lg-6">
              <div class="form-group">
                <label class="control-label">{l s='Etykieta przycisku' d='Modules.Tc_contentrows.Admin'}</label>
                <input type="text" class="form-control" data-tc-cr-name="button_label" value="">
              </div>
            </div>
            <div class="col-lg-6">
              <div class="form-group">
                <label class="control-label">{l s='URL przycisku' d='Modules.Tc_contentrows.Admin'}</label>
                <input type="text" class="form-control" data-tc-cr-name="button_url" value="#">
              </div>
            </div>
          </div>
        </div>
        <div class="col-lg-4">
          <div class="form-group">
            <label class="control-label">{l s='Zdjęcie' d='Modules.Tc_contentrows.Admin'}</label>
            <input type="file" class="form-control" data-tc-cr-file accept="image/*">
            <input type="hidden" data-tc-cr-name="image_keep" value="">
            <p class="help-block">{l s='Zalecany rozmiar: 640×800 px.' d='Modules.Tc_contentrows.Admin'}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
