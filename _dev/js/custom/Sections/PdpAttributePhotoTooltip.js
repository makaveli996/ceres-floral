/**
 * PDP: tooltip with attribute photo on hover/focus (data-tc-attribute-photo-url on variant list items).
 * Used by: product-variants.tpl (tc_attribute_photo + theme); works after AJAX updatedProduct (delegated).
 * Input: li.pdp-variants__list-item[data-tc-attribute-photo-url] inside .js-product-variants.
 * Output: fixed-position .tc-pdp-attribute-photo-tooltip with <img>.
 * Side effects: one global tooltip node on document.body; DOM reads for positioning only.
 */

const TOOLTIP_ID = "tc-pdp-attribute-photo-tooltip";
const SELECTOR_ITEM =
  ".js-product-variants li.pdp-variants__list-item[data-tc-attribute-photo-url]";
const SELECTOR_INPUT = ".pdp-variants__input";

let tooltipEl = null;
let activeLi = null;
let bound = false;

function getTooltip() {
  if (tooltipEl && document.body.contains(tooltipEl)) {
    return tooltipEl;
  }
  let el = document.getElementById(TOOLTIP_ID);
  if (!el) {
    el = document.createElement("div");
    el.id = TOOLTIP_ID;
    el.className = "tc-pdp-attribute-photo-tooltip";
    el.setAttribute("role", "tooltip");
    el.hidden = true;
    const img = document.createElement("img");
    img.alt = "";
    el.appendChild(img);
    document.body.appendChild(el);
  }
  tooltipEl = el;
  return el;
}

function hideTooltip() {
  const el = document.getElementById(TOOLTIP_ID);
  if (el) {
    el.hidden = true;
    const img = el.querySelector("img");
    if (img) {
      img.removeAttribute("src");
    }
  }
  activeLi = null;
}

function positionTooltip(el, anchor) {
  const rect = anchor.getBoundingClientRect();
  const margin = 12;
  const tw = el.offsetWidth || 400;
  const th = el.offsetHeight || 320;
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const pad = 8;

  // Primary: to the left of the swatch, vertically centered on the anchor
  let left = rect.left - tw - margin;
  let top = rect.top + rect.height / 2 - th / 2;

  if (left < pad) {
    left = rect.right + margin;
  }
  if (left + tw > vw - pad) {
    left = Math.max(pad, vw - tw - pad);
  }

  top = Math.min(Math.max(top, pad), vh - th - pad);

  el.style.left = `${Math.round(left)}px`;
  el.style.top = `${Math.round(top)}px`;
}

function showForLi(li) {
  const url = li.getAttribute("data-tc-attribute-photo-url");
  if (!url) {
    return;
  }
  const el = getTooltip();
  const img = el.querySelector("img");
  if (!img) {
    return;
  }
  const label = li.querySelector(".attribute-name, .pdp-variants__radio-label");
  img.src = url;
  img.alt = label ? label.textContent.trim() : "";
  el.hidden = false;
  positionTooltip(el, li);
  requestAnimationFrame(() => positionTooltip(el, li));
}

function onMouseOver(e) {
  const li = e.target.closest?.(SELECTOR_ITEM);
  if (!li) {
    if (activeLi) {
      hideTooltip();
    }
    return;
  }
  if (li === activeLi) {
    return;
  }
  activeLi = li;
  showForLi(li);
}

function onFocusIn(e) {
  const t = e.target;
  if (!(t instanceof HTMLInputElement) || !t.matches(SELECTOR_INPUT)) {
    return;
  }
  const li = t.closest(SELECTOR_ITEM);
  if (!li) {
    return;
  }
  activeLi = li;
  showForLi(li);
}

function onFocusOut() {
  requestAnimationFrame(() => {
    const ae = document.activeElement;
    if (ae && ae.closest?.(SELECTOR_ITEM) === activeLi) {
      return;
    }
    hideTooltip();
  });
}

function onScrollOrResize() {
  if (activeLi && !document.getElementById(TOOLTIP_ID)?.hidden) {
    const el = getTooltip();
    positionTooltip(el, activeLi);
  }
}

export default function initPdpAttributePhotoTooltip() {
  if (bound) {
    return;
  }
  bound = true;

  document.addEventListener("mouseover", onMouseOver, true);
  document.addEventListener("focusin", onFocusIn, true);
  document.addEventListener("focusout", onFocusOut, true);
  window.addEventListener("scroll", onScrollOrResize, true);
  window.addEventListener("resize", onScrollOrResize);
}
