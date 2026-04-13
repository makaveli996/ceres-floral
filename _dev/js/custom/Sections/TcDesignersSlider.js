/**
 * TcDesignersSlider — Splide init for designers slider section on homepage.
 * Used when [data-tc-designers-slider] is present. Inits [data-tc-designers-slider-splide].
 * Desktop: 3 slides visible; tablet/mobile: 2 then 1. Arrows and pagination. Called from _dev/js/custom/theme.js.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-designers-slider-inited";

function initTcDesignersSlider() {
  const roots = document.querySelectorAll("[data-tc-designers-slider]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-tc-designers-slider-splide]");
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

export default initTcDesignersSlider;
