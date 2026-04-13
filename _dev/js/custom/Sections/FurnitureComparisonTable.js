/**
 * PDP tabela porównania mebli (tc_furniture_comparison): obcina wysokość + „Rozwiń więcej”.
 * Root: [data-tc-furniture-comparison]. Wywoływane z theme.js po DOMContentLoaded.
 */
const COLLAPSED_MAX_PX = 400;

function setExpanded(root, expanded) {
  const toggle = root.querySelector("[data-tc-furniture-comparison-toggle]");
  const clip = root.querySelector("[data-tc-furniture-comparison-clip]");
  const expandLabel = root.querySelector(
    ".tc-furniture-comparison__toggle-text--expand",
  );
  const collapseLabel = root.querySelector(
    ".tc-furniture-comparison__toggle-text--collapse",
  );

  if (expanded) {
    root.classList.add("is-expanded");
    if (clip) {
      clip.style.maxHeight = "";
    }
    if (toggle) {
      toggle.setAttribute("aria-expanded", "true");
    }
    if (expandLabel) expandLabel.hidden = true;
    if (collapseLabel) collapseLabel.hidden = false;
  } else {
    root.classList.remove("is-expanded");
    if (clip) {
      clip.style.maxHeight = `${COLLAPSED_MAX_PX}px`;
    }
    if (toggle) {
      toggle.setAttribute("aria-expanded", "false");
    }
    if (expandLabel) expandLabel.hidden = false;
    if (collapseLabel) collapseLabel.hidden = true;
  }
}

function measureClipContentHeight(clip) {
  const inner = clip.querySelector(".tc-furniture-comparison__scroll");
  return inner ? inner.scrollHeight : clip.scrollHeight;
}

function updateStaticState(root) {
  const clip = root.querySelector("[data-tc-furniture-comparison-clip]");
  const toggle = root.querySelector("[data-tc-furniture-comparison-toggle]");
  if (!clip || !toggle) {
    return;
  }

  if (root.classList.contains("is-expanded")) {
    root.classList.remove("tc-furniture-comparison--static");
    toggle.hidden = false;
    return;
  }

  const fullH = measureClipContentHeight(clip);
  if (fullH <= COLLAPSED_MAX_PX) {
    root.classList.add("tc-furniture-comparison--static");
    clip.style.maxHeight = "";
    toggle.hidden = true;
  } else {
    root.classList.remove("tc-furniture-comparison--static");
    clip.style.maxHeight = `${COLLAPSED_MAX_PX}px`;
    toggle.hidden = false;
  }
}

function initRoot(root) {
  if (root.getAttribute("data-tc-furniture-comparison-inited") === "true") {
    return;
  }
  root.setAttribute("data-tc-furniture-comparison-inited", "true");

  const toggle = root.querySelector("[data-tc-furniture-comparison-toggle]");
  const clip = root.querySelector("[data-tc-furniture-comparison-clip]");
  if (!toggle || !clip) {
    return;
  }

  setExpanded(root, false);
  updateStaticState(root);

  toggle.addEventListener("click", () => {
    if (root.classList.contains("tc-furniture-comparison--static")) {
      return;
    }
    const open = !root.classList.contains("is-expanded");
    setExpanded(root, open);
    if (!open) {
      updateStaticState(root);
    }
  });

  window.addEventListener("resize", () => {
    updateStaticState(root);
  });
}

export default function initFurnitureComparisonTable() {
  document
    .querySelectorAll("[data-tc-furniture-comparison]")
    .forEach((root) => initRoot(root));
}
