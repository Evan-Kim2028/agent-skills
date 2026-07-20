---
name: mobile-blog-chart-visual
description: >
  Mobile-readable **blog / article SVG (and static) charts** without wrecking
  desktop density — viewBox/fontSize scale formula, soft type floors, label wrap,
  plot-share, fixed right value column, no max-h / overflow-hidden clip, no chart
  subtitles under the title. Use when blog figures are squinty, clipped, sparse,
  "mobile chart", "fix blog charts", or /mobile-blog-chart-visual. Prefer
  mobile-app-echarts-visual for product card/portfolio ECharts. Prefer tufte for
  chart-type honesty; browser-verify for e2e proof.
metadata:
  short-description: "Blog SVG charts: mobile floors + density, dual-viewport"
---

# Mobile blog chart visual

**Job:** Blog/article charts readable at **~390×844** and useful at **~720–880**
article width. Mobile floors are a **floor**, not a reason to explode type.
Prefer **data density**: the plot carries most of the frame; labels wrap rather
than steal the plot.

**Scope:** Static / SSR SVG and carefully authored blog PNGs. **Not** product
ECharts (card price matrix, portfolio history) — use **mobile-app-echarts-visual**.

## Sources (cite when extending this skill)

| Source | What we take |
|--------|----------------|
| [Nadieh Bremer — Mobile vs desktop dataviz](https://www.visualcinnamon.com/2019/04/mobile-vs-desktop-dataviz/) | Technique ladder: scale (non-linear fonts), fit width, stack/horizontal rows, reposition, or two charts — no one-size-fits-all |
| [Responsive SVG charts — viewBox pitfalls](https://maheshsenniappan.medium.com/responsive-svg-charts-viewbox-may-not-be-the-answer-aaf9c9bc4ca2) | Uniform viewBox scale **stretches text**; floors/caps required |
| [Constant font size in responsive SVGs](https://florian.ec/blog/responsive-svg-constant-font-size/) | Industry workarounds for label size under scale |
| [Tableau — mobile dashboard design](https://www.tableau.com/blog/mobile-dashboard-design-less-more-small-screen-47854) | Simple marks, fewer chrome layers, high-level stats |
| Tufte (data-ink / density) | Plot share ≥ ~0.48; empty gutters = defect |

## Core formula (always)

```text
rendered_css_px ≈ paint_width × (fontSize_user_units / viewBoxWidth)
min_fontSize(role) = ceil(TARGET[role] × viewBoxW / 332)
```

Design width **332px** (390 viewport, padded figure).

| Role | Soft floor @ 332 | Soft cap @ ~720 |
|------|-----------------:|----------------:|
| Title (prefer **HTML** `h3 text-base+`, not in-SVG) | **13** | — |
| Category / row label | **11** | **≤ ~24** |
| Value tip | **11** | **≤ ~22** |
| Axis tick | **10** | **≤ ~20** |
| Source | **10** | — |

**Squint:** ≤~9px @ 332 → fail. **Oversized:** labels >~24px @ 720 or plot share &lt; 0.48 → fail density.

## Data density

| Rule | Pass |
|------|------|
| Plot share | `plotW / viewBoxW ≥ ~0.48` |
| Wrap over pad | ≤ **11** chars/line (forces “Umbreon VMAX”-class wrap) |
| Row pitch | ~1.7× (1 line) / ~2.15× (2 lines) |
| Bar thickness | ~0.4–0.5 of `rowH` |
| Values | **Fixed right column** (`textAnchor=end`), not tip-after-full-bar |
| Char width | Label **0.62×**, value **0.65×** (Inter 600 — not 0.55 regular) |

## Chart title rule (hard)

- **One title only:** HTML heading immediately above the figure (`h3` / section title).  
- **No subtitle** under that title (no second line restating the axis or “Figure N: …” *above* the plot).  
- Captions / sources **below** the plot only (`Source: silphcoanalytics.xyz`, one insight sentence).  
- Prefer **no in-SVG title** when HTML title exists (duplicate titles waste height on mobile).

## Hard bans

- `max-h-*` crushing aspect  
- `overflow-hidden` on chart frames that clips labels/tips  
- Tip-after-bar without reserved right column  
- Synthetic-only unit tests (must use real strings: `$140M`, `Umbreon VMAX`)  
- Chart **subtitles** after the title  

## Workflow

1. List every figure in the article.  
2. Record viewBoxW, fonts, pads, plot share, frame classes.  
3. Soft floors + wrap + fixed value column.  
4. Assert plot share + desktop soft caps.  
5. Strip subtitles; source under plot.  
6. Verify **390 and desktop**.  
7. e2e: blog geometry probe (see verification.md).

## Verification (V1–V14)

See [`references/verification.md`](references/verification.md). Critical:

| # | Check |
|---|--------|
| V5/V13 | No clip; longest tip complete |
| V11 | Plot share ≥ 0.48 |
| V12 | Desktop soft cap |
| V14 | No overflow-hidden clip |
| V15 | **No subtitle under title** |

## Hand off

| Need | Skill |
|------|--------|
| Product ECharts (card/portfolio) | **mobile-app-echarts-visual** |
| Chart type honesty | **tufte** |
| Sticky chrome / buttons | **product-chrome-craft** / **product-ui-craft** |
| Browser e2e | **browser-verify** |

## Done criteria

- [ ] V1–V3, V11–V15 at dual viewports  
- [ ] Real-string unit tests green  
- [ ] Blog geometry e2e green (or documented skip with reason)  
- [ ] Live mobile screenshot: no clip, no subtitle under title  
