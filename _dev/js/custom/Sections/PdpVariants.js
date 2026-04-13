/**
 * PDP color variants overflow toggle ("+").
 * Used by: product-variants.tpl color groups inside the add-to-cart form.
 * Initializes lists marked with data-pdp-color-list and buttons data-pdp-color-toggle.
 * Input: color list items tagged with data-overflow-color="true".
 * Output: toggles .is-expanded on list and updates aria-expanded/label.
 * Called from: _dev/js/custom/theme.js on DOM ready.
 * Side effects: DOM class and aria attribute updates only.
 * Re-initialized after PrestaShop updatedProduct event.
 */
const DATA_INITED = "data-pdp-color-toggle-inited";

function bindColorToggle(list) {
  if (!list || list.getAttribute(DATA_INITED) === "true") {
    return;
  }

  const btn = list.querySelector("[data-pdp-color-toggle]");
  if (!btn) {
    return;
  }

  const overflowItems = list.querySelectorAll("[data-overflow-color='true']");
  if (!overflowItems.length) {
    return;
  }

  list.setAttribute(DATA_INITED, "true");

  const icon = btn.querySelector(".pdp-variants__more-icon");
  const expandLabel = btn.getAttribute("data-expand-label") || "Show more colors";

  btn.addEventListener("click", () => {
    list.classList.add("is-expanded");
    btn.setAttribute("aria-expanded", "true");
    btn.setAttribute("aria-label", expandLabel);
    if (icon) {
      icon.textContent = "+";
    }

    const moreItem = btn.closest(".pdp-variants__list-item--more");
    if (moreItem) {
      moreItem.remove();
    } else {
      btn.remove();
    }
  });
}

function initPdpVariants() {
  document.querySelectorAll("[data-pdp-color-list]").forEach(bindColorToggle);
}

if (window.prestashop && typeof window.prestashop.on === "function") {
  window.prestashop.on("updatedProduct", () => {
    initPdpVariants();
  });
}

export default initPdpVariants;
