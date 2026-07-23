# Pass: charts-numbers

Data-heavy surfaces: price/metric charts, tables, and signed numbers. Conservative — evidence, not demands, especially for perf rules.

### Sign color must match the displayed number

`number-sign-color-agreement` · Critical · Effort: S  
Fix in one phrase: the color of a signed value derives from the **same** value the user sees after formatting — never a sibling metric, never the unrounded raw.

**Detect:** two real failure modes: (a) a dollar amount and a percent computed over different subsets disagree in sign, so one is green and one is red for the same row; (b) the formatter rounds `-0.4%` to `"0%"` while the color ternary reads the raw negative, producing a red zero.

**Hunt:** grep `> 0 \?` / `< 0 \?` color ternaries; check whether the value feeding the ternary is the same variable feeding the adjacent formatted `Text(`, or a separately computed/rounded sibling.

**Why:** a red "0%" or mismatched red/green pair on the same row makes users distrust every number on the screen.

**Gotchas:** intentionally distinct metrics (e.g. day change red, all-time change green) are fine if each color matches its own displayed value — the bug is same-value disagreement, not different-metric disagreement.

---

### The same metric must agree across screens

`cross-surface-number-agreement` · Critical · Effort: M  
Fix in one phrase: a metric shown on more than one screen (counts, totals, changes) reconciles — same number, or an explained difference.

**Detect:** the same underlying field aggregated with different fold/filter logic in more than one view (e.g. a list-screen total that excludes pending items while the detail-screen total includes them).

**Hunt:** grep the metric name (e.g. `totalBalance`, `itemCount`) across `lib/` and diff the aggregation/filter logic at each call site.

**Why:** users compare screens; a total that changes depending on where you look reads as a bug, not a filter.

**Gotchas:** clearly-labeled different scopes (e.g. "This month" vs "All time") are not disagreement — the bug is silent scope drift with identical labels.

---

### One formatter, consistent precision

`precision-consistency` · Noticeable · Effort: S  
Fix in one phrase: precision follows magnitude by rule (e.g. <$1 two decimals, <$1k whole, ≥$10k compact) via one shared formatter, not per-widget guesses.

**Detect:** multiple bespoke `toStringAsFixed(`/ad hoc format calls for the same unit, producing inconsistent decimal places across the app.

**Hunt:** grep `toStringAsFixed\(` and compare call sites for the same field/unit.

**Why:** a price shown as `$4.2` on one screen and `$4.20` on another feels unpolished and undermines trust in the number itself.

**Gotchas:** deliberately different contexts (chart tooltip vs receipt line item) may reasonably differ — flag only same-context inconsistency.

---

### Charts reserve their space

`chart-reserved-space` · Noticeable · Effort: S  
Fix in one phrase: charts occupy fixed space before data lands (skeleton or fixed-height container) — no layout shift on hydrate.

**Detect:** `fl_chart`/`LineChart`/`BarChart` (or equivalent) built inside an unconstrained parent with no placeholder while data loads.

**Hunt:** grep `LineChart\(|BarChart\(|fl_chart` and check the parent for a fixed `height`/`AspectRatio`/skeleton before the data branch.

**Why:** the surrounding UI jumps when the chart pops in, which is disorienting mid-scroll or mid-read.

**Gotchas:** charts already inside a fixed-height card are fine even without an explicit skeleton widget.

---

### Charts need an empty state too

`chart-empty-state` · Noticeable · Effort: S  
Fix in one phrase: an empty series shows "no data" copy — never bare axes or a blank box.

**Detect:** chart builders with no `isEmpty` branch for the series data.

**Hunt:** grep chart widget construction near the data source; check for an empty-series guard.

**Why:** a chart with no data and no message looks broken, not "nothing to show yet."

**Gotchas:** loading state is a separate branch — don't conflate "loading" with "empty"; both need distinct handling.

---

### Truncated axes must be a deliberate, labeled choice

`axis-honesty` · Noticeable · Effort: S  
Fix in one phrase: a truncated y-axis that exaggerates small moves must be a deliberate baseline choice and, for money charts, labeled.

**Detect:** hardcoded `minY:` set close to the data's max-derived range (not zero), with no axis label or context explaining the baseline. Sibling distortions in the same family: a default time window that starts at an outlier with no zoom-out option; two series on mismatched dual axes to force a visual comparison; uneven gridline/tick spacing (interval not proportional to range).

**Hunt:** grep `minY:` and compare against the data range in the same widget/view model. Also grep window defaults (`days = `, range enums) and dual-axis configs (`rightTitles` with a second scale).

**Why:** an unlabeled truncated axis makes a 0.5% wiggle look like a crash, misleading the user about magnitude.

**Gotchas:** deliberately-zoomed technical charts for expert users are fine if labeled; don't demand zero-baseline on every chart. User-selectable windows (7D/30D/90D) satisfy the window rule as long as no single cherry-picked window is the only option.

---

### Stale charts need an as-of label

`as-of-labeling` · Noticeable · Effort: S  
Fix in one phrase: price/market charts carry an as-of timestamp or staleness cue; unlabeled implies "now."

**Detect:** chart headers/sections with no date/as-of text next to fields known to be cached or delayed.

**Hunt:** grep chart section headers for `asOf|lastUpdated|timestamp`; check whether it's rendered near the chart.

**Why:** a user acting on a stale price believing it's live can lose money or trust.

**Gotchas:** genuinely real-time streams (live socket ticking) don't need a static label — the smell is cached/delayed data presented with no cue.

---

### Chart touch targets stay reachable

`chart-touch-targets` · Noticeable · Effort: S  
Fix in one phrase: tooltip/spot interactions have ≥48dp effective hit area — raise `touchSpotThreshold` (or equivalent) rather than leaving pixel-tight defaults.

**Detect:** `LineTouchData`/`touchData` (or equivalent) configured with a small `touchSpotThreshold` on a data-dense chart.

**Hunt:** grep `LineTouchData\(|touchSpotThreshold`.

**Why:** users with imprecise fingers can't land on the right data point, especially on dense line charts.

**Gotchas:** sparse charts with few points already have generous effective spacing — don't flag those.

---

### Direction isn't color-only

`updown-not-color-only` · Noticeable · Effort: S  
Fix in one phrase: pair red/green with a sign or arrow glyph — color-blind users can't rely on hue alone.

**Detect:** positive/negative colored `Text` whose string has no `+`/`-`/▲/▼.

**Hunt:** grep signed-value `Text(` near color logic; check whether the formatted string already includes an explicit sign or arrow.

**Why:** roughly 1 in 12 men have some color vision deficiency; red/green alone is invisible to them.

**Gotchas:** a value string with an explicit sign (`+2.3%`, `-1.1%`) already satisfies this — don't demand an arrow on top.

---

### Numeric columns are tabular and right-aligned

`tabular-numerals-columns` · Noticeable · Effort: S  
Fix in one phrase: numeric table columns (price, qty, balance) are right-aligned and use `FontFeature.tabularFigures()` so digits line up.

**Detect:** price/qty columns using default text alignment and default font features (proportional digits).

**Hunt:** grep table/list column `Text(` for price/qty/balance fields; check `textAlign` and `fontFeatures`.

**Why:** proportional digits and left/center alignment make columns of numbers unscannable — users can't eyeball magnitude at a glance.

**Gotchas:** single standalone numbers outside a column context don't need tabular figures.

---

### Repaint boundary around fast-updating charts

`chart-repaint-boundary` · Subtle · Effort: S  
Fix in one phrase: wrap charts in `RepaintBoundary` when they sit inside a parent that rebuilds frequently from unrelated state.

**Detect:** a chart widget inside a `build()` that also watches fast-changing state (e.g. a ticking price stream driving a sibling widget) with no `RepaintBoundary` isolating the chart.

**Hunt:** grep chart widgets for a wrapping `RepaintBoundary`; check the parent's rebuild triggers.

**Why:** an unnecessary repaint of a complex chart on every unrelated tick can visibly stutter the frame.

**Gotchas:** stay conservative here — only flag with clear evidence of a fast-rebuilding parent; don't demand `RepaintBoundary` everywhere as a reflex.

---

### Axis labels: the minimum that keeps the chart readable

`axis-label-declutter` · Noticeable · Effort: S  
Fix in one phrase: ≤5 y-axis ticks on mobile, filtered via interval/custom title builders — default tick spam is clutter, not information.

**Detect:** chart `titlesData` left at defaults (or dense intervals) producing 8+ axis labels on a phone-width chart; date axes labeling every point.

**Hunt:** grep `titlesData:|getTitlesWidget|interval:` in chart configs; count effective ticks at typical data ranges.

**Why:** dense axis text competes with the data, shrinks the plot area, and makes the one number the user needs harder to find.

**Gotchas:** wide/tablet layouts can afford more ticks; the budget is per rendered width, not absolute.

---

### Labels must not collide

`label-collision` · Noticeable · Effort: S  
Fix in one phrase: axis, tooltip, and legend text never overlaps at real data ranges or at 1.3× text scale — reserve space for the longest formatted value.

**Detect:** fixed `reservedSize:` too small for long formatted values (e.g. `$25.4M`, four-digit dates); tooltips that clip at chart edges; adjacent x-labels that touch on narrow screens.

**Hunt:** grep `reservedSize:` and compare against the longest string the formatter can emit; check tooltip `fitInsideHorizontally`/`fitInsideVertically` flags.

**Why:** overlapping or clipped labels read as broken and make values literally unreadable.

**Gotchas:** intentional label thinning (every other tick) is a fix for this, not a violation.

---

### One reference structure, not three

`data-ink-restraint` · Subtle · Effort: S  
Fix in one phrase: gridlines OR a border OR background bands — one reference structure max; the data should carry the ink.

**Detect:** `FlGridData(show: true)` stacked with visible chart borders and filled background bands/areas in the same chart.

**Hunt:** grep `FlGridData\(|FlBorderData\(|RangeAnnotations|betweenBarsData` per chart and count enabled reference layers.

**Why:** stacked scaffolding buries the series; a small mobile chart has no ink budget for decoration.

**Gotchas:** a single subtle horizontal gridline set with a de-emphasized color is the norm, not a violation; sparklines should have none.

---

### Stat blocks sit on the spacing scale

`stat-density-rhythm` · Subtle · Effort: S  
Fix in one phrase: label→value and stat→stat gaps come from the app's density tokens, not ad-hoc `SizedBox` values — cramped gaps read broken, oversized gaps dissociate label from number.

**Detect:** number-heavy blocks (hero totals, stat rows, KPI cells) using odd one-off spacing (`SizedBox(height: 3)`, `5`, `7`, `9`…) instead of the app's spacing constants; inconsistent gaps between identical stat pairs on the same screen.

**Hunt:** grep `SizedBox(height:` / `SizedBox(width:` inside stat/summary widgets and diff against the app's density/spacing constants file.

**Why:** inconsistent rhythm makes a dense data screen feel chaotic even when every number is correct — users can't group label with value at a glance.

**Gotchas:** one-off optical adjustments (±1dp) around icons are legitimate; flag drift patterns, not single pixels.

---

### Number groups share an alignment edge

`number-block-alignment` · Subtle · Effort: S  
Fix in one phrase: numbers in one visual group align to a common edge (right-aligned columns, consistent decimal position) — extends tabular figures from typography to layout.

**Detect:** vertically stacked or grid-laid numbers (movers grid, stat columns) with mixed `start`/`center`/`end` alignment, so magnitudes can't be compared by eye.

**Hunt:** grep `crossAxisAlignment`/`textAlign` in numeric grid/column widgets; check consistency within each visual group.

**Why:** misaligned numbers force digit-by-digit reading; aligned ones let the eye compare lengths instantly.

**Gotchas:** a single hero number centered in its own card is its own group — alignment applies within groups, not across the whole screen.

---

### Legends live on the data

`chart-legend-integrated` · Subtle · Effort: S  
Fix in one phrase: label series where they appear (end-of-line labels, on-chart annotation, colored inline text in the header) instead of a detached legend the eye must shuttle to.

**Detect:** multi-series charts with a separate legend row/box while series endpoints or headers could carry the labels directly.

**Hunt:** grep legend widgets/rows near multi-series chart configs; check for direct series labeling.

**Why:** cross-referencing a legend on a small screen costs a working-memory round-trip per glance; integrated labels read instantly.

**Gotchas:** single-series charts need no series label at all; dense many-series charts (5+) may genuinely need a legend — flag the 2-3 series cases.
