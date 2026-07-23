# Pass: feedback

### Haptics on meaningful moments

`haptics-on-actions` · Noticeable on primary actions · Effort: S  
Fix in one phrase: success/error/selection/destructive actions get appropriate haptics; wrap `canVibrate` in one helper.

**Detect:** purchase/complete/delete/like/toggle handlers with zero `HapticFeedback` / haptic package calls on the path.

**Hunt:** grep high-value `onPressed|onTap`; grep `HapticFeedback` project-wide — if almost unused, flag primary flows only (budget).

**Why:** silent success/failure feels cheaper; over-haptic feels cartoonish.

**Gotchas:** never haptic on every pointer move. Web may no-op — still call helper safely.

---

### Don’t stack the same snackbar

`snackbar-dedupe` · Noticeable · Effort: S  
Fix in one phrase: if the same message is already visible, shake/replace it instead of queueing duplicates.

**Detect:** rapid `ScaffoldMessenger.showSnackBar` from repeated taps without removing current or checking identity.

**Hunt:** grep `showSnackBar`.

**Why:** triple snackbars on double-tap feel spammy.

**Gotchas:** different messages may still queue with a clear policy.

---

### Feature states are complete

`async-ui-states` · Critical on primary async screens; Noticeable on secondary · Effort: M  
Fix in one phrase: every async surface has loading, empty, error (+ retry when recoverable), and success — not only the happy path.

**Detect:** `FutureBuilder`/`AsyncValue`/streams that only build the data branch; missing empty list copy; errors swallowed.

**Hunt:** grep `FutureBuilder|StreamBuilder|AsyncValue|\.when(`; check connectionState / error / empty coverage on primary screens.

**Why:** production features fail offline and on empty accounts; happy-path-only is a demo.

**Gotchas:** pure static settings pages need no loading state.

---

### Offline / connectivity honesty

`offline-honesty` · Critical on primary data screens; Noticeable elsewhere · Effort: M  
Fix in one phrase: when the app depends on network, show offline/failure UI with retry — don’t spin forever or show a blank body.

**Detect:** repositories/HTTP used in UI with no timeout/error empty state; infinite loaders; catch blocks that set nothing.

**Hunt:** grep `http.|Dio|connectivity|InternetAddress|SocketException`; pair with screens that only show `CircularProgressIndicator` without error branch.

**Why:** users blame the app, not the tunnel.

**Gotchas:** fully offline-first apps with local DB may only need sync-error banners — don’t demand a full airplane-mode redesign.

---

### Pull-to-refresh on primary feeds

`pull-to-refresh` · Noticeable on home/feed/list tabs · Effort: S  
Fix in one phrase: primary vertical feeds support pull-to-refresh (or an obvious refresh control).

**Detect:** main feed `ListView`/`CustomScrollView` without `RefreshIndicator` (or platform equivalent) and no visible refresh action.

**Hunt:** home/feed/inbox routes; grep `RefreshIndicator`.

**Why:** stale content with no recovery path feels broken.

**Gotchas:** chat timelines and paginated “load more” UIs may use different refresh patterns; finite static lists don’t need PTR.
