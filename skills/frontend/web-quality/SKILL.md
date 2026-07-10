---
name: web-quality
description: >
  Audit and fix interaction quality — a11y, focus, forms, touch targets,
  semantics, motion preferences. Use only when the task is an a11y/guidelines
  pass or form/dialog interaction fix. Prefer quality-check when the goal is
  ship/verify/regression; prefer product-design when multi-step product UX craft
  is unclear; frontend-design for full FE builds. Not for visual brand redesign,
  React performance alone (react-performance), or Playwright/e2e proof loops
  (browser-verify).
---

# Web quality (a11y + interaction)

**Job:** Make UI **correct and usable**, not just pretty.

## Sources (attribution)

- **Vercel Web Interface Guidelines** lineage and the public
  `web-design-guidelines` agent skill pattern (rule-oriented UI review:
  a11y, forms, focus, motion, typography practicality).
- **WCAG 2.2** practical AA checks (contrast, name/role/value, keyboard,
  target size where applicable).
- **AccessLint-style** concerns: contrast pairs, color-not-only status,
  descriptive link purpose — synthesized as checklists for agents.

Original checklist packaging for this repo; not a verbatim copy of any
upstream skill file.

## When to load

- Pre-merge UI review  
- axe / `test:a11y` failures  
- Sheets, dialogs, sticky bars, custom controls  
- Status colors, trend arrows, form errors  

## Audit workflow

1. List surfaces in the change (routes/components).  
2. Walk the checklist below; fix blockers first.  
3. Re-run project a11y tests if present (`test:a11y`, axe Playwright).  
4. Note residual risks (e.g. chart canvas labels).  

## Checklist

### Semantics & structure

- [ ] Real headings in order (`h1` → `h2`…); no skip for style  
- [ ] Buttons are `<button>`; links are `<a href>`  
- [ ] Lists/tables use semantic elements when presenting tabular data  
- [ ] Landmarks: main, nav, dialog labeling  

### Keyboard & focus

- [ ] All interactive elements reachable by keyboard  
- [ ] Visible focus rings (tokenized); never `outline-none` without replacement  
- [ ] Focus trap in modal/sheet; restore focus on close  
- [ ] Esc closes overlay; Enter submits forms appropriately  
- [ ] Custom widgets implement expected ARIA patterns  

### Forms

- [ ] Every input has a visible label (or properly associated aria-label)  
- [ ] Errors identified in text, not color only  
- [ ] `autocomplete` where relevant; correct `type`  
- [ ] Disabled submit explained; no silent no-ops  

### Touch & targets

- [ ] Primary controls ≥ ~44×44 px hit area (padding OK)  
- [ ] Spacing between adjacent actions reduces mis-taps  
- [ ] Sticky footers don’t cover content or system gestures  

### Color & contrast

- [ ] Text meets contrast on actual surfaces (glossy glass often fails)  
- [ ] Status not by color alone (icon + text)  
- [ ] Charts: series distinguishable without hue-only (pattern/label)  

### Motion & media

- [ ] `prefers-reduced-motion` respected  
- [ ] No infinite decorative animation on product chrome  
- [ ] Images: meaningful `alt` or empty alt if decorative  

### Feedback

- [ ] Loading regions: `role="status"` / `aria-busy` on containers  
- [ ] Toasts don’t replace critical error UI  
- [ ] Destructive actions confirm when irreversible  

## Output format (reviews)

Prefer terse findings:

```
path/to/File.tsx:42 — focus ring removed on Chip; keyboard users lose position
path/to/Sheet.tsx:18 — missing aria-labelledby on dialog
```

## Hand off

| Need | Next skill |
|------|------------|
| Visual density/spacing | **product-ui-craft** |
| Mobile sticky/safe-area | **mobile-product-ux** |
| Automated proof | **browser-verify** |
| Perf | **react-performance** |
