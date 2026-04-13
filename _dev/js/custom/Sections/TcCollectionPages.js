/**
 * TcCollectionPages — JS for:
 *   1. Category PLP: promo video cards + ps_facetedsearch (cena Od/Do, tcp-faceted-select) + re-init po AJAX
 *   2. Collection detail: sidebar filtrów, sort, paginacja AJAX
 * Used by: theme.js (runWhenReady)
 * Side effects: DOM updates for product list / pagination areas; history.pushState;
 *                after pagination AJAX — smooth scroll to .tcp-collection-detail__layout
 */

// ─── Promo video in product grid (custom play — no native controls) ───────────

function initTcpVideoCards(root) {
  const scope = root || document;
  scope.querySelectorAll("[data-tcp-video-card]").forEach((card) => {
    if (card.dataset.tcpVideoCardInited === "1") return;
    card.dataset.tcpVideoCardInited = "1";

    const video = card.querySelector("video");
    const btn = card.querySelector("[data-tcp-video-play]");
    if (!video || !btn) return;

    const labelPlay = btn.dataset.labelPlay || "Odtwórz film";
    const labelPause = btn.dataset.labelPause || "Wstrzymaj film";

    function sync() {
      const playing = !video.paused;
      card.classList.toggle("tcp-video-card--playing", playing);
      btn.setAttribute("aria-pressed", playing ? "true" : "false");
      btn.setAttribute("aria-label", playing ? labelPause : labelPlay);
    }

    btn.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      if (video.paused) {
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });

    video.addEventListener("click", (e) => {
      e.preventDefault();
      if (video.paused) {
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });

    video.addEventListener("play", sync);
    video.addEventListener("pause", sync);
    video.addEventListener("ended", sync);
    sync();
  });
}

// ─── Category PLP: video in grid (same markup as collection product-grid) ───

function initCategoryPlpVideoCards() {
  const root = document.querySelector('[data-tc-category-plp]');
  if (!root) {
    return;
  }
  initTcpVideoCards(root);
}

function bindCategoryPlpProductListVideo() {
  if (typeof prestashop === 'undefined' || typeof prestashop.on !== 'function') {
    return;
  }
  prestashop.on('updateProductList', () => {
    const root = document.querySelector('[data-tc-category-plp]');
    if (root) {
      initTcpVideoCards(root);
    }
  });
}

/** Category PLP: native select with full sort URLs (same bar as collection) */
function initCategoryPlpSortSelect() {
  document.body.addEventListener('change', (e) => {
    const sel = e.target;
    if (!sel || sel.nodeName !== 'SELECT' || !sel.hasAttribute('data-tcp-category-sort-select')) {
      return;
    }
    if (!document.querySelector('[data-tc-category-plp]')) {
      return;
    }
    const url = sel.value;
    if (!url || typeof prestashop === 'undefined' || typeof prestashop.emit !== 'function') {
      return;
    }
    prestashop.emit('updateFacets', url);
  });
}

// ─── Collection detail page: fully AJAX-driven filters + pagination ──────────

function initCollectionDetailPage() {
  const detailRoot = document.querySelector('[data-tc-collection-detail]');
  if (!detailRoot) return;

  const productGrid  = detailRoot.querySelector('[data-tcp-product-grid]');
  const paginationEl = detailRoot.querySelector('[data-tcp-pagination]');
  const filterForm   = detailRoot.querySelector('[data-tcp-filter-form]');
  const sortSelect   = detailRoot.querySelector('[data-tcp-sort-select]');
  const countEl      = detailRoot.querySelector('[data-tcp-count]');
  if (!productGrid) return;

  initTcpVideoCards(productGrid);

  // Build URL from current filter + sort state ───────────────────────────────
  function buildFilterUrl(extraParams) {
    const baseUrl = filterForm ? filterForm.dataset.tcpBaseUrl : window.location.href;
    const url = new URL(baseUrl, window.location.origin);

    // Clear all filter params first
    ['przeznaczenie[]', 'kolor', 'dostepnosc', 'cena_od', 'cena_do', 'sort', 'page'].forEach(
      (k) => url.searchParams.delete(k)
    );

    if (filterForm) {
      // Checkboxes: przeznaczenie[]
      filterForm.querySelectorAll('input[name="przeznaczenie[]"]:checked').forEach((cb) => {
        url.searchParams.append('przeznaczenie[]', cb.value);
      });

      // Selects: kolor, dostepnosc
      ['kolor', 'dostepnosc'].forEach((name) => {
        const sel = filterForm.querySelector(`select[name="${name}"]`);
        if (sel && sel.value) url.searchParams.set(name, sel.value);
      });

      // Price inputs
      ['cena_od', 'cena_do'].forEach((name) => {
        const inp = filterForm.querySelector(`input[name="${name}"]`);
        if (inp && inp.value.trim()) url.searchParams.set(name, inp.value.trim());
      });
    }

    // Sort
    if (sortSelect && sortSelect.value && sortSelect.value !== 'popular') {
      url.searchParams.set('sort', sortSelect.value);
    }

    // Extra params (e.g. page=N from pagination)
    if (extraParams) {
      Object.entries(extraParams).forEach(([k, v]) => url.searchParams.set(k, v));
    }

    return url.toString();
  }

  // AJAX page loader ──────────────────────────────────────────────────────────
  let loading = false;

  /**
   * @param {string} url
   * @param {{ scrollToLayout?: boolean }} [opts] — scroll to grid layout after load (pagination)
   */
  async function loadPage(url, opts = {}) {
    if (loading) return;
    loading = true;

    const scrollToLayout = opts.scrollToLayout === true;

    const ajaxUrl = new URL(url, window.location.origin);
    ajaxUrl.searchParams.set('ajax', '1');

    // Visual feedback: dim the grid
    productGrid.style.opacity = '0.4';

    try {
      const res = await fetch(ajaxUrl.toString(), {
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
      });
      if (!res.ok) throw new Error('HTTP ' + res.status);

      const data = await res.json();
      if (!data.success) throw new Error('AJAX failed');

      productGrid.innerHTML = data.products;
      if (paginationEl) paginationEl.innerHTML = data.pagination;
      if (countEl && data.total !== undefined) {
        countEl.textContent = data.total + ' produktów';
      }

      bindPaginationLinks();
      initTcpVideoCards(productGrid);

      // Update browser URL without reload
      window.history.pushState({}, '', url);

      if (scrollToLayout) {
        const layout = detailRoot.querySelector('.tcp-collection-detail__layout');
        if (layout) {
          requestAnimationFrame(() => {
            layout.scrollIntoView({ behavior: 'smooth', block: 'start' });
          });
        }
      }
    } catch (_) {
      window.location.href = url;
    } finally {
      productGrid.style.opacity = '';
      loading = false;
    }
  }

  // Apply filters: build URL from current state + AJAX load ──────────────────
  function applyFilters() {
    loadPage(buildFilterUrl());
  }

  // Bind all sidebar filter inputs ───────────────────────────────────────────
  if (filterForm) {
    // Instant: selects + checkboxes
    filterForm.addEventListener('change', (e) => {
      if (e.target.closest('[data-tcp-filter-input]')) {
        applyFilters();
      }
    });

    // Debounced: price number inputs
    let priceTimer = null;
    filterForm.addEventListener('input', (e) => {
      if (!e.target.closest('[data-tcp-filter-price]')) return;
      clearTimeout(priceTimer);
      priceTimer = setTimeout(applyFilters, 600);
    });
  }

  // Sort select (in sort bar, outside filter form) ───────────────────────────
  if (sortSelect) {
    sortSelect.addEventListener('change', applyFilters);
  }

  // Pagination links ─────────────────────────────────────────────────────────
  function bindPaginationLinks() {
    if (!paginationEl) return;
    paginationEl.querySelectorAll('.blog-pagination .links a[href]').forEach((link) => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        loadPage(link.href, { scrollToLayout: true });
      });
    });
  }

  // Legacy category sidebar links (data-tcp-ajax-filter)
  detailRoot.querySelectorAll('[data-tcp-ajax-filter]').forEach((link) => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      loadPage(link.href);
    });
  });

  // Handle browser back/forward
  window.addEventListener('popstate', () => {
    window.location.reload();
  });

  bindPaginationLinks();
}

// ─── ps_facetedsearch: cena jako „Od / Do” (jak kolekcja), URL jak modułowy slider.js ──

function tcpFacetedGetQueryParameters(params) {
  if (!params || typeof params !== 'string') return [];
  return params.split('&').filter(Boolean).map((str) => {
    const eq = str.indexOf('=');
    const key = eq >= 0 ? str.slice(0, eq) : str;
    const val = eq >= 0 ? str.slice(eq + 1) : '';
    return {
      name: decodeURIComponent(key),
      value: decodeURIComponent(val).replace(/\+/g, ' '),
    };
  });
}

/**
 * Usuwa z łańcucha q istniejący fragment ceny (Label-unit-min-max), żeby nie dublować
 * segmentów — inaczej moduł faceted traci poprawny filter.value i pola znikają po AJAX.
 */
function tcpFacetedStripPriceSegmentFromQ(qVal, label, unit) {
  if (!qVal || qVal === '') return '';
  const esc = (s) => String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const re = new RegExp(
    `(?:^|/)${esc(label)}-${esc(unit)}-\\d+(?:\\.\\d+)?-\\d+(?:\\.\\d+)?(?=/|$)`,
    'g',
  );
  let s = String(qVal).replace(re, '');
  s = s.replace(/\/+/g, '/').replace(/^\//, '').replace(/\/$/, '');
  return s;
}

/**
 * Odczyt [min,max] z ?q= w podanym URL (pełny lub względny).
 * Po AJAX fasetów PrestaShop wywołuje updateProductList zanim zrobi pushState —
 * wtedy window.location jest jeszcze stary; użyj current_url z payloadu zdarzenia.
 */
function tcpFacetedParsePricePairFromUrl(label, unit, urlString) {
  if (!label || !unit || !urlString) return null;
  try {
    const u = new URL(String(urlString), window.location.origin);
    const rawQ = u.searchParams.get('q');
    if (!rawQ) return null;
    const q = decodeURIComponent(rawQ.replace(/\+/g, ' '));
    const esc = (s) => String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const re = new RegExp(`${esc(label)}-${esc(unit)}-(\\d+(?:\\.\\d+)?)-(\\d+(?:\\.\\d+)?)`);
    const m = q.match(re);
    if (!m) return null;
    return [parseFloat(m[1]), parseFloat(m[2])];
  } catch (_) {
    return null;
  }
}

/**
 * @param {string} encodedUrl
 * @param {string} label  np. „Cena”
 * @param {string} unit   np. „zł”
 * @param {number|string} valMin
 * @param {number|string} valMax
 */
function tcpFacetedBuildPriceUrl(encodedUrl, label, unit, valMin, valMax) {
  const urlsSplitted = encodedUrl.split('?');
  let queryParams = [];
  if (urlsSplitted.length > 1 && urlsSplitted[1]) {
    queryParams = tcpFacetedGetQueryParameters(urlsSplitted[1]);
  }
  let found = false;
  queryParams.forEach((q) => {
    if (q.name === 'q') found = true;
  });
  if (!found) {
    queryParams.push({ name: 'q', value: '' });
  }
  const segment = [label, '-', unit, '-', valMin, '-', valMax].join('');
  queryParams.forEach((q) => {
    if (q.name === 'q') {
      const cleaned = tcpFacetedStripPriceSegmentFromQ(q.value, label, unit);
      q.value = cleaned.length > 0 ? `${cleaned}/${segment}` : segment;
    }
  });
  const qs = queryParams
    .map((p) => `${encodeURIComponent(p.name)}=${encodeURIComponent(p.value)}`)
    .join('&');
  return `${urlsSplitted[0]}?${qs}`;
}

function tcpFacetedParsePriceBounds(odStr, doStr, absMin, absMax) {
  const parseNum = (s, fallback) => {
    if (s === null || s === undefined || String(s).trim() === '') return fallback;
    const n = Number.parseFloat(String(s).replace(',', '.'));
    return Number.isNaN(n) ? fallback : n;
  };
  let v0 = parseNum(odStr, absMin);
  let v1 = parseNum(doStr, absMax);
  v0 = Math.max(absMin, Math.min(absMax, v0));
  v1 = Math.max(absMin, Math.min(absMax, v1));
  if (v0 > v1) {
    const t = v0;
    v0 = v1;
    v1 = t;
  }
  return [v0, v1];
}

/**
 * @param {ParentNode} [scope]
 * @param {{ listingUrl?: string }} [opts] — listingUrl: ProductListingFrontController JSON current_url (po AJAX)
 */
function initTcpFacetedPriceInputs(scope, opts) {
  const root = scope || document;
  const listingUrl =
    opts && typeof opts.listingUrl === 'string' && opts.listingUrl.length > 0
      ? opts.listingUrl
      : window.location.href;
  const wraps = root.querySelectorAll('[data-tcp-faceted-price]');
  if (!wraps.length) return;

  wraps.forEach((wrap) => {
    if (wrap.getAttribute('data-tcp-price-inited') === '1') return;
    wrap.setAttribute('data-tcp-price-inited', '1');

    const encodedUrl = wrap.getAttribute('data-tcp-price-encoded-url') || '';
    const label = wrap.getAttribute('data-tcp-price-label') || '';
    const unit = wrap.getAttribute('data-tcp-price-unit') || '';
    const absMin = Number.parseFloat(wrap.getAttribute('data-tcp-price-min') || '0');
    const absMax = Number.parseFloat(wrap.getAttribute('data-tcp-price-max') || '0');

    const odInput = wrap.querySelector('[data-tcp-faceted-price-from]');
    const doInput = wrap.querySelector('[data-tcp-faceted-price-to]');
    if (!odInput || !doInput || !encodedUrl) return;

    let filledFromServer = false;
    const valuesJson = wrap.getAttribute('data-tcp-price-values');
    if (valuesJson && valuesJson !== 'null' && valuesJson !== '') {
      try {
        const arr = JSON.parse(valuesJson);
        if (Array.isArray(arr) && arr.length >= 2) {
          odInput.value = String(arr[0]);
          doInput.value = String(arr[1]);
          filledFromServer = true;
        }
      } catch (_) {
        /* ignore */
      }
    }
    if (!filledFromServer) {
      const fromUrl = tcpFacetedParsePricePairFromUrl(label, unit, listingUrl);
      if (fromUrl) {
        odInput.value = String(fromUrl[0]);
        doInput.value = String(fromUrl[1]);
      }
    }

    const apply = () => {
      if (typeof prestashop === 'undefined' || typeof prestashop.emit !== 'function') return;
      const [v0, v1] = tcpFacetedParsePriceBounds(odInput.value, doInput.value, absMin, absMax);
      const requestUrl = tcpFacetedBuildPriceUrl(encodedUrl, label, unit, v0, v1);
      prestashop.emit('updateFacets', requestUrl);
    };

    let timer = null;
    const debounced = () => {
      window.clearTimeout(timer);
      timer = window.setTimeout(apply, 600);
    };

    odInput.addEventListener('input', debounced);
    doInput.addEventListener('input', debounced);
    odInput.addEventListener('change', () => {
      window.clearTimeout(timer);
      apply();
    });
    doInput.addEventListener('change', () => {
      window.clearTimeout(timer);
      apply();
    });
  });
}

/** Delegacja: <select class="tcp-faceted-select"> z value = nextEncodedFacetsURL (jak klik w checkbox). */
let tcpFacetedSelectBound = false;

function bindTcpFacetedSelectFacets() {
  if (tcpFacetedSelectBound) return;
  if (typeof prestashop === 'undefined' || typeof prestashop.emit !== 'function') return;
  tcpFacetedSelectBound = true;
  document.body.addEventListener('change', (e) => {
    const t = e.target;
    if (!t || t.nodeName !== 'SELECT' || !t.classList.contains('tcp-faceted-select')) return;
    const root = document.getElementById('search_filters');
    if (!root || !root.contains(t)) return;
    const url = (t.value || '').trim();
    if (url) {
      prestashop.emit('updateFacets', url);
      return;
    }
    const clearUrl = (t.getAttribute('data-faceted-clear-url') || '').trim();
    if (clearUrl) {
      prestashop.emit('updateFacets', clearUrl);
    }
  });
}

let tcpFacetedPriceListHooked = false;

function bindTcpFacetedPriceInputs() {
  initTcpFacetedPriceInputs(document);
  if (tcpFacetedPriceListHooked) return;
  if (typeof prestashop === 'undefined' || typeof prestashop.on !== 'function') return;
  tcpFacetedPriceListHooked = true;
  prestashop.on('updateProductList', (data) => {
    const listingUrl =
      data && typeof data.current_url === 'string' ? data.current_url : undefined;
    // listing.js podmienia #search_filters w tym samym emit — jeśli init poleci wcześniej,
    // eventy lądują na starych inputach (znika wartość, drugie wpisanie nie wywołuje AJAX).
    queueMicrotask(() => {
      initTcpFacetedPriceInputs(document, { listingUrl });
    });
  });
}

// ─── Mobile sidebar toggle ────────────────────────────────────────────────────
function initSidebarToggle() {
  const toggle = document.querySelector('[data-tcp-sidebar-toggle]');
  const sidebar = document.querySelector('.tcp-collection-detail__sidebar');
  if (!toggle || !sidebar) return;

  toggle.addEventListener('click', () => {
    const open = sidebar.classList.toggle('tcp-collection-detail__sidebar--open');
    toggle.setAttribute('aria-expanded', String(open));
  });
}

export default function initTcCollectionPages() {
  initCategoryPlpSortSelect();
  initCategoryPlpVideoCards();
  bindCategoryPlpProductListVideo();
  bindTcpFacetedSelectFacets();
  bindTcpFacetedPriceInputs();
  initCollectionDetailPage();
  initSidebarToggle();
}
