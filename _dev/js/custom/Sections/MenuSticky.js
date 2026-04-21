/**
 * Menu sticky — dodaje klasę menu-sticky do body po przescrollowaniu #header.
 * Używane w: theme (body), do stylowania np. nagłówka przy scrollu.
 * Efekt: body.menu-sticky tylko przy scrollowaniu w dół i po minięciu wysokości #header.
 * Klasa usuwana natychmiast po rozpoczęciu scrollowania w górę.
 */

export default function initMenuSticky() {
  const body = document.body;
  if (!body) return;

  let ticking = false;
  let lastScrollY = window.scrollY;

  function getHeaderHeight() {
    const header = document.getElementById("header");
    return header ? header.offsetHeight : 0;
  }

  function updateSticky() {
    const currentScrollY = window.scrollY;
    const isScrollingUp = currentScrollY < lastScrollY;

    if (isScrollingUp) {
      body.classList.remove("menu-sticky");
    } else if (currentScrollY > getHeaderHeight()) {
      body.classList.add("menu-sticky");
    } else {
      body.classList.remove("menu-sticky");
    }

    lastScrollY = currentScrollY;
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
