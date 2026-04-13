/**
 * Parse and build ets_blog category list URLs (friendly routes: /category/{id}-{slug} and /category/{page}/{id}-{slug}).
 * Used by: BlogInspirationsFilter.js, BlogTipsFilter.js for AJAX pagination + History API.
 * Inputs: full or relative href / pathname. Outputs: page number (1-based) or pathname for a given page.
 * Side effects: none (pure helpers).
 */

/**
 * @param {string} href
 * @returns {number}
 */
export function parseBlogCategoryPageFromHref(href) {
  let url;
  try {
    url = new URL(href, window.location.href);
  } catch {
    return 1;
  }

  const qp = url.searchParams.get("page");
  if (qp && /^\d+$/.test(qp)) {
    const n = parseInt(qp, 10);
    return n >= 1 ? n : 1;
  }

  const path = url.pathname;
  const withPageNum = path.match(/\/category\/(\d+)\/(\d+-[^/]+)$/);
  if (withPageNum) {
    return parseInt(withPageNum[1], 10) || 1;
  }

  return 1;
}

/**
 * Page 1 path: strip /{page}/ between category/ and {id}-{slug}.
 *
 * @param {string} pathname
 * @returns {string}
 */
export function blogCategoryUrlPageOne(pathname) {
  return pathname.replace(/^(.*\/category\/)\d+\/(\d+-[^/]+)$/, "$1$2");
}

/**
 * @param {string} pathname
 * @param {number} page
 * @returns {string}
 */
export function blogCategoryUrlWithPage(pathname, page) {
  const p = Math.max(1, Math.floor(page));
  if (p <= 1) {
    return blogCategoryUrlPageOne(pathname);
  }
  const m = pathname.match(/^(.*\/category\/)(?:\d+\/)?(\d+-[^/]+)$/);
  if (!m) {
    return pathname;
  }
  const [, prefix, idSlug] = m;
  return `${prefix}${p}/${idSlug}`;
}

/**
 * Full path+search for History API when changing list page (friendly path or ?page= fallback).
 *
 * @param {string} pathname
 * @param {string} search
 * @param {number} pageNum
 * @returns {string}
 */
export function blogListHistoryUrl(pathname, search, pageNum) {
  const u = new URL(pathname + (search || ""), window.location.href);
  const prevPath = u.pathname;
  u.pathname = blogCategoryUrlWithPage(u.pathname, pageNum);
  if (u.pathname === prevPath) {
    if (pageNum <= 1) {
      u.searchParams.delete("page");
    } else {
      u.searchParams.set("page", String(pageNum));
    }
  } else {
    u.searchParams.delete("page");
  }
  return u.pathname + (u.search || "");
}
