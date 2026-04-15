/**
 * Quick-add-to-cart modal for product tiles.
 * Purpose: on cart icon click fetches combination data from tc_quickadd module,
 *   renders a variant picker + qty selector in a modal overlay, then POSTs to PS cart.
 * Called from: _dev/js/custom/theme.js via runWhenReady(initQuickAddModal).
 * Inputs: data-product-id / data-product-url on .js-tile-quick-add buttons.
 * Side effects: updates PS cart (fires prestashop.emit updateCart), localStorage wishlist.
 */

const SEL_OPEN   = ".js-tile-quick-add";
const SEL_WISH   = ".js-tile-wishlist";
const WL_KEY     = "tc_wishlist";
const MODULE_CTL = "tc_quickadd";

// ── Wishlist (localStorage) ──────────────────────────────────────────────────

function getWishlist() {
  try { return JSON.parse(localStorage.getItem(WL_KEY) || "[]"); } catch { return []; }
}

function saveWishlist(list) {
  localStorage.setItem(WL_KEY, JSON.stringify(list));
}

function syncWishlistButtons() {
  const list = getWishlist();
  document.querySelectorAll(SEL_WISH).forEach((btn) => {
    const id = parseInt(btn.dataset.productId, 10);
    btn.classList.toggle("is-active", list.includes(id));
    btn.setAttribute(
      "aria-pressed",
      list.includes(id) ? "true" : "false"
    );
  });
}

function toggleWishlist(btn) {
  const id = parseInt(btn.dataset.productId, 10);
  if (!id) return;
  let list = getWishlist();
  if (list.includes(id)) {
    list = list.filter((i) => i !== id);
    btn.classList.remove("is-active");
    btn.setAttribute("aria-pressed", "false");
  } else {
    list.push(id);
    btn.classList.add("is-active");
    btn.setAttribute("aria-pressed", "true");
  }
  saveWishlist(list);
}

// ── Modal DOM builder ────────────────────────────────────────────────────────

function buildModal() {
  const overlay = document.createElement("div");
  overlay.id = "tc-qam";
  overlay.className = "tc-qam__overlay";
  overlay.setAttribute("role", "dialog");
  overlay.setAttribute("aria-modal", "true");
  overlay.setAttribute("aria-label", "Dodaj do koszyka");
  overlay.innerHTML = `
    <div class="tc-qam__panel" tabindex="-1">
      <div class="tc-qam__header">
        <p class="tc-qam__title"></p>
        <button type="button" class="tc-qam__close js-qam-close" aria-label="Zamknij">
          <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M1 1L17 17M17 1L1 17" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
      <div class="tc-qam__inner"></div>
    </div>`;
  document.body.appendChild(overlay);
  return overlay;
}

// ── Combination resolver ─────────────────────────────────────────────────────

/**
 * Given current selections {groupId: attrId} and the combinations list,
 * returns the matching id_product_attribute (or 0 if not found / incomplete).
 */
function findCombination(selections, combinations) {
  const groupIds = Object.keys(selections).map(Number);
  if (!groupIds.length) return combinations[0]?.id_product_attribute ?? 0;

  for (const combo of combinations) {
    const attrs = combo.attributes;
    const match = groupIds.every(
      (gid) => attrs[gid] !== undefined && attrs[gid] === selections[gid]
    );
    if (match) return combo.id_product_attribute;
  }
  return 0;
}

// ── Available attributes resolver ────────────────────────────────────────────

/**
 * Returns a Set of attr IDs that are still reachable given current partial selections
 * (excluding the group being evaluated).
 */
function getAvailableAttrs(groupId, combinations, currentSelections) {
  const available = new Set();
  const otherSelections = Object.entries(currentSelections)
    .filter(([gid]) => Number(gid) !== Number(groupId));

  for (const combo of combinations) {
    if (!combo.available) continue;
    const matchesOthers = otherSelections.every(
      ([gid, aid]) => combo.attributes[Number(gid)] === Number(aid)
    );
    if (matchesOthers && combo.attributes[Number(groupId)] !== undefined) {
      available.add(combo.attributes[Number(groupId)]);
    }
  }
  return available;
}

// ── Variant groups renderer ───────────────────────────────────────────────────

function renderGroups(groups, combinations, selections, onSelect) {
  if (!groups.length) return "";

  return groups
    .map((group) => {
      const available = getAvailableAttrs(group.id, combinations, selections);
      const isColor = group.type === "color";

      const items = group.attributes
        .map((attr) => {
          const isSelected = selections[group.id] === attr.id;
          const isDisabled = available.size > 0 && !available.has(attr.id);

          const colorStyle =
            isColor && attr.html_color_code
              ? `style="background-color:${attr.html_color_code}"`
              : "";
          const colorTitle = isColor
            ? `title="${attr.name}"`
            : "";
          const btnLabel = isColor ? "" : attr.name;

          return `<li class="tc-qam__attr-item${isColor ? " tc-qam__attr-item--color" : ""}">
            <button
              type="button"
              class="tc-qam__attr-btn${isSelected ? " is-selected" : ""}"
              data-group="${group.id}"
              data-attr="${attr.id}"
              ${colorStyle}
              ${colorTitle}
              ${isDisabled ? "disabled" : ""}
              aria-pressed="${isSelected}"
            >${btnLabel}</button>
          </li>`;
        })
        .join("");

      return `<div class="tc-qam__group">
        <span class="tc-qam__group-label">${group.name}</span>
        <ul class="tc-qam__attrs">${items}</ul>
      </div>`;
    })
    .join("");
}

// ── Inner HTML builder ───────────────────────────────────────────────────────

function buildInner(data, selections) {
  const hasGroups = data.groups && data.groups.length > 0;
  const combinationId = hasGroups
    ? findCombination(selections, data.combinations)
    : data.default_combination;
  const isComplete =
    !hasGroups ||
    data.groups.every((g) => selections[g.id] !== undefined);
  const addDisabled = !isComplete || combinationId === 0 ? "disabled" : "";

  const summary = `
    <div class="tc-qam__summary">
      ${data.cover_url ? `<img class="tc-qam__cover" src="${data.cover_url}" alt="" width="72" height="72" loading="eager">` : ""}
      <div class="tc-qam__price-wrap">
        <span class="tc-qam__price">${data.price}</span>
      </div>
    </div>`;

  const groupsHtml = hasGroups
    ? `<div class="tc-qam__body">${renderGroups(data.groups, data.combinations, selections, null)}</div>`
    : "";

  const feedbackHtml = `<div class="tc-qam__feedback js-qam-feedback"></div>`;

  const footer = `
    <div class="tc-qam__footer">
      <div class="tc-qam__qty-wrap">
        <button type="button" class="tc-qam__qty-btn js-qam-qty-down" aria-label="Zmniejsz ilość">−</button>
        <input type="number" class="tc-qam__qty-input js-qam-qty" value="1" min="1" max="99" aria-label="Ilość">
        <button type="button" class="tc-qam__qty-btn js-qam-qty-up" aria-label="Zwiększ ilość">+</button>
      </div>
      <button
        type="button"
        class="tc-qam__add-btn js-qam-add"
        data-id-product="${data.id_product}"
        data-id-product-attribute="${combinationId}"
        data-cart-url="${data.cart_url}"
        data-token="${data.static_token}"
        ${addDisabled}
      >Dodaj do koszyka</button>
    </div>`;

  return summary + groupsHtml + feedbackHtml + footer;
}

// ── AJAX helpers ─────────────────────────────────────────────────────────────

function getAjaxBaseUrl() {
  return (
    (window.prestashop && window.prestashop.urls && window.prestashop.urls.base_url) ||
    "/"
  );
}

async function fetchProductData(productId) {
  const base = getAjaxBaseUrl();
  const url = `${base}index.php?fc=module&module=${MODULE_CTL}&controller=product&id_product=${productId}`;
  const resp = await fetch(url, { headers: { Accept: "application/json" } });
  if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
  return resp.json();
}

async function addToCart({ idProduct, idProductAttribute, qty, cartUrl, token }) {
  const body = new URLSearchParams({
    ajax: "1",
    action: "update",
    add: "1",
    id_product: idProduct,
    id_product_attribute: idProductAttribute || 0,
    qty,
    token,
  });
  const resp = await fetch(cartUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body.toString(),
  });
  if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
  return resp.json();
}

// ── Modal controller ─────────────────────────────────────────────────────────

let overlay = null;
let currentData = null;
let currentSelections = {};

function openModal() {
  if (!overlay) overlay = buildModal();
  overlay.classList.add("is-open");
  document.body.classList.add("tc-qam-open");
  overlay.querySelector(".tc-qam__panel").focus();
  trapFocusInit(overlay);
}

function closeModal() {
  if (!overlay) return;
  overlay.classList.remove("is-open");
  document.body.classList.remove("tc-qam-open");
  trapFocusDestroy();
  currentData = null;
  currentSelections = {};
}

function setTitle(text) {
  if (!overlay) return;
  overlay.querySelector(".tc-qam__title").textContent = text;
}

function setLoading() {
  if (!overlay) return;
  overlay.querySelector(".tc-qam__inner").innerHTML = `
    <div class="tc-qam__loader">
      <span>Ładowanie…</span>
    </div>`;
}

function renderModal() {
  if (!overlay || !currentData) return;
  overlay.querySelector(".tc-qam__inner").innerHTML = buildInner(
    currentData,
    currentSelections
  );
  bindInnerEvents();
}

function showFeedback(msg, isError = false) {
  const fb = overlay && overlay.querySelector(".js-qam-feedback");
  if (!fb) return;
  fb.textContent = msg;
  fb.classList.add("is-visible");
  if (isError) fb.style.background = "#b44";
  else fb.style.background = "";
  setTimeout(() => fb.classList.remove("is-visible"), 2800);
}

// ── Inner event binding (re-run after each re-render) ────────────────────────

function bindInnerEvents() {
  if (!overlay) return;
  const inner = overlay.querySelector(".tc-qam__inner");

  // Attribute selection
  inner.querySelectorAll(".tc-qam__attr-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const gid = Number(btn.dataset.group);
      const aid = Number(btn.dataset.attr);
      if (currentSelections[gid] === aid) {
        delete currentSelections[gid];
      } else {
        currentSelections[gid] = aid;
      }
      renderModal();
    });
  });

  // Quantity
  const qtyInput = inner.querySelector(".js-qam-qty");
  inner.querySelector(".js-qam-qty-up")?.addEventListener("click", () => {
    qtyInput.value = Math.min(99, parseInt(qtyInput.value || "1", 10) + 1);
  });
  inner.querySelector(".js-qam-qty-down")?.addEventListener("click", () => {
    qtyInput.value = Math.max(1, parseInt(qtyInput.value || "1", 10) - 1);
  });

  // Add to cart
  const addBtn = inner.querySelector(".js-qam-add");
  addBtn?.addEventListener("click", async () => {
    const idProduct = parseInt(addBtn.dataset.idProduct, 10);
    const idProductAttribute = parseInt(addBtn.dataset.idProductAttribute, 10) || 0;
    const qty = parseInt(qtyInput?.value || "1", 10);
    const cartUrl = addBtn.dataset.cartUrl;
    const token = addBtn.dataset.token;

    addBtn.disabled = true;
    addBtn.textContent = "…";

    try {
      await addToCart({ idProduct, idProductAttribute, qty, cartUrl, token });
      showFeedback("Dodano do koszyka!");

      if (window.prestashop) {
        window.prestashop.emit("updateCart", {
          reason: {
            idProduct,
            idProductAttribute,
            linkAction: "add-to-cart",
          },
        });
      }

      setTimeout(() => closeModal(), 1400);
    } catch {
      showFeedback("Wystąpił błąd. Spróbuj ponownie.", true);
      addBtn.disabled = false;
      addBtn.textContent = "Dodaj do koszyka";
    }
  });
}

// ── Focus trap ───────────────────────────────────────────────────────────────

let _trapHandler = null;

function trapFocusInit(el) {
  const focusable = 'button:not([disabled]),input,select,[tabindex]:not([tabindex="-1"])';
  _trapHandler = (e) => {
    if (e.key !== "Tab" && e.key !== "Escape") return;
    if (e.key === "Escape") { closeModal(); return; }
    const nodes = [...el.querySelectorAll(focusable)];
    if (!nodes.length) return;
    const first = nodes[0], last = nodes[nodes.length - 1];
    if (e.shiftKey ? document.activeElement === first : document.activeElement === last) {
      e.preventDefault();
      (e.shiftKey ? last : first).focus();
    }
  };
  el.addEventListener("keydown", _trapHandler);
}

function trapFocusDestroy() {
  if (overlay && _trapHandler) overlay.removeEventListener("keydown", _trapHandler);
  _trapHandler = null;
}

// ── Main init ────────────────────────────────────────────────────────────────

function initQuickAddModal() {
  // Lazy-build modal once
  overlay = buildModal();

  // Close on overlay click (outside panel)
  overlay.addEventListener("click", (e) => {
    if (e.target === overlay) closeModal();
  });

  // Close button
  overlay.addEventListener("click", (e) => {
    if (e.target.closest(".js-qam-close")) closeModal();
  });

  // Delegate cart icon clicks
  document.addEventListener("click", async (e) => {
    const btn = e.target.closest(SEL_OPEN);
    if (!btn) return;
    e.preventDefault();

    const productId = parseInt(btn.dataset.productId, 10);
    if (!productId) return;

    openModal();
    setLoading();
    setTitle("Dodaj do koszyka");

    try {
      currentData = await fetchProductData(productId);
      currentSelections = {};

      // Pre-select the default combination attributes
      if (currentData.default_combination) {
        const defCombo = currentData.combinations.find(
          (c) => c.id_product_attribute === currentData.default_combination
        );
        if (defCombo) currentSelections = { ...defCombo.attributes };
      }

      setTitle(currentData.name);
      renderModal();
    } catch {
      overlay.querySelector(".tc-qam__inner").innerHTML = `
        <div class="tc-qam__message">Nie można załadować produktu. Spróbuj ponownie.</div>`;
    }
  });

  // Delegate wishlist icon clicks
  document.addEventListener("click", (e) => {
    const btn = e.target.closest(SEL_WISH);
    if (!btn) return;
    e.preventDefault();
    toggleWishlist(btn);
  });

  // Sync wishlist state on load
  syncWishlistButtons();
}

export default initQuickAddModal;
