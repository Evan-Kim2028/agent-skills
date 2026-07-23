# Pass: trust-safety

### Empty states are designed, not blank

`empty-state-designed` · Noticeable (Critical if primary onboarding/home list) · Effort: S  
Fix in one phrase: lists/grids backed by dynamic data render a designed empty state (icon + copy + action) — never a blank body or `SizedBox.shrink()`.

**Detect:** `isEmpty` branches that return `SizedBox.shrink()` / empty `Container()` / nothing; list/grid builders with no empty branch at all.

**Hunt:** grep `isEmpty` near list/grid builders; grep `SizedBox.shrink\(\)` for a bare-empty return.

**Why:** a blank screen reads as broken or loading forever; users don’t know if there’s no data or an error.

**Gotchas:** intentionally-invisible layers (e.g. a badge overlay) and sections that collapse by design (e.g. an optional promo banner) are not empty states — don’t flag those.

---

### Destructive actions confirm or offer undo

`destructive-confirm-or-undo` · Critical · Effort: S  
Fix in one phrase: delete/remove/clear actions get a confirm dialog **or** an undo snackbar; irreversible actions (account delete) require confirm.

**Detect:** `onTap`/`onPressed` calling delete/remove/clear repository or state methods with neither `showDialog` nor an undo-capable `SnackBar` nearby.

**Hunt:** grep `delete|remove|clear` on `onTap:`/`onPressed:` handlers; check for `showDialog` or `SnackBar` with an undo action in the same handler.

**Why:** a stray tap that permanently destroys data is the fastest way to lose trust.

**Gotchas:** item add/remove inside an edit sheet with an explicit save step is fine (the sheet itself is the undo). `Dismissible` with a built-in undo snackbar already satisfies this — don’t double-flag.

---

### Prime before requesting permissions

`permission-priming` · Critical · Effort: S–M  
Fix in one phrase: runtime permission requests are preceded by an in-app rationale ("priming") screen and triggered by user intent — never fired from `initState`/`main`.

**Detect:** `.request()` / `permission_handler` calls inside `initState`, `main`, or first-frame callbacks with no preceding rationale UI.

**Hunt:** grep `\.request\(\)|permission_handler` and check the call site — flag `initState`, `main`, `addPostFrameCallback` at launch.

**Why:** a system permission dialog on cold launch, with no context, gets reflexively denied and the user rarely revisits it.

**Gotchas:** re-requesting after the user already saw the rationale once is fine. Requesting camera permission when the user taps "Scan" IS intent-triggered — that's correct, not a smell. The smell is launch-time or navigation-time requests with no explanation.
