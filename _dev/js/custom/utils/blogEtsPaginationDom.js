/**
 * Builds the same blog list pagination DOM as TcEtsBlogPaggination_class::render() + ets_blog html.tpl.
 * Used by: BlogInspirationsFilter.js, BlogTipsFilter.js — keeps AJAX markup aligned with SSR (.results + .links).
 * Inputs: page counts + pageToAbsoluteHref(page). Output: DocumentFragment. Clicks: data-tc-page on every <a>.
 * Side effects: none (pure DOM factory + click helper).
 */

import { blogPaginationSequence } from "./blogPaginationSequence";
import {
  parseBlogCategoryPageFromHref,
  blogListHistoryUrl,
} from "./blogCategoryListUrl";

/**
 * @typedef {Object} EtsBlogPaginationOptions
 * @property {number} currentPage
 * @property {number} totalPages
 * @property {number} perPage
 * @property {number} totalItems
 * @property {(page: number) => string} pageToAbsoluteHref
 */

/**
 * @param {EtsBlogPaginationOptions} opts
 * @returns {DocumentFragment}
 */
export function buildEtsBlogPaginationFragment(opts) {
  const {
    currentPage,
    totalPages,
    perPage,
    totalItems,
    pageToAbsoluteHref,
  } = opts;

  const pages = Math.max(1, Math.floor(totalPages));
  const page = Math.min(Math.max(1, Math.floor(currentPage)), pages);
  const limit = Math.max(1, Math.floor(perPage));
  const total = Math.max(0, Math.floor(totalItems));

  const frag = document.createDocumentFragment();

  const results = document.createElement("div");
  results.className = "results";
  const start = total ? (page - 1) * limit + 1 : 0;
  const end = Math.min((page - 1) * limit + limit, total);
  results.appendChild(
    document.createTextNode(
      `Showing ${start} to ${end} of ${total} (${pages} Pages)`
    )
  );

  const links = document.createElement("div");
  links.className = "links";

  function appendArrowLink(className, targetPage, spanChar) {
    const a = document.createElement("a");
    a.className = className;
    a.href = pageToAbsoluteHref(targetPage);
    a.setAttribute("data-tc-page", String(targetPage));
    const span = document.createElement("span");
    span.textContent = spanChar;
    a.appendChild(span);
    links.appendChild(a);
  }

  if (page > 1) {
    appendArrowLink("prev", page - 1, "<");
  }

  if (pages > 1) {
    const seq = blogPaginationSequence(page, pages);
    let prevNum = null;
    for (const n of seq) {
      if (prevNum !== null && n - prevNum > 1) {
        const pEl = document.createElement("p");
        pEl.className = "paginration_vv";
        pEl.textContent = "...";
        links.appendChild(pEl);
      }
      if (n === page) {
        const b = document.createElement("b");
        b.textContent = String(n);
        links.appendChild(b);
      } else {
        const a = document.createElement("a");
        a.href = pageToAbsoluteHref(n);
        a.setAttribute("data-tc-page", String(n));
        a.textContent = String(n);
        links.appendChild(a);
      }
      prevNum = n;
    }
  }

  if (page < pages) {
    appendArrowLink("next", page + 1, ">");
  }

  frag.appendChild(results);
  frag.appendChild(links);
  return frag;
}

/**
 * Resolve target list page from a click inside .links, or null if not a pagination control.
 *
 * @param {MouseEvent} e
 * @param {HTMLElement} paginRoot - e.g. nav#blog-insp-pagination
 * @returns {number|null}
 */
export function getPaginationLinkTargetPage(e, paginRoot) {
  const wrap = paginRoot?.querySelector?.(".links");
  const a = e.target.closest("a[href]");
  if (!a || !wrap || !wrap.contains(a)) return null;

  const ds = a.getAttribute("data-tc-page");
  if (ds != null && ds !== "") {
    const n = parseInt(ds, 10);
    if (Number.isFinite(n) && n >= 1) return n;
  }

  return parseBlogCategoryPageFromHref(a.href);
}

/**
 * @returns {(page: number) => string}
 */
export function defaultPageToAbsoluteHref() {
  const path = window.location.pathname;
  const search = window.location.search;

  return (p) =>
    new URL(blogListHistoryUrl(path, search, p), window.location.origin).href;
}
