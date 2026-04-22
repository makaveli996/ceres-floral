/**
 * Quick-add-to-cart modal for product tiles.
 * Purpose: on cart icon click fetches combination data from tc_quickadd module,
 *   renders a variant picker + qty selector in a modal overlay, then POSTs to PS cart.
 * Called from: _dev/js/custom/theme.js via runWhenReady(initQuickAddModal).
 * Inputs: data-product-id / data-product-url / data-product-name on .js-tile-quick-add buttons.
 * Side effects: updates PS cart (fires prestashop.emit updateCart), wishlist UI sync.
 */

const SEL_OPEN   = ".js-tile-quick-add";
const SEL_WISH   = ".js-tile-wishlist";
const MODULE_CTL = "tc_quickadd";

/** Native blockwishlist runs its own Vue + EventBus on these URLs; skip theme wishlist hooks there. */
function isBlockwishlistModulePage() {
  return window.location.pathname.includes("/module/blockwishlist/");
}

/** Pojedyncza lista produktów (view), nie ekran list list */
function isBlockwishlistSingleListViewPage() {
  return /\/module\/blockwishlist\/view/.test(window.location.pathname);
}
const WISH_ADD_LABEL = "Dodaj do ulubionych";
const WISH_REMOVE_LABEL = "Usuń z ulubionych";

// ── Wishlist (blockwishlist) ─────────────────────────────────────────────────

function isCustomerLoggedIn() {
  const isLogged = window?.prestashop?.customer?.is_logged;
  return isLogged === true || isLogged === 1 || isLogged === "1";
}

function getTaggedProducts() {
  return Array.isArray(window.productsAlreadyTagged) ? window.productsAlreadyTagged : [];
}

function setTaggedProducts(nextTagged) {
  window.productsAlreadyTagged = nextTagged;
}

/**
 * @param {Element | null} [wrap] optional .wishlist-smarty-tile (has data-remove-from-wishlist-url)
 */
function getRemoveFromWishlistUrl(wrap) {
  if (window.removeFromWishlistUrl) {
    return window.removeFromWishlistUrl;
  }
  if (wrap && wrap.dataset && wrap.dataset.removeFromWishlistUrl) {
    return wrap.dataset.removeFromWishlistUrl;
  }
  const container = document.querySelector(".wishlist-products-container");
  if (container && container.dataset && container.dataset.deleteProductUrl) {
    return container.dataset.deleteProductUrl;
  }
  return "";
}

function setWishlistButtonState(btn, isActive, wishlistId = 0) {
  btn.classList.toggle("is-active", isActive);
  btn.setAttribute("aria-pressed", isActive ? "true" : "false");
  btn.setAttribute("aria-label", isActive ? WISH_REMOVE_LABEL : WISH_ADD_LABEL);
  btn.setAttribute("title", isActive ? WISH_REMOVE_LABEL : WISH_ADD_LABEL);

  if (wishlistId) btn.dataset.wishlistId = String(wishlistId);
  else delete btn.dataset.wishlistId;
}

function getServerWishlistState(productId) {
  const matches = getTaggedProducts().filter(
    (entry) => Number(entry.id_product) === Number(productId)
  );
  if (!matches.length) return { isActive: false, wishlistId: 0 };

  const preferred = matches.find(
    (entry) => Number(entry.id_product_attribute || 0) === 0
  ) || matches[0];

  return {
    isActive: true,
    wishlistId: Number(preferred.id_wishlist) || 0,
  };
}

function updateWishlistButtons(productId, isActive, wishlistId = 0) {
  document.querySelectorAll(SEL_WISH).forEach((btn) => {
    if (Number(btn.dataset.productId) !== Number(productId)) return;
    setWishlistButtonState(btn, isActive, wishlistId);
  });
}

function syncWishlistButtons() {
  document.querySelectorAll(SEL_WISH).forEach((btn) => {
    const id = parseInt(btn.dataset.productId, 10);
    if (!id) return;

    const { isActive, wishlistId } = isCustomerLoggedIn()
      ? getServerWishlistState(id)
      : { isActive: false, wishlistId: 0 };
    setWishlistButtonState(btn, isActive, wishlistId);
  });
}

async function postWishlistAction(url, params) {
  if (!url) throw new Error("Missing wishlist endpoint URL");

  const query = Object.entries(params)
    .map(([key, value]) => `params[${encodeURIComponent(key)}]=${encodeURIComponent(value)}`)
    .join("&");
  const fullUrl = `${url}${url.includes("?") ? "&" : "?"}${query}`;

  const response = await fetch(fullUrl, {
    method: "POST",
    headers: { Accept: "application/json" },
  });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
}

function getWishlistEventBus() {
  return window.WishlistEventBus || null;
}

function emitWishlistEvent(name, detail = {}) {
  const bus = getWishlistEventBus();
  if (!bus || typeof bus.$emit !== "function") return false;
  bus.$emit(name, { detail });
  return true;
}

function openAddToWishlistModal(productId) {
  return emitWishlistEvent("showAddToWishList", {
    productId,
    productAttributeId: 0,
    quantity: 1,
    forceOpen: true,
  });
}

function notifyWishlistToast(type, message) {
  emitWishlistEvent("showToast", { type, message });
}

function bindWishlistBusListeners() {
  const bus = getWishlistEventBus();
  if (!bus || typeof bus.$on !== "function") return false;

  bus.$on("addedToWishlist", (event) => {
    const detail = event?.detail || {};
    const productId = Number(detail.productId);
    const listId = Number(detail.listId) || 0;
    const productAttributeId = Number(detail.productAttributeId || 0);
    if (!productId || !listId) return;

    const tagged = getTaggedProducts();
    const alreadyTagged = tagged.some(
      (entry) => Number(entry.id_product) === productId
        && Number(entry.id_wishlist) === listId
        && Number(entry.id_product_attribute || 0) === productAttributeId
    );

    if (!alreadyTagged) {
      tagged.push({
        id_product: String(productId),
        id_wishlist: String(listId),
        id_product_attribute: String(productAttributeId),
        quantity: "1",
      });
      setTaggedProducts(tagged);
    }

    const state = getServerWishlistState(productId);
    updateWishlistButtons(productId, state.isActive, state.wishlistId);
  });

  return true;
}

/**
 * Na stronie widoku listy: serce w kafelku usuwa produkt z tej listy (to samo co przycisk pod kafelkiem).
 * @param {Element} triggerEl serce (.js-tile-wishlist) albo przycisk „Usuń z listy”
 * @param {Element | null} wrapEl opcjonalnie .wishlist-smarty-tile (gdy trigger jest poza embedem HTML)
 */
async function removeProductFromCurrentWishlistListView(triggerEl, wrapEl = null) {
  const wrap = wrapEl || triggerEl.closest(".wishlist-smarty-tile");
  if (!wrap) {
    return;
  }
  const fromContainer = document.querySelector(".wishlist-products-container");
  const listId =
    parseInt(wrap.dataset.wishlistId, 10) ||
    (fromContainer && fromContainer.dataset
      ? parseInt(fromContainer.dataset.listId, 10)
      : 0) ||
    0;
  const idProduct =
    parseInt(wrap.dataset.idProduct, 10) || parseInt(triggerEl.dataset.productId, 10);
  const idAttr = parseInt(String(wrap.dataset.idProductAttribute ?? "0"), 10) || 0;
  if (!listId || !idProduct) {
    return;
  }
  const url = getRemoveFromWishlistUrl(wrap);
  if (!url) {
    // eslint-disable-next-line no-console
    console.error("[wishlist] remove from list: brak URL (removeFromWishlistUrl / data-remove-from-wishlist-url)");
    return;
  }
  if (triggerEl.disabled) {
    return;
  }
  triggerEl.disabled = true;
  try {
    const removeResp = await postWishlistAction(url, {
      id_product: idProduct,
      idWishList: listId,
      id_product_attribute: idAttr,
    });
    if (!removeResp?.success) {
      throw new Error(removeResp?.message || "remove failed");
    }
    const nextTagged = getTaggedProducts().filter(
      (entry) =>
        !(
          Number(entry.id_product) === idProduct
          && Number(entry.id_wishlist) === listId
          && Number(entry.id_product_attribute || 0) === idAttr
        )
    );
    setTaggedProducts(nextTagged);
    const heartInWrap = wrap.querySelector(SEL_WISH);
    if (heartInWrap) {
      setWishlistButtonState(heartInWrap, false, 0);
    }
    if (!emitWishlistEvent("refetchList", { detail: {} })) {
      window.location.reload();
      return;
    }
    notifyWishlistToast("success", removeResp?.message || WISH_REMOVE_LABEL);
  } catch (err) {
    notifyWishlistToast("error", (err && err.message) || "Błąd usuwania");
  } finally {
    triggerEl.disabled = false;
  }
}

async function toggleWishlist(btn) {
  const id = parseInt(btn.dataset.productId, 10);
  if (!id) return;

  if (!isCustomerLoggedIn()) {
    emitWishlistEvent("showLogin");
    return;
  }

  const isActive = btn.classList.contains("is-active");
  if (!isActive) {
    const opened = openAddToWishlistModal(id);
    if (!opened) {
      // eslint-disable-next-line no-console
      console.warn("[wishlist] EventBus unavailable, cannot open wishlist modal");
    }
    return;
  }

  btn.disabled = true;

  try {
    const fallbackState = getServerWishlistState(id);
    const listId = Number(btn.dataset.wishlistId) || fallbackState.wishlistId;
    if (!listId) throw new Error("Missing wishlist id for remove");

    const removeResp = await postWishlistAction(getRemoveFromWishlistUrl(), {
      id_product: id,
      idWishList: listId,
      id_product_attribute: 0,
    });

    if (!removeResp?.success) throw new Error(removeResp?.message || "Remove failed");

    const nextTagged = getTaggedProducts().filter(
      (entry) => !(
        Number(entry.id_product) === id
        && Number(entry.id_wishlist) === listId
        && Number(entry.id_product_attribute || 0) === 0
      )
    );
    setTaggedProducts(nextTagged);

    const state = getServerWishlistState(id);
    updateWishlistButtons(id, state.isActive, state.wishlistId);
    notifyWishlistToast("success", removeResp.message || "Produkt usunięty z ulubionych");
  } catch (error) {
    notifyWishlistToast("error", "Nie udało się usunąć produktu z ulubionych.");
    // eslint-disable-next-line no-console
    console.error("[wishlist] toggle failed", error);
  } finally {
    btn.disabled = false;
  }
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
  // Simple products: id_product_attribute 0 — only disable when attribute groups exist but combo unresolved.
  const addDisabled =
    hasGroups && (!isComplete || combinationId === 0) ? "disabled" : "";

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
  const resp = await fetch(url, {
    headers: { Accept: "application/json" },
    credentials: "same-origin",
  });
  let data;
  try {
    data = await resp.json();
  } catch {
    throw new Error("INVALID_JSON");
  }
  if (!resp.ok || (data && typeof data.error === "string" && data.error.length)) {
    throw new Error(data?.error || `HTTP ${resp.status}`);
  }
  if (!data || data.id_product == null) {
    throw new Error("INVALID_PAYLOAD");
  }
  return data;
}

/**
 * Parses cart AJAX body — may be prefixed with PHP/HTML noise; core returns JSON from displayAjaxUpdate.
 * @returns {object|null}
 */
function parseCartJsonResponse(rawText) {
  const trimmed = (rawText || "").trim();
  if (!trimmed) return null;
  const start = trimmed.indexOf("{");
  if (start === -1) return null;
  try {
    return JSON.parse(trimmed.slice(start));
  } catch {
    return null;
  }
}

async function addToCart({ idProduct, idProductAttribute, qty, cartUrl, token }) {
  const body = new URLSearchParams({
    ajax: "1",
    action: "update",
    add: "1",
    id_product: String(idProduct),
    id_product_attribute: String(idProductAttribute || 0),
    qty: String(qty),
    token,
  });
  const resp = await fetch(cartUrl, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Accept: "application/json, text/javascript, */*; q=0.01",
      "X-Requested-With": "XMLHttpRequest",
    },
    body: body.toString(),
  });
  const rawText = await resp.text();
  const data = parseCartJsonResponse(rawText);

  if (!resp.ok) {
    throw new Error(`HTTP ${resp.status}`);
  }
  if (data && data.hasError) {
    const errs = data.errors;
    const msg = Array.isArray(errs) ? errs.join(" ") : String(errs || "Błąd koszyka");
    throw new Error(msg);
  }
  if (data && data.success === false) {
    throw new Error("Cart update failed");
  }
  // 200 + parsable success payload, or 200 + noise/HTML after successful postProcess — still refresh header cart
  if (data && (data.success === true || data.cart)) {
    return data;
  }
  if (data === null && rawText.length > 0) {
    // Unparseable but HTTP OK — product may still have been added; let updateCart refresh preview
    return { success: true, cart: null };
  }
  if (data === null && rawText.length === 0) {
    return { success: true, cart: null };
  }
  return data || { success: true, cart: null };
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

/** When AJAX fails: message + optional link to full product page (variant picker). */
function setLoadError(productPageUrl) {
  if (!overlay) return;
  const inner = overlay.querySelector(".tc-qam__inner");
  inner.textContent = "";
  const msg = document.createElement("div");
  msg.className = "tc-qam__message";
  msg.textContent = "Nie można załadować produktu. Spróbuj ponownie.";
  inner.appendChild(msg);
  if (productPageUrl && typeof productPageUrl === "string") {
    const actions = document.createElement("div");
    actions.className = "tc-qam__message-actions";
    const link = document.createElement("a");
    link.className = "tc-qam__fallback-link";
    link.href = productPageUrl;
    link.textContent = "Wybierz wariant na stronie produktu";
    actions.appendChild(link);
    inner.appendChild(actions);
  }
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
      const cartResp = await addToCart({ idProduct, idProductAttribute, qty, cartUrl, token });
      showFeedback("Dodano do koszyka!");

      if (window.prestashop) {
        if (cartResp && cartResp.cart) {
          window.prestashop.cart = cartResp.cart;
        }
        window.prestashop.emit("updateCart", {
          reason: {
            idProduct,
            idProductAttribute,
            idCustomization: 0,
            linkAction: "add-to-cart",
          },
          resp: cartResp && typeof cartResp === "object" ? cartResp : { success: true },
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

    const productPageUrl = btn.dataset.productUrl || "";
    const tileName = (btn.dataset.productName || "").trim();

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

      setTitle(tileName || currentData.name);
      renderModal();
    } catch {
      setLoadError(productPageUrl);
    }
  });

  if (isBlockwishlistSingleListViewPage()) {
    document.addEventListener(
      "click",
      async (e) => {
        const btn = e.target.closest(SEL_WISH);
        if (!btn) {
          return;
        }
        if (!btn.closest(".wishlist-smarty-tile")) {
          return;
        }
        e.preventDefault();
        e.stopPropagation();
        await removeProductFromCurrentWishlistListView(btn);
      },
      true
    );
    /** Przycisk „Usuń z listy”: jest poza v-html embedem — bierzemy .wishlist-smarty-tile z rodzeństwa, bez serca. */
    document.addEventListener(
      "click",
      async (e) => {
        const subBtn = e.target.closest(".wishlist-tile__remove button");
        if (!subBtn) {
          return;
        }
        const row = subBtn.closest(".wishlist-tile");
        if (!row) {
          return;
        }
        const wrap = row.querySelector(".wishlist-smarty-tile");
        if (!wrap) {
          return;
        }
        e.preventDefault();
        e.stopPropagation();
        await removeProductFromCurrentWishlistListView(subBtn, wrap);
      },
      true
    );
  }

  if (!isBlockwishlistModulePage()) {
    // Delegate wishlist icon clicks (product tiles only — not module wishlist UI)
    document.addEventListener("click", async (e) => {
      const btn = e.target.closest(SEL_WISH);
      if (!btn) return;
      e.preventDefault();
      await toggleWishlist(btn);
    });

    syncWishlistButtons();

    if (!bindWishlistBusListeners() && window.prestashop?.on) {
      window.prestashop.on("wishlistEventBusInit", () => {
        bindWishlistBusListeners();
        syncWishlistButtons();
      });
    }

    let syncRaf = 0;
    const observer = new MutationObserver(() => {
      if (syncRaf) return;
      syncRaf = window.requestAnimationFrame(() => {
        syncRaf = 0;
        syncWishlistButtons();
      });
    });
    observer.observe(document.body, { childList: true, subtree: true });
  }
}

export default initQuickAddModal;
