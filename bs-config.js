module.exports = {
  port: 3000,
  proxy: {
    target: "http://127.0.0.1:8090",
    reqHeaders: () => ({ Host: "ceres-floral.test:8090" }),
  },

  // Rewrite backend URLs to relative so the browser requests from localhost (same origin) → no CORS, fonts/images/API work.
  rewriteRules: [
    { match: /https?:\/\/ceres-floral\.test:8090/g, replace: "" },
    { match: /\/\/ceres-floral\.test:8090/g, replace: "" }, // protocol-relative URLs
  ],

  // Watch: webpack output, SCSS source, and sentinel file (webpack touches .reload after cache clear → reload).
  files: [
    "prestashop/themes/ceres_floral/assets/css/theme.css",
    "prestashop/themes/ceres_floral/assets/css/**/*.css",
    "prestashop/themes/ceres_floral/assets/js/theme.js",
    "prestashop/themes/ceres_floral/assets/js/**/*.js",
    "prestashop/themes/ceres_floral/assets/.reload",
    "prestashop/themes/ceres_floral/templates/**/*.tpl",
    "_dev/css/**/*.scss",
  ],

  watchOptions: {
    ignoreInitial: true,
    ignored: ["node_modules", "prestashop/**/var/**"],
  },

  open: false,
  notify: false,
  ghostMode: false,

  injectChanges: false,
  reloadDelay: 200,
  // Wait for webpack to write theme.css after SCSS save (source watch triggers reload after this ms).
  reloadDebounce: 1200,
  watch: true,

  snippetOptions: {
    rule: {
      match: /<\/body>/i,
      fn(snippet, match) {
        return snippet + match;
      },
    },
  },
};

