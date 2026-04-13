/**
 * Menu sticky — dodaje klasę menu-sticky do body po rozpoczęciu scrollowania.
 * Używane w: theme (body), do stylowania np. nagłówka przy scrollu.
 * Efekt: body.menu-sticky gdy scrollY > próg; klasa usuwana przy powrocie na górę.
 */

const SCROLL_THRESHOLD = 1;

export default function initMenuSticky() {
  const body = document.body;
  if (!body) return;

  let ticking = false;

  function updateSticky() {
    if (window.scrollY > SCROLL_THRESHOLD) {
      body.classList.add("menu-sticky");
    } else {
      body.classList.remove("menu-sticky");
    }
    ticking = false;
  }

  function onScroll() {
    if (!ticking) {
      requestAnimationFrame(updateSticky);
      ticking = true;
    }
  }

  window.addEventListener("scroll", onScroll, { passive: true });
  updateSticky();
}
