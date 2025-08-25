/* assets/js/popovers.js
   Minimal popover controller for:
   - Triggers:  .popover-trigger  (must have aria-controls="<popoverId>")
   - Popovers:  .popover          (inside a wrapper .popovers)
   - Optional close button inside popover: .popover-close
*/

(function () {
  // ---------- helpers ----------
  function $(sel, root = document) { return root.querySelector(sel); }
  function $all(sel, root = document) { return Array.prototype.slice.call(root.querySelectorAll(sel)); }
  function wrapperOf(pop) { return pop.closest('.popovers'); }
  function byId(id) { return document.getElementById(id); }

  function setOpen(trigger, pop, open) {
    if (!pop) return;
    if (open) {
      pop.removeAttribute('hidden');
      pop.setAttribute('aria-hidden', 'false');
      if (trigger) trigger.setAttribute('aria-expanded', 'true');

      const wrap = wrapperOf(pop);
      if (wrap) {
        wrap.removeAttribute('hidden');
        wrap.setAttribute('aria-expanded', 'true');
        wrap.setAttribute('aria-hidden', 'false');
      }

      // Send focus to heading or close button (if present) so SRs announce dialog
      const headingId = pop.getAttribute('aria-labelledby');
      const heading = headingId && byId(headingId);
      const closer = $('.popover-close', pop);
      (heading || closer || pop).focus?.();
    } else {
      pop.setAttribute('hidden', 'hidden');
      pop.setAttribute('aria-hidden', 'true');
      if (trigger) trigger.setAttribute('aria-expanded', 'false');

      const wrap = wrapperOf(pop);
      if (wrap && !wrap.querySelector('.popover:not([hidden])')) {
        wrap.setAttribute('aria-expanded', 'false');
        wrap.setAttribute('aria-hidden', 'true');
      }
    }
  }

  function closeAllPopovers() {
    $all('.popover:not([hidden])').forEach((pop) => setOpen(null, pop, false));
    $all('.popover-trigger[aria-expanded="true"]').forEach((t) => t.setAttribute('aria-expanded', 'false'));
  }

  // ---------- open/close on click ----------
  document.addEventListener('click', (ev) => {
    // Close buttons
    const closer = ev.target.closest('.popover-close');
    if (closer) {
      const pop = closer.closest('.popover');
      setOpen(null, pop, false);
      // Return focus to the trigger if we can find it
      if (pop && pop.id) {
        const trig = document.querySelector('.popover-trigger[aria-controls="' + CSS.escape(pop.id) + '"]');
        trig?.focus?.();
      }
      return;
    }

    // Triggers
    const trigger = ev.target.closest('.popover-trigger');
    if (trigger) {
      const id = trigger.getAttribute('aria-controls');
      if (!id) return;

      const pop = byId(id);
      if (!pop) return;

      const isOpen = !pop.hasAttribute('hidden');

      // Close others in the same wrapper (so only one at a time per group)
      const wrap = wrapperOf(pop);
      if (wrap) {
        $all('.popover:not([hidden])', wrap).forEach((p) => {
          if (p !== pop) setOpen(null, p, false);
        });
        $all('.popover-trigger[aria-expanded="true"]', wrap).forEach((t) => {
          if (t !== trigger) t.setAttribute('aria-expanded', 'false');
        });
      }

      setOpen(trigger, pop, !isOpen);
      return;
    }

    // Click outside any open popover = close all
    const insideOpen = ev.target.closest('.popover:not([hidden])');
    const isTrigger = ev.target.closest('.popover-trigger');
    if (!insideOpen && !isTrigger) {
      closeAllPopovers();
    }
  });

  // ---------- keyboard support ----------
  document.addEventListener('keydown', (ev) => {
    if (ev.key === 'Escape') {
      // Close the topmost open popover (or all; this closes all)
      closeAllPopovers();
    }
  });

  // Make popovers programmatically focusable if needed
  $all('.popover').forEach((pop) => {
    if (!pop.hasAttribute('tabindex')) pop.setAttribute('tabindex', '-1');
    if (!pop.hasAttribute('aria-hidden')) pop.setAttribute('aria-hidden', 'true');
  });

  // Ensure triggers have proper initial state
  $all('.popover-trigger').forEach((t) => {
    if (!t.hasAttribute('aria-expanded')) t.setAttribute('aria-expanded', 'false');
    if (!t.hasAttribute('aria-haspopup')) t.setAttribute('aria-haspopup', 'dialog');
  });
})();