// Minimal popover toggles for author chips, citations, and footnotes

(function () {
  const $ = (sel, root=document) => root.querySelector(sel);

  // 1) Author chips: <button class="chip" aria-controls="author-pop-…">
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.chip[aria-controls]');
    if (!btn) return;
    const id = btn.getAttribute('aria-controls');
    const pop = $('#' + CSS.escape(id));
    if (!pop) return;

    const isHidden = pop.hasAttribute('hidden');
    if (isHidden) pop.removeAttribute('hidden'); else pop.setAttribute('hidden', '');
    btn.setAttribute('aria-expanded', String(isHidden));
  });

  // 2) Reference popovers: trigger carries data-ref-popup="RID" → #ref-pop-RID
  document.addEventListener('click', (e) => {
    const a = e.target.closest('[data-ref-popup]');
    if (!a) return;
    e.preventDefault();
    const rid = a.getAttribute('data-ref-popup');
    const pop = $('#ref-pop-' + CSS.escape(rid));
    if (!pop) return;

    const isHidden = pop.hasAttribute('hidden');
    if (isHidden) pop.removeAttribute('hidden'); else pop.setAttribute('hidden', '');
    // optional aria-expanded on the trigger if it’s a button/link
    if (a.hasAttribute('aria-expanded')) a.setAttribute('aria-expanded', String(isHidden));
  });

  // 3) Footnote popovers: trigger carries data-fn-popup="RID" → #fn-pop-RID
  document.addEventListener('click', (e) => {
    const a = e.target.closest('[data-fn-popup]');
    if (!a) return;
    e.preventDefault();
    const rid = a.getAttribute('data-fn-popup');
    const pop = $('#fn-pop-' + CSS.escape(rid));
    if (!pop) return;

    const isHidden = pop.hasAttribute('hidden');
    if (isHidden) pop.removeAttribute('hidden'); else pop.setAttribute('hidden', '');
    if (a.hasAttribute('aria-expanded')) a.setAttribute('aria-expanded', String(isHidden));
  });

  // 4) Close buttons inside any popover: <button class="popover-close">
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.popover-close');
    if (!btn) return;
    const pop = btn.closest('.popover');
    if (!pop) return;
    pop.setAttribute('hidden','');

    // If opener had aria-controls pointing here, collapse it
    const id = pop.id;
    const opener = document.querySelector('[aria-controls="' + CSS.escape(id) + '"]');
    if (opener) opener.setAttribute('aria-expanded', 'false');
  });
})();