/**
 * Product Slider — universal Splide init for any product tile slider.
 * Target: section with [data-tc-product-slider] → finds first .splide inside.
 * Custom arrows: binds [data-slider-prev] / [data-slider-next] found anywhere in the section.
 * Pagination: enabled (requires <ul class="splide__pagination ..."> in the template).
 * Called from _dev/js/custom/theme.js via runWhenReady(initProductSlider).
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-product-slider-inited";

function initProductSlider() {
  const roots = document.querySelectorAll("[data-tc-product-slider]");

  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") return;
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector(".splide");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "slide",
      perPage: 4,
      perMove: 1,
      gap: "20px",
      arrows: false,
      pagination: true,
      autoplay: false,
      drag: true,
      breakpoints: {
        1200: { perPage: 3, gap: "20px" },
        992: { perPage: 2, gap: "16px" },
        640: { perPage: 1, gap: "0" },
      },
    });

    splide.mount();

    // Bind custom arrow buttons (e.g. from section header)
    const prevBtn = root.querySelector("[data-slider-prev]");
    const nextBtn = root.querySelector("[data-slider-next]");
    if (prevBtn) prevBtn.addEventListener("click", () => splide.go("<"));
    if (nextBtn) nextBtn.addEventListener("click", () => splide.go(">"));
  });
}

export default initProductSlider;
