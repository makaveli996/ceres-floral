/**
 * PostInspiration — Splide init for single Inspiracje post page.
 * Gallery slider: [data-post-insp-splide] — full-width, 1 slide, loop, pagination + arrows.
 * Related posts slider is handled by TcInspirationsSlider.js ([data-inspirations-slider]).
 * Called from _dev/js/custom/theme.js via runWhenReady().
 */
import Splide from "@splidejs/splide";

const DATA_GALLERY_INITED = "data-post-insp-splide-inited";

function initPostInspiration() {
  document.querySelectorAll("[data-post-insp-splide]").forEach((el) => {
    if (el.getAttribute(DATA_GALLERY_INITED) === "true") {
      return;
    }
    if (el.querySelectorAll(".splide__slide").length === 0) {
      return;
    }
    el.setAttribute(DATA_GALLERY_INITED, "true");

    new Splide(el, {
      type: "loop",
      perPage: 1,
      perMove: 1,
      gap: 0,
      arrows: true,
      pagination: true,
    }).mount();
  });
}

export default initPostInspiration;
