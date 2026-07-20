---
name: mobile-chart-visual
description: >
  Mobile-readable charts without wrecking desktop density — viewBox/fontSize
  scale formula, soft type floors, label wrap, plot-share / data-density rules,
  padding, tick thinning, height-cap bans, and visual verification. Use when
  blog charts are hard to read on phone, labels look tiny/squinty, charts are
  sparse with wasted whitespace, axes look crushed on desktop, "mobile chart",
  "chart text too small", "fix blog charts for mobile", or /mobile-chart-visual.
  Prefer over freestyle font bumps. Prefer tufte for chart-type honesty;
  browser-verify for general e2e proof. Not for product sticky chrome
  (mobile-product-ux) or non-chart UI density (product-ui-craft).
metadata:
  short-description: "Mobile-readable charts with data density on desktop"
---

# Mobile chart visual

**Job:** Charts readable at ~390×844 **and** useful at desktop article width.
Mobile floors are a **floor**, not a reason to explode type. Prefer **data
density**: the plot should carry most of the frame; labels wrap rather than
steal the plot.

## When to load

- Blog / article inline SVG or static chart images  
- “Text too small”, squinting, **or** “too much empty space / sparse chart”  
- Axes look fine on phone but tiny/cramped relative to huge labels on desktop  
- Before publishing a data-backed post with figures  

## Core formula (always)

For `width: 100%` SVG with a viewBox:

```text
rendered_css_px ≈ paint_width × (fontSize_user_units / viewBoxWidth)
```

At design width **332px** (390 viewport, padded figure):

```text
min_fontSize(role) = ceil(TARGET[role] × viewBoxW / 332)
```

| Role | TARGET CSS px (**soft floor** @ 332) | Soft cap @ ~720 paint |
|------|-------------------------------------:|----------------------:|
| Title (in-SVG) | **13** | — |
| Category / row label | **11** | **≤ ~24** (body, not poster) |
| Value tip | **11** | **≤ ~22** |
| Axis tick | **10** | **≤ ~20** |
| Source | **10** | — |

**Squint band:** labels/ticks **≤ ~9px** at 332 → fail.  
**Pass band:** labels **≥ ~11px**, ticks **≥ ~10px** at 332.  
**Oversized band:** labels **> ~24px** at ~720 paint (or giant gutters /
plot share &lt; 0.48) → fail density. Soft caps catch deliberate overshoot;
plot-share is the primary density gate.

Uniform SVG scale **cannot** independently optimize phone and desktop. Size for
soft mobile floors + **max plot share**; do not chase “as big as possible” type.

## Data density (first-class)

Wasted whitespace is a defect equal to unreadably small type.

| Rule | Pass |
|------|------|
| **Plot share** | `plotW / viewBoxW ≥ ~0.48` (data region is majority of the frame) |
| **Wrap over pad** | Prefer **2-line category labels** (~12 chars/line) over a huge single-line left gutter |
| **Row pitch** | Compact: ~1.7× label font (1 line) or ~2.15× (2 lines)—not 2.4×+ giant empty bands |
| **Bar thickness** | Marks fill a real fraction of the row (~0.4–0.5 of `rowH`), not hairlines in tall rows |
| **Values** | Outside bars (to the right), not on fill; short tips |
| **Axis presence** | Ticks + axis title share a compact bottom band but remain legible; plot width gives axes room |
| **Chrome** | No chart subtitles that restate the axis; source under the plot, not floating over marks |

**Anti-pattern (what went wrong on market-cap v1 mobile pass):**  
Huge single-line fonts → enormous left pad → thin plot strip → axes look
“condensed/small” on desktop even though absolute text is large. Fix: **wrap +
soft floors + denser rows**.

## Spacing (user units, travel with type)

| Region | Rule |
|--------|------|
| Left gutter | Sized from **max chars per line** (after wrap), not full string length |
| Right value gutter | Fit longest tip at **value** size |
| Row height | Compact mult above; increase only for wrap or collision |
| Bottom pad | Tick band + axis title without overlap; no double-duty strip |
| Tick density | ≥ **48 CSS px** between tick labels on mobile |

## Density & structure

1. Prefer **horizontal ranking / range rows** for n ≤ 12 categories on mobile.  
2. Thin time-series x labels (key days only + one callout).  
3. Y ticks: **3–5** max on mobile.  
4. Short tip strings (`+$1.2k`, `+75% (99)`).  
5. Direct labels beat remote multi-series legends when space is tight.  
6. Tables when exact values matter more than shape.  
7. **Verify at both ~390 and ~720–880** paint widths when the article is wide.

## Hard bans

- **`max-h-*`** that crushes the plot and undercuts type floors.  
- **`overflow-hidden` on the chart frame** that clips SVG labels/tips when gutters are short (hides the bug instead of fixing layout).  
- Desktop-only tiny fonts (10–13 uu on wide viewBoxes) without checking 332px.  
- **Mobile-only giant type** that collapses plot share on desktop.  
- **Value tips after full-width bars** without a reserved right column / tip budget — the longest bar (`$140M`) will shove the tip past the viewBox.  
- Raster exports that only work after pinch/lightbox.  
- **0.55× char-width estimates with font-weight 600** — Inter semi-bold is ~0.62–0.65×; underestimates clip “Umbreon VMAX” and the trailing `M` on market-cap tips. 

## Raster / PNG path

- Prefer **mobile primary** export with the same density rules.  
- Inline asset must pass floors at ~360px; lightbox is secondary.  

## Workflow

1. List every figure.  
2. Note viewBoxW, fonts, pads, rowH, max-h, **plot share**.  
3. Apply soft floors; wrap long labels; shrink gutters.  
4. Assert `plotW/viewBoxW ≥ ~0.48` and desktop soft caps.  
5. Remove crushing height caps and redundant chart subtitles.  
6. Verify at **390 and desktop** article width.  
7. Prefer shared helpers (`minFontUserUnits`, `wrapLabelLines`, plot-share).  

## Mobile / desktop visual verification

Full detail: [`references/verification.md`](references/verification.md).

| # | Check | Pass |
|---|--------|------|
| V1 | **Label floor** | Category labels ≥ ~11px CSS at ~332 paint |
| V2 | **Tick floor** | Axis ticks ≥ ~10px at ~332 |
| V3 | **Title** | HTML `text-base+` or in-SVG ≥ ~13px |
| V4 | **No height crush** | No max-h undercutting natural aspect |
| V5 | **No clip** | Labels + value tips fully inside SVG (semi-bold-safe width; **real data strings**, not only synthetic maxChars) |
| V6 | **No collision** | Tips/labels do not systematically overlap |
| V7 | **Tick density** | Adjacent ticks not jammed |
| V8 | **Gutter breath** | Gap to plot; values outside bars **or fixed right column** |
| V9 | **Caption / source** | `Source: …` under plot; no “Data source” fluff |
| V10 | **Raster** | Inline readable without pinch |
| **V11** | **Plot share / density** | Data region ≥ ~48% of viewBox width; no giant empty label columns |
| **V12** | **Desktop soft cap** | At ~720px paint, labels not poster-sized (≤ ~24px; prefer plot-share fix over raw type) |
| **V13** | **Longest bar tip** | Full-scale bar (rank #1) still shows complete tip (`$140M` including `M`) |
| **V14** | **No frame clip** | Chart surface is **not** `overflow-hidden` (or overflow is proven unused) |

## Anti-patterns

- “Bump fontSize +10” without recomputing pads or plot share.  
- Single-line labels for “Prismatic Evolutions” / “Umbreon VMAX”-class names.  
- Proving only mobile **or** only desktop.  
- Chart subtitles that restate the axis (wasted vertical space).  
- Unit tests that only check synthetic `maxValueChars: 6` while real tips are `$140M` under **font-weight 600**.  
- Placing tips at `mL + barW + gap` without a reserved right column — rank #1 always collides.  

## Horizontal ranking bars (required pattern)

1. **Wrap** category labels (≤ ~11 chars/line) so gutters use per-line width.  
2. Size left gutter with **semi-bold-safe** advance (~0.62× em).  
3. Put values in a **fixed right column** (`textAnchor=end` at `viewBoxW − margin`), not after the bar tip.  
4. Size right pad from **real tip strings** × ~0.65× em + gap.  
5. Unit-test **TOP5-class fixtures** (`Umbreon VMAX`, `$140M`) against the shipped layout.  

## Hand off

| Need | Skill |
|------|--------|
| Chart type honesty / Tufte | **tufte** |
| Product chart tokens | **design-system** |
| Browser e2e harness | **browser-verify** |

## Done criteria

- [ ] V1–V3 at ~390; V11–V12 at desktop width  
- [ ] V4–V8, **V13–V14** clean (longest tip + no overflow-hidden clip)  
- [ ] Type from soft floors + wrap; plot share ≥ ~0.48  
- [ ] Evidence: unit tests on **real label/tip strings** and shipped layout constants
