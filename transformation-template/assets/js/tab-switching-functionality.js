// tabs.js — minimal controller for your existing markup
(function () {
  const tabs = Array.from(document.querySelectorAll('.content-tabs .tab'));
  if (!tabs.length) return;

  function activateTab(btn) {
    const targetId = btn.getAttribute('aria-controls');
    const targetPanel = document.getElementById(targetId);
    if (!targetPanel) return;

    // Deactivate all tabs/panels
    tabs.forEach(t => {
      t.classList.remove('is-active');
      t.setAttribute('aria-selected', 'false');
      t.setAttribute('tabindex', '-1');
      const pid = t.getAttribute('aria-controls');
      const panel = pid && document.getElementById(pid);
      if (panel) {
        panel.classList.remove('is-active');
        panel.setAttribute('hidden', '');
      }
      // TOCs share the same suffix as panels: #toc-full-article / #toc-figures-tables
      const toc = pid && document.querySelector(`#toc-${pid.replace('panel-','')}`);
      if (toc) toc.setAttribute('hidden', '');
    });

    // Activate clicked tab/panel
    btn.classList.add('is-active');
    btn.setAttribute('aria-selected', 'true');
    btn.setAttribute('tabindex', '0');
    targetPanel.classList.add('is-active');
    targetPanel.removeAttribute('hidden');

    // Matching TOC (expects ids: toc-full-article / toc-figures-tables)
    const tocId = `toc-${targetId.replace('panel-','')}`;
    const tocEl = document.getElementById(tocId) || document.querySelector(`#${tocId}`);
    if (tocEl) tocEl.removeAttribute('hidden');
  }

  // Click + keyboard
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.content-tabs .tab');
    if (btn) {
      activateTab(btn);
      // keep focus on the active tab for a11y
      btn.focus();
    }
  });

  document.addEventListener('keydown', (e) => {
    const current = document.activeElement.closest('.content-tabs .tab');
    if (!current) return;
    const idx = tabs.indexOf(current);
    if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
      e.preventDefault();
      const next = e.key === 'ArrowRight'
        ? tabs[(idx + 1) % tabs.length]
        : tabs[(idx - 1 + tabs.length) % tabs.length];
      next.focus();
    } else if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      activateTab(current);
    }
  });

  // Ensure initial state is consistent with markup
  const initiallyActive = document.querySelector('.content-tabs .tab.is-active') || tabs[0];
  activateTab(initiallyActive);
})();