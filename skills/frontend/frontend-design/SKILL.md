---
name: frontend-design
description: >
  Routing hub for frontend product UI — routes to design-system, product-ui-craft,
  mobile-product-ux, mockup-implement, ui-explore, tufte, web-quality,
  react-performance, and (after build) browser-verify. Use when building or
  polishing product UI, card/chat/trade surfaces, charts, mobile chrome, or when
  the right frontend skill is unclear. Prefer this hub over frontend-ui-engineering
  and over loading multiple FE specialists at once. Do not use for pure QA/
  regression/e2e/ship proof alone (quality-check), pure backend APIs, data
  pipelines (data), or marketing copy strategy (marketing).
metadata:
  short-description: "FE hub — craft, mobile, explore, charts; then quality-check"
---

# Frontend design — routing hub

Single entry point for frontend work. **Route first**, then load the specialist.

When a specialist clearly fits, load it directly — skip re-reading this whole file.

**Prefer this pack over `frontend-ui-engineering`.** Specialists compose better.

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Project tokens / brand locks | **design-system** | Existing product look |
| Spacing, density, hierarchy polish | **product-ui-craft** | “Works but feels off” |
| A11y / focus / forms checklist | **web-quality** | Interaction audit |
| React waterfalls, bundles, jank | **react-performance** | Perf is the problem |
| Sticky / sheets / safe areas / mobile | **mobile-product-ux** | Phone chrome |
| Signed-off mockup → production | **mockup-implement** | Design already chosen |
| HTML A/B, prototypes, “try designs” | **ui-explore** | Explore before commit |
| Charts / dashboards craft | **tufte** | Quantitative viz |
| Browser proof (Playwright / DevTools) | **browser-verify** | After build — or via **quality-check** |
| Unclear multi-step FE | **start here** | Default |

Aliases (thin redirects): `ui-explore`, `ui-explore` → **ui-explore**;  
`browser-verify`, `browser-testing-with-devtools` → **browser-verify**.

### Multi-step pipeline

1. **design-system** — tokens / bans  
2. **ui-explore** if design not signed off  
3. **mockup-implement** after pick  
4. **product-ui-craft** (+ **mobile-product-ux** if touch)  
5. **tufte** + design-system chart tokens if charts  
6. **web-quality** if forms/focus  
7. **react-performance** if heavy data/charts  
8. **quality-check** / **browser-verify** before done  

```
ui-explore → mockup-implement → craft (+ mobile) → web-quality → quality-check / browser-verify
```

### Build vs prove

| Phase | Hub |
|-------|-----|
| Build / redesign product UI | **frontend-design** (this hub) |
| Prove / regression / e2e / ship | **quality-check** |
| Full feature | this hub → **quality-check** before done |

## Shared principles

1. **Project constraints beat generic taste** (DESIGN.md / tokens win).  
2. **Product UI ≠ marketing UI** — density, states, trust.  
3. **One component kit** — no one-off magic hex.  
4. **States are design** — loading / empty / error.  
5. **Mobile is a first viewport** — **mobile-product-ux**.  
6. **Prove pixels** — **browser-verify** / **quality-check**.  
7. **Performance is UX** — **react-performance**.  
8. **Charts** — **tufte** + design-system tokens.  

## Anti-patterns

- Mega `frontend-ui-engineering` when this hub exists  
- Freestyle production off an unsigned mockup  
- Desktop-only for mobile-critical chrome  
- Claiming done without browser proof when layout/gesture risk is real  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Pure QA / prove / e2e / ship | **quality-check** |
| Marketing | **marketing** |
| Data pipelines | **data** |
| No UI | — |

## Done criteria

- [ ] Correct specialist(s)  
- [ ] Design-system respected  
- [ ] Loading/empty/error for new async UI  
- [ ] Mobile considered if touch-reachable  
- [ ] **tufte** if quantitative charts  
- [ ] Browser proof when layout/gesture risk is non-trivial  
