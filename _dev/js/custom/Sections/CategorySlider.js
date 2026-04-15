/**
 * Category Slider section — Splide init for per-category product sliders.
 * Target: each section with [data-tc-category-slider] → finds .splide inside.
 * 3 products per page on desktop (vs 4 in ProductSlider), arrow: [data-slider-next].
 * Called from _dev/js/custom/theme.js via runWhenReady(initCategorySlider).
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-category-slider-inited";

function initCategorySlider() {
  const roots = document.querySelectorAll("[data-tc-category-slider]");

  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") return;
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector(".splide");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
      fixedWidth: "285px", // > 991.98px — auto-fill based on container width
      perMove: 1,
      gap: "20px",
      arrows: false,
      pagination: true,
      autoplay: true,
      drag: true,
      breakpoints: {
        992: { perPage: 2, gap: "16px" },
        640: { focus: "center", trimSpace: false },
      },
    });

    splide.mount();

    const nextBtn = root.querySelector("[data-slider-next]");
    if (nextBtn) nextBtn.addEventListener("click", () => splide.go(">"));
  });
}

export default initCategorySlider;
