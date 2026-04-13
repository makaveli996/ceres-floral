/**
 * TcTestimonialsSlider — Splide init for testimonials/opinie section on homepage.
 * Used when [data-tc-testimonials] is present. Inits [data-tc-testimonials-splide].
 * autoWidth: true — liczba widocznych slajdów zależy od szerokości .splide__slide (CSS), bez ułamkowego perPage.
 * Called from _dev/js/custom/theme.js. No double init.
 */
import Splide from "@splidejs/splide";

const DATA_INITED = "data-tc-testimonials-inited";

function initTcTestimonialsSlider() {
  const roots = document.querySelectorAll("[data-tc-testimonials]");
  roots.forEach((root) => {
    if (root.getAttribute(DATA_INITED) === "true") {
      return;
    }
    root.setAttribute(DATA_INITED, "true");

    const splideEl = root.querySelector("[data-tc-testimonials-splide]");
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
    initMoreButtons(root);
  });
}

function initMoreButtons(root) {
  root.querySelectorAll("[data-tc-testimonials-more]").forEach((btn) => {
    const textEl = btn.closest(".tc-testimonials__card")?.querySelector(".tc-testimonials__text");
    if (!textEl) return;
    const shortContent = textEl.getAttribute("data-shortcontent");
    const fullContent = textEl.getAttribute("data-fullcontent");
    const moreLabel = btn.getAttribute("data-more") || "Więcej";
    const lessLabel = btn.getAttribute("data-less") || "Mniej";
    if (!shortContent || !fullContent) return;

    btn.addEventListener("click", () => {
      const isExpanded = textEl.getAttribute("data-expanded") === "true";
      if (isExpanded) {
        textEl.innerHTML = shortContent;
        textEl.removeAttribute("data-expanded");
        btn.textContent = moreLabel;
      } else {
        textEl.innerHTML = fullContent.replace(/\n/g, "<br>");
        textEl.setAttribute("data-expanded", "true");
        btn.textContent = lessLabel;
      }
    });
  });
}

export default initTcTestimonialsSlider;
