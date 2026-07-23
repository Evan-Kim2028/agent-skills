---
name: flutter-pro-ux-review
description: >
  Production Flutter UX audit: ranked polish findings (dead taps, null text,
  a11y, keyboard, haptics, layout shift, async/offline honesty, motion, empty
  states, destructive confirm, permission priming, RTL, charts/number
  consistency) with optional PLAN.md per pick. Use for Flutter app polish,
  "feels off", release UX pass, /flutter-pro-ux-review, /flutter. Complements
  official Flutter architecture/test skills — does not replace them. Not for
  greenfield layering, RenderFlex-only fixes, React/web craft, or CI setup.
---

# Flutter pro UX review

**Version:** 1.1

**Job:** Find **user-visible** Flutter polish failures with grep-backed evidence.
Do not redesign brand, refactor architecture, or restate framework tutorials.

## Hard stops (other skills own these)

| User ask | Do this instead |
|----------|-----------------|
| Project structure / MVVM / layers | Official **flutter-apply-architecture-best-practices** |
| RenderFlex / unbounded height only | **flutter-fix-layout-issues** |
| Widget/integration tests only | **flutter-add-widget-test** / integration skills |
| React/web density / sticky CSS | **product-ui-craft** / **mobile-product-ux** |
| Full e2e device farm | **quality-check** |

If the message is clearly one of the above, **do not** run a full UX catalog pass.

## Modes

Read the user message; default **`review`**.

| Mode | Do | Stop when |
|------|-----|-----------|
| **`review`** | Hunt → ranked findings | After report; **do not implement** unless asked |
| **`plan`** | Selected finding(s) → `PLAN.md` | Plans written |
| **`fix`** | One plan or one slug | Diff done + re-Detect that rule |

Say the mode in the first line of your reply: `Mode: review | scope: lib/… | budget: 12`.

## Scope & budget (required defaults)

| Knob | Default | Notes |
|------|---------|--------|
| **scope** | User paths, else primary product UI under `lib/` (prefer `features/`, `ui/`, `screens/`, `pages/` over generated/test) | Never require boiling the whole monorepo |
| **budget** | **12** findings (Critical+Noticeable first) | Subtle only if budget remains or user asked `taste` / `strictness: taste` |
| **passes** | See default pass set below | User may name passes: `touch,a11y,forms` |
| **strictness** | `release` | `release` = Critical+Noticeable; `taste` = include Subtle |

**Primary path first:** prefer home, auth, checkout, pay, search, core tabs over settings chrome.

## Decision principles

1. **User cost** — flag taps, trust, and time lost; not style nits without effect  
2. **Primary path first** — core journeys before admin/settings  
3. **Prevent ≤ punish** — block bad input; don’t only error on submit  
4. **Stable layout** — images, numbers, async must not jump under the finger  
5. **Acknowledge intent** — press / success / error get feedback  
6. **Platform expectations** — back, swipe-dismiss, keyboard, status bar  
7. **Honesty under failure** — empty, offline, error, retry  
8. **A11y is polish** — unusable for some users → Critical  
9. **Budget attention** — top N by severity then effort; stop at budget  
10. **One fix, one verify** — no drive-by architecture in `fix` mode  

## Severity (with decision rules)

| Severity | When |
|----------|------|
| **Critical** | Broken primary interaction, trust failure, or blocker for some users (dead primary tap, “null” on primary UI, stuck modal, missing Semantics on primary icon button, no error/retry on primary async) |
| **Noticeable** | Every-session friction on common paths (layout jump, raw phones/dates, weak keyboard flow, missing haptics on primary actions, no bottom inset) |
| **Subtle** | Taste / secondary (exit timing, changelog, list edge fade) — omit under `strictness: release` unless budget allows and user wants taste |

If a rule lists two severities: **Critical on primary path / core widget; else Noticeable** (or Subtle when the rule says so).

| Effort | Meaning |
|--------|---------|
| **S** | Local one-liner / small helper |
| **M** | Cross-widget or shared util |
| **L** | Product surface (analytics, changelog, design-system) |

## Progressive disclosure (load only what you need)

| File | Load when |
|------|-----------|
| `references/surfaces.md` | **Always** in `review` (index + pass order) |
| `references/touch.md` | Pass `touch` |
| `references/data-display.md` | Pass `data` |
| `references/forms-keyboard.md` | Pass `forms` |
| `references/scroll-layout.md` | Pass `scroll` |
| `references/feedback-async.md` | Pass `feedback` |
| `references/a11y.md` | Pass `a11y` (default on) |
| `references/motion.md` | Pass `motion` (default off in `release` unless user asks) |
| `references/platform-chrome.md` | Pass `platform` |
| `references/performance-feel.md` | Pass `perf` (default off; on for `taste` or user asks jank) |
| `references/trust-safety.md` | Pass `trust` (default on — empty states, destructive confirm, permission priming) |
| `references/charts-numbers.md` | Pass `charts` (on when scope has charts/tables/signed numbers) |
| `assets/findings-template.md` | Emitting the report — see `references/example-run.md` for a good-vs-bad worked example |
| `assets/plan-template.md` | `plan` mode |
| `references/vs-official.md` | Only if tempted to refactor architecture |
| `references/experts.md` | **Never** during audit (attribution only) |
| `references/rule-catalog.md` | Legacy monolith — **prefer surface files**; load only if you need one-file search |

### Default passes

- **`strictness: release`:** `touch` → `a11y` → `data` → `forms` → `scroll` → `feedback` → `platform` → `trust` → `charts` (if scope has charts/tables/signed numbers)  
- **`strictness: taste`:** above + `motion` + `perf`  
- Skip `platform` analytics/changelog noise if no analytics SDK and budget is tight.  
- Skip `charts` entirely if scope has no data-viz/numeric surfaces.

## Workflow

### Mode `review`

1. Confirm Flutter app (`pubspec.yaml` with `flutter:`).  
2. Set scope, budget, passes (defaults above).  
3. Read `references/surfaces.md`, then **only** the pass files for this run.  
4. Hunt primary-path files first; record `slug`, severity, effort, `file:line`, evidence, why.  
5. Dedupe (see rules below); sort Critical → Noticeable → Subtle, then effort S → L.  
6. Cap at **budget**.  
7. **Self-validate report** (below).  
8. Emit findings. **Stop.**

### Mode `plan`

1. For each selected ID/slug: use `assets/plan-template.md`.  
2. Prefer existing project helpers; no new state-management library.  
3. One plan per finding.

### Mode `fix`

1. Implement **one** plan or slug.  
2. Small diff; match ThemeData / tokens.  
3. Re-run that rule’s Detect; note residual risk.

## Dedupe rules

- **Anti-clustering:** if one Hunt yields many hits of the same `slug`, report **one** systemic finding — state the count and give 2–3 representative `file:line` samples. Don't spend the findings budget listing every hit.
- **Cross-slug dedupe:** if two different slugs both flag the same widget instance, keep the higher-severity finding and cross-reference the dropped slug in that finding's evidence line (e.g. "also matches `min-touch-target`").

## Report self-validation (before sending)

- [ ] Every finding has existing `file:line` (or honest “project-wide absence” for opportunity rules)  
- [ ] Every `slug` comes from a loaded surface file  
- [ ] Every finding has Evidence + Why  
- [ ] Count ≤ budget  
- [ ] Subtle count is 0 under `release` unless user asked taste  
- [ ] Did not implement in `review` mode  
- [ ] Did not recommend architecture rewrites  

## Out of scope (explicit)

- **Flutter web / desktop chrome** (browser tab titles, OG tags, web-only transitions) unless user opts in with `passes: web`  
- Brand redesign, new design system, package upgrades for their own sake  

## Hand off

| Need | Skill |
|------|--------|
| Layers / feature structure | **flutter-apply-architecture-best-practices** |
| Overflow / constraints | **flutter-fix-layout-issues** |
| Tests for a fixed widget | **flutter-add-widget-test** |
| Flutter work routing | **flutter** hub (if installed) |
| Browser proof (Flutter web) | **browser-verify** / **quality-check** |
