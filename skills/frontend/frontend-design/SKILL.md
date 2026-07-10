---
name: frontend-design
description: >
  Routing hub for implementing product UI in code — SPA structure, React
  performance, mockup ports, and the full build pipeline. Use when building or
  shipping product UI features, card/chat/trade surfaces, code-splitting, or when
  the right FE engineering skill is unclear. Prefer product-design for pure craft
  (density, mobile chrome, “feels off”, tokens/a11y polish without a full build).
  Prefer quality-check for prove/e2e/ship. Prefer this hub over frontend-ui-engineering.
  Do not use for marketing copy (marketing) or data pipelines (data).
metadata:
  short-description: "FE implement hub — perf, build pipeline; craft via product-design"
---

# Frontend design — implement hub

**Build the feature.** Engineering path for product UI in the codebase.

Craft specialists (**product-ui-craft**, **mobile-product-ux**, **design-system**,
**web-quality**, **ui-explore**, **tufte**) are **owned primarily by
`product-design`**. This hub still lists them for one-shot implement pipelines,
but if the ask is *only* craft/UX, load **product-design** instead.

**Route first → open 1–3 specialists.**

## Routing table

| Your task | Skill | Notes |
|-----------|--------|--------|
| React waterfalls, bundles, jank, code-split | **react-performance** | Primary FE-engineering specialist |
| Signed-off mockup → production code | **mockup-implement** | Fidelity implement (craft after via product-design) |
| Prove UI after implement | **browser-verify** or **quality-check** | Prefer quality-check if full QA path |
| Tokens / craft / mobile / a11y / explore / charts | **product-design** → its table | Prefer that hub for craft-only work |
| Unclear multi-step **implement** | **start here** | Default for “build the page” |

Aliases still resolve: `html-design`/`prototype` → **ui-explore**;  
`visual-verify`/`browser-testing-with-devtools` → **browser-verify**.

### Multi-step implement pipeline

1. If design unsigned → **product-design** → **ui-explore**  
2. **mockup-implement** when signed off  
3. Implement structure with **design-system** constraints (via product-design if craft-heavy)  
4. **react-performance** if data/chart-heavy  
5. Craft pass: **product-design** specialists as needed  
6. **quality-check** / **browser-verify** before done  

### Build vs craft vs prove

| Phase | Hub |
|-------|-----|
| Implement product UI (full FE path) | **frontend-design** (this hub) |
| Craft / mobile UX / density / “feels off” | **product-design** |
| Prove / regression / e2e / ship | **quality-check** |

## Shared principles (implement)

1. **Project design system wins** — no freestyle brand.  
2. **Reuse kit primitives** — no one-off hex/`p-[13px]`.  
3. **States in the PR** — loading/empty/error with the feature.  
4. **Mobile if touch-reachable** — or route **product-design**.  
5. **Perf is part of ship** — **react-performance**.  
6. **Prove pixels** — **browser-verify** / **quality-check**.  

## Sources (attribution)

- Hub synthesis: Evan-Kim2028/agent-skills  
- Specialist lineages: see [ATTRIBUTION.md](../../../ATTRIBUTION.md) and each skill’s Sources section  
- Prefer this hub over mega **frontend-ui-engineering** packs  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Pure craft / mobile UX / density | **product-design** |
| Pure QA / e2e / ship | **quality-check** |
| Marketing | **marketing** |
| Data pipelines | **data** |

## Done criteria

- [ ] Implement path used the right engineering specialist(s)  
- [ ] Craft-only work was routed to **product-design** when appropriate  
- [ ] Design-system constraints respected  
- [ ] Perf considered if data/chart-heavy  
- [ ] Browser proof when layout/gesture risk is non-trivial  
