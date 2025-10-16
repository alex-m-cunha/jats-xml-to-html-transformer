/* popovers.js */
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

  // ---------- stacking for nested popovers ----------
  // Determine a baseline z-index from CSS (fallback to 1000),
  // and increment for each newly opened popover so nested ones stack on top.
  var FIRST_POPOVER = document.querySelector('.popover');
  var BASE_Z = (function () {
    if (FIRST_POPOVER) {
      var z = parseInt(window.getComputedStyle(FIRST_POPOVER).zIndex, 10);
      if (!isNaN(z)) return z;
    }
    return 1000;
  })();
  var zCounter = BASE_Z;

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

      // If opening from within another open popover, elevate this one
      var parentOpenPop = trigger && trigger.closest('.popover:not([hidden])');
      if (parentOpenPop) {
        // Bring this popover to the front by incrementing z-index
        pop.style.zIndex = String(++zCounter);
        pop.classList.add('is-elevated');
      } else {
        // Still bring the most recently opened popover to top
        pop.style.zIndex = String(++zCounter);
        pop.classList.remove('is-elevated');
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

      // Clear any elevation when closing
      pop.style.zIndex = '';
      pop.classList.remove('is-elevated');

      const wrap = wrapperOf(pop);
      if (wrap && !wrap.querySelector('.popover:not([hidden])')) {
        wrap.setAttribute('aria-expanded', 'false');
        wrap.setAttribute('aria-hidden', 'true');
        
      }
    }
  }

  function closeAllPopovers() {
    $all('.popover:not([hidden])').forEach((pop) => {
      setOpen(null, pop, false);
      pop.style.zIndex = '';
      pop.classList.remove('is-elevated');
    });
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

/* right-sidebar.js */
/**
 * Right Sidebar JavaScript functionality
 */

document.addEventListener('DOMContentLoaded', function() {
    // Handle copy to clipboard functionality
    const copyButtons = document.querySelectorAll('[data-copy]');
    
    copyButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const targetSelector = this.getAttribute('data-copy');
            const targetElement = document.querySelector(targetSelector);
            
            if (!targetElement) {
                console.error('Copy target element not found:', targetSelector);
                return;
            }
            
            try {
                // Get the text content from the target element and normalize whitespace
                const textToCopy = targetElement.textContent
                    .trim()
                    .replace(/\s+/g, ' ')  // Replace multiple whitespace with single space
                    .replace(/\n+/g, ' ')  // Replace newlines with spaces
                    .replace(/\s*\.\s*/g, '. ')  // Normalize spacing around periods
                    .replace(/\s*,\s*/g, ', ')   // Normalize spacing around commas
                    .replace(/\s*\?\s*/g, '? ')  // Normalize spacing around question marks
                    .replace(/\s*!\s*/g, '! ')   // Normalize spacing around exclamation marks
                    .replace(/\s*;\s*/g, '; ')   // Normalize spacing around semicolons
                    .replace(/\s*:\s*/g, ': ');  // Normalize spacing around colons
                
                // Use the modern Clipboard API if available
                if (navigator.clipboard && window.isSecureContext) {
                    await navigator.clipboard.writeText(textToCopy);
                } else {
                    // Fallback for older browsers
                    const textArea = document.createElement('textarea');
                    textArea.value = textToCopy;
                    textArea.style.position = 'fixed';
                    textArea.style.left = '-999999px';
                    textArea.style.top = '-999999px';
                    document.body.appendChild(textArea);
                    textArea.focus();
                    textArea.select();
                    document.execCommand('copy');
                    textArea.remove();
                }
                
                // Visual feedback - temporarily change button text and style
                const originalText = this.querySelector('span').textContent;
                const spanElement = this.querySelector('span');
                const svgPaths = this.querySelectorAll('svg path');
                
                // Store original styles
                const originalBgColor = this.style.backgroundColor;
                const originalBorderColor = this.style.borderColor;
                const originalTextColor = this.style.color;
                const originalStrokeColor = svgPaths.length > 0 ? svgPaths[0].getAttribute('stroke') : null;
                
                // Apply success styling
                spanElement.textContent = 'Copied!';
                this.style.backgroundColor = '#f0f9f0'; // Very subtle green background
                this.style.borderColor = '#4ade80';     // Subtle green border
                this.style.color = '#4ade80';           // Green text color
                
                // Change SVG stroke to green
                svgPaths.forEach(path => {
                    path.setAttribute('stroke', '#4ade80');
                });
                
                // Reset button text and styling after 2 seconds
                setTimeout(() => {
                    spanElement.textContent = originalText;
                    this.style.backgroundColor = originalBgColor;
                    this.style.borderColor = originalBorderColor;
                    this.style.color = originalTextColor;
                    
                    // Reset SVG stroke
                    if (originalStrokeColor) {
                        svgPaths.forEach(path => {
                            path.setAttribute('stroke', originalStrokeColor);
                        });
                    }
                }, 2000);
                
            } catch (err) {
                console.error('Failed to copy text:', err);
                
                // Show error feedback
                const spanElement = this.querySelector('span');
                const originalText = spanElement.textContent;
                spanElement.textContent = 'Copy failed';
                
                setTimeout(() => {
                    spanElement.textContent = originalText;
                }, 2000);
            }
        });
    });
});

/* toc.js */
/* assets/js/toc-spy.js
   Highlights the visible section in the currently visible TOC.
   - Adds/removes .is-active on <a> in nav.toc
   - Smooth-scrolls on click with header offset
*/
(function () {
  const HEADER_OFFSET = 80; // px—tweak if you have a taller sticky header

  function getVisibleToc() {
    // TOCs use [hidden]; pick the one currently shown
    return document.querySelector('nav.toc:not([hidden])');
  }

  function buildMap(toc) {
    const map = new Map(); // id -> <a>
    toc.querySelectorAll('a[href^="#"]').forEach(a => {
      const id = decodeURIComponent(a.getAttribute('href').slice(1));
      if (id) map.set(id, a);
    });
    return map;
  }

  function setActive(link, toc) {
    if (!toc) return;
    // Clear previous active state on links and list items
    toc.querySelectorAll('a.is-active').forEach(a => a.classList.remove('is-active'));
    toc.querySelectorAll('li.is-active').forEach(li => li.classList.remove('is-active'));
    if (link) {
      link.classList.add('is-active');
      const li = link.closest('li');
      if (li) li.classList.add('is-active');
    }
  }

  // Smooth scroll on TOC click (with offset)
  document.addEventListener('click', (e) => {
    const toc = e.target.closest('nav.toc');
    const a = e.target.closest('a[href^="#"]');
    if (!toc || !a) return;

    const id = decodeURIComponent(a.getAttribute('href').slice(1));
    const target = document.getElementById(id);
    if (!target) return;

    e.preventDefault();
    
    // Immediately set active state
    setActive(a, toc);
    history.replaceState(null, '', '#' + id);
    
    // Instant jump to target
    const top = target.getBoundingClientRect().top + window.scrollY - HEADER_OFFSET;
    window.scrollTo(0, top);
  });

  let observer = null;

  // One-time default highlight for a specific TOC (per-TOC)
  function defaultHighlightOnceFor(toc) {
    if (!toc) return;
    if (toc.hasAttribute('data-toc-defaulted')) return;

    const hasActive = !!toc.querySelector('a.is-active, li.is-active');
    if (hasActive) { toc.setAttribute('data-toc-defaulted', 'true'); return; }

    const map = buildMap(toc);
    if (!map.size) { return; } // no links yet; try again later

    const hash = decodeURIComponent((location.hash || '').slice(1));
    const hashValid = hash && map.has(hash) && document.getElementById(hash);
    if (hashValid) { toc.setAttribute('data-toc-defaulted', 'true'); return; }

    for (const [id, a] of map) {
      if (document.getElementById(id)) {
        a.classList.add('is-active');
        const li = a.closest('li');
        if (li) li.classList.add('is-active');
        toc.setAttribute('data-toc-defaulted', 'true');
        return;
      }
    }
    // If we didn’t find a valid target yet, do nothing; we’ll try again on next init when content is ready
  }

  function initObserver() {
    if (observer) { observer.disconnect(); observer = null; }

    const toc = getVisibleToc();
    if (!toc) return;

    const map = buildMap(toc);
    if (!map.size) return;

    // Observe only sections we can link to
    const targets = Array.from(map.keys())
      .map(id => document.getElementById(id))
      .filter(Boolean);

    // Determine a sensible first link to use as fallback when none qualify
    const firstLink = (function(){
      for (const id of map.keys()) {
        const a = map.get(id);
        if (a && document.getElementById(id)) return a;
      }
      return null;
    })();

    if (!('IntersectionObserver' in window)) {
      // Fallback: basic onscroll
      const onScroll = () => {
        let best = null, bestDelta = Infinity;
        targets.forEach(sec => {
          const y = sec.getBoundingClientRect().top - HEADER_OFFSET;
          const delta = Math.abs(y);
          if (y <= HEADER_OFFSET && delta < bestDelta) { best = sec; bestDelta = delta; }
        });
        setActive(best ? map.get(best.id) : firstLink, toc);
      };
      window.addEventListener('scroll', onScroll, { passive: true });
      window.addEventListener('resize', onScroll);
      onScroll();
      return;
    }

    // IO: consider a section "active" when it’s within the middle band of the viewport
    observer = new IntersectionObserver((entries) => {
      // Pick the entry with greatest intersectionRatio
      let best = null;
      entries.forEach(en => {
        if (en.isIntersecting) {
          if (!best || en.intersectionRatio > best.intersectionRatio) best = en;
        }
      });
      if (best) {
        const link = map.get(best.target.id);
        setActive(link, toc);
      } else {
        // If none intersect, choose the one closest to top
        let candidate = null, bestDelta = Infinity;
        targets.forEach(sec => {
          const y = sec.getBoundingClientRect().top - HEADER_OFFSET;
          const delta = Math.abs(y);
          if (y <= HEADER_OFFSET && delta < bestDelta) { candidate = sec; bestDelta = delta; }
        });
        setActive(candidate ? map.get(candidate.id) : firstLink, toc);
      }
    }, {
      // Shrink the observable area so the “active” band is roughly middle of viewport
      root: null,
      rootMargin: `-${HEADER_OFFSET + 20}px 0px -55% 0px`,
      threshold: [0.0, 0.25, 0.5, 0.75, 1.0]
    });

    targets.forEach(sec => observer.observe(sec));

    // Ensure a default is marked active once for this TOC when it becomes visible
    defaultHighlightOnceFor(toc);
  }

  // Re-init when panels/tabs change visibility
  const mo = new MutationObserver(initObserver);
  mo.observe(document.body, { attributes: true, subtree: true, attributeFilter: ['hidden', 'class'] });

  // Kickoff
  window.addEventListener('load', () => {
    initObserver();
    requestAnimationFrame(() => defaultHighlightOnceFor(getVisibleToc()));
  });
  document.addEventListener('DOMContentLoaded', () => {
    initObserver();
    requestAnimationFrame(() => defaultHighlightOnceFor(getVisibleToc()));
  });
})();

/* lightbox.js */
(function () {
  let activeTrigger = null;

  function createLightbox() {
    const wrap = document.createElement('div');
    wrap.className = 'lightbox-backdrop';
    wrap.setAttribute('role', 'dialog');
    wrap.setAttribute('aria-modal', 'true');
    wrap.setAttribute('aria-label', 'Image viewer');
    wrap.tabIndex = -1;

    const box = document.createElement('div');
    box.className = 'lightbox-box';

    const closeBtn = document.createElement('button');
    closeBtn.className = 'lightbox-close';
    closeBtn.type = 'button';
    closeBtn.setAttribute('aria-label', 'Close image viewer');
    closeBtn.innerHTML = `<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 4L4 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M4 4L12 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`;

    const img = document.createElement('img');
    img.className = 'lightbox-img';
    img.alt = ''; // no caption/description in the lightbox itself

    box.appendChild(closeBtn);
    box.appendChild(img);
    wrap.appendChild(box);
    document.body.appendChild(wrap);

    function close() {
      wrap.remove();
      document.body.classList.remove('no-scroll');
      document.removeEventListener('keydown', onKey);
      if (activeTrigger) activeTrigger.focus();
      activeTrigger = null;
    }
    function onKey(e) {
      if (e.key === 'Escape') close();
    }

    wrap.addEventListener('click', (e) => {
      if (e.target === wrap) close(); // click backdrop closes
    });
    closeBtn.addEventListener('click', close);
    document.addEventListener('keydown', onKey);

    return { wrap, img, closeBtn };
  }

  document.addEventListener('click', function (e) {
    const trigger = e.target.closest('a.open-image');
    if (!trigger) return;
    e.preventDefault();

    const href = trigger.getAttribute('href');
    if (!href) return;

    const { img, closeBtn } = createLightbox();
    activeTrigger = trigger;

    // If you want to pass alt text, put it on the link as data-alt
    const alt = trigger.getAttribute('data-alt') || '';
    img.alt = alt;
    img.src = href;

    document.body.classList.add('no-scroll');
    closeBtn.focus();
  });
})();

/* tab-switching-functionality.js */
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

