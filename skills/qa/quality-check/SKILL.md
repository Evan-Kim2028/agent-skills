---
name: quality-check
description: >
  QA routing hub for verification — TDD, diagnose, browser/visual proof,
  web-quality, doubt-driven review, check-work, PR review, ship checklists,
  data-semantic-quality. Use when the QA path is unclear, when shipping or
  fixing consumer-facing regressions (search, filters, sticky chrome, URL/
  debounce), or on "QA", "verify", "prove it", "e2e", "flaky", "don't ship bugs".
  Prefer specialists directly when already clear (only tdd, only browser-verify).
  Prefer frontend-design when the work is still building/redesigning product UI
  (hand off here for proof). Do not use for pure product design exploration,
  marketing, issue filing alone (qa), or lakehouse design without verification
  intent (data).
metadata:
  short-description: "QA hub — route TDD, diagnose, browser verify, review, ship"
---

# Quality-check — QA routing hub

**Route first → open the specialist → do the work.** This file is the router
plus a few load-bearing rules. Deep workflows live in specialists.

When a specialist clearly fits, load it directly — skip re-reading this hub.

## Portability

| Need | Where |
|------|--------|
| Race matrix (debounce × URL) | [`references/interaction-races.md`](references/interaction-races.md) |
| Companion install + **credit** | [`references/companion-install.md`](references/companion-install.md) |
| Short source table | [`references/sources.md`](references/sources.md) |
| One-shot copy install | [`scripts/install-companions.sh`](scripts/install-companions.sh) |

- **Hub + browser-verify / web-quality / frontend-design / data-semantic-quality** ship in [Evan-Kim2028/agent-skills](https://github.com/Evan-Kim2028/agent-skills) — clone is enough for FE proof paths.
- **Optional companions** (tdd, diagnose, doubt-driven, ship, …) may come from Matt Pocock / Addy Osmani packs — see companion-install. Grok may already bundle `check-work`.
- Missing specialist → **If specialist missing** (do not invent skill files).

## How to use this hub

1. Match the task in the **routing table** (one primary skill).  
2. **Open that specialist’s `SKILL.md` now** before coding or claiming done.  
3. If the skill is missing, use **If specialist missing** fallbacks below.  
4. For multi-step work, follow the matching **pipeline** (A–C).  
5. Stop only when **Done criteria** pass.

Load at most **1–3** specialists. Do not spray-load the whole table.

## Routing table

One **default** name per row. Aliases only if that name is not installed.

| Your task | Default skill | Alias / note |
|-----------|---------------|--------------|
| Failing tests first / red-green | **tdd** | `test-driven-development` |
| Prove bug before fix | **tdd** | Prove-It: fail first |
| Hard bug / flaky / unclear root cause | **diagnose** | then `debugging-and-error-recovery` |
| Non-trivial invariant / “is this safe?” | **doubt-driven-development** | before clever sync/fix |
| Browser proof (Playwright e2e / snapshots / axe / DevTools MCP) | **browser-verify** | was visual-verify + browser-testing-with-devtools |
| A11y, focus, forms, touch | **web-quality** | ship-quality pass |
| Self-verify this session | **check-work** | after implement |
| PR / branch review | **review** | `code-review-and-quality` |
| Until named suite green | **implement-until-green** | CI loop |
| Pre-launch go/no-go | **shipping-and-launch** | `ship` if that’s what’s installed |
| Full feature plan→PR | **ship-feature** | delivery loop |
| File bugs conversationally | **qa** | not a fix path |
| Auth / secrets / threat model | **security-and-hardening** | security-sensitive |
| Row-truth / quality flags | **data-semantic-quality** | pipelines |
| UI still being built/redesigned (not proof yet) | **frontend-design** | then return here to prove |
| A11y checklist during ship (not full redesign) | **web-quality** | after build |
| Unclear multi-step QA | **start here** | pipeline A or B |

## Pipelines

### A — Consumer UI (search, filters, trade, chat, sticky)

1. **tdd** — race-aware tests if URL/debounce/local sync  
   → if debounce/URL: read [`references/interaction-races.md`](references/interaction-races.md)  
2. Implement  
3. **doubt-driven-development** if any sync invariant  
4. **browser-verify** (type/click ~2s; no input flicker)  
5. **web-quality** if forms/focus/touch  
6. **check-work** before “done”  

Do **not** claim done after unit green alone on consumer typing/sticky surfaces.

### B — Production bug / regression

1. **diagnose** — reproduce, minimize  
2. **tdd** — test that fails on old behavior  
3. Fix root cause  
4. Browser/visual proof if user-visible  
5. Tag defect class: `state-sync` | `mobile-chrome` | `search-language` | `deploy-trust` | `label-data`  

### C — Ship feature

1. **tdd** while building  
2. **frontend-design** if UI  
3. **check-work** → **review** → **shipping-and-launch** if production  

### D — Human QA session (file only)

1. **qa** — clarify and file issues  
2. **triage** / **to-issues** if already planned  

```
bug → diagnose → tdd → fix → [doubt] → browser proof → check-work
feature → tdd → [frontend-design] → check-work → review → ship
```

## Shared principles (hub-level only)

### 1. Prove where the user lives

Vitest green ≠ consumer green. Search/filter/sticky/share: open a real browser
before “done.”

**Test:** Would a user typing for two seconds notice flicker, rewind, or empty flash?

### 2. Interaction races

Local input + debounce + URL (or other external) sync → **must read**
[`references/interaction-races.md`](references/interaction-races.md) before
implementing or reviewing. Do not invent dual `useEffect` sync without that matrix.
Row “settle, then extend” is the usual miss.

### 3. One shared primitive

If two features debounce the same URL param pattern, share one hook + one suite.

### 4. Adversarial review ≠ delete safety

If review says “remove this ref,” require: replacement invariant + which race-matrix
row proves it.

### 5. Red before green on regressions

User-facing fix ships a test that **failed on the old code** (journey-shaped when racey).

### 6. Defect classes

Tag escaped bugs; add one automated check that would have blocked the class.

### 7. Minimum proof by risk

| Risk | Minimum proof |
|------|----------------|
| Pure logic | unit / TDD |
| Debounce / URL / local sync | race matrix + 30s browser type |
| Sticky / gesture / density | **browser-verify** multi-viewport |
| Auth / money / PII | **security-and-hardening** + **review** |
| Data truth | **data-semantic-quality** + golden pack |

## If specialist missing

Do not invent a fake skill name. Run the fallback, then note the gap.

| Default skill | Fallback when not installed |
|---------------|----------------------------|
| **tdd** | Write failing test first in project runner; implement; re-run |
| **diagnose** | Reproduce → minimize → one hypothesis → instrument → fix → regression test |
| **browser-verify** | Project Playwright/e2e if any; else headed browser or DevTools MCP: sample UI 2s |
| **check-work** | Diff + build/test + re-read user ask; list gaps |
| **review** | Standards + spec pass on the diff; no drive-by refactors |
| **doubt-driven-development** | Fresh-context “find issues” pass on the invariant only |
| **qa** | `gh issue create` with repro steps; no code paths in body |

## Hard anti-patterns

- Consumer UI ship with only unit tests  
- “Race-proof” after removing lastSynced without race-matrix row 3  
- Fix prod bug with no regression test  
- Using **qa** (file issues) when user asked to **fix**  
- **check-work** alone as proof of no visual flicker  
- Loading >3 specialists for one task  
- Snapshot/assert weaken to silence failures  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Build / redesign product UI (implement path) | **frontend-design** |
| Craft / mobile UX / density polish | **product-design** |
| Marketing narrative | **marketing** |
| Lakehouse / DuckDB / ingest without verify intent | **data** |
| Spec before code | **spec** / **spec-driven-development** |
| Images | **imagine** |
| Design docs / PR plans | bundled **design** (docs) |

### Build vs prove (with frontend-design)

| Phase | Hub |
|-------|-----|
| Build / redesign product UI | **frontend-design** |
| Prove / regression / e2e / ship checklist | **quality-check** (this hub) |
| Full feature | **frontend-design** while implementing → **this hub** before done |

Attribution / install: [`references/companion-install.md`](references/companion-install.md),
[`references/sources.md`](references/sources.md).

## Done criteria

- [ ] Routed to default specialist(s) and **opened** their SKILL.md (or used fallback)  
- [ ] User-visible failure has an automated oracle  
- [ ] Debounce/URL sync: race matrix applied (L3 read)  
- [ ] Browser/visual proof when typing/layout/gesture risk is non-trivial  
- [ ] Regression: defect class tagged  
- [ ] Repo lint/typecheck/tests green as required  
- [ ] Merge-bound: **check-work** or **review** done  
