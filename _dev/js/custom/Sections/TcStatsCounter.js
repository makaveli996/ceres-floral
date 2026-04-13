/**
 * TcStatsCounter (tc_statscounter) — animate numbers from 0 to target when section enters viewport.
 * Used on homepage when [data-tc-statscounter] is present. Reads data-counter-target (integer),
 * optional data-counter-suffix; suffix is rendered static in template. Called from _dev/js/custom/theme.js.
 * Runs once per page load per section. No side effects; DOM-only.
 */
const DATA_INITED = "data-tc-statscounter-inited";
const DURATION_MS = 1500;
const TICK_MS = 20;

function animateCounter(el, target, onComplete) {
  let start = null;
  const startVal = 0;

  function step(timestamp) {
    if (start === null) start = timestamp;
    const elapsed = timestamp - start;
    const progress = Math.min(elapsed / DURATION_MS, 1);
    const easeOutQuart = 1 - (1 - progress) ** 4;
    const current = Math.round(startVal + (target - startVal) * easeOutQuart);
    el.textContent = String(current);
    if (progress < 1) {
      requestAnimationFrame(step);
    } else {
      el.textContent = String(target);
      if (typeof onComplete === "function") onComplete();
    }
  }

  requestAnimationFrame(step);
}

function initSection(section) {
  const numbers = section.querySelectorAll(".tc-statscounter__number");
  if (numbers.length === 0) return;

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.target !== section || !entry.isIntersecting) continue;
        observer.disconnect();
        numbers.forEach((el) => {
          const targetRaw = el.getAttribute("data-counter-target");
          const target = targetRaw !== null ? parseInt(targetRaw, 10) : 0;
          if (!Number.isNaN(target) && target >= 0) {
            animateCounter(el, target);
          }
        });
        break;
      }
    },
    { rootMargin: "0px", threshold: 0.1 }
  );

  observer.observe(section);
}

function initTcStatsCounter() {
  const sections = document.querySelectorAll("[data-tc-statscounter]");
  sections.forEach((section) => {
    if (section.getAttribute(DATA_INITED) === "true") {
      return;
    }
    section.setAttribute(DATA_INITED, "true");
    initSection(section);
  });
}

export default initTcStatsCounter;
