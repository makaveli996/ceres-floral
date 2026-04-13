/**
 * Product Slider — Splide init for global product-slider component.
 * Used when [data-tc-product-slider] is present. Autoplay + loop. Reusable for bestsellers, new products, custom queries.
 * Called from _dev/js/custom/theme.js.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-product-slider-inited";

function initProductSlider() {
  const roots = document.querySelectorAll("[data-tc-product-slider]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector(".splide");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
      perPage: 4,
      perMove: 1,
      gap: "24px",
      arrows: true,
      pagination: false,
      autoplay: true,
      interval: 4000,
      pauseOnHover: true,
      breakpoints: {
        1200: { perPage: 3 },
        992: { perPage: 2 },
        768: { perPage: 1 },
      },
    });

    splide.mount();
  });
}

export default initProductSlider;
