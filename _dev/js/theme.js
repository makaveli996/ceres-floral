/**
 * Main JS entry — source (Classic) first, then custom.
 * Used by: webpack entry "theme".
 * Order: 1) CSS bundle, 2) Classic theme.js, 3) Custom theme.js (overrides/extensions).
 */
import "../css/theme.scss";

// 1) Classic theme (base layer — do not edit; override in custom)
import "./source/theme";

// 2) Custom theme (overrides and custom components)
import "./custom/theme";
