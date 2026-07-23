# Pass: motion

### Exit faster than enter

`enter-slow-exit-fast` · Subtle · Effort: S  
Fix in one phrase: dismissals use shorter duration than entrances; don’t share one long symmetric controller blindly.

**Detect:** custom `AnimationController` / `PageRouteBuilder` / dialogs where reverse uses the same long duration (>300ms) as forward.

**Hunt:** grep `duration:` near `AnimationController|PageRouteBuilder|showModalBottomSheet`.

**Why:** users already decided to leave; lag on exit feels like jank.

**Gotchas:** hero flights may need symmetry. Honor reduced motion.

---

### Springs for interactive motion

`spring-interactive` · Subtle · Effort: M  
Fix in one phrase: pressable UI and drag-end settle use springs rather than only linear ease for finger-driven motion.

**Detect:** gesture-driven cards using only `Curves.linear` with no spring; opacity fades may stay eased.

**Hunt:** grep `Curves.linear` near gesture code; check `SpringSimulation` / spring packages.

**Why:** linear motion feels robotic on press/drag.

**Gotchas:** don’t spring everything — large page routes can stay platform defaults.

---

### Honor reduced motion

`reduced-motion` · Noticeable if large motion ignores it; Subtle otherwise · Effort: S  
Fix in one phrase: gate non-essential animation on `MediaQuery.disableAnimationsOf` / platform accessibility.

**Detect:** decorative or large custom animations with no reduced-motion check.

**Hunt:** grep custom `AnimationController` in UI polish widgets; check for `disableAnimations` / `AccessibilityFeatures`.

**Why:** motion can make some users ill or distracted; system setting must win.

**Gotchas:** functional transitions (route push) may stay minimal rather than zero.
