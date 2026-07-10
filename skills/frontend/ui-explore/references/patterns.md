# HTML Design — Patterns

## A/B switcher (canonical)

```html
<html lang="en" data-design="a">
...
<button type="button" id="btn-a" aria-pressed="true">A · Before</button>
<button type="button" id="btn-b" aria-pressed="false">B · After</button>
<script>
function setDesign(d) {
  const design = d === 'b' ? 'b' : 'a';
  document.documentElement.dataset.design = design;
  document.getElementById('btn-a').setAttribute('aria-pressed', design === 'a' ? 'true' : 'false');
  document.getElementById('btn-b').setAttribute('aria-pressed', design === 'b' ? 'true' : 'false');
  const url = new URL(location.href);
  url.searchParams.set('design', design);
  history.replaceState(null, '', url.pathname + url.search + url.hash);
}
document.getElementById('btn-a').onclick = () => setDesign('a');
document.getElementById('btn-b').onclick = () => setDesign('b');
window.addEventListener('keydown', (e) => {
  if (/input|textarea|select/i.test(e.target.tagName)) return;
  if (e.key === 'a' || e.key === 'A' || e.key === '1') setDesign('a');
  if (e.key === 'b' || e.key === 'B' || e.key === '2') setDesign('b');
});
const q = new URLSearchParams(location.search).get('design');
setDesign(q === 'b' ? 'b' : 'a');
</script>
```

Hide B-only nodes with CSS:

```css
html[data-design="a"] .only-b { display: none !important; }
html[data-design="b"] .only-a { display: none !important; }
/* optional: ring the delta in B */
html[data-design="b"] .delta {
  outline: 1px solid rgba(52, 211, 153, 0.55);
  box-shadow: 0 0 0 1px rgba(52, 211, 153, 0.15);
}
```

## Floating picker bar

```css
.picker {
  position: fixed; z-index: 100; left: 50%; bottom: max(1rem, env(safe-area-inset-bottom));
  transform: translateX(-50%);
  display: flex; align-items: center; gap: 0.35rem;
  padding: 0.4rem 0.45rem; border-radius: 999px;
  border: 1px solid rgba(168, 85, 247, 0.4);
  background: rgba(10, 8, 18, 0.94);
  box-shadow: 0 12px 40px rgba(0,0,0,0.55);
  backdrop-filter: blur(16px);
}
```

## Multi-variant (C, D, …)

Same as A/B with `data-design="a|b|c"` and buttons for each. Cap at **5**.
Label with the tradeoff, not "Option 3":

- `A · Current`
- `B · + Add to trade`
- `C · Overflow menu`

## Faithful production mock

1. Open the real page (or read the component).
2. Copy: breadcrumb, title pattern, action row order, stat cards, spacing.
3. Use production asset URLs when public (e.g. card images).
4. Placeholder the **unchanged** lower page (dashed "rest of page" block) so
   attention stays on the delta.

## Side-by-side (optional)

When the user insists on simultaneous view:

```html
<div class="split">
  <iframe src="?design=a&embed=1" title="A"></iframe>
  <iframe src="?design=b&embed=1" title="B"></iframe>
</div>
```

Hide the picker when `embed=1` so iframes stay clean. Prefer single-tab switch
for density and mobile.

## Live data in mocks (optional)

If the decision needs real numbers, proxy via a tiny local server (see repo
`design/server.py` proto-api pattern) — never hardcode fake TVWAPs when the
question is about market truth. Pure layout questions: static fixture is fine.

## Serving checklist

- [ ] Port free or reuse existing design server
- [ ] URL works from host browser (not only agent sandbox)
- [ ] `?design=` round-trips on refresh
