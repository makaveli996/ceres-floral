# Repeater in a module (list of items in BO)

## When to use

When a module has a **repeatable list of items** in the Back Office (e.g. slides, entries, collections), where the user can add/remove/reorder rows and each row has the same fields (title, description, link, image, etc.). Pattern: one config key with JSON + form with indexed fields + JS for add/remove/reorder.

**Reference module:** `prestashop/modules/tc_collections` — full implementation (section title + repeater: title, description, link, image).

---

## 1. Data storage

- **Single value (e.g. section title):** separate `Configuration` key, e.g. `TC_COLLECTIONS_TITLE`.
- **List of items:** one key with **JSON**, e.g. `TC_COLLECTIONS_ITEMS`. Each element in the array is an object with fields, e.g.:
  - `id` — identifier (e.g. `item_0`, `item_1`) or from DB
  - `title`, `description`, `link`, `image` — form fields
  - `position` — order (0, 1, 2…)

Example save in PHP:

```php
Configuration::updateValue(self::CONFIG_ITEMS, json_encode($saved));
```

**If the repeater has WYSIWYG (rich text) fields:** Do **not** use the third parameter `true` (that runs `purifyHTML()` on the whole JSON and corrupts it). Instead: before `json_encode($saved)`, entity-encode only the HTML field(s), e.g. `$item['description'] = htmlspecialchars($item['description'], ENT_QUOTES | ENT_HTML5, 'UTF-8');`. Then save with 2 params. In `getStoredItems()` decode with `html_entity_decode()` when building each item. Reference: **tc_contentrows** (description field).

---

## 2. PHP — read and write

### Read (for form and FO)

- A method like `getStoredItems()`: `Configuration::get(CONFIG_ITEMS)` → `json_decode(..., true)`.
- Return an array of normalized items (set default values for `id`, `position`, etc. if missing in JSON).
- Example: `tc_collections.php` → `getStoredItems()`.

### Parsing POST (on submit)

- A method like `getSubmittedItems()`:
  - Get the array: `Tools::getValue('collection_items', [])` (name matches `name="collection_items[0][title]"` etc.).
  - For each row collect fields, e.g. `title`, `description`, `link`, `image_keep` (existing image — filename).
  - **Files:** separately from `$_FILES['collection_image']` — in a repeater use the index: `$_FILES['collection_image']['name'][$index]`, `$_FILES['collection_image']['tmp_name'][$index]`, `$_FILES['collection_image']['error'][$index]`.

### Validation

- In `_postValidation()` loop over `getSubmittedItems()` and check required fields and (optionally) file extension/size for new uploads.
- On errors: `$this->displayError(...)` and return `false`; the form will be shown again with the data.

### Save

- In `_postProcess()`:
  1. Get `getSubmittedItems()`.
  2. For each index: if there is a new file (`UPLOAD_ERR_OK`), `move_uploaded_file()` to a directory in the module (e.g. `views/img/`), generate a unique name; if there was `image_keep`, you can delete the old file.
  3. Build array `$saved[]` with fields (id, title, description, link, image, position).
  4. `Configuration::updateValue(CONFIG_ITEMS, json_encode($saved))`. For WYSIWYG fields in the repeater, entity-encode them before encode and decode in getStoredItems (see above; do not use third param `true`).

Details (extension validation, max size, deleting images on uninstall): see `tc_collections.php` — `_postValidation`, `_postProcess`, `getImageDir()`, `deleteAllCollectionImages()`.

---

## 3. BO form template

- **Path:** e.g. `views/templates/admin/configure.tpl`.
- **Form:** `method="post"` and **`enctype="multipart/form-data"`** (required for file upload).
- **Token:** `<input type="hidden" name="token" value="{$token}">`.
- **Single field (e.g. section title):** plain `name="tc_collections_title"` (or equivalent).

### Repeater container

- One `<div id="tc_collections_items">` (or another name) with `{foreach from=$collection_items item=item name=collectionLoop}`.
- **Loop index:** use `{$smarty.foreach.collectionLoop.iteration|intval - 1}` as the index (0, 1, 2…) so field names match the PHP array.

### Field names per row

- All text/textarea fields in one row must share the same index:
  - `name="collection_items[0][title]"`, `name="collection_items[0][description]"`, `name="collection_items[0][link]"` etc.
- **Keeping existing image:** hidden field `name="collection_items[0][image_keep]"` with value `{$item.image}`; on save without a new file use this value.
- **New file:** `name="collection_image[0]"` (separate array in `$_FILES`, index = same as row). For multiple rows: `collection_image[1]`, `collection_image[2]`…

### Buttons in row

- **Remove:** `type="button"` + class e.g. `.tc-collections-remove` — JS removes `.tc-collections-item` and calls reindex.
- **Move up / down:** `type="button"` + classes `.tc-collections-move-up` / `.tc-collections-move-down` — JS reorders DOM and reindex.

### “Add item” button

- Outside the loop: `type="button"` with id e.g. `tc_collections_add` — JS inserts a new row from template and calls reindex.

---

## 4. JavaScript (add / remove / reorder)

- Script in the same template (e.g. at the bottom of `configure.tpl`) or in a separate file loaded only on the config page.

### New row template

- Function `itemTemplate(index)` returning HTML for one row with empty fields and `name="collection_items[" + index + "][title]"` etc., and `name="collection_image[" + index + "]"`.
- Index when adding = current row count (`container.querySelectorAll('.tc-collections-item').length`).

### Reindex after each change

- Function `reindexItems()`:
  1. Get all rows (e.g. `.tc-collections-item`).
  2. For each row (i = 0, 1, 2…): set `data-index="i"` and for each `input`/`textarea`/`select` in the row replace in the `name` attribute:
     - `collection_items[\d+]` → `collection_items[i]`
     - `collection_image[\d+]` → `collection_image[i]`
  (e.g. regex `.replace(/collection_items\[\d+\]/, 'collection_items[' + i + ']')` and similarly for files.)

### Event handlers

- **Add:** click on `#tc_collections_add` → append `itemTemplate(count)` to container → `reindexItems()`.
- **Remove:** delegate on container — click `.tc-collections-remove` → remove `.tc-collections-item` → `reindexItems()`.
- **Move up:** `.tc-collections-move-up` → `insertBefore(item, item.previousElementSibling)` → `reindexItems()`.
- **Move down:** `.tc-collections-move-down` → `insertBefore(item.nextElementSibling, item)` → `reindexItems()`.

Reference: `tc_collections/views/templates/admin/configure.tpl` (script block).

---

## 5. Image in repeater (preview, upload)

- Preview in BO: in template, if `$item.image`: `<img src="{$image_base_url}{$item.image}">` (module base URL + filename).
- Upload: `move_uploaded_file()` to a directory in the module; in config store only the **filename** (not full path).
- Uninstall: delete files from that directory based on stored names (e.g. `deleteAllCollectionImages()` in `tc_collections`).
- More (HelperForm + override `form.tpl` for a single file field): `.cursor/rules/prestashop-modules.mdc` — section “Image input in a repeater”.

---

## 6. Checklist for a new module with repeater

- [ ] Config key for the list (JSON); optionally a separate one for a global value (e.g. title).
- [ ] Method `getStoredItems()` — decode JSON, normalize (id, position).
- [ ] Method `getSubmittedItems()` — `Tools::getValue('items_key', [])` + for files `$_FILES['items_file'][$index]`.
- [ ] `_postValidation()` — required fields and (when image) file format/size.
- [ ] `_postProcess()` — upload to module directory, build array, `Configuration::updateValue(..., json_encode($saved))`.
- [ ] Admin template: form with `enctype="multipart/form-data"`, `name="items_key[index][field]"`, `name="items_file[index]"`, `image_keep` where needed.
- [ ] JS: row template with index, `reindexItems()` (update indices in `name`), handlers for Add / Remove / Move up / Move down.
- [ ] Uninstall: remove config keys and (when there are files) delete files from module directory.

---

## Source

Pattern based on the **tc_collections** module in this project. When writing new modules with a repeater, use this document and `tc_collections` as reference.
