{*
 * Purpose: Back-office repeater form for category slider segments.
 * Used from: tc_categoryslider::getContent().
 * Inputs: $segments (array), $categories (array of {id, name}), $form_action (string).
 * Side effects: Image uploads saved to views/img/uploads/; config saved as JSON.
 *}
<div class="panel tc-categoryslider-admin">
  <h3>{l s='Segmenty slidera kategorii' d='Modules.Tc_categoryslider.Admin'}</h3>
  <p class="help-block">
    {l s='Każdy segment składa się z obrazka tła oraz wybranej kategorii — jej produkty będą wyświetlane w sliderze.' d='Modules.Tc_categoryslider.Admin'}
  </p>

  <form method="post" action="{$form_action|escape:'htmlall':'UTF-8'}" enctype="multipart/form-data">

    <div class="tc-cs-admin__repeater" data-tc-cs-repeater>
      <div class="tc-cs-admin__items" data-tc-cs-items>

        {foreach from=$segments item=seg name=segsLoop}
          {assign var=idx value=$smarty.foreach.segsLoop.index}
          <div class="tc-cs-admin__item panel panel-default" data-tc-cs-item>
            <div class="panel-heading tc-cs-admin__item-header">
              <strong>{l s='Segment' d='Modules.Tc_categoryslider.Admin'} {$smarty.foreach.segsLoop.iteration}</strong>
              <div class="tc-cs-admin__item-actions">
                <button type="button" class="btn btn-default btn-sm tc-cs-move-up" data-tc-cs-move-up>
                  &#8593; {l s='Wyżej' d='Modules.Tc_categoryslider.Admin'}
                </button>
                <button type="button" class="btn btn-default btn-sm tc-cs-move-down" data-tc-cs-move-down>
                  &#8595; {l s='Niżej' d='Modules.Tc_categoryslider.Admin'}
                </button>
                <button type="button" class="btn btn-danger btn-sm tc-cs-remove" data-tc-cs-remove>
                  {l s='Usuń' d='Modules.Tc_categoryslider.Admin'}
                </button>
              </div>
            </div>
            <div class="panel-body row">
              <div class="col-lg-6">
                <div class="form-group">
                  <label class="control-label">{l s='Kategoria' d='Modules.Tc_categoryslider.Admin'} <span class="required">*</span></label>
                  <select class="form-control" name="segments[{$idx}][id_category]" data-tc-cs-name="id_category">
                    <option value="0">{l s='— wybierz kategorię —' d='Modules.Tc_categoryslider.Admin'}</option>
                    {foreach from=$categories item=cat}
                      <option value="{$cat.id|intval}" {if $cat.id == $seg.id_category}selected="selected"{/if}>
                        {$cat.name|escape:'html':'UTF-8'}
                      </option>
                    {/foreach}
                  </select>
                </div>
              </div>
              <div class="col-lg-6">
                <div class="form-group">
                  <label class="control-label">{l s='Obraz tła' d='Modules.Tc_categoryslider.Admin'}</label>
                  {if $seg.image}
                    <div class="tc-cs-admin__preview">
                      <img src="{$seg.image|escape:'htmlall':'UTF-8'}" alt="">
                    </div>
                  {/if}
                  <input type="file"
                    class="form-control"
                    name="segments_image[{$idx}]"
                    data-tc-cs-file
                    accept="image/*">
                  <input type="hidden"
                    name="segments[{$idx}][image_keep]"
                    data-tc-cs-name="image_keep"
                    value="{$seg.image|escape:'htmlall':'UTF-8'}">
                  <p class="help-block">{l s='Zalecany rozmiar: 570×600 px.' d='Modules.Tc_categoryslider.Admin'}</p>
                </div>
              </div>
            </div>
          </div>
        {/foreach}

      </div>{* /data-tc-cs-items *}

      <button type="button" class="btn btn-default" data-tc-cs-add>
        <i class="icon-plus"></i> {l s='Dodaj segment' d='Modules.Tc_categoryslider.Admin'}
      </button>
    </div>{* /data-tc-cs-repeater *}

    <div class="panel-footer">
      <button type="submit" name="submitTcCategorySlider" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Zapisz' d='Modules.Tc_categoryslider.Admin'}
      </button>
    </div>

  </form>
</div>

{* Template for a new (empty) segment row — names intentionally without index; JS assigns them *}
<template id="tc-cs-segment-template">
  <div class="tc-cs-admin__item panel panel-default" data-tc-cs-item>
    <div class="panel-heading tc-cs-admin__item-header">
      <strong>{l s='Nowy segment' d='Modules.Tc_categoryslider.Admin'}</strong>
      <div class="tc-cs-admin__item-actions">
        <button type="button" class="btn btn-default btn-sm tc-cs-move-up" data-tc-cs-move-up>
          &#8593; {l s='Wyżej' d='Modules.Tc_categoryslider.Admin'}
        </button>
        <button type="button" class="btn btn-default btn-sm tc-cs-move-down" data-tc-cs-move-down>
          &#8595; {l s='Niżej' d='Modules.Tc_categoryslider.Admin'}
        </button>
        <button type="button" class="btn btn-danger btn-sm tc-cs-remove" data-tc-cs-remove>
          {l s='Usuń' d='Modules.Tc_categoryslider.Admin'}
        </button>
      </div>
    </div>
    <div class="panel-body row">
      <div class="col-lg-6">
        <div class="form-group">
          <label class="control-label">{l s='Kategoria' d='Modules.Tc_categoryslider.Admin'} <span class="required">*</span></label>
          <select class="form-control" data-tc-cs-name="id_category">
            <option value="0">{l s='— wybierz kategorię —' d='Modules.Tc_categoryslider.Admin'}</option>
            {foreach from=$categories item=cat}
              <option value="{$cat.id|intval}">{$cat.name|escape:'html':'UTF-8'}</option>
            {/foreach}
          </select>
        </div>
      </div>
      <div class="col-lg-6">
        <div class="form-group">
          <label class="control-label">{l s='Obraz tła' d='Modules.Tc_categoryslider.Admin'}</label>
          <input type="file" class="form-control" data-tc-cs-file accept="image/*">
          <input type="hidden" data-tc-cs-name="image_keep" value="">
          <p class="help-block">{l s='Zalecany rozmiar: 570×600 px.' d='Modules.Tc_categoryslider.Admin'}</p>
        </div>
      </div>
    </div>
  </div>
</template>
