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