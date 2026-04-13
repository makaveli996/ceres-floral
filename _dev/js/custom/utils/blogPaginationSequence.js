/**
 * Page indices for blog list pagination (mirrors TcEtsBlogPaggination_class::buildVisiblePages).
 * Used by: BlogTipsFilter.js, BlogInspirationsFilter.js — keep in sync with PHP when changing rules.
 * Inputs: current page and total pages (1-based). Output: sorted unique integers; UI inserts ellipsis between gaps > 1.
 * Side effects: none.
 */

/**
 * @param {number} current
 * @param {number} total
 * @returns {number[]}
 */
export function blogPaginationSequence(current, total) {
  const t = Math.max(1, Math.floor(total));
  const p = Math.min(Math.max(1, Math.floor(current)), t);

  if (t <= 7) {
    return Array.from({ length: t }, (_, i) => i + 1);
  }

  /** @type {number[]} */
  let nums = [];

  if (p <= 4) {
    for (let i = 1; i <= Math.min(5, t); i += 1) {
      nums.push(i);
    }
    if (t > 5) {
      nums.push(t);
    }
  } else if (p >= t - 3) {
    nums.push(1);
    const start = Math.max(2, t - 4);
    for (let i = start; i <= t; i += 1) {
      nums.push(i);
    }
  } else {
    nums.push(1, p - 1, p, p + 1, t);
  }

  nums = [...new Set(nums)].sort((a, b) => a - b);
  return nums;
}
