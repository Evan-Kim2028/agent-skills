# Interaction races — local input × debounce × external state

Load when implementing or reviewing search boxes, filter chips, URL-synced
forms, or any "type locally, publish later" pattern.

## The failure mode

Two effects:

1. **External → local:** when URL (or server state) changes, set input  
2. **Local → external:** when debounce settles, write URL  

If (1) decides "external changed" by comparing URL to **debounced** value,
then after a settled push the user keeps typing:

- debounce advances to the new string  
- URL still holds the previous string for a tick  
- (1) rewinds the input → flicker / oscillation  

**False invariant:** "own push always lands with `q === debouncedQuery`."  
That is only true *after* navigation commits, not during the lag window.

## Preferred pattern

Track `lastSynced` (ref) of the last value **you** wrote or **applied from
outside**.

```text
on external q change:
  if q !== lastSynced:
    lastSynced = q
    setLocal(q)

on debounce settle (debounced === local && debounced !== q):
  lastSynced = debounced
  publish(debounced)
```

On reset/preset: set `lastSynced` and local immediately, then publish.

## Required tests (race matrix)

| # | Action | Assert |
|---|--------|--------|
| 1 | Type full query without advancing timers past debounce | input has full string; URL not partial-written |
| 2 | Advance past debounce | URL equals full string |
| 3 | **After settle, extend the query** | input never rewinds to pre-extend value; URL updates to extended |
| 4 | Clear / reset mid-debounce | input empty; URL empty after settle (no resurrection) |
| 5 | Preset mid-debounce | same as 4 for preset's q |
| 6 | Mount with `?q=foo` | input is `foo` once; no oscillation over 1–2s |
| 7 | Browser back to prior q | input follows; no loop |

Row **3** is the one most agent-written suites miss.

## Browser canary (30–60s)

After unit green, for consumer search/filter surfaces:

1. Open the real URL (with optional `?q=` seed)  
2. Focus the product search (not a header search if distinct)  
3. Type or extend the query  
4. Sample `input.value` + `location.search` every 100–200ms for 2s  
5. Fail if the input value ever regresses to a prior shorter/stale string while the user is not deleting  

## Anti-patterns

- Comparing external state to `debounced` to detect "external change"  
- Removing `lastSynced` / `lastPushed` because reset/preset was buggy — fix the
  writers instead  
- Only testing "type all at once then one timer advance"  
- Duplicating the dual-effect pattern in a second feature without shared tests  
