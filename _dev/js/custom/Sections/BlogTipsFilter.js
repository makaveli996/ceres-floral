/**
 * Blog Tips archive filter (AJAX).
 * Markup for each card mirrors themes/ceres_floral/templates/_partials/post-card.tpl (keep in sync).
 * Used on: /blog/category/porady — .blog-tips[data-ajax-url].
 * Filter tabs + AJAX pagination; po fetch ten sam markup co SSR (.results + .links).
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

const HISTORY_STATE_KEY = "tcBlogTips";

const ARROW_SVG = `<svg class="post-card__arrow-icon" width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M0 10.5C0 4.70101 4.70101 0 10.5 0C16.299 0 21 4.70101 21 10.5C21 16.299 16.299 21 10.5 21C4.70101 21 0 16.299 0 10.5Z" fill="#F7A626"/>
  <path d="M12.8117 10.0769C13.0972 10.2867 13.0972 10.7133 12.8117 10.9231L9.89207 13.0684C9.54535 13.3232 9.0562 13.0756 9.0562 12.6454L9.0562 8.35464C9.0562 7.92438 9.54536 7.6768 9.89207 7.93158L12.8117 10.0769Z" fill="#1E1E1E"/>
</svg>`;

/**
 * @param {{ id: number, title: string, link: string, thumb_url: string, date_formatted: string, category_label: string }} post
 * @returns {string}
 */
function renderBlogCard(post) {
  const imgWrap = post.thumb_url
    ? `<div class="post-card__img-wrap">
        <img src="${escHtml(post.thumb_url)}" alt="${escHtml(post.title)}" class="post-card__img" loading="lazy">
        ${post.category_label ? `<span class="post-card__cat">${escHtml(post.category_label)}</span>` : ""}
      </div>`
    : "";

  return `<li class="post-card">
    <a href="${escHtml(post.link)}" class="post-card__link">
      ${imgWrap}
      <div class="post-card__body">
        <time class="post-card__date">${escHtml(post.date_formatted)}</time>
        <h3 class="post-card__title">${escHtml(post.title)}</h3>
        <div class="post-card__arrow" aria-hidden="true">${ARROW_SVG}</div>
      </div>
    </a>
  </li>`;
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function initBlogTipsFilter() {
  const root = document.querySelector(".blog-tips[data-ajax-url]");
  if (!root) return;
  if (root.getAttribute("data-tc-tips-filter-inited") === "true") return;
  root.setAttribute("data-tc-tips-filter-inited", "true");

  const ajaxUrl = root.dataset.ajaxUrl;
  const filterList = root.querySelector(".blog-tips__filters");
  const grid = document.getElementById("blog-tips-grid");
  const paginEl = document.getElementById("blog-tips-pagination");
  const loadingEl = document.getElementById("blog-tips-loading");

  if (!ajaxUrl || !grid || !filterList) return;

  const originalGridHtml = grid.innerHTML;
  const originalPaginHtml = paginEl ? paginEl.innerHTML : "";

  let activeFilter = "all";
  let activeCatId = 0;
  let currentPage = 1;
  let ajaxMode = false;
  let abortCtrl = null;

  function getPsToken() {
    if (typeof window.prestashop !== "undefined" && window.prestashop.static_token) {
      return window.prestashop.static_token;
    }
    if (typeof window.static_token !== "undefined") return window.static_token;
    const meta = document.querySelector('meta[name="ps-token"]');
    if (meta) return meta.getAttribute("content") || "";
    return "";
  }

  function setLoading(on) {
    if (!loadingEl) return;
    loadingEl.classList.toggle("blog-tips__loading--visible", on);
    loadingEl.setAttribute("aria-hidden", on ? "false" : "true");
    grid.setAttribute("aria-busy", on ? "true" : "false");
  }

  function setActiveBtn(btn) {
    filterList.querySelectorAll(".blog-tips__filter-btn").forEach((b) => {
      b.classList.remove("blog-tips__filter-btn--active");
      b.setAttribute("aria-selected", "false");
    });
    btn.classList.add("blog-tips__filter-btn--active");
    btn.setAttribute("aria-selected", "true");
  }

  function activateAllTab() {
    const allBtn = filterList.querySelector('.blog-tips__filter-btn[data-filter="all"]');
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
    grid.innerHTML = originalGridHtml;
    if (paginEl) paginEl.innerHTML = originalPaginHtml;
    currentPage = 1;
    const u = new URL(window.location.href);
    u.pathname = blogCategoryUrlPageOne(u.pathname);
    u.searchParams.delete("page");
    history.replaceState(null, "", u.pathname + u.search);
  }

  function scrollToGrid() {
    const wrap = document.getElementById("blog-tips-grid-wrap");
    if (wrap) {
      wrap.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }

  async function fetchPosts(filter, idCategory, page, historyOpts = { mode: "none" }) {
    if (abortCtrl) abortCtrl.abort();
    abortCtrl = new AbortController();

    const params = new URLSearchParams({
      filter,
      id_category: idCategory || 0,
      page,
      token: getPsToken(),
    });

    const sep = ajaxUrl.includes("?") ? "&" : "?";
    const resp = await fetch(`${ajaxUrl}${sep}${params.toString()}`, {
      signal: abortCtrl.signal,
      headers: { "X-Requested-With": "XMLHttpRequest" },
    });

    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    return resp.json();
  }

  async function renderAfterFetch(data, historyOpts) {
    if (!data.success) throw new Error(data.error || "Unknown error");

    grid.innerHTML = data.posts.map(renderBlogCard).join("");

    if (paginEl) {
      if (data.pages > 1) {
        paginEl.innerHTML = "";
        const pageToAbsoluteHref = defaultPageToAbsoluteHref();
        paginEl.appendChild(
          buildEtsBlogPaginationFragment({
            currentPage: data.current_page,
            totalPages: data.pages,
            perPage: data.per_page || 10,
            totalItems: data.total,
            pageToAbsoluteHref,
          })
        );
      } else {
        paginEl.innerHTML = "";
      }
    }

    if (data.posts.length === 0) {
      grid.innerHTML = `<li class="blog-tips__empty" style="grid-column:1/-1">${
        "Brak artykułów spełniających kryteria."
      }</li>`;
    }

    currentPage = data.current_page;
    ajaxMode = true;
    applyHistory(historyOpts, data.current_page);
  }

  async function applyFilter(btn) {
    const filter = btn.dataset.filter || "all";
    const catId = parseInt(btn.dataset.catId || "0", 10);

    if (filter === "all") {
      setActiveBtn(btn);
      activeFilter = "all";
      activeCatId = 0;
      currentPage = 1;
      restoreOriginal();
      return;
    }

    setActiveBtn(btn);
    activeFilter = filter;
    activeCatId = catId;
    currentPage = 1;
    setLoading(true);

    try {
      const data = await fetchPosts(filter, catId, 1, { mode: "none" });
      await renderAfterFetch(data, { mode: "replace" });
    } catch (err) {
      if (err.name === "AbortError") return;
      console.error("[BlogTipsFilter] fetch error:", err);
    } finally {
      setLoading(false);
    }
  }

  function onPopState() {
    if (!root.isConnected) {
      window.removeEventListener("popstate", onPopState);
      return;
    }
    if (!window.location.pathname.includes("/category/")) return;
    const page = parseBlogCategoryPageFromHref(window.location.href);
    setLoading(true);
    fetchPosts(activeFilter, activeCatId, page, { mode: "none" })
      .then((data) => renderAfterFetch(data, { mode: "none" }))
      .catch((err) => {
        if (err.name !== "AbortError") console.error("[BlogTipsFilter] popstate:", err);
      })
      .finally(() => {
        setLoading(false);
        scrollToGrid();
      });
  }

  window.addEventListener("popstate", onPopState);

  filterList.addEventListener("click", (e) => {
    const btn = e.target.closest(".blog-tips__filter-btn");
    if (!btn) return;
    e.preventDefault();
    applyFilter(btn);
  });

  if (paginEl) {
    paginEl.addEventListener("click", (e) => {
      const page = getPaginationLinkTargetPage(e, paginEl);
      if (page == null) return;
      e.preventDefault();
      if (!ajaxMode) {
        activeFilter = "all";
        activeCatId = 0;
        activateAllTab();
      }
      const a = e.target.closest("a[href]");
      const abs = a ? new URL(a.href, window.location.href).href : undefined;
      setLoading(true);
      fetchPosts(activeFilter, activeCatId, page, { mode: "none" })
        .then((data) => renderAfterFetch(data, { mode: "push", href: abs }))
        .catch((err) => {
          if (err.name !== "AbortError") console.error("[BlogTipsFilter] pagination click:", err);
        })
        .finally(() => {
          setLoading(false);
          scrollToGrid();
        });
    });
  }
}

export default initBlogTipsFilter;
