---
name: quality
description: >
  QA routing hub for quality work — picks the right specialist for unit/TDD,
  hard-bug diagnosis, browser/e2e/visual proof, a11y/web quality, adversarial
  doubt review, self-verify, PR review, ship checklists, conversational bug
  filing, data semantic quality, and CI-until-green. Prefer this hub when the
  right QA skill is unclear, when shipping consumer-facing UI, or when fixing
  regressions (search, filters, sticky chrome, state sync). Use on "QA",
  "quality", "verify", "regression", "smoke", "e2e", "flaky", "prove it",
  "check work", or "don't ship bugs". Do not use for pure product design
  exploration (frontend-design), marketing copy (marketing), or lakehouse
  design without quality intent (data).
metadata:
  short-description: "QA hub — route TDD, diagnose, browser verify, review, ship"
---

# Quality — QA routing hub

Single entry point for **quality / QA / verification**. **Route first**, then
load the specialist. This hub carries shared principles (especially
consumer-facing interaction races) that every specialist assumes.

When a specialist clearly fits, load it directly — skip re-reading this whole
file if you already know the lane.

**Progressive disclosure:** this file is the router + shared rules. Deep
workflows live in specialist skills. Race-matrix detail:
[`references/interaction-races.md`](references/interaction-races.md).

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Write failing tests first / red-green-refactor | **tdd** or **test-driven-development** | New behavior or bug with a clear oracle |
| Prove a bug exists before fixing (Prove-It) | **test** (if installed) or **tdd** | User reports broken behavior |
| Hard bug, flaky path, "something is wrong" | **diagnose** (+ **debugging-and-error-recovery**) | Reproduce → minimize → hypothesise → instrument |
| Non-trivial decision / racey invariant / "is this safe?" | **doubt-driven-development** | Before committing a clever sync/fix |
| Live browser: DOM, console, network, paint | **browser-testing-with-devtools** | Runtime debug with Chrome DevTools MCP |
| Playwright e2e, screenshots, axe, visual proof | **visual-verify** | Sticky/mobile chrome, share flows, pre-claim-done |
| A11y, focus, forms, touch targets, motion | **web-quality** | Audit or ship-quality interaction pass |
| Self-verify this session's work | **check-work** | After implementation, before "done" |
| PR / branch review (standards + spec) | **review** or **code-review-and-quality** | Before merge |
| Keep iterating until named suite is green | **implement-until-green** | CI or local test command must pass |
| Pre-launch / go-no-go checklist | **shipping-and-launch** or **ship** | Production readiness |
| End-to-end feature workflow (plan→ship) | **ship-feature** | Full delivery loop |
| Conversational bug report → GitHub issues | **qa** | User is filing issues, not implementing |
| Auth, input, secrets, threat model | **security-and-hardening** | Security-sensitive change |
| Semantic data correctness (row truth, flags) | **data-semantic-quality** | Pipeline quality flags, golden packs |
| FE craft that *is* quality (states, density) | **frontend-design** → craft/a11y specialists | UI quality is design + verify |
| Unclear / multi-step quality task | **start here**, then pipeline below | Default |

### Multi-step default pipelines

#### A. Consumer-facing UI change (search, filters, trade, chat, sticky chrome)

1. **tdd** / race-aware unit tests (local state + URL + debounce — see principles)  
2. Implement  
3. **doubt-driven-development** on any sync/invariant (do not "simplify away" refs without a stronger invariant)  
4. **browser-testing-with-devtools** or **visual-verify** — real viewport, type/click for ~2s  
5. **web-quality** if forms/focus/touch  
6. **check-work** before claiming done  

#### B. Production bug report

1. **diagnose** — reproduce, minimize  
2. **tdd** — failing test that would have caught it (unit *and* journey if racey)  
3. Fix the root cause (not a symptom patch)  
4. **visual-verify** / browser proof if user-visible  
5. Tag defect class in the PR/issue (`state-sync`, `mobile-chrome`, `search-language`, …)  

#### C. "Ship this feature"

1. **tdd** while building  
2. **frontend-design** hub if UI  
3. **check-work**  
4. **review** on the PR  
5. **shipping-and-launch** / **ship** if production  

#### D. Conversational QA session (human finds bugs)

1. **qa** — clarify, file durable issues  
2. Optionally **triage** / **to-issues** if already planned  

```
bug / regression
    → diagnose (reproduce)
    → tdd (failing oracle)
    → fix
    → doubt-driven if invariant was subtle
    → visual-verify | browser-testing-with-devtools
    → check-work
```

```
feature ship
    → tdd while building
    → frontend-design specialists as needed
    → check-work
    → review
    → shipping-and-launch
```

## Shared principles (every quality path)

### 1. Prove in the environment the user uses

Vitest green ≠ consumer green. For search boxes, filters, sticky bars, sheets,
and share flows, **open a real browser** (Playwright / DevTools MCP) before
"done." Unit tests with fake timers miss multi-tick races.

**Test:** Would a user typing for two seconds notice a flicker, rewind, or empty flash?

### 2. Interaction races need a race matrix

Any local-input + debounce + URL (or other external) sync must cover:

| Case | Assert |
|------|--------|
| Type continuously | no dropped characters |
| Settle, then extend | input never rewinds to previous URL value |
| Clear mid-debounce | URL does not resurrect stale text |
| Preset / reset mid-debounce | same |
| Mount with `?q=` set | input matches URL once, stable |
| Back / forward | input follows history, no loop |

Detail: [`references/interaction-races.md`](references/interaction-races.md).

### 3. Prefer one shared primitive over N hand-rolled syncs

If Explore and Scanner both debounce URL params, **one hook + one test suite**.
Duplicated dual-`useEffect` sync is how "correct" and "broken" variants coexist.

### 4. Adversarial review must not delete safety without a stronger invariant

When doubt/review says "remove this ref," require: *what invariant replaces it,
and which race matrix row proves it?* A confident "provably race-proof" comment
is not proof.

### 5. Red before green for regressions

Every user-facing regression fix ships a test that **failed on the old code**.
Prefer the smallest failing test that encodes the user journey (extend-after-settle
over "renders without crash").

### 6. Defect classes beat one-off hotfixes

Tag and re-use: `state-sync`, `mobile-chrome`, `search-language`, `deploy-trust`,
`label-data`. Escaped defect → one automated check that would have blocked it
(unit race, Playwright smoke, or deploy canary — as appropriate).

### 7. Progressive verification depth

| Risk | Minimum proof |
|------|----------------|
| Pure logic | unit / TDD |
| State sync / debounce / URL | race-matrix unit + 30s browser type |
| Sticky / gesture / density | **visual-verify** multi-viewport |
| Auth / money / PII | **security-and-hardening** + review |
| Data truth | **data-semantic-quality** + golden pack |

### 8. Checklists without enforcement are suggestions

Prefer runtime guards and CI gates over "remember to open the browser." Where
you only have a checklist, put it in this hub's done criteria and in PR templates.

## Hard anti-patterns (hub-level)

- Shipping consumer UI with only unit tests and no browser touch  
- Claiming "race-proof" after removing a last-pushed/last-synced ref without a race-matrix test  
- Fixing production bugs without a regression test  
- Using **qa** (issue filing) when the user asked you to **fix** the bug  
- Using **check-work** as a substitute for domain proof (it won't catch visual flicker alone)  
- Spray-and-pray skill loading (read the table; load 1–3 specialists, not ten)  
- Updating snapshots / weakening asserts to silence failures  
- "Works on desktop" only for mobile-critical chrome  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Pure UI craft / tokens / mockups | **frontend-design** |
| Marketing narrative | **marketing** |
| Lakehouse / DuckDB / ingest design | **data** |
| Spec before any code | **spec** / **spec-driven-development** |
| Image generation | **imagine** |
| Architecture design docs | bundled **design** (docs), not QA |

## Source attribution

| Skill | Primary sources (attribution) |
|-------|-------------------------------|
| **visual-verify** | Playwright; webapp-testing skill lineage |
| **browser-testing-with-devtools** | Chrome DevTools MCP / live-browser practice |
| **web-quality** | Vercel Web Interface Guidelines; WCAG |
| **tdd** / **test-driven-development** | Classic TDD; Prove-It for bugs |
| **diagnose** | Reproduce-minimize-instrument loops |
| **doubt-driven-development** | Fresh-context adversarial review |
| **check-work** | Session verifier subagent pattern |
| **data-semantic-quality** | Write-time quality attributes; golden packs |
| **This hub** | Synthesis for routing + Silph-style consumer race lessons (Evan-Kim2028/agent-skills) |

External packs (optional install, not required by this hub): community QA skill packs
(e.g. petrkindlmann/qa-skills Playwright/strategy skills) — use as references, not as a
second competing router. **Prefer this hub** for progressive disclosure; pull one
external specialist only when a gap is clear.

## Done criteria (any routed quality task)

- [ ] Correct specialist(s) loaded (or deliberate general path)  
- [ ] Failure mode has an automated oracle when user-visible  
- [ ] Race matrix covered if debounce/URL/local sync was touched  
- [ ] Browser or visual proof when layout/gesture/typing risk is non-trivial  
- [ ] Defect class tagged on regression fixes  
- [ ] Lint/typecheck/tests per repo norms  
- [ ] **check-work** or **review** when the change is merge-bound  
