# Pass: scroll

### Last item breathing room

`scroll-bottom-inset` · Noticeable · Effort: S  
Fix in one phrase: outermost vertical scrollables need dynamic bottom padding (`MediaQuery.viewPadding` / viewInsets-aware), not only a wrapping `SafeArea` that clips.

**Detect:** `ListView` / `CustomScrollView` / `SingleChildScrollView` at screen bottom without bottom padding for home indicator / nav bar; or `SafeArea` wrapping the scrollable (clips overscroll content).

**Hunt:** grep scroll widgets in scope; check `padding:` and trailing `SizedBox`/`SliverPadding`.

**Why:** last row glued to the home indicator feels unfinished and can be hard to tap.

**Gotchas:** nested list inside an already-padded parent — only outermost needs it. Bottom sheets have their own rules.

---

### Reserve space for images

`reserve-image-space` · Noticeable · Effort: S  
Fix in one phrase: give images explicit aspect ratio or height so lists don’t jump when images resolve.

**Detect:** `Image.network` / `CachedNetworkImage` in lists without `width`/`height`/`AspectRatio`/`SizedBox` constraints.

**Hunt:** grep `Image\.network|CachedNetworkImage`.

**Why:** layout shift is disorienting and causes mis-taps.

**Gotchas:** hero full-bleed backgrounds may size to parent; still avoid zero-height until load.

---

### Don’t clip horizontal lists with page padding only

`horizontal-list-padding` · Noticeable · Effort: S  
Fix in one phrase: horizontal lists should pad first/last items (or full-bleed list + item padding) so content can peek.

**Detect:** horizontal `ListView` inside a padded parent with no item edge padding strategy.

**Hunt:** grep `scrollDirection: Axis.horizontal`.

**Why:** users can’t tell there’s more to scroll; first/last cards look cropped.

**Gotchas:** if a fade/shader or scrollbar already signals more content, severity drops to Subtle.
