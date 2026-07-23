# Pass: touch

### Make the whole control tappable

`gesture-opaque-hit-target` · Critical · Effort: S  
Fix in one phrase: set `HitTestBehavior.opaque` (or use a real Material button) so padding and gaps receive taps.

**Detect:** `GestureDetector` / `Listener` wrapping multi-child layouts (`Row`, `Column`, `Padding`) used as buttons without `behavior: HitTestBehavior.opaque` (or translucent when intentional). Also custom cards where only the text child hits.

**Hunt:** grep `GestureDetector\(` then read children; flag when child is `Row`/`Column`/`Padding` and `behavior` is missing or `deferToChild`.

**Why:** users tap the empty space between icon and label and nothing happens — classic dead zone.

**Gotchas:** `InkWell` / `TextButton` / `IconButton` already expand hit tests — don’t flag those. `translucent` is OK when stacked handlers must both fire. Decorative detectors with no `onTap` are fine.

---

### Primary actions need a press feel

`press-feedback` · Noticeable (Critical if primary CTA is silent) · Effort: S–M  
Fix in one phrase: give primary taps scale/opacity/spring or Material splash — never a silent custom `onTap` with zero visual/haptic change.

**Detect:** custom tappable widgets that only call `onTap` with no `InkWell`/`Material`, no scale animation, no opacity change, no haptic.

**Hunt:** grep `onTap:` on non-Material widgets; check nearby for `AnimationController`, `HapticFeedback`, `InkWell`.

**Why:** apps feel broken when the finger down produces no acknowledgment.

**Gotchas:** disabled controls should not animate as success. Dense icon-only toolbars may use light haptic + opacity only.
