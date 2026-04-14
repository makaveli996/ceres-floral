/**
 * Mobile header drawer toggle for ceres-floral.
 * Called from: _dev/js/custom/theme.js via initMobileHeader().
 * Inputs: button.js-mobile-menu-open, #mobile_top_menu_wrapper (.mobile-drawer).
 * Side effects: toggles body.mobile-menu-open (disables scroll), aria-expanded, aria-hidden.
 */

export default function initMobileHeader() {
  const btn = document.querySelector(".js-mobile-menu-open");
  const drawer = document.getElementById("mobile_top_menu_wrapper");
  const hamburger = btn; // same element, aliases for clarity

  if (!btn || !drawer) return;

  function openMenu() {
    drawer.style.display = "";
    drawer.setAttribute("aria-hidden", "false");
    btn.setAttribute("aria-expanded", "true");
    hamburger.classList.add("is-open");
    document.body.classList.add("mobile-menu-open");
  }

  function closeMenu() {
    drawer.style.display = "none";
    drawer.setAttribute("aria-hidden", "true");
    btn.setAttribute("aria-expanded", "false");
    hamburger.classList.remove("is-open");
    document.body.classList.remove("mobile-menu-open");
  }

  btn.addEventListener("click", () => {
    const isOpen = btn.getAttribute("aria-expanded") === "true";
    if (isOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeMenu();
  });

  /* Close drawer if window resizes to desktop */
  const mq = window.matchMedia("(min-width: 992px)");
  mq.addEventListener("change", (e) => {
    if (e.matches) closeMenu();
  });
}
