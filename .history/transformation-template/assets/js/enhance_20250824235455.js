// assets/js/enhance.js
(function () {
  const d = document;

  // --- Utilities ------------------------------------------------------------
  const focusables = [
    'a[href]','button:not([disabled])','input:not([disabled])',
    'select:not([disabled])','textarea:not([disabled])',
    '[tabindex]:not([tabindex="-1"])'
  ].join(',');

  function qs(sel, root = d) { return root.querySelector(sel); }
  function qsa(sel, root = d) { return Array.prototype.slice.call(root.querySelectorAll(sel)); }

  function openPopover(trigger, pop) {
    if (!pop) return;
    // track opener for focus restore
    pop.__opener = trigger;

    pop.hidden = false;
    trigger.setAttribute('aria-expanded', 'true');

    // Try to focus a close button or first focusable
    const first = qs('.popover-close', pop) || qs(focusables, pop);
    if (first) first.focus();

    // Add listeners for escape and outside click
    pop.__escHandler = (e) => { if (e.key === 'Escape') closePopover(pop); };
    pop.__outsideHandler = (e) => {
      // if click outside popover and not the trigger, close
      if (!pop.contains(e.target) && e.target !== trigger) closePopover(pop);
    };
    d.addEventListener('keydown', pop.__escHandler);
    d.addEventListener('click', pop.__outsideHandler);

    // optional: basic focus trap
    pop.__trap = (e) => {
      if (e.key !== 'Tab') return;
      const f = qsa(focusables, pop);
      if (!f.length) return;
      const firstEl = f[0], lastEl = f[f.length - 1];
      if (e.shiftKey && d.activeElement === firstEl) { lastEl.focus(); e.preventDefault(); }
      else if (!e.shiftKey && d.activeElement === lastEl) { firstEl.focus(); e.preventDefault(); }
    };
    pop.addEventListener('keydown', pop.__trap);
  }

  function closePopover(pop) {
    if (!pop || pop.hidden) return;
    pop.hidden = true;
    pop.removeEventListener('keydown', pop.__trap);
    d.removeEventListener('keydown', pop.__escHandler);
    d.removeEventListener('click', pop.__outsideHandler);

    // push focus back to opener and flip aria-expanded if we can find the trigger
    const opener = pop.__opener;
    if (opener) {
      opener.setAttribute('aria-expanded', 'false');
      if (typeof opener.focus === 'function') opener.focus();
      pop.__opener = null;
    }
  }

  // Close buttons inside popovers
  d.addEventListener('click', (e) => {
    const btn = e.target.closest('.popover-close');
    if (!btn) return;
    const pop = btn.closest('.popover');
    closePopover(pop);
  });

  // --- Author chips ---------------------------------------------------------
  // Your markup: <button class="chip" aria-controls="author-pop-...">
  d.addEventListener('click', (e) => {
    const btn = e.target.closest('.chip[aria-controls]');
    if (!btn) return;
    const id = btn.getAttribute('aria-controls');
    const pop = qs('#' + CSS.escape(id));
    if (!pop) return;

    // toggle behavior
    if (pop.hidden) openPopover(btn, pop);
    else closePopover(pop);
  });

  // --- Reference popovers ---------------------------------------------------
  // Your triggers should have: data-ref-popup="RID"
  d.addEventListener('click', (e) => {
    const trigger = e.target.closest('[data-ref-popup]');
    if (!trigger) return;
    e.preventDefault();

    const rid = trigger.getAttribute('data-ref-popup');     // e.g., b12
    const pop = qs('#ref-pop-' + CSS.escape(rid));          // matches back.xsl id scheme
    if (!pop) return;

    if (pop.hidden) openPopover(trigger, pop);
    else closePopover(pop);
  });

  // --- Footnote popovers ----------------------------------------------------
  // Your triggers should have: data-fn-popup="RID"
  d.addEventListener('click', (e) => {
    const trigger = e.target.closest('[data-fn-popup]');
    if (!trigger) return;
    e.preventDefault();

    const rid = trigger.getAttribute('data-fn-popup');      // e.g., fn1
    const pop = qs('#fn-pop-' + CSS.escape(rid));           // matches back.xsl id scheme
    if (!pop) return;

    if (pop.hidden) openPopover(trigger, pop);
    else closePopover(pop);
  });

  // --- Optional: copy-to-clipboard (e.g., How to Cite) ----------------------
  d.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-copy]');
    if (!btn) return;
    const targetSel = btn.getAttribute('data-copy');
    const el = qs(targetSel);
    if (!el) return;

    const text = el.innerText.trim();
    try {
      await navigator.clipboard.writeText(text);
      btn.setAttribute('aria-live', 'polite');
      const original = btn.textContent;
      btn.textContent = 'Copied!';
      setTimeout(() => { btn.textContent = original; }, 1200);
    } catch (_) {
      // fail silently
    }
  });

})();