{**
 * Renders the "Dodatkowy tekst" field in the BO attribute edit form.
 * Called by: hook displayAttributeForm (after the "Nazwa" row).
 * Variables: $tc_subtitle (string), $tc_id_attribute (int).
 *}
<div class="form-group">
    <label class="control-label col-lg-3">
        {l s='Dodatkowy tekst' d='Modules.Tc_attributeextra.Admin'}
    </label>
    <div class="col-lg-9">
        <input
            type="text"
            name="tc_attribute_subtitle"
            id="tc_attribute_subtitle"
            value="{$tc_subtitle|escape:'html':'UTF-8'}"
            class="form-control"
            maxlength="255"
            placeholder="{l s='np. 12 paczek' d='Modules.Tc_attributeextra.Admin'}"
        />
        <p class="help-block">
            {l s='Wyświetlany pod nazwą atrybutu na karcie produktu.' d='Modules.Tc_attributeextra.Admin'}
        </p>
    </div>
</div>
