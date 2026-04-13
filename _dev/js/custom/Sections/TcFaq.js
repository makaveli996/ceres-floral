/**
 * FAQ accordion (tc_faq) — front-end expand/collapse with smooth open/close.
 * Used on homepage when [data-tc-faq] is present. Called from _dev/js/custom/theme.js.
 * Uses maxHeight + opacity for animation; one item open at a time; handleResize updates open panel height.
 */
function setPanelState(panel, open) {
  if (!panel) return;
  if (open) {
    panel.style.maxHeight = `${panel.scrollHeight}px`;
    panel.style.opacity = '1';
  } else {
    panel.style.maxHeight = '0px';
    panel.style.opacity = '0';
  }
}

function initTcFaq() {
  const roots = document.querySelectorAll('[data-tc-faq]');
  roots.forEach((root) => {
    if (root.getAttribute('data-tc-faq-inited') === 'true') {
      return;
    }
    root.setAttribute('data-tc-faq-inited', 'true');

    const items = Array.from(root.querySelectorAll('.tc-faq__item'));
    if (!items.length) return;

    const handleResize = () => {
      items.forEach((item) => {
        if (!item.classList.contains('is-open')) return;
        const panel = item.querySelector('.tc-faq__panel');
        if (!panel) return;
        panel.style.maxHeight = `${panel.scrollHeight}px`;
      });
    };

    items.forEach((item) => {
      const button = item.querySelector('.tc-faq__trigger');
      const panel = item.querySelector('.tc-faq__panel');
      if (!button || !panel) return;

      if (item.classList.contains('is-open')) {
        setPanelState(panel, true);
        button.setAttribute('aria-expanded', 'true');
      } else {
        setPanelState(panel, false);
        button.setAttribute('aria-expanded', 'false');
      }

      button.addEventListener('click', () => {
        const isOpening = !item.classList.contains('is-open');
        items.forEach((other) => {
          const otherButton = other.querySelector('.tc-faq__trigger');
          const otherPanel = other.querySelector('.tc-faq__panel');
          if (!otherButton || !otherPanel) return;
          if (other === item && isOpening) {
            other.classList.add('is-open');
            otherButton.setAttribute('aria-expanded', 'true');
            setPanelState(otherPanel, true);
          } else {
            other.classList.remove('is-open');
            otherButton.setAttribute('aria-expanded', 'false');
            setPanelState(otherPanel, false);
          }
        });
      });
    });

    window.addEventListener('resize', handleResize);
  });
}

export default initTcFaq;
