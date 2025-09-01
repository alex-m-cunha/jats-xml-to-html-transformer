<script>
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
    closeBtn.innerHTML = '&times;';

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
</script>