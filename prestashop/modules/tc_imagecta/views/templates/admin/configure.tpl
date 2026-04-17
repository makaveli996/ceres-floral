{*
 * Purpose: Back-office configuration form for tc_imagecta module.
 * Used from: tc_imagecta::getContent().
 * Inputs: $form_action, $conf (array with all config values).
 * Outputs: HTML form for managing title, description, CTA, and 6 image uploads.
 * Side effects: None.
 *}
<style>
  .tc-admin-section {
    background: #f8f8f8;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 20px 24px 12px;
    margin-bottom: 24px;
  }
  .tc-admin-section__title {
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    color: #555;
    margin: 0 0 16px;
    padding-bottom: 10px;
    border-bottom: 2px solid #dde;
  }
  .tc-admin-img-field {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    flex-wrap: wrap;
  }
  .tc-admin-img-preview {
    width: 100px;
    height: 100px;
    object-fit: cover;
    border: 1px solid #ccc;
    border-radius: 4px;
    background: #eee;
    flex-shrink: 0;
  }
  .tc-admin-img-placeholder {
    width: 100px;
    height: 100px;
    border: 2px dashed #ccc;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #aaa;
    font-size: 11px;
    text-align: center;
    flex-shrink: 0;
  }
  .tc-admin-img-input { flex: 1; min-width: 200px; }
  .tc-admin-img-input label { font-weight: 600; margin-bottom: 6px; display: block; color: #444; }
  .tc-admin-img-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 20px;
  }
  @media (max-width: 992px) {
    .tc-admin-img-grid { grid-template-columns: 1fr; }
  }
</style>

<div class="panel">
  <div class="panel-heading">
    <i class="icon-picture"></i>
    {l s='Image CTA — konfiguracja' mod='tc_imagecta'}
  </div>

  <form action="{$form_action|escape:'html':'UTF-8'}" method="post"
        enctype="multipart/form-data" class="form-horizontal">

    {* ── TREŚĆ ── *}
    <div class="tc-admin-section">
      <p class="tc-admin-section__title">{l s='Treść sekcji' mod='tc_imagecta'}</p>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Nagłówek (H2)' mod='tc_imagecta'}</label>
        <div class="col-lg-9">
          <input type="text" name="title" class="form-control"
            value="{$conf.title|escape:'html':'UTF-8'}">
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Opis' mod='tc_imagecta'}</label>
        <div class="col-lg-9">
          <textarea name="description" class="form-control" rows="3">{$conf.description|escape:'html':'UTF-8'}</textarea>
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Etykieta przycisku' mod='tc_imagecta'}</label>
        <div class="col-lg-9">
          <input type="text" name="btn_label" class="form-control"
            value="{$conf.btn_label|escape:'html':'UTF-8'}">
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='URL przycisku' mod='tc_imagecta'}</label>
        <div class="col-lg-9">
          <input type="text" name="btn_url" class="form-control"
            value="{$conf.btn_url|escape:'html':'UTF-8'}">
        </div>
      </div>
    </div>

    {* ── LEWA STRONA ── *}
    <div class="tc-admin-section">
      <p class="tc-admin-section__title">{l s='Lewa strona — mozaika obrazków' mod='tc_imagecta'}</p>
      <div class="tc-admin-img-grid">

        <div class="tc-admin-img-field">
          {if $conf.img_left_big}
            <img class="tc-admin-img-preview" src="{$conf.img_left_big|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">285×285<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Duży obrazek' mod='tc_imagecta'}</label>
            <input type="file" name="img_left_big" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_left_big_keep" value="{$conf.img_left_big|escape:'html':'UTF-8'}">
          </div>
        </div>

        <div class="tc-admin-img-field">
          {if $conf.img_left_small}
            <img class="tc-admin-img-preview" src="{$conf.img_left_small|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">81×81<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Mały obrazek (góra)' mod='tc_imagecta'}</label>
            <input type="file" name="img_left_small" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_left_small_keep" value="{$conf.img_left_small|escape:'html':'UTF-8'}">
          </div>
        </div>

        <div class="tc-admin-img-field">
          {if $conf.img_left_med}
            <img class="tc-admin-img-preview" src="{$conf.img_left_med|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">183×183<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Średni obrazek (dół-prawo)' mod='tc_imagecta'}</label>
            <input type="file" name="img_left_med" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_left_med_keep" value="{$conf.img_left_med|escape:'html':'UTF-8'}">
          </div>
        </div>

      </div>
    </div>

    {* ── PRAWA STRONA ── *}
    <div class="tc-admin-section">
      <p class="tc-admin-section__title">{l s='Prawa strona — mozaika obrazków' mod='tc_imagecta'}</p>
      <div class="tc-admin-img-grid">

        <div class="tc-admin-img-field">
          {if $conf.img_right_big}
            <img class="tc-admin-img-preview" src="{$conf.img_right_big|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">285×285<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Duży obrazek' mod='tc_imagecta'}</label>
            <input type="file" name="img_right_big" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_right_big_keep" value="{$conf.img_right_big|escape:'html':'UTF-8'}">
          </div>
        </div>

        <div class="tc-admin-img-field">
          {if $conf.img_right_small}
            <img class="tc-admin-img-preview" src="{$conf.img_right_small|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">81×81<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Mały obrazek (góra)' mod='tc_imagecta'}</label>
            <input type="file" name="img_right_small" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_right_small_keep" value="{$conf.img_right_small|escape:'html':'UTF-8'}">
          </div>
        </div>

        <div class="tc-admin-img-field">
          {if $conf.img_right_med}
            <img class="tc-admin-img-preview" src="{$conf.img_right_med|escape:'html':'UTF-8'}" alt="">
          {else}
            <div class="tc-admin-img-placeholder">183×183<br>px</div>
          {/if}
          <div class="tc-admin-img-input">
            <label>{l s='Średni obrazek (dół-lewo)' mod='tc_imagecta'}</label>
            <input type="file" name="img_right_med" accept="image/*" class="form-control-file">
            <input type="hidden" name="img_right_med_keep" value="{$conf.img_right_med|escape:'html':'UTF-8'}">
          </div>
        </div>

      </div>
    </div>

    <div class="panel-footer">
      <button type="submit" name="submitTcImageCta" class="btn btn-default pull-right">
        <i class="process-icon-save"></i>
        {l s='Zapisz' mod='tc_imagecta'}
      </button>
    </div>

  </form>
</div>
