# Mobile chart visual verification

Prove under **mobile-chart-visual** at **~390×844** *and* a wide article paint
(~720–880 CSS px) when the layout is responsive SVG.

## 1. Text size floors (mobile, primary)

| Role | Min rendered height (CSS px) @ ~332 paint | Fail band |
|------|-------------------------------------------|-----------|
| Category / row label | **11** | ≤9 |
| Value tip | **11** | ≤9 |
| Axis tick | **10** | ≤9 |
| In-SVG title | **13** | ≤11 |

HTML titles (`h3 text-base`) outside the SVG satisfy V3.

## 2. Desktop soft caps (density)

At ~720px chart width:

| Role | Soft max CSS px |
|------|----------------:|
| Label | **~24** (body-sized; soft floors scale here) |
| Value | **~22** |
| Tick | **~20** |

**Primary density fail:** thin plot strip (`plotW/viewBoxW < 0.48`) even when
type is “readable.” Fix wrap/gutters first, not only font size.

## 3. Scale math

```text
expected ≈ paintWidth × (fontSizeAttr / viewBoxWidth)
minFont(role) = ceil(TARGET[role] × viewBoxW / 332)
```

## 4. Height-cap ban

No `max-height` that undercuts natural aspect and floors.

## 5. Clip & collision (V5/V6/V13/V14)

- Left labels sized by **per-line** width after wrap, using **semi-bold-safe**
  char width (~0.62× em for Inter 600). Regular 0.55× is a known underestimate.  
- Values in a **fixed right column** (preferred) or proven to fit after the
  **full-width** bar (rank #1 tip, including trailing `M` on `$140M`).  
- No systematic overlap of tips/labels.  
- Chart frame must **not** use `overflow-hidden` to hide overflow (V14).  
- Unit tests must include **real article strings** (e.g. `Umbreon VMAX`, `$140M`),
  not only synthetic `maxChars`.

## 6. Tick density (V7)

≥ ~48 CSS px between adjacent tick labels, or ≤ 3–5 ticks.

## 7. Data density (V11)

| Metric | Pass |
|--------|------|
| `plotW / viewBoxW` | **≥ ~0.48** |
| Row pitch | Compact (not empty bands between marks) |
| Bar / mark thickness | Meaningful fraction of row height |
| Left gutter | From wrap width, not full unwrapped string |

## 8. Source (V9)

- Under the plot, not over marks  
- Copy: **`Source: silphcoanalytics.xyz`** (not “Data source”)  
- No redundant chart subtitles that restate the axis  

## 9. Evidence

- Unit tests on shipped layout constants (floors, soft caps, plot share, wrap)  
- Optional Playwright at 390 + 1280 measuring text heights and plot share  

## 10. Silph lessons

- Pitch Black: fat horizontal rankings work; ratio beats raw font bumps.  
- Market-cap v1 mobile pass: floors OK, density failed (giant type + huge pad).  
- Fix path: soft floors + wrap + plot-share gate + values off bars.  
- **Market-cap TOP5 (2026-07):** unit tests passed floors/plot-share, but live
  mobile clipped `$140M`’s `M` and `Umbreon VMAX` — 0.55× width + tip-after-bar
  + `overflow-hidden`. Fix: 0.62/0.65× fracs, wrap ≤11, **fixed right value
  column**, ban frame `overflow-hidden`, test real strings (V13/V14).  
