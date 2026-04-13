/**
 * Banner Tabs (tc_bannertabs) — front-end tab switching.
 * Used on homepage (displayHome) when #tc-bannertabs is present. Called from _dev/js/custom/theme.js.
 * Inits tablist/tabpanel ARIA and keyboard (arrows, Home, End). No side effects; DOM-only.
 */
function initBannerTabs() {
  const container = document.getElementById("tc-bannertabs");
  if (
    !container ||
    container.getAttribute("data-tc-bannertabs-inited") === "true"
  ) {
    return;
  }
  container.setAttribute("data-tc-bannertabs-inited", "true");

  const banner = container.querySelector(".tc-bannertabs__banner");
  const tablist = container.querySelector(".tc-bannertabs__tablist");
  const tabs = container.querySelectorAll(".tc-bannertabs__tab");
  const panels = container.querySelectorAll(".tc-bannertabs__panel");

  if (!banner || !tablist || tabs.length === 0 || panels.length === 0) {
    return;
  }

  const TRANSITION_MS = 400;
  const RESIZE_DEBOUNCE_MS = 150;
  let currentIndex = 0;
  let minHeightTimeout = null;
  let resizeDebounce = null;

  function applyBannerMinHeight() {
    if (banner.offsetHeight > 0) {
      banner.style.minHeight = `${banner.offsetHeight}px`;
    }
  }

  /** Przy resize min-height blokuje wysokość — czyścimy go, czekamy na reflow, odczytujemy nową wysokość i ustawiamy min-height. */
  function refreshBannerMinHeight() {
    banner.style.minHeight = "";
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        applyBannerMinHeight();
      });
    });
  }

  function observeBannerResize() {
    let rafId = null;
    const resizeObserver = new ResizeObserver(() => {
      if (rafId !== null) return;
      rafId = requestAnimationFrame(() => {
        applyBannerMinHeight();
        rafId = null;
      });
    });
    resizeObserver.observe(banner);
  }

  function setActive(index) {
    const prevIndex = Array.prototype.findIndex.call(
      panels,
      (p) => p.getAttribute("aria-hidden") === "false",
    );
    const isDeactivating = prevIndex >= 0 && prevIndex !== index;

    if (minHeightTimeout) {
      clearTimeout(minHeightTimeout);
      minHeightTimeout = null;
    }

    // Anuluj wszystkie odroczone ustawienia hidden — przy szybkim przełączaniu obrazek nie znika
    for (let i = 0; i < panels.length; i++) {
      if (panels[i]._hideTimeout) {
        clearTimeout(panels[i]._hideTimeout);
        panels[i]._hideTimeout = null;
      }
    }

    // Przed przełączeniem: ustaw min-height na obecną wysokość banera, żeby strona nie skakała
    if (isDeactivating) {
      applyBannerMinHeight();
    }

    currentIndex = index;
    const selectedPanel = panels[index];
    const selectedTab = tabs[index];
    if (selectedPanel) {
      selectedPanel.removeAttribute("hidden");
      selectedPanel.setAttribute("aria-hidden", "false");
    }
    if (selectedTab) {
      selectedTab.setAttribute("aria-selected", "true");
      selectedTab.setAttribute("tabindex", "0");
    }

    for (let i = 0; i < tabs.length; i++) {
      if (i === index) continue;
      const tab = tabs[i];
      const panel = panels[i];
      tab.setAttribute("aria-selected", "false");
      tab.setAttribute("tabindex", "-1");
      if (panel) {
        panel.setAttribute("aria-hidden", "true");
        const deferHide = isDeactivating && i === prevIndex;
        if (deferHide) {
          const panelIndex = i;
          panel._hideTimeout = setTimeout(() => {
            if (currentIndex !== panelIndex) {
              panel.setAttribute("hidden", "");
            }
            panel._hideTimeout = null;
          }, TRANSITION_MS);
        } else {
          panel.setAttribute("hidden", "");
        }
      }
    }

    // Po zakończeniu transition: zaktualizuj min-height na wysokość nowego banera
    if (isDeactivating) {
      minHeightTimeout = setTimeout(() => {
        applyBannerMinHeight();
        minHeightTimeout = null;
      }, TRANSITION_MS);
    }
  }

  function handleTabClick(e) {
    const tab = e.target.closest(".tc-bannertabs__tab");
    if (!tab) return;
    const id = tab.getAttribute("data-tab-id");
    if (id === null) return;
    const index = parseInt(id, 10);
    if (!Number.isNaN(index) && index >= 0 && index < tabs.length) {
      setActive(index);
    }
  }

  function handleKeydown(e) {
    const tab = e.target.closest(".tc-bannertabs__tab");
    if (!tab || tab.getAttribute("role") !== "tab") return;

    const index = Array.prototype.indexOf.call(tabs, tab);
    if (index < 0) return;

    let nextIndex = index;
    switch (e.key) {
      case "ArrowLeft":
      case "ArrowUp":
        e.preventDefault();
        nextIndex = index - 1;
        if (nextIndex < 0) nextIndex = tabs.length - 1;
        break;
      case "ArrowRight":
      case "ArrowDown":
        e.preventDefault();
        nextIndex = index + 1;
        if (nextIndex >= tabs.length) nextIndex = 0;
        break;
      case "Home":
        e.preventDefault();
        nextIndex = 0;
        break;
      case "End":
        e.preventDefault();
        nextIndex = tabs.length - 1;
        break;
      default:
        return;
    }
    setActive(nextIndex);
    tabs[nextIndex].focus();
  }

  function handleResize() {
    if (resizeDebounce) clearTimeout(resizeDebounce);
    resizeDebounce = setTimeout(() => {
      refreshBannerMinHeight();
      resizeDebounce = null;
    }, RESIZE_DEBOUNCE_MS);
  }

  tablist.addEventListener("click", handleTabClick);
  tablist.addEventListener("keydown", handleKeydown);
  window.addEventListener("resize", handleResize);

  setActive(0);

  // Na starcie ustaw min-height na podstawie pierwszego banera (po pierwszym renderze)
  requestAnimationFrame(() => {
    requestAnimationFrame(applyBannerMinHeight);
  });

  // ResizeObserver — min-height aktualizuje się przy każdej zmianie rozmiaru banera (resize, załadowanie obrazków, zmiana treści)
  observeBannerResize();
}

export default initBannerTabs;
