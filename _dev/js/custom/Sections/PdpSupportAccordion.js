/**
 * PDP accordions — smooth expand/collapse (same pattern as TcFaq.js).
 * Roots: tc_pdpsupport [data-tc-pdp-support], tc_pdpdelivery [data-tc-pdp-delivery].
 * Called from theme.js on DOM ready.
 */
function setPanelState(panel, open) {
  if (!panel) return;
  if (open) {
    panel.style.maxHeight = `${panel.scrollHeight}px`;
    panel.style.opacity = "1";
  } else {
    panel.style.maxHeight = "0px";
    panel.style.opacity = "0";
  }
}

const ACCORDION_CONFIGS = [
  {
    rootSel: "[data-tc-pdp-support]",
    itemSel: ".tc-pdp-support__item",
    triggerSel: "[data-tc-pdp-support-trigger]",
    panelSel: "[data-tc-pdp-support-panel]",
    initedAttr: "data-tc-pdp-support-inited",
  },
  {
    rootSel: "[data-tc-pdp-delivery]",
    itemSel: ".tc-pdp-delivery__item",
    triggerSel: "[data-tc-pdp-delivery-trigger]",
    panelSel: "[data-tc-pdp-delivery-panel]",
    initedAttr: "data-tc-pdp-delivery-inited",
  },
];

function initAccordionRoot(root, cfg) {
  if (root.getAttribute(cfg.initedAttr) === "true") {
    return;
  }
  root.setAttribute(cfg.initedAttr, "true");

  const items = Array.from(root.querySelectorAll(cfg.itemSel));
  if (!items.length) {
    return;
  }

  const handleResize = () => {
    items.forEach((item) => {
      if (!item.classList.contains("is-open")) return;
      const panel = item.querySelector(cfg.panelSel);
      if (!panel) return;
      panel.style.maxHeight = `${panel.scrollHeight}px`;
    });
  };

  items.forEach((item) => {
    const button = item.querySelector(cfg.triggerSel);
    const panel = item.querySelector(cfg.panelSel);
    if (!button || !panel) return;

    if (item.classList.contains("is-open")) {
      setPanelState(panel, true);
      button.setAttribute("aria-expanded", "true");
    } else {
      setPanelState(panel, false);
      button.setAttribute("aria-expanded", "false");
    }

    button.addEventListener("click", () => {
      const isOpening = !item.classList.contains("is-open");
      items.forEach((other) => {
        const otherButton = other.querySelector(cfg.triggerSel);
        const otherPanel = other.querySelector(cfg.panelSel);
        if (!otherButton || !otherPanel) return;
        if (other === item && isOpening) {
          other.classList.add("is-open");
          otherButton.setAttribute("aria-expanded", "true");
          setPanelState(otherPanel, true);
        } else {
          other.classList.remove("is-open");
          otherButton.setAttribute("aria-expanded", "false");
          setPanelState(otherPanel, false);
        }
      });
    });
  });

  window.addEventListener("resize", handleResize);
}

export default function initPdpSupportAccordion() {
  ACCORDION_CONFIGS.forEach((cfg) => {
    document.querySelectorAll(cfg.rootSel).forEach((root) => {
      initAccordionRoot(root, cfg);
    });
  });
}
