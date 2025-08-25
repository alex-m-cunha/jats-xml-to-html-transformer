document.addEventListener('click', (e) => {
  const trig = e.target.closest('.cite-trigger');
  if (!trig) return;

  e.preventDefault();
  const popId = trig.getAttribute('aria-controls');
  if (!popId) return;

  const pop = document.getElementById(popId);
  if (!pop) return;

  // Unhide any hidden ancestors of the popover (defensive)
  let p = pop;
  while (p) { if (p.hasAttribute('hidden')) p.removeAttribute('hidden'); p = p.parentElement; }

  const willOpen = pop.hasAttribute('hidden'); // currently hidden → will open
  if (willOpen) {
    pop.removeAttribute('hidden');
    trig.setAttribute('aria-expanded', 'true');
    // focus the dialog for accessibility
    pop.focus();
  } else {
    pop.setAttribute('hidden', 'hidden');
    trig.setAttribute('aria-expanded', 'false');
  }
});

// Close buttons
document.addEventListener('click', (e) => {
  const closeBtn = e.target.closest('.popover-close');
  if (!closeBtn) return;
  const pop = closeBtn.closest('.popover');
  if (!pop) return;
  pop.setAttribute('hidden', 'hidden');
  // Optionally return focus to last trigger:
  // (Keep a global ref to the last opened trigger if you want perfect focus return.)
});

// ESC to close
document.addEventListener('keydown', (e) => {
  if (e.key !== 'Escape') return;
  document.querySelectorAll('.popover:not([hidden])').forEach(pop => {
    pop.setAttribute('hidden','hidden');
  });
});
</script>