(function () {
  let activeTrigger = null;

  function createLightbox() {
    const wrap = document.createElement('div');
    wrap.className = 'lightbox-backdrop';
    wrap.setAttribute('role', 'dialog');
    wrap.setAttribute('aria-modal', 'true');
    wrap.setAttribute('aria-label', 'Image viewer');
    wrap.tabIndex = -1;

    // container
    const box = document.createElement('div');
    box.className = 'lightbox-box';

    // close button
    const closeBtn = document.createElement('button');
    closeBtn.className = 'lightbox-close';
    closeBtn.type = 'button';
    closeBtn.setAttribute('aria-label', 'Close image viewer');
    closeBtn.innerHTML = '&times;';

    // image
    const img = document.createElement('img');
    img.className = 'lightbox-img';
    img.alt = '';

    // interactions
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
      if (e.target === wrap) close(); // click backdrop
    });
    closeBtn.addEventListener('click', close);
    document.addEventListener('keydown', onKey);

    return { wrap, img, closeBtn };
  }

  document.addEventListener('click', function (e) {
    const trigger = e.target.closest('a.open-image');
    if (!trigger) return;
    // hijack the default “new tab” behavior for lightbox
    e.preventDefault();

    const href = trigger.getAttribute('href');
    if (!href) return;

    const { wrap, img, caption, closeBtn } = createLightbox();
    activeTrigger = trigger;

    // Fill caption from nearby figure’s caption, if present
    const fig = trigger.closest('figure');
    if (fig) {
      const cap = fig.querySelector('figcaption');
      caption.innerHTML = cap ? cap.innerHTML : '';
    } else {
      caption.textContent = '';
    }

    // load image
    img.src = href;

    // show
    document.body.classList.add('no-scroll');
    // focus close for screen readers
    closeBtn.focus();
  });
})();