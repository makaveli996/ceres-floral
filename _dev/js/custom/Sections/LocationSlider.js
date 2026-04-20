/**
 * Location Slider — Splide init for the showroom image slider.
 * Target: section with [data-tc-location-slider] → finds first .splide inside.
 * Custom arrows: next on all viewports, prev only rendered on mobile in template.
 * Called from _dev/js/custom/theme.js via runWhenReady(initLocationSlider).
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-location-slider-inited";

function initLocationSlider() {
  const roots = document.querySelectorAll("[data-tc-location-slider]");

  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") return;
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector(".splide");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
      perPage: 2,
      perMove: 1,
      gap: "16px",
      arrows: false,
      pagination: false,
      autoplay: true,
      drag: true,
      breakpoints: {
        768: { perPage: 1 },
      },
    });

    splide.mount();

    const prevBtn = root.querySelector("[data-slider-prev]");
    if (prevBtn) prevBtn.addEventListener("click", () => splide.go("<"));

    const nextBtn = root.querySelector("[data-slider-next]");
    if (nextBtn) nextBtn.addEventListener("click", () => splide.go(">"));
  });
}

export default initLocationSlider;
