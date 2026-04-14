{*
 * Purpose: Back-office form for slider/list repeater configuration.
 * Used from: `tc_homepromoslider::getContent`.
 * Inputs: `slides`, `list_title`, `list_items`.
 * Outputs: Form payload for module configuration save.
 * Side effects: Allows upload of image files for slides.
 *}
<div class="panel tc-home-promo-admin">
  <h3>{l s='Slider promocyjny strony głównej' d='Modules.Tc_homepromoslider.Admin'}</h3>
  <form method="post" action="{$form_action|escape:'htmlall':'UTF-8'}" enctype="multipart/form-data">
    <div class="form-group">
      <label class="control-label">{l s='Slajdy' d='Modules.Tc_homepromoslider.Admin'}</label>
      <p class="help-block">
        {l s='Możesz dodać dowolną liczbę slajdów. Dla każdego slajdu zalecane jest zdjęcie.' d='Modules.Tc_homepromoslider.Admin'}
      </p>
    </div>

    <div class="tc-home-promo-admin__repeater" data-tc-slides-repeater>
      <div class="tc-home-promo-admin__items" data-tc-repeater-items>
        {foreach from=$slides item=slide name=slide_items}
          <div class="tc-home-promo-admin__item" data-tc-slide-item>
            <div class="tc-home-promo-admin__item-header">
              <strong>{l s='Slajd' d='Modules.Tc_homepromoslider.Admin'} {$smarty.foreach.slide_items.iteration}</strong>
              <button type="button" class="btn btn-default tc-remove-slide" data-tc-remove-item>
                {l s='Usuń' d='Modules.Tc_homepromoslider.Admin'}
              </button>
            </div>
            <div class="row">
              <div class="col-lg-12">
                <div class="form-group">
                  <label>{l s='URL przycisku' d='Modules.Tc_homepromoslider.Admin'}</label>
                  <input type="text" class="form-control" data-tc-name="button_url" name="slides[{$smarty.foreach.slide_items.index}][button_url]" value="{$slide.button_url|escape:'htmlall':'UTF-8'}">
                </div>
                <div class="form-group">
                  <label>{l s='Obraz slajdu' d='Modules.Tc_homepromoslider.Admin'}</label>
                  <input type="file" class="form-control" data-tc-file-input name="slides_image[{$smarty.foreach.slide_items.index}]" accept="image/*">
                  <input type="hidden" data-tc-name="current_image" name="slides[{$smarty.foreach.slide_items.index}][current_image]" value="{$slide.image|escape:'htmlall':'UTF-8'}">
                </div>
                {if $slide.image}
                  <div class="tc-home-promo-admin__preview">
                    <img src="{$slide.image|escape:'htmlall':'UTF-8'}" alt="">
                  </div>
                {/if}
              </div>
            </div>
          </div>
        {/foreach}
      </div>
      <button type="button" class="btn btn-default" data-tc-add-slide>{l s='Dodaj slajd' d='Modules.Tc_homepromoslider.Admin'}</button>
    </div>

    <hr>

    <div class="form-group">
      <label class="control-label">{l s='Tytuł listy' d='Modules.Tc_homepromoslider.Admin'}</label>
      <input type="text" class="form-control" name="list_title" value="{$list_title|escape:'htmlall':'UTF-8'}">
    </div>

    <div class="form-group">
      <label class="control-label">{l s='Elementy listy' d='Modules.Tc_homepromoslider.Admin'}</label>
      <div class="tc-home-promo-admin__list" data-tc-list-repeater>
        <div class="tc-home-promo-admin__list-items" data-tc-list-items>
          {foreach from=$list_items item=item name=list_items_loop}
            <div class="tc-home-promo-admin__list-item" data-tc-list-item>
              <input type="text" class="form-control" name="list_items[]" value="{$item|escape:'htmlall':'UTF-8'}">
              <button type="button" class="btn btn-default" data-tc-remove-list-item>
                {l s='Usuń' d='Modules.Tc_homepromoslider.Admin'}
              </button>
            </div>
          {/foreach}
        </div>
        <button type="button" class="btn btn-default" data-tc-add-list-item>{l s='Dodaj element listy' d='Modules.Tc_homepromoslider.Admin'}</button>
      </div>
    </div>

    <div class="panel-footer">
      <button type="submit" name="submitTcHomePromoSlider" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Zapisz' d='Modules.Tc_homepromoslider.Admin'}
      </button>
    </div>
  </form>
</div>

<template id="tc-home-promo-slide-template">
  <div class="tc-home-promo-admin__item" data-tc-slide-item>
    <div class="tc-home-promo-admin__item-header">
      <strong>{l s='Nowy slajd' d='Modules.Tc_homepromoslider.Admin'}</strong>
      <button type="button" class="btn btn-default tc-remove-slide" data-tc-remove-item>
        {l s='Usuń' d='Modules.Tc_homepromoslider.Admin'}
      </button>
    </div>
    <div class="row">
      <div class="col-lg-12">
        <div class="form-group">
          <label>{l s='URL przycisku' d='Modules.Tc_homepromoslider.Admin'}</label>
          <input type="text" class="form-control" data-tc-name="button_url" value="#">
        </div>
        <div class="form-group">
          <label>{l s='Obraz slajdu' d='Modules.Tc_homepromoslider.Admin'}</label>
          <input type="file" class="form-control" data-tc-file-input accept="image/*">
          <input type="hidden" data-tc-name="current_image" value="">
        </div>
      </div>
    </div>
  </div>
</template>

<template id="tc-home-promo-list-item-template">
  <div class="tc-home-promo-admin__list-item" data-tc-list-item>
    <input type="text" class="form-control" name="list_items[]" value="">
    <button type="button" class="btn btn-default" data-tc-remove-list-item>
      {l s='Usuń' d='Modules.Tc_homepromoslider.Admin'}
    </button>
  </div>
</template>
