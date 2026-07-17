---
name: product-design
description: >
  Routing hub for product UI/UX craft — density, hierarchy, mobile chrome,
  design-system fidelity, interaction quality, explore-before-build, and product
  chart judgment. Use when polishing app surfaces (card, chat, trade, filters,
  HUDs), sticky/mobile UX, empty/loading/error states, "works but feels off",
  motion/micro-interaction review, or when the right craft skill is unclear.
  Routes to product-ui-craft, mobile-product-ux, design-system, web-quality,
  ui-explore, mockup-implement, tufte, emil-design-eng,
  make-interfaces-feel-better, 12-principles-of-animation, then browser-verify.
  Prefer frontend-design for full FE implementation
  pipelines (perf, SPA structure) when the ask is build-the-feature not craft.
  Do not use for marketing landings (marketing), pure QA/e2e (quality-check),
  or data pipelines (data).
metadata:
  short-description: "Product UI/UX hub — craft, mobile, tokens, a11y, explore"
---

# Product design — UI/UX routing hub

**Craft and product judgment first.** This hub is for *how product surfaces feel
and behave* — not marketing heroes, not backend, not “prove CI green.”

**Route first → open one specialist → do the work.** Load at most 1–3 specialists.

```
product-design (this hub)
    → design-system | product-ui-craft | mobile-product-ux | web-quality
    → ui-explore | mockup-implement | tufte
    → emil-design-eng | make-interfaces-feel-better | 12-principles-of-animation (motion/feel review)
    → quality-check / browser-verify (prove pixels)
```

## When to use this hub

| Signal | Example |
|--------|---------|
| Polish / craft | “Spacing is off”, “feels cheap”, density, hierarchy |
| Mobile product chrome | Sticky bars, sheets, safe areas, one-thumb |
| Product states | Empty, loading, error, selected — missing or awkward |
| System fidelity | Wrong tokens, inventing fonts/colors, off-brand |
| Interaction UX | Focus traps, form friction, touch targets (not full e2e suite) |
| Explore options | A/B product chrome before committing production |
| Product charts | KPI tiles, series charts that must stay honest (**tufte**) |
| Motion / feel review | "Animation feels janky", micro-interaction polish, "works but feels off" on transitions |

## Primary ownership (vs frontend-design)

These specialists **belong here first** (product UX). **frontend-design** only
pulls them in as steps inside a full implement pipeline:

| Primary under **product-design** | Why |
|----------------------------------|-----|
| **design-system** | Product visual law |
| **product-ui-craft** | Density / hierarchy craft |
| **mobile-product-ux** | Mobile product chrome |
| **web-quality** | Interaction UX / a11y craft |
| **ui-explore** | Explore before build |
| **mockup-implement** | Fidelity after sign-off (craft path) |
| **tufte** | Product chart judgment |

**frontend-design** owns primarily: **react-performance**, SPA/feature structure,
“build the page” orchestration.

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Tokens, components, brand locks, DESIGN.md | **design-system** | Project law; agents inventing aesthetics |
| Spacing, type hierarchy, density, radii, motion restraint | **product-ui-craft** | Desktop/app chrome polish |
| Sticky bars, bottom sheets, safe areas, gestures | **mobile-product-ux** | Phone/tablet product surfaces |
| A11y, focus, forms, touch targets, motion prefs | **web-quality** | Interaction/a11y craft (not full ship QA) |
| HTML A/B or throwaway UI/logic prototypes | **ui-explore** | Design not signed off yet |
| Port signed-off mockup with fidelity | **mockup-implement** | Winner chosen; match don’t freestyle |
| Quantitative charts / dashboards | **tufte** | Viz craft (+ design-system chart tokens) |
| UI polish, component craft, perceived performance | **emil-design-eng** | Optional install — Emil Kowalski design-engineering pass on invisible details |
| Micro-interaction / "feels better" review | **make-interfaces-feel-better** | Optional install — Jakub Krehel detail checklist (radius, optical align, shadows) |
| Animation audit vs. 12 principles | **12-principles-of-animation** | Optional install — Disney's 12 principles adapted for web, file:line findings |
| Prove sticky/viewport/a11y in browser | **browser-verify** | After craft — or **quality-check** for full QA path |
| Full feature build (perf, SPA, implement pipeline) | **frontend-design** | Broader FE engineering hub |
| Unclear multi-step *craft* | **start here** | Default for product UX |

### Multi-step craft pipeline

1. **design-system** — lock tokens / kit / bans  
2. **ui-explore** if the look is still open  
3. **mockup-implement** once signed off  
4. **product-ui-craft** (+ **mobile-product-ux** if touch/sticky)  
5. **web-quality** for forms/focus/targets  
6. **tufte** if product charts  
7. **emil-design-eng** / **make-interfaces-feel-better** / **12-principles-of-animation** if motion/feel is the specific complaint (optional installs)  
8. **browser-verify** or **quality-check** before claiming done  

```
explore (ui-explore)
  → mockup-implement
  → product-ui-craft (+ mobile-product-ux)
  → web-quality
  → emil-design-eng / make-interfaces-feel-better / 12-principles-of-animation (motion/feel)
  → browser-verify / quality-check
```

### product-design vs frontend-design vs quality-check

| Hub | Job |
|-----|-----|
| **product-design** (this) | Product UX craft, mobile chrome, density, system fidelity, explore |
| **frontend-design** | Full FE implement path (also routes to craft specialists + **react-performance**) |
| **quality-check** | Prove / regression / TDD / ship — not invent craft |

If the user says “build the page” → **frontend-design**.  
If they say “make the trade HUD feel right on mobile” → **this hub**.  
If they say “prove sticky doesn’t break” → **quality-check** / **browser-verify**.

## Shared product UX principles

Each has a falsifiable **Test:**.

### 1. Project design system beats generic “pretty”

DESIGN.md, tokens, kit components win over neo-brutalism packs and random Inter/purple defaults.

**Test:** Would a design-system owner accept this without a rebrand fight?

### 2. Product surfaces optimize for scan, density, trust

Tables, chat, trade HUDs, filters ≠ marketing heroes. Prefer clear hierarchy and restrained motion.

**Test:** Can a user find the primary action and current state in under 2 seconds?

### 3. States are part of the design

Loading, empty, error, success, disabled, selected — not “polish later.”

**Test:** Is every async path designed, or only the happy path?

### 4. Mobile is a first viewport

Sticky, sheets, safe areas, and thumb reach are designed — not shrunk desktop.

**Test:** Does 390-class width need a special layout, or did we only check desktop?

### 5. Touch and focus are product quality

Targets, focus rings, form labels, motion prefs — **web-quality**. Automated axe alone is not craft.

**Test:** Keyboard-only and thumb-only paths both complete the primary job?

### 6. Charts carry product truth

Quantitative UI uses **tufte** (honest encoding) + design-system chart shells — not decorative sparklines that lie.

**Test:** Does the chart answer a product question without chartjunk?

### 7. Explore before freestyle production

Unsigned visuals → **ui-explore**. Signed → **mockup-implement**. Don’t invent production chrome mid-port.

**Test:** Is there a named source design, or are we improvising?

### 8. Prove the craft in a browser when pixels matter

Sticky, overflow, gesture, density → **browser-verify** (or **quality-check** for full QA).

**Test:** Have you opened the real viewport, or only reasoned about CSS?

## Sources (attribution)

Full pack table: [ATTRIBUTION.md](../../../ATTRIBUTION.md).

| Specialist | Lineage (summary) |
|------------|-------------------|
| **product-ui-craft** | Impeccable / make-interfaces-feel-better craft principles — original synthesis |
| **mobile-product-ux** | iOS HIG / Material density practice — original synthesis |
| **design-system** | Project DESIGN.md law; Anthropic constraint-before-code idea |
| **web-quality** | Vercel Web Interface Guidelines + WCAG practical AA |
| **ui-explore** | Unreasonable effectiveness of HTML + throwaway prototype branches |
| **mockup-implement** | Design-to-code fidelity lineage |
| **tufte** | Edward Tufte — optional install; we route only |
| **emil-design-eng** | Emil Kowalski / animations.dev design-engineering — optional install; we route only |
| **make-interfaces-feel-better** | Jakub Krehel / interfaces.dev — optional install; we route only (condensed lineage already folded into **product-ui-craft** above) |
| **12-principles-of-animation** | Raphael Salaja — Disney's 12 principles adapted for web — optional install; we route only |
| **browser-verify** | Playwright + condensed Addy Osmani DevTools MCP lineage |

Do **not** install competing aesthetic mega-skills (“UI/UX Pro Max” style) alongside
this hub — they fight your design system. Prefer **design-system + craft**.

## Anti-patterns

- Marketing landing maximalism on data/product chrome  
- Inventing fonts/colors when a design system exists  
- Desktop-only for mobile-critical product flows  
- Happy-path-only UI (no empty/error)  
- “Looks fine in my head” without viewport proof  
- Using **quality-check** when you still need craft decisions  
- Using this hub for pure React perf / code-split (**frontend-design** → **react-performance**)  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Full FE feature implement + perf | **frontend-design** |
| TDD / e2e / regression / ship checklist | **quality-check** |
| Offers, ads, viral, landing narrative | **marketing** |
| Lakehouse / DuckDB / pipelines | **data** |
| No UI | — |

## Done criteria

- [ ] Routed to the right craft specialist(s)  
- [ ] Design-system constraints respected  
- [ ] Loading/empty/error considered for new async UI  
- [ ] Mobile considered if the surface is touch-reachable  
- [ ] Charts used **tufte** when quantitative  
- [ ] Browser proof when sticky/gesture/density risk is non-trivial  
