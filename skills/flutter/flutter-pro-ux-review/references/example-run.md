# Worked example: good vs bad finding

## Good finding

1. `Critical · S` `destructive-confirm-or-undo` — `lib/features/wallet/watchlist_tile.dart:88`  
   Evidence: `onTap: () => ref.read(watchlistProvider.notifier).remove(symbol)` fires directly from a swipe-row trailing icon — no `showDialog`, no undo `SnackBar` anywhere in the handler or the widget above it.  
   Why: a mis-swipe permanently deletes a tracked symbol with zero recovery path; the user has to re-search and re-add it, and has no way to know it was even removed until they notice it's gone.

**Why this is good:** exact `file:line`, a literal grep-backed pattern, states what was actually checked (both confirm and undo paths, and confirmed neither exists), and the "why" names the concrete user cost (data loss, no recovery, silent) rather than a general appeal to "best practice."

## Bad finding (rejected)

- `Subtle · S` `?` — "Consider using more consistent spacing in the settings list, it feels a bit inconsistent in places."

**Why this is rejected:**
- No `file:line` — can't be verified or fixed.
- No slug — doesn't map to a loaded surface rule.
- No grep-backed Hunt pattern — "feels a bit inconsistent" isn't detectable, it's a vibe.
- No user cost — spacing variance on a secondary settings screen costs the user nothing measurable; this is a style nit, not a UX failure. Under `strictness: release` it wouldn't clear the bar even if it had evidence.

Don't submit findings like the second one. If a rule can't produce a `file:line` and a stated user cost, it doesn't belong in the report — note it under "Skipped / out of budget" instead, or drop it.
