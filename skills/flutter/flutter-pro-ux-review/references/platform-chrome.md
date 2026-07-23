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
