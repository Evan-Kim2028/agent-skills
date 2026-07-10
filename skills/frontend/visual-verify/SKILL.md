---
name: visual-verify
description: >
  Prove UI in a real browser via Playwright e2e, visual snapshots, axe, and
  screenshot-driven fix loops. Use only when the task is proof/regression
  (sticky, multi-viewport, share flows) or "claim done" needs pixels. Prefer
  quality-check when QA path is unclear (ship/regression/verify). Prefer
  frontend-design when still building/redesigning UI. For live DOM/console/
  network via Chrome DevTools MCP use browser-testing-with-devtools instead.
  Not for writing product styles from scratch (design-system / product-ui-craft).
---

# Visual verify

**Job:** Close the loop — **see** the UI, then fix. Blind agents ship sticky bugs.

## Sources (attribution)

- **Playwright** official testing model (projects, fixtures, trace, screenshots).
- **Webapp-testing** skill patterns (Anthropic/OpenAI agent skill lineage):
  run app → capture → assert → iterate.
- **axe-core + Playwright** accessibility scanning patterns.
- Optional fleet **DesignReview** idea: vision/rubric on captured screenshots
  when configured — always prefer deterministic asserts first.

## When to load

- Mobile sticky bars, sheets, HUDs, gesture conflicts  
- After mockup ports or density passes  
- Chat share / restore / streaming UI  
- Pre-merge for visual surfaces  

## Workflow

### 1. Prefer project harness

Discover and use repo scripts first:

| Common | Purpose |
|--------|---------|
| `npm run test:e2e` / `test:e2e:smoke` | Functional flows |
| `npm run test:visual` / `test:visual:update` | Screenshot baselines |
| `npm run test:a11y` | axe |
| `playwright.config.*` | Viewports/projects (chromium, ios, android) |

Do **not** invent a parallel stack if one exists.

### 2. Pick the smallest proof

| Risk | Proof |
|------|--------|
| Logic/regression | e2e assert on role/text/url |
| Layout/sticky/overflow | visual snapshot desktop **and** mobile |
| A11y | axe on changed routes |
| One-off bug | headed debug + trace |

### 3. Capture loop

1. Reproduce on the target viewport (390×844 class mobile when relevant)  
2. Stabilize: wait for network idle / testids / skeleton gone  
3. Assert or snapshot  
4. If fail: fix product code, **not** the snapshot (unless intentional redesign)  
5. Re-run until green  

### 4. Determinism rules

- Fixture/API mode when available (`SILPH_FRONTEND_FIXTURE_MODE`, MSW, etc.)  
- Avoid clock-dependent copy in snapshots; mock time if needed  
- Mask volatile regions (ads, live timestamps) via project patterns  
- Prefer `getByRole` over brittle CSS selectors  

### 5. What “done” means

- [ ] Relevant project Playwright projects pass  
- [ ] New behavior covered or justified as manual-only  
- [ ] Snapshots updated only with intentional visual change  
- [ ] No known sticky/overflow on mobile for touched surfaces  

## Anti-patterns

- “Looks good in my head” without browser  
- Updating snapshots to silence failures without looking  
- Desktop-only proof for mobile-critical chrome  
- Full suite when a single smoke + visual would gate the risk  

## Hand off

| Fail type | Next skill |
|-----------|------------|
| Spacing/density | **product-ui-craft** |
| Tokens wrong | **design-system** |
| Safe area / gesture | **mobile-product-ux** |
| Focus/axe | **web-quality** |
| Slow after fix | **react-performance** |
