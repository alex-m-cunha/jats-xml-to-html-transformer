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
    toc.querySelectorAll('a.is-active').forEach(a => a.classList.remove('is-active'));
    if (link) {
      link.classList.add('is-active');
      // Uncomment next line if you want focus to follow the active section
      // link.focus();
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

    if (!('IntersectionObserver' in window)) {
      // Fallback: basic onscroll
      const onScroll = () => {
        let best = null, bestDelta = Infinity;
        targets.forEach(sec => {
          const y = sec.getBoundingClientRect().top - HEADER_OFFSET;
          const delta = Math.abs(y);
          if (y <= HEADER_OFFSET && delta < bestDelta) { best = sec; bestDelta = delta; }
        });
        setActive(best ? map.get(best.id) : null, toc);
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
        setActive(candidate ? map.get(candidate.id) : null, toc);
      }
    }, {
      // Shrink the observable area so the “active” band is roughly middle of viewport
      root: null,
      rootMargin: `-${HEADER_OFFSET + 20}px 0px -55% 0px`,
      threshold: [0.0, 0.25, 0.5, 0.75, 1.0]
    });

    targets.forEach(sec => observer.observe(sec));
  }

  // Re-init when panels/tabs change visibility
  const mo = new MutationObserver(initObserver);
  mo.observe(document.body, { attributes: true, subtree: true, attributeFilter: ['hidden', 'class'] });

  // Kickoff
  window.addEventListener('load', initObserver);
  document.addEventListener('DOMContentLoaded', initObserver);
})();