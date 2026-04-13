/**
 * Process Tabs (tc_processtabs) — front-end tab switching.
 * Used on O nas (displayAboutUs) when [data-tc-processtabs] is present. Called from _dev/js/custom/theme.js.
 * Supports multiple instances; manages active tab/panel classes and ARIA. Keyboard: arrows, Home, End.
 */
function initTcProcessTabs() {
  const containers = document.querySelectorAll("[data-tc-processtabs]");
  containers.forEach((container) => {
    if (container.getAttribute("data-tc-processtabs-inited") === "true") {
      return;
    }
    container.setAttribute("data-tc-processtabs-inited", "true");

    const nav = container.querySelector(".tc-processtabs__nav");
    const tabButtons = container.querySelectorAll(".tc-processtabs__tab");
    const panels = container.querySelectorAll(".tc-processtabs__panel");

    if (!nav || tabButtons.length === 0 || panels.length === 0) {
      return;
    }

    let currentIndex = 0;

    function setActive(index) {
      if (index < 0 || index >= tabButtons.length) return;
      currentIndex = index;

      tabButtons.forEach((tab, i) => {
        const isSelected = i === index;
        tab.classList.toggle("is-active", isSelected);
        tab.setAttribute("aria-selected", isSelected ? "true" : "false");
        tab.setAttribute("tabindex", isSelected ? "0" : "-1");
      });

      panels.forEach((panel, i) => {
        const isSelected = i === index;
        panel.classList.toggle("is-active", isSelected);
        panel.setAttribute("aria-hidden", isSelected ? "false" : "true");
        if (isSelected) {
          panel.removeAttribute("hidden");
        } else {
          panel.setAttribute("hidden", "");
        }
      });
    }

    function handleTabClick(e) {
      const tab = e.target.closest(".tc-processtabs__tab");
      if (!tab) return;
      const id = tab.getAttribute("data-tab-trigger");
      if (id === null) return;
      const index = parseInt(id, 10);
      if (!Number.isNaN(index) && index >= 0 && index < tabButtons.length) {
        setActive(index);
      }
    }

    function handleKeydown(e) {
      const tab = e.target.closest(".tc-processtabs__tab");
      if (!tab || tab.getAttribute("role") !== "tab") return;

      const index = Array.prototype.indexOf.call(tabButtons, tab);
      if (index < 0) return;

      let nextIndex = index;
      switch (e.key) {
        case "ArrowLeft":
        case "ArrowUp":
          e.preventDefault();
          nextIndex = index - 1;
          if (nextIndex < 0) nextIndex = tabButtons.length - 1;
          break;
        case "ArrowRight":
        case "ArrowDown":
          e.preventDefault();
          nextIndex = index + 1;
          if (nextIndex >= tabButtons.length) nextIndex = 0;
          break;
        case "Home":
          e.preventDefault();
          nextIndex = 0;
          break;
        case "End":
          e.preventDefault();
          nextIndex = tabButtons.length - 1;
          break;
        default:
          return;
      }
      setActive(nextIndex);
      tabButtons[nextIndex].focus();
    }

    nav.addEventListener("click", handleTabClick);
    nav.addEventListener("keydown", handleKeydown);

    setActive(0);
  });
}

export default initTcProcessTabs;
