/**
 * PDP Splide gallery init (main + optional thumbnail sync) with video autoplay support.
 * Used by: product.tpl via product-gallery-splide.tpl markup.
 * Inputs: [data-pdp-gallery] roots, nested [data-pdp-gallery-main]/thumbs, .pdp-gallery__slide--video slides.
 * Output: Mounted Splide instances; video in active slide autoplays with controls, pauses on slide change.
 * Side effects: Attaches listeners on DOM ready and PrestaShop updatedProduct event.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-pdp-gallery-inited";

/** @type {WeakMap<Element, { main: import("@splidejs/splide").Splide, thumbs?: import("@splidejs/splide").Splide }>} */
const instances = new WeakMap();

/**
 * Pause and hide controls on all videos inside root, then optionally play one.
 *
 * @param {Element} mainEl
 * @param {number|null} activeIndex
 */
function handleVideoForSlide(mainEl, activeIndex) {
  const slides = mainEl.querySelectorAll(".splide__slide");

  slides.forEach((slide) => {
    const video = slide.querySelector(".pdp-gallery__video");
    if (!video) return;
    video.pause();
    video.removeAttribute("controls");
  });

  if (activeIndex === null) return;

  const activeSlide = slides[activeIndex];
  if (!activeSlide) return;

  const video = activeSlide.querySelector(".pdp-gallery__video");
  if (!video) return;

  video.setAttribute("controls", "");
  // muted allows autoplay without user gesture; user can unmute via controls
  video.muted = false;
  video.play().catch(() => {
    // Browser blocked autoplay (no prior interaction) — stay paused, controls still visible
  });
}

function destroyGallery(root) {
  const stored = instances.get(root);
  if (stored) {
    if (stored.thumbs) {
      stored.thumbs.destroy(true);
    }
    stored.main.destroy(true);
    instances.delete(root);
  }
  root.removeAttribute(DATA_INITED);
}

function mountGallery(root) {
  if (!root) {
    return;
  }

  const mainEl = root.querySelector("[data-pdp-gallery-main]");
  const thumbsEl = root.querySelector("[data-pdp-gallery-thumbs]");
  if (!mainEl) {
    return;
  }

  const slideCount = mainEl.querySelectorAll(".splide__slide").length;
  if (!slideCount) {
    return;
  }

  root.setAttribute(DATA_INITED, "true");

  const multiple = slideCount > 1 && thumbsEl;

  const main = new Splide(mainEl, {
    type: "slide",
    rewind: multiple,
    pagination: false,
    arrows: multiple,
    speed: 400,
    drag: multiple,
  });

  main.on("moved", (newIndex) => {
    handleVideoForSlide(mainEl, newIndex);
  });

  /** @type {import("@splidejs/splide").Splide | undefined} */
  let thumbs;

  if (multiple) {
    thumbs = new Splide(thumbsEl, {
      fixedWidth: "calc((100% - 10px) / 6)",
      fixedHeight: 100,
      gap: 2,
      rewind: true,
      pagination: false,
      arrows: false,
      isNavigation: true,
      dragMinThreshold: {
        mouse: 4,
        touch: 10,
      },
      breakpoints: {
        991: {
          fixedWidth: "calc((100% - 8px) / 5)",
          fixedHeight: 74,
        },
      },
    });

    main.sync(thumbs);
    thumbs.mount();
  }

  main.mount();
  instances.set(root, { main, thumbs });
}

function initPdpGallery() {
  document.querySelectorAll("[data-pdp-gallery]").forEach((root) => {
    destroyGallery(root);
    mountGallery(root);
  });
}

if (window.prestashop && typeof window.prestashop.on === "function") {
  window.prestashop.on("updatedProduct", () => {
    initPdpGallery();
  });
}

export default initPdpGallery;
