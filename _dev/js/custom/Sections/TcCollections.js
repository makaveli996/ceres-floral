/**
 * TcCollections (tc_collections) — Splide init + left content sync.
 * Used on homepage when [data-tc-collections] is present. Inits [data-tc-collections-splide] and syncs
 * panels [data-tc-collections-panel] with active slide index. Called from _dev/js/custom/theme.js.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-collections-inited";

function syncPanels(root, index) {
  const panels = root.querySelectorAll("[data-tc-collections-panel]");
  panels.forEach((panel, i) => {
    const idx = panel.getAttribute("data-tc-collections-panel");
    const num = idx !== null ? parseInt(idx, 10) : i;
    if (num === index) {
      panel.removeAttribute("hidden");
    } else {
      panel.setAttribute("hidden", "");
    }
  });
}

function initTcCollections() {
  const roots = document.querySelectorAll("[data-tc-collections]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-tc-collections-splide]");
    if (!splideEl || splideEl.querySelectorAll(".splide__slide").length === 0) {
      return;
    }

    const splide = new Splide(splideEl, {
      type: "slide",
      perPage: 1,
      perMove: 1,
      gap: 0,
      arrows: true,
      pagination: true,
      breakpoints: {
        992: { arrows: true, pagination: true },
        576: { arrows: true, pagination: true },
      },
    });

    splide.on("moved", (index) => {
      syncPanels(root, index);
    });

    splide.on("mounted", () => {
      syncPanels(root, splide.index);
    });

    splide.mount();
  });
}

export default initTcCollections;
