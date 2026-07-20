# Mobile chart visual verification

Use this when proving a chart pass under **mobile-chart-visual**. Target viewport
**390×844** (or 375×812); measure chart content width ~**320–360 CSS px**.

## 1. Text size floors (primary)

For each main figure’s SVG `<text>` nodes (sample titles, category labels, value
tips, ticks):

```js
const r = textEl.getBoundingClientRect();
// r.height is the practical “rendered size” signal
```

| Role | Min rendered height (CSS px) | Fail band |
|------|------------------------------|-----------|
| Category / row label | **12** | ≤9 |
| Value tip | **12** | ≤9 |
| Axis tick | **11** | ≤9 |
| In-SVG title | **14** | ≤11 |
| Source (in-SVG) | **11** | ≤9 |

If titles live in HTML (`h3 text-base`) outside the SVG, that is OK for V3 as
long as category/value/tick floors still hold inside the plot.

## 2. Scale math cross-check

```text
expected ≈ chartClientWidth × (fontSizeAttr / viewBoxWidth)
```

If measured height is far below expected, check transforms, `max-h`, or
`preserveAspectRatio` crop. If expected itself is below floors, fix **user-unit
fonts or viewBox width** — not CSS alone.

```text
minFont(role) = ceil(TARGET[role] × viewBoxW / designW)
designW default = 332
```

## 3. Height-cap ban

Fail if the SVG (or wrapper) uses `max-height` / fixed height that:

- shrinks `clientHeight` well below natural `clientWidth × (vbH/vbW)`, **and**
- leaves labels/ticks in the squint band.

Prefer `className="w-full h-auto"` (or equivalent) with natural aspect.

## 4. Clip & collision

- Longest left-axis label: full string bbox inside SVG; not cut by `overflow:hidden` without ellipsis intent.  
- Value labels outside bars must not sit under adjacent rows.  
- Rotated x labels: allow extra bottom pad; if still colliding, switch to horizontal bars or fewer categories.

## 5. Tick density

On the axis with continuous ticks, require **≥ ~48 CSS px** between adjacent
tick label centers (or drop to 3–5 ticks). Dense day labels on launch charts
should thin to key dates + one callout.

## 6. Spacing gutters

Visually (or via bbox):

- Category text ends ≥ ~6–8 CSS px before the plot origin.  
- Outer figure padding exists (`p-3`+); charts not flush to article edge.  
- Legend/source not overlapping the last data row.

## 7. Raster figures

For `<img>` charts:

- `displayWidth / naturalWidth` scale applied to estimated design-time type.  
- If estimated tick type &lt; 11px at display size → re-export mobile primary or
  replace with SVG.  
- Lightbox/`@2x` is **not** a pass for inline reading.

## 8. Evidence package

Record under the task scratch (or CI artifact):

| File | Content |
|------|---------|
| `*-mobile-metrics.json` | Per figure: viewBox, clientW/H, sample texts with `renderedH`, pass/fail |
| `*-chart-*.png` | Optional viewport screenshots of each figure |
| `verify-summary.md` | Which checks ran; market-cap-only vs multi-post |

## 9. Automated helpers (recommended)

Unit-test pure layout constants:

```ts
renderedCssPx(fontSize, viewBoxW, 332) >= TARGET.label
```

Browser/Playwright: open the real article route at 390 width, query
`figure svg text`, assert heights. Prefer measuring **shipped** DOM over
reimplementing layout in the test.

## 10. Silph blog lessons (Pitch Black)

- Horizontal ranking bars with fat type + fat gutters pass easiest.  
- Wide viewBox (900–1200) needs **large** user-unit fonts or it still lands ~10px.  
- Pad growth must travel with type (clip failures on long card names).  
- Many manual type-bump PRs → encode ratio + clip gate once instead.  
