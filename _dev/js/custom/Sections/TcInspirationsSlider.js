/**
 * TcInspirationsSlider — Splide init for .inspirations-slider component.
 * Selects every [data-inspirations-slider] root and inits [data-inspirations-slider-splide].
 * Used on: homepage (tc_inspirationsslider), single inspiration post (related posts).
 * Called from _dev/js/custom/theme.js.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-inspirations-slider-inited";

function initTcInspirationsSlider() {
  const roots = document.querySelectorAll("[data-inspirations-slider]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-inspirations-slider-splide]");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
      focus: "center",
      autoWidth: true,
      perMove: 1,
      gap: "24px",
      arrows: true,
      pagination: true,
    });

    splide.mount();
  });
}

export default initTcInspirationsSlider;
