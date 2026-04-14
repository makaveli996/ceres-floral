import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-home-promo-slider-inited";

function initHomePromoSlider() {
  const roots = document.querySelectorAll("[data-tc-home-promo-slider]");

  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-tc-home-promo-splide]");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "loop",
      perPage: 1,
      perMove: 1,
      arrows: false,
      pagination: true,
      autoplay: true,
      interval: 5000,
      pauseOnHover: true,
      drag: true,
    });

    splide.mount();
  });
}

export default initHomePromoSlider;
