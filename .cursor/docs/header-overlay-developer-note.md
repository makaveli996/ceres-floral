# Header / navigation overlay — developer note

## Summary

The main site header (below the existing black sticky bar) has been restyled to match the Figma overlay design: **transparent**, **fixed** below the sticky bar, with **logo left**, **search center**, **utility links + account/cart right**, and **primary navigation** in a second row.

The black sticky bar above the menu is **unchanged** (module `tc_stickybar`, hook `displayTop` or as configured in BO).

---

## Template

- **File:** `prestashop/themes/meblowosk/templates/_partials/header.tpl`
- **Structure:**
  - `header_banner` → `{hook displayBanner}` (unchanged).
  - `header_main` → single block containing:
    - **Desktop:** one row with logo, `displayTop` (stickybar + menu + search), and `displayNav1` + `displayNav2` (utils). The primary menu is laid out in a second row via CSS grid (content still comes from `displayTop`).
    - **Mobile:** classic top bar (menu icon, cart, user, logo placeholders) and `#mobile_top_menu_wrapper` for the dropdown.
  - After `header_main`: `{hook displayNavFullWidth}`.

Blocks `header_nav` and `header_top` from the classic structure are no longer used in this theme; the layout is merged into `header_main`.

---

## Data sources (unchanged)

- **Logo:** theme/shop logo via `$shop.logo_details` and `{renderLogo}` in `header-main__logo` / `#_desktop_logo`.
- **Primary navigation:** `ps_mainmenu` on **displayTop** (menu items from BO > Design > Menus).
- **Utility links:** **displayNav1** (e.g. `ps_contactinfo`), **displayNav2** (e.g. `ps_languageselector`, `ps_currencyselector`, `ps_customersignin`, `ps_shoppingcart`). “O nas”, “Kontakt”, “Katalogi”, “Strefa Projektanta” can be added via link list or CMS links on these hooks if not already present.
- **Search:** `ps_searchbar` on **displayTop** (existing search implementation).
- **Account / cart:** existing **displayNav2** modules (`ps_customersignin`, `ps_shoppingcart`).

No menu items or links have been hardcoded; only wrappers and classes were added for layout and styling.

---

## Sticky behaviour

- **CSS-only.** No new JS for sticky/fixed.
- **#header:** `position: fixed; top: var(--sticky-bar-height); left: 0; right: 0; z-index: 99; background: transparent;`
- The **sticky bar** stays fixed at the top (z-index 100, from `_dev/css/custom/sections/_sticky-bar.scss`); the main header is fixed directly below it.
- **Body** already has `padding-top: var(--sticky-bar-height)` so content starts below the sticky bar. The overlay header then sits over the first part of the page (e.g. hero). No extra spacer was added for the main header; inner pages without a hero may want a top spacer or body class if content must start below the full header.

---

## Styling

- **Location:** `_dev/css/custom/components/_header.scss` (imported via `_dev/css/custom/components/_index.scss` → `custom/theme.scss`).
- **Design:** Transparent background, white/light text, PT Sans, vertical separators between nav items, search field with light border/placeholder, account and cart as grey icon boxes, orange cart badge. Submenus use dark background for contrast.
- **Responsive:** Desktop layout (grid) is applied with `.header-main__row--desktop`; below `lg` the desktop row is hidden and the mobile row is used. Mobile styles are scoped so the overlay look is desktop-first.

---

## Checkout

Checkout uses `prestashop/themes/meblowosk/templates/checkout/_partials/header.tpl`, which was **not** modified. The overlay header applies only to the main layout (e.g. `layout-both-columns.tpl`).

---

## Build

After changing SCSS, run the theme build (e.g. `npm run build` or your usual command) so `prestashop/themes/meblowosk/assets/css/theme.css` is updated. No new JS was added.
