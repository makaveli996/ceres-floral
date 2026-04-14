/**
 * Bestsellers slider — Splide init for tc_bestsellersslider section.
 * Target: [data-tc-bestsellers-slider] → finds [data-tc-bestsellers-splide] inside.
 * Arrows: pagination: true, arrows: false; [data-slider-prev/next] bound manually to Splide API.
 * Called from _dev/js/custom/theme.js via runWhenReady(initBestsellersSlider).
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-bestsellers-slider-inited";

function initBestsellersSlider() {
  const roots = document.querySelectorAll("[data-tc-bestsellers-slider]");

  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") return;
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-tc-bestsellers-splide]");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
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

    // Bind custom arrow buttons from the section header
    const prevBtn = root.querySelector("[data-slider-prev]");
    const nextBtn = root.querySelector("[data-slider-next]");

    if (prevBtn) {
      prevBtn.addEventListener("click", () => splide.go("<"));
    }
    if (nextBtn) {
      nextBtn.addEventListener("click", () => splide.go(">"));
    }
  });
}

export default initBestsellersSlider;
