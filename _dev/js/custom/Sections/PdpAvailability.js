/**
 * PDP availability pill: sync “Duża / Średnia / Mała / Niedostępny” with stock after AJAX variant refresh.
 * Used by: product page (.pdp__availability-row + #product-availability in product-availability-pdp.tpl).
 * Reads qty from .product-quantities [data-stock] or .js-product-details[data-product].quantity; labels from data-label-* on row.
 * Output: updates badge text, modifier classes, data-pdp-stock-qty.
 * Side effects: DOM only.
 */
const BADGE_MODIFIER_CLASSES = [
  "pdp__availability-tag--stock-large",
  "pdp__availability-tag--stock-medium",
  "pdp__availability-tag--stock-small",
  "pdp__availability-tag--unavailable",
];

/** Fallback if data-label-* missing (should be set from Smarty translations). */
const FALLBACK_LABELS = {
  stockLarge: "Duża",
  stockMedium: "Średnia",
  stockSmall: "Mała",
  unavailable: "Niedostępny",
};

function tierForQty(qty) {
  const q = Math.max(0, parseInt(qty, 10) || 0);
  if (q >= 100) {
    return { modifier: "stock-large", labelKey: "stockLarge" };
  }
  if (q >= 10) {
    return { modifier: "stock-medium", labelKey: "stockMedium" };
  }
  if (q > 0) {
    return { modifier: "stock-small", labelKey: "stockSmall" };
  }
  return { modifier: "unavailable", labelKey: "unavailable" };
}

function readLabels(row) {
  return {
    stockLarge: row.dataset.labelStockLarge || "",
    stockMedium: row.dataset.labelStockMedium || "",
    stockSmall: row.dataset.labelStockSmall || "",
    unavailable: row.dataset.labelUnavailable || "",
  };
}

function parseQtyFromProductDetailsFragment(html) {
  if (!html || typeof html !== "string") {
    return null;
  }
  const tmp = document.createElement("div");
  tmp.innerHTML = html;
  const stockEl = tmp.querySelector(
    ".product-quantities [data-stock], .pdp-details__quantities [data-stock]",
  );
  if (stockEl) {
    const n = parseInt(stockEl.getAttribute("data-stock"), 10);
    if (!Number.isNaN(n)) {
      return n;
    }
  }
  const details = tmp.querySelector(".js-product-details[data-product]");
  if (details) {
    try {
      const attrs = JSON.parse(details.getAttribute("data-product"));
      if (attrs && attrs.quantity != null) {
        const n = parseInt(attrs.quantity, 10);
        if (!Number.isNaN(n)) {
          return n;
        }
      }
    } catch {
      /* ignore */
    }
  }
  return null;
}

function getStockQtyFromDom() {
  return parseQtyFromProductDetailsFragment(
    document.querySelector(".page-product .js-product-details")?.outerHTML || "",
  );
}

function resolveQuantity(refreshEvent) {
  if (refreshEvent && refreshEvent.product_details) {
    const fromAjax = parseQtyFromProductDetailsFragment(refreshEvent.product_details);
    if (fromAjax !== null) {
      return fromAjax;
    }
  }
  return getStockQtyFromDom();
}

function applyPdpAvailabilityBadge(refreshEvent) {
  const row = document.querySelector(".page-product .pdp__availability-row[data-pdp-availability-labels]");
  const badge = document.querySelector(".page-product #product-availability.js-product-availability");
  if (!row || !badge) {
    return;
  }

  const qty = resolveQuantity(refreshEvent);
  if (qty === null) {
    return;
  }

  const { modifier, labelKey } = tierForQty(qty);
  const labels = readLabels(row);
  const label = labels[labelKey] || FALLBACK_LABELS[labelKey] || FALLBACK_LABELS.unavailable;

  BADGE_MODIFIER_CLASSES.forEach((c) => badge.classList.remove(c));
  badge.classList.add(`pdp__availability-tag--${modifier}`);
  badge.textContent = label;
  badge.setAttribute("data-pdp-stock-qty", String(qty));
}

function initPdpAvailability() {
  applyPdpAvailabilityBadge();
}

if (window.prestashop && typeof window.prestashop.on === "function") {
  window.prestashop.on("updatedProduct", (event) => {
    requestAnimationFrame(() => {
      applyPdpAvailabilityBadge(event);
    });
  });
}

export default initPdpAvailability;
