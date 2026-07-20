# Mobile chart contract (numeric)

## Design constants

| Token | Value | Meaning |
|-------|------:|---------|
| `DESIGN_WIDTH` | 332 | CSS px chart width (390 viewport, padded frame) |
| `DESKTOP_SOFT_WIDTH` | 720 | Article paint width for soft caps |
| `MIN_TICK_GAP_CSS` | 48 | Min gap between tick labels on mobile |
| `ROW_H_MULT_1` | 1.7 | Single-line row pitch |
| `ROW_H_MULT_2` | 2.15 | Two-line wrapped row pitch |
| `MAX_CHARS_PER_LINE` | 11 | Wrap budget (forces “Umbreon VMAX”-class wrap) |
| `MIN_PLOT_WIDTH_SHARE` | 0.48 | Data region ≥ 48% of viewBox width |
| `CHAR_WIDTH_FRAC_LABEL` | 0.62 | Semi-bold-safe label advance (not 0.55 regular) |
| `CHAR_WIDTH_FRAC_VALUE` | 0.65 | Semi-bold / tabular tip advance |
| `LABEL_END_GAP` | 10 | Plot origin → label end (textAnchor=end) |
| `LABEL_LEFT_MARGIN` | 4 | SVG left → label start |

## Soft floors (at DESIGN_WIDTH)

```ts
const TARGET = {
  title: 13,
  label: 11,
  value: 11,
  tick: 10,
  source: 10,
} as const;
```

## Desktop soft caps (at DESKTOP_SOFT_WIDTH)

```ts
// Soft floors @ 332 → ~24px labels @ 720 (OK). Cap stops poster overshoot.
const DESKTOP_CAP = { label: 24, value: 22, tick: 20 } as const;
// renderedCssPx(font, viewBoxW, 720) <= CAP[role]
// Primary density gate is still plotW/viewBoxW >= 0.48
```

## Helpers (reference)

```ts
function minFontUserUnits(role, viewBoxW, designW = 332) {
  return Math.ceil(TARGET[role] * (viewBoxW / designW));
}

function renderedCssPx(fontSize, viewBoxW, paintW = 332) {
  return paintW * (fontSize / viewBoxW);
}

function leftGutterForLabels(maxCharsPerLine, labelFont, frac = 0.62) {
  return Math.ceil(maxCharsPerLine * frac * labelFont + 10 + 4);
}

function rowHeightForLabel(labelFont, lines = 1) {
  return Math.ceil(labelFont * (lines >= 2 ? 2.15 : 1.7));
}

function wrapLabelLines(text, maxCharsPerLine = 11) { /* ≤2 lines, word break */ }

// Horizontal ranking bars: fixed right value column (textAnchor=end at viewBoxW-4)
// so the full-width bar never shoves "$140M" past the edge.

function plotWidthShare(plotW, viewBoxW) {
  return plotW / viewBoxW; // ≥ 0.48
}
```

## Horizontal bar layout sketch

```ts
const viewBoxW = 720;
const label = minFontUserUnits("label", viewBoxW);
const value = minFontUserUnits("value", viewBoxW);
const tick = minFontUserUnits("tick", viewBoxW);
const mL = leftGutterForLabels(12, label); // per-line after wrap
const mR = padForLabelChars(6, value, 10);
const rowH = rowHeightForLabel(label, 2);
const barH = Math.round(rowH * 0.42);
const plotW = viewBoxW - mL - mR;
// assert plotW / viewBoxW >= 0.48
// values always at mL + barW + gap (never on fill)
// NO max-height on the SVG
```

## Pass/fail examples

| Case | Verdict |
|------|---------|
| 720 uu, font 12 @ 332 paint (~5.5px) | Fail floor |
| 720 uu, font 24 @ 332 (~11.1px) | Pass soft floor |
| 720 uu, font 29 @ 720 paint (~29px) | Fail desktop soft cap / density |
| Single-line 22-char label → mL ~ half viewBox | Fail plot share |
| Wrap to 12 chars/line → plot share ≥ 0.48 | Pass density |

## Anti-patterns

- max-height crush  
- Giant mobile-only type that empties the plot on desktop  
- Single-line gutters for multi-word set names  
