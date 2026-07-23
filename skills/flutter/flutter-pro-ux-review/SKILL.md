---
name: flutter-pro-ux-review
description: >
  Production Flutter UX/UI audit — find user-felt polish bugs (dead tap zones,
  layout shift, "null" on screen, missing haptics, keyboard dead-ends, raw
  dates/phones, exit-slower-than-enter motion) with ranked findings and
  optional per-finding PLAN.md. Complements official Flutter skills (architecture,
  layers, tests, routing) which teach how to build; this finds how the shipped
  product feels broken. Use when reviewing a Flutter app for polish, "feels off",
  UX tip pass, design review before release, /flutter-pro-ux-review, or when
  official Flutter skills already structured the code but micro-UX is missing.
  Prefer flutter-apply-architecture-best-practices for layering; prefer
  flutter-fix-layout-issues for RenderFlex overflows only; prefer product-ui-craft
  for generic web density. Not for greenfield architecture, package setup, or CI.
---

# Flutter pro UX review

**Job:** Audit a Flutter codebase for **user-visible production polish failures**
and emit ranked, grep-backed findings. Optionally turn selected findings into
small implementation plans. Do **not** redesign brand, refactor architecture,
or restate framework guidelines.

Official Flutter / Dart skills answer *how to structure and write Flutter*.
This skill answers *what still makes the app feel amateur on a real device*.

## Sources (attribution)

Original synthesis for agents. Rule themes distilled from public Flutter craft
practice (not a dump of any single site or skill repo):

| Personality | Public signal | What we take for agents |
|-------------|---------------|-------------------------|
| **Kamran Bekirov** | flutterpro.design, @kamranbekirovyz | Atomic Detect/Hunt/Why/Gotchas; dead taps, null, haptics, human formatting, scroll/safe-area |
| **Andrea Bizzotto** | codewithandrea, @biz84 | Production feature completeness: loading/empty/error/retry, form validation paths |
| **Mitch Koko** | @createdbykoko | Visual cleanliness, practical widget-level tips, theming hygiene |
| **Roaa Khaddam** | @roaakdm | Animation craft — intentional motion, not decoration spam |
| **Ethiel Adisso** | @enthusiastDev | Spring physics, sheet/blur polish, Apple-adjacent feel in Flutter |
| **Luke Pighetti** | @luke_pighetti | Prod gotchas (e.g. keyboard not dismissing on outside tap) |
| **Filip Hráček** | Flutter “little things” design-dev | Designer-developer discipline: spacing, hierarchy, restraint |
| **Elvira Leveque** | micro-interactions talks | Feedback loops: press, success, transition micro-moments |
| **Mike Rydstrom** | RydMike / adaptive theming | Platform-adaptive pickers, Material/Cupertino care |
| **Majid Hajian** | @mhadaily | Production Flutter engineering taste at scale |

See `references/experts.md` and `references/vs-official.md`. Full hunt recipes:
`references/rule-catalog.md`.

## When to load

- “Review this Flutter app for UX / polish / release readiness”
- “Feels off” / dead buttons / layout jumps / snackbar spam
- After architecture skills landed structure but product still rough
- Pre-store-submit micro-pass
- User runs `/flutter-pro-ux-review`

## When **not** to load

- Greenfield project structure → official **flutter-apply-architecture-best-practices**
- Widget/integration tests only → **flutter-add-widget-test** / integration skills
- Pure RenderFlex / unbounded height → **flutter-fix-layout-issues**
- Web React product craft → **product-ui-craft** / **web-quality**
- Full e2e proof on device farm → project QA / **quality-check** path

## Workflow (strict)

### Phase A — Review (strong model)

1. Confirm this is a Flutter tree (`pubspec.yaml` with `flutter:`).
2. Load `references/rule-catalog.md` and run **hunts by surface** (order below).
3. For each hit: evidence at `file:line`, slug, severity, effort, one-line why.
4. Deduplicate. Cap noise: prefer Critical/Noticeable; Subtle only when clear.
5. Emit the **Findings report** (format below). **Stop.** Do not implement
   the whole list unless the user asked to fix specific items.

### Phase B — Plan (on user selection)

For each selected finding ID / slug:

- Write `PLAN.md` (or append section) with: problem, acceptance criteria,
  files, minimal approach, out of scope, how to verify on device.
- Prefer existing project helpers over new packages.
- One plan per finding (cheap model can implement later).

### Phase C — Implement (cheap model OK)

- One plan at a time. Small diffs. No drive-by refactors.
- Re-run the single rule’s Detect after the fix.

## Hunt order (surfaces)

Run in this order so high-cost user pain surfaces first:

1. **Touch / hit testing** — dead zones, GestureDetector defaults  
2. **Data shown to humans** — null, raw dates/phones/numbers  
3. **Forms / keyboard** — action button, autofocus, dismiss, formatters  
4. **Scroll / safe area / layout stability** — bottom inset, image jump, tabular nums  
5. **Feedback** — haptics, snackbar dedupe, loading/empty/error completeness  
6. **Motion** — exit faster than enter, spring vs linear spam  
7. **Platform / product chrome** — analytics screen names, adaptive pickers, back/sheets  

Details and grep recipes: `references/rule-catalog.md`.

## Severity & effort

| Severity | User impact |
|----------|-------------|
| **Critical** | Broken interaction or trust failure (dead tap, “null”, unclosable modal, unusable form) |
| **Noticeable** | Feels unfinished every session (layout jump, raw phone strings, missing primary haptics, no bottom inset) |
| **Subtle** | Taste polish (exit timing, list edge fade, missing changelog) |

| Effort | Scope |
|--------|-------|
| **S** | Local one-liner / small helper |
| **M** | Cross-widget or shared util |
| **L** | Product surface (analytics pipeline, changelog, design-system change) |

## Findings report format

```markdown
# Flutter pro UX review

Scope: <paths or "whole lib/">
Official skills note: architecture/tests not re-audited here.

## Findings

1. [Critical · S] `gesture-opaque-hit-target` — `lib/widgets/foo.dart:42`
   Evidence: GestureDetector on Row without HitTestBehavior.opaque
   Why: taps in gaps between icon and label do nothing

2. [Noticeable · S] `never-show-null` — `lib/screens/profile.dart:88`
   Evidence: Text(user.bio.toString()) without null/empty/"null" guard
   Why: users may see the word null

## Recommended order
Critical S → Critical M → Noticeable S → Noticeable M → Subtle …

## Next
Reply with finding numbers (or slugs) to generate PLAN.md for each.
```

## Implementation principles (when fixing)

- **Prevent invalid input** over post-hoc error banners when the limit is hard.
- **Human formats** for anything users read (locale-aware dates, phones, numbers).
- **Helpers over ceremony** — small extensions (`orPlaceholder`), not new layers.
- **Platform realism** — iOS status-bar scroll-to-top, Android back closes sheets,
  adaptive date pickers when the app already claims adaptive UI.
- **Respect reduced motion** when adding animation.
- **Do not invent brand** — match existing ThemeData / design tokens.
- Prefer **Navigator / routing patterns already in the project** (1.0 or go_router).

## Anti-patterns for the agent

- Dumping “use Material 3” or architecture lectures (out of scope)
- Flagging style preferences with no user-visible effect
- Mass-renaming widgets or introducing Riverpod/Bloc mid-polish
- Copying long third-party article text into the repo
- Implementing all findings without user selection

## Hand off

| Need | Skill |
|------|--------|
| Layered architecture / feature structure | Official **flutter-apply-architecture-best-practices** |
| Overflow / constraint errors | **flutter-fix-layout-issues** |
| Widget tests for a fixed component | **flutter-add-widget-test** |
| Generic web density / hierarchy | **product-ui-craft** |
| Mobile web sticky chrome (not Flutter) | **mobile-product-ux** |
| Prove in browser (Flutter web) | **browser-verify** / **quality-check** |
