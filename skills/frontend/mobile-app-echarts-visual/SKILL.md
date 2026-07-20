---
name: mobile-app-echarts-visual
description: >
  Mobile-readable **product ECharts** (card price/volume, portfolio history, set
  charts) without desktop regressions — grid gutters, axisLabel floors, legend
  placement, adaptive height, touch tooltips, dual-viewport proof. Use when card
  or portfolio charts are clipped, tiny, sparse, legend-jammed, "mobile echarts",
  or /mobile-app-echarts-visual. Prefer mobile-blog-chart-visual for blog SVG.
  Prefer design-system chart tokens + tufte for honesty.
metadata:
  short-description: "Product ECharts: mobile grid/axis floors + dual-viewport"
---

# Mobile app ECharts visual

**Job:** Product charts (canvas ECharts) stay legible at **~390×844** and
coherent at desktop widths. Mobile is primary for SilphCo; desktop must not
gain poster labels or empty plots from mobile-only hacks.

**Scope:** `frontend/src/charts/**`, card-detail price/volume, portfolio valuation
history, set volume charts. **Not** blog SVG — use **mobile-blog-chart-visual**.

## Sources

| Source | What we take |
|--------|----------------|
| [Nadieh Bremer — Mobile vs desktop dataviz](https://www.visualcinnamon.com/2019/04/mobile-vs-desktop-dataviz/) | Non-linear type; stack/simplify on small screens; different chart when needed |
| [Tableau mobile dashboard design](https://www.tableau.com/blog/mobile-dashboard-design-less-more-small-screen-47854) | Simple views, fewer filters, high-level marks |
| [Create with Swift — humanist mobile dataviz](https://www.createwithswift.com/designing-humanist-data-visualization-for-mobile/) | No hover-only UX; high contrast; color-independent cues |
| Apache ECharts docs (grid / axisLabel / containLabel) | `grid` + `containLabel` + resize rebuild — not CSS font hacks on canvas |
| Silph `chartTheme` + `adaptiveChartHeight` | Token colors; mobile height ≥ desktop for dense series |

## Core rules (ECharts)

### Grid (gutters)

At mobile container width (~350–370 CSS px after padding):

| Region | Floor (CSS px) | Notes |
|--------|---------------:|-------|
| `grid.left` | **≥ 44** | Room for y labels (or use `containLabel: true`) |
| `grid.right` | **≥ 12** (more if right-side series labels) | |
| `grid.top` | **≥ 28** if legend/title; else **≥ 12** | Prefer **no** chart title if page already has one |
| `grid.bottom` | **≥ 36** | x labels + dataZoom |

Prefer `containLabel: true` on card/portfolio series charts unless a fixed grid is proven.

### Type floors (CSS px, ECharts `fontSize`)

| Role | Mobile min | Desktop soft max |
|------|----------:|-----------------:|
| axisLabel | **11** | **14** |
| legend | **11** | **13** |
| tooltip | **12** | **14** |

Do **not** use blog SVG viewBox math here — ECharts sizes in CSS pixels after layout.

### Height

Use `resolveAdaptiveChartHeight` (or equivalent):

- Sparse series: compact (~180)  
- Mobile dense: **≥ 280**  
- Desktop dense: ~260  

Leave room for sticky chrome (card: app + command + tabs + bottom nav). Chart
viewport ≈ remaining space after chrome — do not force a 400px chart under a
160px sticky stack without scroll.

### Interaction

- Touch: use project `touchTooltip` / axisPointer patterns — **no hover-only** insight.  
- DataZoom: show a mobile hint once if pinch/pan is required.  
- Legend: bottom or scrollable; never overflow the container width.

### Color

- Always go through `chartTheme` / marketplace color maps — no one-off hex in options.  
- Dark + light modes both pass contrast against `chartSurface`.  
- Color-independent series cues (line type / marker) for critical series when possible.

### Title hygiene

- Page/section heading owns the title.  
- **No ECharts `title` text** that duplicates the section heading (wastes top grid).  
- No subtitle line under the page title restating the axis.

## Verification (product)

| # | Check | Pass |
|---|--------|------|
| E1 | axisLabel fontSize ≥ 11 at 390 | |
| E2 | grid gutters / containLabel — labels fully inside chart DOM box | |
| E3 | No horizontal document overflow | |
| E4 | Canvas width ≥ ~300 on 390 viewport for primary chart | |
| E5 | Legend not clipped | |
| E6 | Dual viewport 390 + 1280 — no desktop poster fonts | |
| E7 | e2e: `card-echarts-mobile-geometry` (or successor) green | |

## Workflow

1. Identify option builder (e.g. PriceOverTime, DailyVolume, portfolio history).  
2. Set `grid` + `axisLabel` + legend for mobile first.  
3. Wire `adaptiveChartHeight(isMobile)`.  
4. Confirm theme tokens.  
5. Run card ECharts mobile e2e + manual 390 screenshot.  
6. Desktop smoke: same option path at ≥1280.

## Anti-patterns

- Copying blog SVG floor math into ECharts options.  
- `grid.left: '2%'` with long grade labels → clip.  
- Desktop-only legend on the right → mobile overflow.  
- Functional e2e green with unreadable axis (must geometry-probe).  
- Fixing clip with `overflow:hidden` on the chart shell.

## Hand off

| Need | Skill |
|------|--------|
| Blog SVG | **mobile-blog-chart-visual** |
| Tokens | **design-system** |
| Sticky chrome | **product-chrome-craft** |
| Viz honesty | **tufte** |
| e2e proof | **browser-verify** |

## Done criteria

- [ ] E1–E7 for touched product charts  
- [ ] No title/subtitle duplicate under section heading  
- [ ] Live card mobile screenshot: labels inside canvas box  
