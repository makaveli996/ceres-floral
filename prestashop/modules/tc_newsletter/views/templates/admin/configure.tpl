{*
 * Purpose: Back-office configuration form for tc_newsletter module.
 * Used from: tc_newsletter::getContent().
 * Inputs: $form_action, $image_url (current image URL or empty).
 * Outputs: HTML form for uploading the decorative newsletter bouquet image.
 * Side effects: None.
 *}
<style>
  .tc-nl-section {
    background: #f8f8f8;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 20px 24px 12px;
    margin-bottom: 24px;
  }
  .tc-nl-section__title {
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    color: #555;
    margin: 0 0 16px;
    padding-bottom: 10px;
    border-bottom: 2px solid #dde;
  }
  .tc-nl-img-field {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    flex-wrap: wrap;
  }
  .tc-nl-img-preview {
    width: 140px;
    height: 160px;
    object-fit: cover;
    border: 1px solid #ccc;
    border-radius: 4px;
    background: #eee;
    flex-shrink: 0;
  }
  .tc-nl-img-placeholder {
    width: 140px;
    height: 160px;
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
  .tc-nl-img-input { flex: 1; min-width: 200px; }
  .tc-nl-img-input label { font-weight: 600; margin-bottom: 6px; display: block; color: #444; }
  .tc-nl-hint {
    font-size: 12px;
    color: #888;
    margin-top: 6px;
  }
</style>

<div class="panel">
  <div class="panel-heading">
    <i class="icon-envelope"></i>
    {l s='Newsletter — konfiguracja sekcji' mod='tc_newsletter'}
  </div>

  <form action="{$form_action|escape:'html':'UTF-8'}" method="post"
        enctype="multipart/form-data" class="form-horizontal">

    <div class="tc-nl-section">
      <p class="tc-nl-section__title">{l s='Obrazek dekoracyjny (prawa strona)' mod='tc_newsletter'}</p>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Bukiet / obrazek' mod='tc_newsletter'}</label>
        <div class="col-lg-9">
          <div class="tc-nl-img-field">
            {if $image_url}
              <img class="tc-nl-img-preview" src="{$image_url|escape:'html':'UTF-8'}" alt="">
            {else}
              <div class="tc-nl-img-placeholder">Brak<br>obrazka</div>
            {/if}
            <div class="tc-nl-img-input">
              <label>{l s='Wgraj nowy obrazek' mod='tc_newsletter'}</label>
              <input type="file" name="newsletter_image" accept="image/*" class="form-control-file">
              <input type="hidden" name="newsletter_image_keep" value="{$image_url|escape:'html':'UTF-8'}">
              <p class="tc-nl-hint">{l s='Zalecany format: PNG z przezroczystością. Min. 430 × 510 px.' mod='tc_newsletter'}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="panel-footer">
      <button type="submit" name="submitTcNewsletter" class="btn btn-default pull-right">
        <i class="process-icon-save"></i>
        {l s='Zapisz' mod='tc_newsletter'}
      </button>
    </div>

  </form>
</div>
