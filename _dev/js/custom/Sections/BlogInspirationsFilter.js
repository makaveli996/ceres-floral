/**
 * Blog Inspirations archive filter (AJAX).
 * Used on: /blog/category/inspiracje — .blog-inspiration[data-ajax-url].
 * Filter tabs + AJAX pagination; po fetch ten sam markup co SSR (.results + .links, a/b/p).
 * Updates #blog-insp-grid and #blog-insp-pagination without full page reload.
 * No side effects outside the DOM. Called from theme.js via runWhenReady.
 */

import {
  parseBlogCategoryPageFromHref,
  blogCategoryUrlPageOne,
  blogListHistoryUrl,
} from "../utils/blogCategoryListUrl";
import {
  buildEtsBlogPaginationFragment,
  getPaginationLinkTargetPage,
  defaultPageToAbsoluteHref,
} from "../utils/blogEtsPaginationDom";

const HISTORY_STATE_KEY = "tcBlogInsp";

/** Matches themes/ceres_floral/templates/_partials/button.tpl (arrow-right, no_url_as_span). */
const INSP_CARD_CTA_ARROW_SVG = `<svg width="8" height="11" viewBox="0 0 8 11" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.15334 4.2823C7.69716 4.6819 7.69716 5.49437 7.15334 5.89397L1.59214 9.9804C0.931721 10.4657 4.33248e-07 9.9941 4.69071e-07 9.17456L8.26318e-07 1.00171C8.62141e-07 0.18217 0.931721 -0.289406 1.59214 0.195874L7.15334 4.2823Z" fill="currentColor"></path></svg>`;

/**
 * @param {string} label
 * @returns {string}
 */
function renderInspCardCtaHtml(label) {
  const t = String(label || "").trim();
  if (!t) return "";
  return `<span class="insp-card__button button--empty button--white button">
    <span class="button__text">${escHtml(t)}</span>
    <span class="button__icon button__icon--arrow-right" aria-hidden="true">${INSP_CARD_CTA_ARROW_SVG}</span>
  </span>`;
}

/**
 * @param {{ id: number, title: string, link: string, image_url: string }} post
 * @param {string} ctaLabel - from data-insp-card-cta (same as insp-card.tpl)
 * @returns {string}
 */
function renderInspCard(post, ctaLabel) {
  const media = post.image_url
    ? `<span class="insp-card__media">
        <img src="${escHtml(post.image_url)}" alt="${escHtml(post.title)}" class="insp-card__img" loading="lazy">
      </span>`
    : "";

  return `<li>
    <a href="${escHtml(post.link)}" class="insp-card">
      ${media}
      <span class="insp-card__overlay"></span>
      <div class="insp-card__content">
        <span class="insp-card__title">${escHtml(post.title)}</span>
        ${renderInspCardCtaHtml(ctaLabel)}
      </div>
    </a>
  </li>`;
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function getPsToken() {
  if (typeof window.prestashop !== "undefined" && window.prestashop.static_token) {
    return window.prestashop.static_token;
  }
  if (typeof window.static_token !== "undefined") return window.static_token;
  const meta = document.querySelector('meta[name="ps-token"]');
  if (meta) return meta.getAttribute("content") || "";
  return "";
}

/**
 * @typedef {{ mode: "none"|"push"|"replace"; href?: string }} HistoryOpts
 */

export default function initBlogInspirationsFilter() {
  const root = document.querySelector(".blog-inspiration[data-ajax-url]");
  if (!root) return;

  const ajaxUrl = root.dataset.ajaxUrl;
  const filterBar = root.querySelector(".blog-inspiration__filter-bar");
  const grid = document.getElementById("blog-insp-grid");
  const paginWrap = document.getElementById("blog-insp-pagination");
  const loading = document.getElementById("blog-insp-loading");

  if (!grid || !ajaxUrl || !filterBar) return;

  const originalGrid = grid.innerHTML;
  const originalPagination = paginWrap ? paginWrap.innerHTML : "";

  let currentFilter = "all";
  let currentCatId = 0;
  let currentPage = 1;
  let ajaxMode = false;
  let abortController = null;

  function setLoading(on) {
    if (!loading) return;
    if (on) {
      loading.classList.add("blog-inspiration__loading--visible");
    } else {
      loading.classList.remove("blog-inspiration__loading--visible");
    }
  }

  function setActiveBtn(btn) {
    filterBar.querySelectorAll(".blog-inspiration__filter-btn").forEach((b) => {
      b.classList.remove("blog-inspiration__filter-btn--active");
      b.setAttribute("aria-selected", "false");
    });
    btn.classList.add("blog-inspiration__filter-btn--active");
    btn.setAttribute("aria-selected", "true");
  }

  function activateAllTab() {
    const allBtn = filterBar.querySelector('.blog-inspiration__filter-btn[data-filter="all"]');
    if (allBtn) setActiveBtn(allBtn);
  }

  function applyHistory(historyOpts, currentPageNum) {
    if (!historyOpts || historyOpts.mode === "none") return;
    if (historyOpts.mode === "push" && historyOpts.href) {
      history.pushState({ [HISTORY_STATE_KEY]: 1 }, "", historyOpts.href);
      return;
    }
    const u = new URL(window.location.href);
    if (historyOpts.mode === "push") {
      const url = blogListHistoryUrl(u.pathname, u.search, currentPageNum);
      history.pushState({ [HISTORY_STATE_KEY]: 1 }, "", url);
    } else if (historyOpts.mode === "replace") {
      u.pathname = blogCategoryUrlPageOne(u.pathname);
      u.searchParams.delete("page");
      history.replaceState({ [HISTORY_STATE_KEY]: 1 }, "", u.pathname + u.search);
    }
  }

  function restoreOriginal() {
    ajaxMode = false;
    grid.innerHTML = originalGrid;
    if (paginWrap) paginWrap.innerHTML = originalPagination;
    currentPage = 1;
    const u = new URL(window.location.href);
    u.pathname = blogCategoryUrlPageOne(u.pathname);
    u.searchParams.delete("page");
    history.replaceState(null, "", u.pathname + u.search);
    window.scrollTo({ top: grid.closest(".blog-inspiration__grid-wrap")?.offsetTop ?? 0, behavior: "smooth" });
  }

  function scrollToGrid() {
    const wrap = grid.closest(".blog-inspiration__grid-wrap");
    if (wrap) {
      window.scrollTo({ top: wrap.offsetTop - 80, behavior: "smooth" });
    }
  }

  async function fetchPosts(filter, idCategory, page, historyOpts = { mode: "none" }) {
    if (abortController) abortController.abort();
    abortController = new AbortController();

    setLoading(true);

    const params = new URLSearchParams({
      filter,
      id_category: idCategory,
      page,
      token: getPsToken(),
    });

    const sep = ajaxUrl.includes("?") ? "&" : "?";

    try {
      const resp = await fetch(`${ajaxUrl}${sep}${params.toString()}`, {
        signal: abortController.signal,
        headers: { "X-Requested-With": "XMLHttpRequest" },
      });

      if (!resp.ok) throw new Error("HTTP " + resp.status);

      const data = await resp.json();

      if (!data.success) {
        console.error("[BlogInspirationsFilter]", data.error);
        setLoading(false);
        return;
      }

      const ctaLabel =
        root.dataset.inspCardCta || "Zobacz aranżację";
      grid.innerHTML = data.posts.map((p) => renderInspCard(p, ctaLabel)).join("");

      if (paginWrap) {
        if (data.pages > 1) {
          paginWrap.innerHTML = "";
          const pageToAbsoluteHref = defaultPageToAbsoluteHref();
          paginWrap.appendChild(
            buildEtsBlogPaginationFragment({
              currentPage: data.current_page,
              totalPages: data.pages,
              perPage: data.per_page || 8,
              totalItems: data.total,
              pageToAbsoluteHref,
            })
          );
        } else {
          paginWrap.innerHTML = "";
        }
      }

      currentPage = data.current_page;
      ajaxMode = true;

      applyHistory(historyOpts, data.current_page);
    } catch (err) {
      if (err.name !== "AbortError") {
        console.error("[BlogInspirationsFilter] fetch error:", err);
      }
    } finally {
      setLoading(false);
    }
  }

  function applyFilter(btn) {
    const filter = btn.dataset.filter || "all";
    const catId = parseInt(btn.dataset.catId || "0", 10);

    setActiveBtn(btn);

    if (filter === "all" && !ajaxMode) {
      return;
    }

    if (filter === "all") {
      restoreOriginal();
      currentFilter = "all";
      currentCatId = 0;
      return;
    }

    currentFilter = filter;
    currentCatId = catId;
    currentPage = 1;

    fetchPosts(currentFilter, currentCatId, currentPage, { mode: "replace" });
  }

  function onPopState() {
    if (!root.isConnected) {
      window.removeEventListener("popstate", onPopState);
      return;
    }
    if (!window.location.pathname.includes("/category/")) return;
    const page = parseBlogCategoryPageFromHref(window.location.href);
    fetchPosts(currentFilter, currentCatId, page, { mode: "none" });
    scrollToGrid();
  }

  window.addEventListener("popstate", onPopState);

  filterBar.addEventListener("click", (e) => {
    const btn = e.target.closest(".blog-inspiration__filter-btn");
    if (!btn) return;
    applyFilter(btn);
  });

  if (paginWrap) {
    paginWrap.addEventListener("click", (e) => {
      const page = getPaginationLinkTargetPage(e, paginWrap);
      if (page == null) return;
      e.preventDefault();
      if (!ajaxMode) {
        currentFilter = "all";
        currentCatId = 0;
        activateAllTab();
      }
      const a = e.target.closest("a[href]");
      const abs = a ? new URL(a.href, window.location.href).href : undefined;
      fetchPosts(currentFilter, currentCatId, page, {
        mode: "push",
        href: abs,
      });
      scrollToGrid();
    });
  }
}
