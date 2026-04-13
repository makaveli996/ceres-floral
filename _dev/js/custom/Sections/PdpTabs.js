/**
 * PDP tabs (tc_pdptabs): custom tab switching for module markup in media column.
 * Used from _dev/js/custom/theme.js on product pages when [data-tc-pdp-tabs] exists.
 */
export default function initPdpTabs() {
  const containers = document.querySelectorAll("[data-tc-pdp-tabs]");
  if (!containers.length) {
    return;
  }

  containers.forEach((container) => {
    if (container.getAttribute("data-tc-pdp-tabs-inited") === "true") {
      return;
    }
    container.setAttribute("data-tc-pdp-tabs-inited", "true");

    const tabs = Array.from(container.querySelectorAll(".tc-pdp-tabs__link"));
    const panels = Array.from(container.querySelectorAll(".tc-pdp-tabs__panel"));
    if (!tabs.length || !panels.length) {
      return;
    }

    const activateTab = (tabEl) => {
      const targetId = (tabEl.getAttribute("href") || "").replace(/^#/, "");
      if (!targetId) {
        return;
      }

      tabs.forEach((tab) => {
        const isActive = tab === tabEl;
        tab.classList.toggle("active", isActive);
        tab.classList.toggle("js-product-nav-active", isActive);
        tab.setAttribute("aria-selected", isActive ? "true" : "false");
      });

      panels.forEach((panel) => {
        const isActive = panel.id === targetId;
        panel.classList.toggle("active", isActive);
        panel.classList.toggle("js-product-tab-active", isActive);
      });
    };

    container.addEventListener("click", (event) => {
      const tab = event.target.closest(".tc-pdp-tabs__link");
      if (!tab || !container.contains(tab)) {
        return;
      }
      event.preventDefault();
      activateTab(tab);
    });
  });
}
