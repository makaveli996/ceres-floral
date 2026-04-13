# Theme build pipeline (source + custom)

This directory is the single source of truth for the ceres_floral theme assets. Webpack builds from here into `prestashop/themes/ceres_floral/assets/` (css/, js/).

## Folder structure

```
_dev/
  css/
    theme.scss          ← Main CSS entry (orchestrator: source then custom)
    source/             ← From Classic theme (do not edit; base layer)
      theme.scss
      partials/
      components/
    custom/             ← Your SCSS (overrides and additions)
      theme.scss
      base/
      components/
      pages/
      sections/
      utils/
      parts/
  js/
    theme.js            ← Main JS entry (orchestrator: CSS, then source, then custom)
    source/             ← From Classic theme (do not edit; base layer)
      theme.js
      components/
      lib/
    custom/             ← Your JS (overrides and custom components)
      theme.js
      Components/
      Sections/
```

## Import order

1. **CSS**: `css/theme.scss` imports `source/theme` then `custom/theme`. So Classic styles load first, your styles second (overrides apply).
2. **JS**: `js/theme.js` imports the main stylesheet, then `source/theme`, then `custom/theme`. Classic behaviour runs first, your code runs after and can override or extend.

Avoid editing files under `source/` so that future Classic theme updates can be re-applied by re-copying from the reference Classic `_dev` into `_dev/css/source` and `_dev/js/source`.

## Commands

From project root:

- `npm run dev` — one-off development build
- `npm run build` — production build (minified)
- `npm run watch` — watch and rebuild on changes
- `npm run start` — watch + browser-sync

After adding or changing dependencies, run `npm install` from the project root.

## Dependencies

- **Custom layer**: `@splidejs/splide`, `glightbox`, `sprintf-js` (and existing devDependencies).
- **Source (Classic) layer**: `bootstrap` (4.0.0-alpha.5), `bourbon`, `bootstrap-touchspin`, `tether`, `flexibility`, `jquery-touchswipe`, `expose-loader`, `velocity-animate`. These are required for the Classic theme SCSS/JS to build; they are listed in the root `package.json`.
