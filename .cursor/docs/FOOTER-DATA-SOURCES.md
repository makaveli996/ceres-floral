# Footer — where to edit each datum (developer note)

Footer layout and styling follow the Figma design (STOPA). Data sources are PrestaShop BO and theme; **do not** add new modules for data that already exists.

---

## Footer email
- **Current source:** `ps_contactinfo` → `Configuration::get('PS_SHOP_EMAIL')`
- **Recommended source:** Same (shop contact email).
- **Where to edit:** **Back Office → Shop Parameters → Contact** — store email. Editable per shop.

---

## Footer phone
- **Current source:** `ps_contactinfo` → `Configuration::get('PS_SHOP_PHONE')`
- **Recommended source:** Same.
- **Where to edit:** **Back Office → Shop Parameters → Contact** — store phone.

---

## Footer logo
- **Current source:** Theme footer.tpl uses `$shop.logo_details` (same as header).
- **Recommended source:** Same (shop logo).
- **Where to edit:** **Back Office → Design → Theme & Logo** (or **Shop Parameters → Contact** for store logo). One logo for header and footer.

---

## Social icons/links
- **Current source:** `ps_socialfollow` → configuration (URLs and network type).
- **Recommended source:** Same.
- **Where to edit:** **Back Office → Design → Social networks** (module **Social media links**). Add/edit links and labels.

---

## Footer menu columns
- **Current source:** `ps_linklist` on hook `displayFooter` — link blocks for this hook.
- **Recommended source:** Same.
- **Where to edit:** **Back Office → Design → Link list** (or **Modules → Link list**). Create/edit link blocks for the **Footer** hook; each block = one column (e.g. “Meblo - Wosk”, “Sprzedaż”, “Informacje”). “Logowanie” column = **ps_customeraccountlinks** (same hook); edit labels in **International → Translations** if needed.

---

## Address and opening hours
- **Current source:**  
  - Address: `ps_contactinfo` → shop address from **Shop Parameters → Contact**.  
  - Opening hours: `$contact_infos.details` → **PS_SHOP_DETAILS** (optional rich text).
- **Recommended source:** Same. Use **PS_SHOP_DETAILS** for hours so they are editable in BO.
- **Where to edit:**  
  - **Back Office → Shop Parameters → Contact** — address (and optional “Details” / opening hours if your theme/BO exposes it).  
  - If “Details” is not shown: **Shop Parameters → Store Contacts** or add a custom field; alternatively store hours in a CMS page and link from footer, or keep in theme override only (not ideal).

**Note:** Opening hours are currently taken from **PS_SHOP_DETAILS**. If your BO does not expose this for “opening hours”, consider adding a dedicated config key or using a CMS block.

---

## Copyright
- **Current source:** Theme template `prestashop/themes/meblowosk/templates/_partials/footer.tpl` — block `copyright_link` with translation `%copyright% %year% - %shop_name%. Wszelkie prawa zastrzeżone.`
- **Recommended source:** Keep in theme template with translation so year and shop name stay dynamic; text can be changed via **International → Translations** (Shop.Theme.Global).
- **Where to edit:**  
  - **International → Translations** — search for the copyright string and translate/edit.  
  - Or edit the template string in `footer.tpl` if you need a different sentence structure.

---

## “Made by two colours”
- **Current source:** Hardcoded in theme `footer.tpl`: “Made by” + link to https://two-colours.com (“two colours”).
- **Recommended source:** Acceptable as hardcoded (single credit line). If you need BO editability, add a small config in theme or a custom module (e.g. “Footer credit text” and “Footer credit URL”).
- **Where to edit:** **Theme file** `prestashop/themes/meblowosk/templates/_partials/footer.tpl` — block `footer-made-by` and `footer-made-by__link`.

---

## Back-to-top button
- **Current source:** Theme footer.tpl (HTML) + **theme _dev JS** `_dev/js/custom/Sections/FooterBackToTop.js` (behavior) + **theme _dev SCSS** `_dev/css/custom/components/_footer.scss` (styling).
- **Recommended source:** Same — no module; theme only.
- **Where to edit:**  
  - **Behavior:** `_dev/js/custom/Sections/FooterBackToTop.js` (and import in `_dev/js/custom/theme.js`).  
  - **Styling:** `_dev/css/custom/components/_footer.scss` (`.footer-back-to-top__btn`, `.footer-back-to-top__icon`).  
  - **Markup/label:** `prestashop/themes/meblowosk/templates/_partials/footer.tpl` — `footer_back_to_top` block and `aria-label`.

---

## Summary table

| Datum              | Edit in BO / Code |
|--------------------|-------------------|
| Email              | Shop Parameters → Contact |
| Phone              | Shop Parameters → Contact |
| Logo               | Design → Theme & Logo (or Contact) |
| Social links       | Design → Social networks (ps_socialfollow) |
| Footer menus       | Design → Link list (ps_linklist) |
| Address / hours    | Shop Parameters → Contact (+ PS_SHOP_DETAILS for hours) |
| Copyright text     | International → Translations or footer.tpl |
| “Made by two colours” | footer.tpl (hardcoded) |
| Back-to-top        | _dev JS + _dev SCSS + footer.tpl |

After changing templates or theme.yml, run **`make cache-clear`** so Smarty and Symfony pick up changes.
