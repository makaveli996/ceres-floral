# WYSIWYG fields in PrestaShop modules

## Rule: save raw, no sanitization

To preserve formatting (paragraphs, `<br>`, bold, lists) from the TinyMCE editor in the BO:

1. **Do not sanitize on save** — no `strip_tags()`, no custom “cleaning” of HTML. Any such processing can strip tags (e.g. PHP `strip_tags()` ignores self-closing forms like `<br/>`, so line breaks disappear).

2. **Save the form value directly to configuration.**  
   **Important:** The correct way depends on whether you store **one HTML string per key** or **JSON (e.g. repeater) that contains HTML** — see below.

---

## A. Single config key (one WYSIWYG value per key)

Use the third argument `true` (treat as HTML):

```php
Configuration::updateValue('MODULE_KEY_DESCRIPTION', (string) Tools::getValue('MODULE_KEY_DESCRIPTION'), true);
```

The third parameter `true` tells PrestaShop not to run `strip_tags()` on this value when saving (see “Why: PrestaShop behaviour” at the end of this doc).

---

## B. Repeater or one config key with JSON containing HTML

When you store a **JSON string** (e.g. repeater items) and some fields are WYSIWYG/HTML:

- **Do not** use the third parameter `true` for `Configuration::updateValue()`.  
  With `true`, PrestaShop runs `Tools::purifyHTML()` on the **whole** value before saving. The whole JSON is passed to the HTML purifier, which corrupts the structure (quotes, brackets, tags) and can empty or break the stored data — after save, all repeater fields can appear “zerowane”.
- **Do not** leave the value as raw HTML inside JSON and save with 2 params.  
  With 2 params, PrestaShop passes the value to `Db::escape($string, false)`, which runs `strip_tags()` on the **whole** string. That strips all `<…>` from the JSON (including the HTML inside description), so formatting is lost and the JSON can break.

**Correct approach:**

1. **Before** `json_encode($saved)`: entity-encode **only** the HTML field(s), so the stored string contains no raw `<` or `>`:
   ```php
   'description' => htmlspecialchars($item['description'], ENT_QUOTES | ENT_HTML5, 'UTF-8'),
   ```
2. Save with **2 params** (no third `true`):
   ```php
   Configuration::updateValue(self::CONFIG_ITEMS, json_encode($saved));
   ```
   Then `strip_tags()` runs on the whole value but finds no angle brackets (they are `&lt;` / `&gt;`), so the JSON and the encoded HTML stay intact.
3. **When reading** (e.g. in `getStoredItems()`): decode the HTML field(s) with `html_entity_decode()` so BO and FO get real HTML again:
   ```php
   $desc = html_entity_decode($desc, ENT_QUOTES | ENT_HTML5, 'UTF-8');
   ```

**Reference in this project:** module **tc_contentrows** (repeater with WYSIWYG description). See also `.cursor/docs/prestashop/07_REPEATER_IN_MODULES.md` (section 1, “If the repeater has WYSIWYG…”).

---

## Form and FO (same for A and B)

3. **Form (HelperForm)**  
   - In the field definition: `'type' => 'textarea'`, `'autoload_rte' => true`, and optionally `'rows'`, `'cols'`, `'desc'`.  
   - **Do not override** this textarea in a custom `form.tpl` — leave the default template (parent) so the BO can attach TinyMCE and the form layout stays correct.  
   - In a custom `form.tpl`, override only other field types (e.g. `type == 'file'`); pass the rest to `{$smarty.block.parent}`.

4. **Display in the FO template**  
   Output the HTML variable with `nofilter` so tags are not escaped:

   ```smarty
   <div class="description">{$tc_cta_description nofilter}</div>
   ```

## Reference implementation: tc_cta module

- **Save (PHP):**  
  `Configuration::updateValue('TC_CTA_DESCRIPTION', (string) Tools::getValue('TC_CTA_DESCRIPTION'), true);`  
  No `strip_tags`, no `sanitize*`, no `normalize*`.

- **Form:**  
  Field in `$fieldsForm['form']['input']`: `type => textarea`, `autoload_rte => true`.  
  In `views/templates/admin/_configure/helpers/form/form.tpl` — **no** block for this textarea; only override for the file field (background image).

- **Read into template:**  
  `$description = (string) Configuration::get('TC_CTA_DESCRIPTION');`  
  Pass to Smarty and in the .tpl: `{$tc_cta_description nofilter}`.

## What to avoid

- `strip_tags($html, $allowed)` — strips `<br/>` / `<br />` because PHP only recognizes `<br>` in allowed_tags.
- Custom “normalize” or sanitize steps on HTML before save — they break formatting.
- Overriding the WYSIWYG textarea in a custom `form.tpl` — breaks the BO form layout; TinyMCE is still wired by the default template.
- In a **repeater** (JSON config): using `Configuration::updateValue(..., json_encode($saved), true)` — corrupts or empties data when the JSON contains HTML (purifyHTML runs on the whole string).

---

## Why: PrestaShop behaviour on Configuration::updateValue

So that this is not forgotten when debugging or adding new modules:

1. **Configuration::updateValue($key, $value, $html = false)**  
   - If `$html === true`: PrestaShop first runs **Tools::purifyHTML($value)** on the **entire** value (see `classes/Configuration.php`). Then the value is passed to **pSQL($value, true)** → **Db::escape($string, true)** → **no** `strip_tags()`.  
   - If `$html === false` (default): **purifyHTML** is not called. The value is passed to **pSQL($value, false)** → **Db::escape($string, false)** → **strip_tags(Tools::nl2br($string))** is applied to the **entire** string (see `classes/db/Db.php` method `escape()`).

2. **Implications**  
   - **Single HTML string per key:** use `true` so that `strip_tags()` is not run; the value is “HTML safe” and stored as-is (after purifyHTML, which is intended for single HTML content).  
   - **One key with JSON (e.g. repeater) that contains HTML:**  
     - Using `true`: the **whole JSON** is passed to `purifyHTML()` → structure is corrupted → after save, data can be empty or broken (“wszystkie pola się zerują”).  
     - Using 2 params: the **whole JSON** is passed to `strip_tags()` → any `<…>` inside the string (e.g. in description) is stripped → formatting is lost and JSON can break.  
   - **Correct approach for JSON with HTML:** entity-encode only the HTML parts before `json_encode()`, save with 2 params (so there are no raw `<`/`>` in the string and `strip_tags()` does nothing harmful), then decode with `html_entity_decode()` when reading.

3. **Code references**  
   - `classes/Configuration.php`: around line 455–458 (`if ($html) { array_map(purifyHTML, ...) }`), then 476 (`pSQL($value, $html)`).  
   - `config/alias.php`: `pSQL($string, $htmlOK)` → `Db::getInstance()->escape($string, $htmlOK)`.  
   - `classes/db/Db.php`: `escape()` — when `$html_ok === false`, `strip_tags(Tools::nl2br($string))` is applied.

---

## References

Working WYSIWYG field in this project: **tc_cta** (description field in module config).  
Another example: **ri_knowledgebase** (Answer field in the FAQ item form) — also raw save, no sanitization.
