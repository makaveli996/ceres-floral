/**
 * TcCompanyHistory — Splide init per history item slider + read more/less toggle for descriptions.
 * Used when [data-tc-companyhistory] is present. Inits [data-tc-companyhistory-splide] and [data-tc-companyhistory-toggle].
 * Called from _dev/js/custom/theme.js. No double init.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-companyhistory-inited";
const DESCRIPTION_CHARS_COLLAPSED = 855;
const ELLIPSIS = "...";

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

function textToHtmlWithBr(text) {
  return escapeHtml(text.trim()).replace(/\n/g, "<br>");
}

function initSliders(root) {
  root.querySelectorAll("[data-tc-companyhistory-slider]").forEach((wrap) => {
    if (wrap.getAttribute("data-tc-companyhistory-slider-inited") === "true") {
      return;
    }
    const splideEl = wrap.querySelector("[data-tc-companyhistory-splide]");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }
    wrap.setAttribute("data-tc-companyhistory-slider-inited", "true");
    const splide = new Splide(splideEl, {
      type: "loop",
      perPage: 1,
      perMove: 1,
      arrows: true,
      pagination: true,
      gap: 0,
    });
    splide.mount();
  });
}

function initReadMore(root) {
  root.querySelectorAll("[data-tc-companyhistory-description]").forEach((descEl) => {
    const wrap = descEl.closest(".tc-companyhistory__description-wrap");
    const toggle = wrap?.querySelector("[data-tc-companyhistory-toggle]");
    if (!toggle) return;

    const fullHtml = descEl.innerHTML;
    const plainText = (descEl.textContent || "").trim();

    if (plainText.length <= DESCRIPTION_CHARS_COLLAPSED) {
      toggle.setAttribute("aria-hidden", "true");
      return;
    }

    const shortText = plainText.slice(0, DESCRIPTION_CHARS_COLLAPSED) + ELLIPSIS;
    const shortHtml = textToHtmlWithBr(shortText);

    descEl.style.overflow = "hidden";
    descEl.innerHTML = shortHtml;
    const shortHeight = descEl.scrollHeight;
    descEl.style.maxHeight = shortHeight + "px";
    descEl.setAttribute("data-expanded", "false");

    const moreLabel = toggle.getAttribute("data-more") || "Rozwiń więcej";
    const lessLabel = toggle.getAttribute("data-less") || "Zwiń";
    const textSpan = toggle.querySelector(".tc-companyhistory__toggle-text");
    if (textSpan) textSpan.textContent = moreLabel;

    toggle.style.display = "";
    toggle.setAttribute("aria-hidden", "false");

    const onExpand = () => {
      descEl.innerHTML = fullHtml;
      descEl.style.maxHeight = "none";
      const fullHeight = descEl.scrollHeight;
      descEl.style.maxHeight = shortHeight + "px";
      descEl.setAttribute("data-expanded", "true");
      if (textSpan) textSpan.textContent = lessLabel;
      requestAnimationFrame(() => {
        descEl.style.maxHeight = fullHeight + "px";
      });
    };

    const onCollapse = () => {
      descEl.style.maxHeight = shortHeight + "px";
      const onTransitionEnd = () => {
        descEl.removeEventListener("transitionend", onTransitionEnd);
        descEl.innerHTML = shortHtml;
        descEl.style.maxHeight = shortHeight + "px";
        if (textSpan) textSpan.textContent = moreLabel;
        descEl.setAttribute("data-expanded", "false");
      };
      descEl.addEventListener("transitionend", onTransitionEnd);
    };

    toggle.addEventListener("click", () => {
      const expanded = descEl.getAttribute("data-expanded") === "true";
      if (expanded) {
        onCollapse();
      } else {
        onExpand();
      }
    });
  });
}

function initTcCompanyHistory() {
  const roots = document.querySelectorAll("[data-tc-companyhistory]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");
    initSliders(root);
    initReadMore(root);
  });
}

export default initTcCompanyHistory;
