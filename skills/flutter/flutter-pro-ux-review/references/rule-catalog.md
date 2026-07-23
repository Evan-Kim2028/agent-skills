# Flutter pro UX — rule catalog

Each rule: **slug**, severity · effort, fix in one phrase, **Detect**, **Hunt**,
**Why**, **Gotchas**. The catalog detects; you implement only selected findings.

Agent: cite `slug` in findings. Prefer `file:line` evidence from the Hunt.

---

## Touch / hit testing

### Make the whole control tappable

`gesture-opaque-hit-target` · Critical · Effort: S  
Fix in one phrase: set `HitTestBehavior.opaque` (or use a real Material button) so padding and gaps receive taps.

**Detect:** `GestureDetector` / `Listener` wrapping multi-child layouts (`Row`, `Column`, `Padding`) used as buttons without `behavior: HitTestBehavior.opaque` (or translucent when intentional). Also custom cards where only the text child hits.

**Hunt:** grep `GestureDetector\(` then read children; flag when child is `Row`/`Column`/`Padding` and `behavior` is missing or `deferToChild`.

**Why:** users tap the empty space between icon and label and nothing happens — classic “dead zone.”

**Gotchas:** `InkWell` / `TextButton` / `IconButton` already expand hit tests — don’t flag those. `translucent` is OK when stacked handlers must both fire. Decorative detectors with no `onTap` are fine.

---

### Primary actions need a press feel

`press-feedback` · Noticeable · Effort: S–M  
Fix in one phrase: give primary taps scale/opacity/spring or Material splash — never a silent custom `onTap` with zero visual/haptic change.

**Detect:** custom tappable widgets that only call `onTap` with no `InkWell`/`Material`, no scale animation, no opacity change, no haptic.

**Hunt:** grep `onTap:` on non-Material widgets; check nearby for `AnimationController`, `HapticFeedback`, `InkWell`.

**Why:** apps feel broken when the finger down produces no acknowledgment.

**Gotchas:** disabled controls should not animate as success. Dense icon-only toolbars may use light haptic + opacity only.

---

## Data shown to humans

### Never let users see "null"

`never-show-null` · Critical · Effort: S  
Fix in one phrase: never render null/empty/`"null"` as user-visible text; use placeholder or hide the row.

**Detect:** `Text(...toString())`, string interpolation of nullable fields, or display of API strings that can be the literal `"null"`.

**Hunt:** grep `Text\([^)]*toString` and `\$\{` / `\$[a-zA-Z]` in UI files; grep `??` absence near nullable model fields in widgets.

**Why:** the word “null” is developer debris; empty holes look equally broken.

**Gotchas:** debug-only overlays and logger output are fine. Zero as a valid number is not null.

---

### Format dates for humans

`human-dates` · Noticeable · Effort: S  
Fix in one phrase: locale-aware relative or medium dates — never raw ISO/`DateTime.toString()` in UI.

**Detect:** `DateTime` / ISO-8601 strings shown via `toString()`, `toIso8601String()`, or fixed `yyyy-MM-ddTHH:mm` in widgets.

**Hunt:** grep `toIso8601String|DateTime\.now\(\)\.toString|Text\([^)]*DateTime`.

**Why:** ISO timestamps are for machines; users need “24 Jun 2016, 14:44” or relative time by context.

**Gotchas:** logs, filenames, and API payloads are not UI. Pick relative vs absolute from context (chat vs invoice).

---

### Format phone numbers for humans

`human-phones` · Noticeable · Effort: S  
Fix in one phrase: display and mask phones with grouping; store digits separately if needed.

**Detect:** phone fields or list tiles showing continuous digit strings (8+ digits) with no spaces/dashes/parens formatting.

**Hunt:** grep `phone|mobile|tel` in UI; check `Text(` near those fields.

**Why:** `994501234567` is a blob; grouped numbers are readable and harder to mistype.

**Gotchas:** don’t break `tel:` URIs or WhatsApp deep links that need E.164. Respect locale dial patterns when known.

---

### Format numbers for humans + tabular figures

`human-numbers-tabular` · Noticeable · Effort: S  
Fix in one phrase: group thousands by locale; use tabular figures for values that tick or align in columns.

**Detect:** prices/counts via bare `toString()`; animated or column numbers without `fontFeatures: [FontFeature.tabularFigures()]` (or theme equivalent) when digits change width and shift layout.

**Hunt:** grep `Text\([^)]*price|amount|balance|count` and `toString()`; check changing metrics in headers.

**Why:** layout jumps when “9” becomes “10”; misaligned columns destroy scanability.

**Gotchas:** decorative one-off numbers in marketing copy may stay proportional.

---

## Forms / keyboard

### Keyboard action button has a job

`text-input-action` · Noticeable · Effort: S  
Fix in one phrase: `TextInputAction.next` focuses the next field; `done`/`send` submits on the last field — not only unfocus.

**Detect:** multi-field forms where every field uses default action or all use `done` without `onSubmitted` / `FocusNode` chain / `Form` submit.

**Hunt:** grep `TextFormField|TextField` — check `textInputAction` and `onFieldSubmitted`/`onSubmitted`.

**Why:** users expect the bottom-right keyboard key to advance or submit, not shrug.

**Gotchas:** single-field search may correctly use `search` + submit. Multiline notes use `newline`.

---

### Autofocus single-purpose pages

`autofocus-single-field` · Subtle–Noticeable · Effort: S  
Fix in one phrase: if the screen’s only job is one field (search, OTP, rename), autofocus it on open.

**Detect:** routes that are essentially one `TextField` without `autofocus: true` or post-frame `FocusNode.requestFocus`.

**Hunt:** screens named/search/otp/rename/create-tag with a single field.

**Why:** making the user tap the only field is wasted motion.

**Gotchas:** don’t autofocus when it would pop the keyboard over critical instructions or on desktop web without intent.

---

### Cap length with formatters, not angry errors

`max-length-formatter` · Noticeable · Effort: S  
Fix in one phrase: hard limits use `LengthLimitingTextInputFormatter` / custom formatters; don’t wait for submit to yell.

**Detect:** validators that only check `maxLength` on submit while the field still accepts more characters; or error shown *while typing* past limit instead of blocking input.

**Hunt:** grep `maxLength` / `LengthLimiting` / amount validators.

**Why:** preventing overflow feels better than punishing it.

**Gotchas:** soft guidelines (“recommended 80 chars”) may show a counter instead of a hard block.

---

### Dismiss keyboard on outside / scroll when appropriate

`keyboard-dismiss-path` · Noticeable · Effort: S  
Fix in one phrase: scrollable forms use `keyboardDismissBehavior: onDrag` (or equivalent); tap-outside unfocus where platform expects it.

**Detect:** long forms with no dismiss-on-scroll; full-screen barriers that never unfocus.

**Hunt:** grep `ListView|SingleChildScrollView` near forms; check `keyboardDismissBehavior`; grep `GestureDetector` on scaffold for unfocus patterns.

**Why:** trapped keyboards cover CTAs and feel like a stuck app (common prod complaint).

**Gotchas:** chat composers often keep focus on purpose.

---

## Scroll / safe area / layout stability

### Last item breathing room

`scroll-bottom-inset` · Noticeable · Effort: S  
Fix in one phrase: outermost vertical scrollables need dynamic bottom padding (`MediaQuery.viewPadding` / viewInsets-aware), not only a wrapping `SafeArea` that clips.

**Detect:** `ListView` / `CustomScrollView` / `SingleChildScrollView` at screen bottom without bottom padding accounting for home indicator / nav bar; or `SafeArea` wrapping the scrollable (clips overscroll content).

**Hunt:** grep scroll widgets in `lib/`; check `padding:` and trailing `SizedBox`/`SliverPadding`.

**Why:** last row glued to the home indicator feels unfinished and can be hard to tap.

**Gotchas:** nested list inside an already-padded parent — only outermost needs it. Bottom sheets have their own safe padding rules.

---

### Reserve space for images

`reserve-image-space` · Noticeable · Effort: S  
Fix in one phrase: give images explicit aspect ratio or height so lists don’t jump when images resolve.

**Detect:** `Image.network` / `CachedNetworkImage` in lists without `width`/`height`/`AspectRatio`/`SizedBox` constraints.

**Hunt:** grep `Image\.network|CachedNetworkImage|DecorationImage`.

**Why:** layout shift is disorienting and causes mis-taps.

**Gotchas:** hero full-bleed backgrounds may intentionally size to parent; still avoid zero-height until load.

---

### Don’t clip horizontal lists with page padding only

`horizontal-list-padding` · Noticeable · Effort: S  
Fix in one phrase: horizontal lists should pad first/last items (or use full-bleed list + item padding) so content isn’t symmetrically clipped and can peek.

**Detect:** `ListView.separated` horizontal inside a padded parent with no item edge padding strategy.

**Hunt:** grep `scrollDirection: Axis.horizontal`.

**Why:** users can’t tell there’s more to scroll; first/last cards look wrongly cropped.

**Gotchas:** if a fade/shader or scrollbar already signals more content, severity drops.

---

## Feedback

### Haptics on meaningful moments

`haptics-on-actions` · Noticeable · Effort: S  
Fix in one phrase: success/error/selection/destructive actions get appropriate haptics; wrap `canVibrate` checks in one helper.

**Detect:** purchase/complete/delete/like/toggle handlers with zero `HapticFeedback` / haptic package calls anywhere in the path.

**Hunt:** grep `onPressed|onTap` for high-value actions; grep `HapticFeedback` project-wide — if almost unused, flag primary flows.

**Why:** silent success/failure feels cheaper; over-haptic feels cartoonish — match intensity to stakes.

**Gotchas:** never haptic on every pointer move. Respect platform settings / `canVibrate`. Web may no-op — still call helper safely.

---

### Don’t stack the same snackbar

`snackbar-dedupe` · Noticeable · Effort: S  
Fix in one phrase: if the same message is already visible, animate/shake it instead of queueing duplicates.

**Detect:** rapid `ScaffoldMessenger.showSnackBar` from repeated taps without removing current or checking identity.

**Hunt:** grep `showSnackBar`.

**Why:** triple snackbars on double-tap feel spammy and block the UI.

**Gotchas:** different messages may still queue with clear policy.

---

### Feature states are complete

`async-ui-states` · Critical–Noticeable · Effort: M  
Fix in one phrase: every async surface has loading, empty, error (+ retry when recoverable), and success — not only the happy path widget.

**Detect:** screens that `FutureBuilder`/`watch` data but only build the data branch; missing empty list copy; errors swallowed.

**Hunt:** grep `FutureBuilder|StreamBuilder` and Riverpod/`AsyncValue` usage; check `.when` / connectionState coverage.

**Why:** production features fail offline and on empty accounts; happy-path-only is a demo, not a product (Bizzotto-style completeness).

**Gotchas:** pure static settings pages need no loading state.

---

## Motion

### Exit faster than enter

`enter-slow-exit-fast` · Subtle · Effort: S  
Fix in one phrase: reverse transitions / dismissals use shorter duration than entrances; don’t share one symmetric controller blindly.

**Detect:** custom `AnimationController` or `showGeneralDialog` routes where forward and reverse use the same long duration (>300ms) for dismiss.

**Hunt:** grep `duration:` near `AnimationController|PageRouteBuilder|showModalBottomSheet`.

**Why:** users already decided to leave; lag on exit feels like jank.

**Gotchas:** shared element / hero flights may need symmetry. Honor `reduceMotion`.

---

### Springs for interactive motion

`spring-interactive` · Subtle · Effort: M  
Fix in one phrase: pressable UI and drag-end settle use springs (or `SpringDescription`) rather than only linear ease for finger-driven motion.

**Detect:** gesture-driven cards using only `Curves.linear` / fixed ease with no spring; vs opacity fades which may stay eased.

**Hunt:** grep `Curves.linear` near gesture code; check for `SpringSimulation` / packages used in polish widgets.

**Why:** linear motion feels robotic on press/drag (Ethiel / iOS-adjacent craft).

**Gotchas:** don’t spring everything — large page routes can stay platform defaults.

---

## Platform / product chrome

### Real screen names in analytics

`analytics-screen-names` · Noticeable · Effort: M  
Fix in one phrase: log human screen names; disable useless default FlutterViewController/MainActivity-only noise if that’s all you have.

**Detect:** analytics only automatic route observer missing names; or no screen logging at all in a multi-screen app that already has analytics SDK.

**Hunt:** grep `FirebaseAnalytics|logScreenView|Observer|RouteAware|analytics`.

**Why:** product decisions need funnels; “MainActivity” is worthless.

**Gotchas:** don’t invent a full analytics stack if the app has none — flag as opportunity, lower severity.

---

### Adaptive pickers / sheets when claiming native feel

`adaptive-date-picker-sheet` · Subtle–Noticeable · Effort: S  
Fix in one phrase: use platform-adaptive date pickers and modern sheet patterns when the rest of the app is adaptive.

**Detect:** `showDatePicker` only on iOS-heavy apps; outdated sheet configs ignoring `showModalBottomSheet` scroll-control / `Cupertino` alternatives inconsistently.

**Hunt:** grep `showDatePicker|showModalBottomSheet|CupertinoDatePicker`.

**Why:** Material dialogs on a Cupertino-styled iOS app break immersion (RydMike / adaptive discipline).

**Gotchas:** fully custom brand pickers are fine if intentional.

---

### Android back and iOS swipe must close overlays

`back-closes-overlay` · Critical · Effort: S–M  
Fix in one phrase: modal routes and custom barriers participate in the back dispatcher / pop scope.

**Detect:** custom dialogs/`Stack` overlays that ignore `PopScope`/`WillPopScope`/route pops; Android back leaves a stuck scrim.

**Hunt:** grep `Stack` full-screen barriers; grep `PopScope|WillPopScope|barrierDismissible`.

**Why:** stuck modals are a store-review and rage-quit moment.

**Gotchas:** intentional hard-blockers (forced update) must explain why back is disabled.

---

## Optional opportunities (usually Subtle)

### In-app changelog after update

`in-app-changelog` · Subtle · Effort: L  
Fix in one phrase: show what changed when version bumps so work gets seen.

**Detect:** no changelog / what’s-new surface tied to package version.

**Hunt:** grep `changelog|whats_new|last_seen_version|package_info`.

**Why:** silent updates train users to ignore your product.

**Gotchas:** opportunity, not a defect — never block release solely on this.

---

### Show app version where support needs it

`show-app-version` · Subtle · Effort: S  
Fix in one phrase: settings/about shows version (+ build) for support screenshots.

**Detect:** no version string in settings/profile/about.

**Hunt:** grep `PackageInfo|version` in settings UI.

**Why:** support tickets without version waste everyone’s time.
