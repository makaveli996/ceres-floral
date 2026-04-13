/**
 * Footer back-to-top button — scrolls to top on click.
 * Used by: theme footer.tpl trigger .js-footer-back-to-top.
 */

export default function initFooterBackToTop() {
  const btn = document.querySelector(".js-footer-back-to-top");
  if (!btn) return;

  btn.addEventListener("click", () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });
}
