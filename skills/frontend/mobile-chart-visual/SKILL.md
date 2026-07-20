---
name: mobile-chart-visual
description: >
  Mobile-first chart readability for blog posts, product charts, and exported
  figures — viewBox/fontSize → CSS-px scale formula, min rendered type floors,
  padding/row-height rules, tick density, height-cap bans, and mobile visual
  verification. Use when blog charts are hard to read on phone, labels look
  tiny/squinty, chart spacing is cramped, "mobile chart", "chart text too
  small", "fix blog charts for mobile", or /mobile-chart-visual. Prefer over
  freestyle font bumps. Prefer tufte for chart-type honesty; browser-verify for
  general e2e proof. Not for product sticky chrome (mobile-product-ux) or
  non-chart UI density (product-ui-craft).
metadata:
  short-description: "Mobile-first chart type, spacing, and visual gates"
---

# Mobile chart visual

**Job:** Make chart text and spacing readable at ~390×844 without pinch-zoom.
Design for **~320–360px chart width** first; desktop is free scale-up.

## When to load

- Blog / article inline SVG or static chart images  
- “Text too small”, “squinting at charts”, mobile chart polish  
- Before publishing a data-backed post with figures  
- Backfilling older desktop-first chart posts  

## Core formula (always)

For `width: 100%` SVG with a viewBox:

```text
rendered_css_px ≈ container_width × (fontSize_user_units / viewBoxWidth)
```

At design width **332px** (390 viewport, padded figure):

```text
min_fontSize(role) = ceil(TARGET[role] × viewBoxW / 332)
```

| Role | TARGET CSS px (min) |
|------|---------------------|
| Title (in-SVG) | **15** |
| Category / row label | **13** |
| Value tip label | **12** |
| Axis tick | **11** |
| Source line | **11** |

**Squint band:** labels/ticks rendering at **~7–9px** → fail.  
**Pass band:** labels **≥12px**, ticks **≥11px** typical rendered height.

Raising `fontSize` while also widening `viewBoxW` can cancel out. Prefer a
**higher font/viewBox ratio** or a **narrower viewBox**, not only bigger numbers.

## Spacing (user units, travel with type)

| Region | Rule |
|--------|------|
| Left category gutter (`padL` / `mL`) | Fit longest label at **label** size + ≥8px gap to plot |
| Right value gutter | Fit longest value at **value** size |
| Row height | `≥ 2.4 × labelFont` |
| Top pad | Title + axis header without colliding grid |
| Bottom pad | X labels + legend + source; no double-duty strip |
| Tick density | ≥ **48 CSS px** between tick labels → `maxTicks = floor(plotW_css / 48)` |

**Pad estimate (sans):** `padL ≈ maxLabelChars × 0.55 × labelFont + gap`.

## Density & structure

1. Prefer **horizontal ranking bars** for n ≤ 12 categories on mobile.  
2. Thin time-series x labels (key days only + one callout).  
3. Y ticks: **3–5** max on mobile.  
4. Short tip strings (`+$1.2k`, `+75% (99)`).  
5. Direct labels beat remote multi-series legends when space is tight.  
6. Tables when exact values matter more than shape.

## Hard bans

- **`max-h-*` / fixed short height** on responsive SVG that forces the plot
  shorter than natural aspect and undercuts type floors.  
- Desktop font sizes (10–13) on wide viewBoxes (640–1200) without checking the
  ratio at 332px.  
- Raster exports designed only for ~1000–1500px width shown full-bleed on phone
  without baking mobile-sized type (or a mobile primary canvas).

## Raster / PNG path

- Prefer **mobile primary** export (~720 wide, taller if many rows).  
- Inline asset must pass floors when displayed at ~360px (lightbox is secondary).  
- Dark/light theme variants both pass the same size contract.

## Workflow

1. List every figure (SVG or image) in the article/component.  
2. For each SVG: note `viewBoxW`, current fonts, pads, rowH, any `max-h`.  
3. Compute `min_fontSize` per role; raise type **and** pads/rowH together.  
4. Remove crushing height caps.  
5. Thin ticks / shorten labels if collisions appear.  
6. **Verify** with the mobile visual checklist below (browser or harness).  
7. Prefer a shared helper (`minFontUserUnits`, pad/row estimators) over magic
   numbers so unit tests can lock the contract.

## Mobile visual verification (what to check)

Full detail: [`references/verification.md`](references/verification.md).

At **~390×844** (chart content ~320–360px wide):

| # | Check | Pass |
|---|--------|------|
| V1 | **Label floor** | Category/row labels rendered height **≥ ~12px** |
| V2 | **Tick floor** | Axis ticks **≥ ~11px** |
| V3 | **Title floor** | In-chart title **≥ ~14–15px** (or title is HTML outside SVG at readable `text-base+`) |
| V4 | **No height crush** | No `max-h` (or equivalent) that makes the SVG box systematically shorter than natural aspect in a way that undercuts V1–V3 |
| V5 | **No clip** | Longest category label fully inside SVG bbox |
| V6 | **No collision** | Value tips / category labels do not systematically overlap marks or each other |
| V7 | **Tick density** | Adjacent tick labels not jammed (&lt; ~48px gap) |
| V8 | **Gutter breath** | Visible gap between category text and plot; values not flush against frame edge |
| V9 | **Caption / source** | Figcaption readable; source line ≥ ~11px if in-SVG |
| V10 | **Raster scale** (if PNG) | Inline image not relying on pinch/lightbox for basic axis reading |

**Measure:** `element.getBoundingClientRect().height` on SVG `<text>` (or equivalent Playwright bbox). Capture JSON + optional screenshots under the task scratch dir.

## Anti-patterns

- “Bump fontSize +10” without recomputing pads (clips “Mega…”-class names).  
- Wide viewBox + big fonts that still ratio to ~10px.  
- Lightbox as the only mobile fix.  
- Per-post magic numbers with no formula comment.  
- Proving only desktop screenshots.

## Hand off

| Need | Skill |
|------|--------|
| Chart type honesty / Tufte | **tufte** |
| Product chart tokens | **design-system** |
| Browser e2e harness | **browser-verify** |
| Sticky product chrome | **mobile-product-ux** |

## Done criteria

- [ ] Every major figure hits V1–V3 at ~390 width  
- [ ] V4–V8 clean (no crush/clip/collision/jam)  
- [ ] Type and spacing derived from the ratio formula (or shared helper)  
- [ ] Evidence: metrics JSON and/or unit test on real layout constants  
