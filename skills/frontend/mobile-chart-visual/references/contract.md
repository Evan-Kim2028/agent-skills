# Mobile chart contract (numeric)

## Design constants

| Token | Value | Meaning |
|-------|------:|---------|
| `DESIGN_WIDTH` | 332 | CSS px chart width assumption (390 viewport, padded frame) |
| `MIN_TICK_GAP_CSS` | 48 | Min gap between tick labels on mobile |
| `ROW_H_MULT` | 2.4 | `rowH >= labelFont * ROW_H_MULT` |
| `CHAR_WIDTH_FRAC` | 0.55 | Approx advance width for pad from char count (proportional sans) |
| `PAD_GAP` | 8 | Extra user units between label end and plot |

## Target rendered CSS px

```ts
const TARGET = {
  title: 15,
  label: 13,
  value: 12,
  tick: 11,
  source: 11,
} as const;
```

## Helpers (reference implementation)

```ts
function minFontUserUnits(role: keyof typeof TARGET, viewBoxW: number, designW = 332) {
  return Math.ceil(TARGET[role] * (viewBoxW / designW));
}

function renderedCssPx(fontSize: number, viewBoxW: number, designW = 332) {
  return designW * (fontSize / viewBoxW);
}

function padForLabelChars(maxChars: number, labelFont: number, gap = 8) {
  return Math.ceil(maxChars * 0.55 * labelFont + gap);
}

function rowHeightForLabel(labelFont: number) {
  return Math.ceil(labelFont * 2.4);
}

function maxTicksForPlotCss(plotWidthCss: number, minGap = 48) {
  return Math.max(2, Math.floor(plotWidthCss / minGap));
}
```

## Horizontal bar layout sketch

```ts
const viewBoxW = 720; // or project choice
const label = minFontUserUnits("label", viewBoxW);
const value = minFontUserUnits("value", viewBoxW);
const tick = minFontUserUnits("tick", viewBoxW);
const mL = padForLabelChars(maxLabelChars, label);
const mR = padForLabelChars(maxValueChars, value);
const rowH = rowHeightForLabel(label);
const barH = Math.round(label * 0.9);
// mT/mB: tick labels + axis title clearance using tick/title sizes
// NO max-height on the SVG
```

## Pass/fail examples at designW=332

| viewBoxW | fontSize | rendered | Verdict for labels |
|---------:|---------:|---------:|--------------------|
| 676 | 12 | ~5.9 | Fail |
| 720 | 11 | ~5.1 | Fail |
| 720 | 29 | ~13.4 | Pass |
| 960 | 32 | ~11.1 | Borderline label (raise or narrow W) |
| 960 | 38 | ~13.1 | Pass |
| 340 | 11 | ~10.7 | Borderline tick; ok-ish for compact hist |
| 340 | 14 | ~13.7 | Pass |

## Anti-pattern: max-height

Desktop layout with `max-h-[300px]` on a 676×250 viewBox at width 324 yields
~120px height and crushes perceived type further when combined with small
user-unit fonts. Remove the cap; let height follow aspect ratio.
