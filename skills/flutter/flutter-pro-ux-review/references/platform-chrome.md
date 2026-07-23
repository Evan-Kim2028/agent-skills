# Pass: platform

### Real screen names in analytics

`analytics-screen-names` · Noticeable if analytics SDK present · Effort: M  
Fix in one phrase: log human screen names; avoid MainActivity/FlutterViewController-only noise.

**Detect:** analytics SDK present but routes lack names; or only automatic native screen noise.

**Hunt:** grep `FirebaseAnalytics|logScreenView|Observer|RouteAware|analytics`.

**Why:** product decisions need funnels.

**Gotchas:** if the app has no analytics at all, skip or Subtle opportunity only — don’t invent a stack.

---

### Adaptive pickers / sheets when claiming native feel

`adaptive-date-picker-sheet` · Noticeable if app is Cupertino-styled on iOS; Subtle otherwise · Effort: S  
Fix in one phrase: use platform-adaptive date pickers/sheets when the rest of the app is adaptive.

**Detect:** Material-only `showDatePicker` on iOS-heavy Cupertino apps; inconsistent sheet patterns.

**Hunt:** grep `showDatePicker|showModalBottomSheet|CupertinoDatePicker`.

**Why:** wrong platform chrome breaks immersion.

**Gotchas:** fully custom brand pickers are fine if intentional.

---

### Android back and iOS swipe must close overlays

`back-closes-overlay` · Critical · Effort: S–M  
Fix in one phrase: modal routes and custom barriers participate in the back dispatcher / pop scope.

**Detect:** custom dialogs/`Stack` overlays that ignore `PopScope`/`WillPopScope`/route pops; Android back leaves a stuck scrim.

**Hunt:** grep full-screen barriers; grep `PopScope|WillPopScope|barrierDismissible`.

**Why:** stuck modals are rage-quit moments.

**Gotchas:** forced-update blockers must explain why back is disabled.

---

### Bottom nav reselect scrolls to top

`bottom-nav-reselect` · Noticeable · Effort: S  
Fix in one phrase: tapping the active tab again scrolls that tab’s primary list to top (platform expectation).

**Detect:** `BottomNavigationBar` / `NavigationBar` / indexed stack with no re-tap scroll-to-top behavior.

**Hunt:** grep bottom nav / `currentIndex` handlers; check for scroll controller jump on reselect.

**Why:** users rely on re-tap to recover position in long feeds.

**Gotchas:** tabs without scrollables don’t need it.

---

### Status bar tap scrolls to top (iOS expectation)

`statusbar-tap-scroll` · Subtle–Noticeable on iOS-primary apps · Effort: M  
Fix in one phrase: primary scroll views participate in status-bar tap → scroll to top where appropriate.

**Detect:** large iOS-oriented feeds with no `PrimaryScrollController` / scroll-to-top wiring.

**Hunt:** home feed scaffolds; check primary scroll controller usage.

**Why:** iOS users expect status-bar tap to jump up.

**Gotchas:** Android behavior differs; don’t break Android-only apps for this.

---

### In-app changelog after update

`in-app-changelog` · Subtle · Effort: L  
Fix in one phrase: show what changed when version bumps.

**Detect:** no changelog / what’s-new tied to package version.

**Hunt:** grep `changelog|whats_new|last_seen_version|package_info`.

**Why:** silent updates train users to ignore your product.

**Gotchas:** opportunity, not a release blocker.

---

### Show app version where support needs it

`show-app-version` · Subtle · Effort: S  
Fix in one phrase: settings/about shows version (+ build).

**Detect:** no version string in settings/profile/about.

**Hunt:** grep `PackageInfo|version` in settings UI.

**Why:** support tickets without version waste time.

---

### Layouts mirror correctly in RTL

`rtl-directional-layout` · Noticeable (Critical if primary nav/back breaks) · Effort: S–M  
Fix in one phrase: use directional/start-end APIs (`EdgeInsetsDirectional`, `AlignmentDirectional`) instead of left/right; `Icons.arrow_back` auto-mirrors but custom arrow/chevron assets don't.

**Detect:** `EdgeInsets.only(left:` / `Alignment.centerLeft` / hardcoded left-right positioning on widgets that should flip in RTL locales; custom arrow/chevron image assets used without a mirroring check.

**Hunt:** grep `EdgeInsets.only\(left:|EdgeInsets.only\(right:|Alignment.centerLeft|Alignment.centerRight`; grep custom arrow/chevron asset paths and check for `Directionality`/`Transform.flip` handling.

**Why:** in RTL locales a left-anchored back chevron or badge sits on the wrong side, breaking the reading flow and looking untranslated.

**Gotchas:** charts, numbers, and code/URL fields are legitimately LTR everywhere — don't flag those for staying left-to-right.

---

### Support predictive back on Android 14+

`predictive-back` · Noticeable · Effort: S  
Fix in one phrase: primary routes use `PopScope` with `canPop` wired correctly, and the manifest enables `enableOnBackInvokedCallback` so the system predictive-back gesture works.

**Detect:** `WillPopScope` (deprecated) or `PopScope` with `canPop: false` and no `onPopInvoked`/`onPopInvokedWithResult` handling; missing `android:enableOnBackInvokedCallback="true"` in `AndroidManifest.xml`.

**Hunt:** grep `PopScope\(|WillPopScope\(` and check `canPop`/callback wiring; grep `enableOnBackInvokedCallback` in the manifest.

**Why:** without opt-in, Android 14+ users lose the predictive back preview animation and the app feels behind platform conventions.

**Gotchas:** apps intentionally blocking back (forced update, in-progress payment) should still explain why, per `back-closes-overlay`.

---

### State restoration on process death

`state-restoration` · Noticeable · Effort: M  
Fix in one phrase: forms use `restorationId`/`RestorationMixin`, long scroll views use `PageStorageKey`, and deep links restore to the intended screen — not just the app root.

**Detect:** multi-step forms or long lists with no `restorationId`/`PageStorageKey`; deep-link handling that always lands on home after a cold relaunch instead of the linked screen.

**Hunt:** grep `restorationId|RestorationMixin|PageStorageKey` presence on primary forms/scroll views; check deep-link route handling for state recovery.

**Why:** Android can kill backgrounded apps at any time; losing form progress or scroll position on return feels like data loss.

**Gotchas:** short single-screen flows with nothing to lose don't need this; focus on multi-step forms and long feeds.
