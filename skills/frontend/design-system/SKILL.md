---
name: design-system
description: >
  Keep frontend work on the project's design system — tokens, typography,
  components, chart contracts, and brand locks. Use when implementing or
  reviewing UI inside an existing product, when DESIGN.md / design-system docs /
  token CSS exist, or when agents keep inventing fonts, colors, or spacing.
  Prefer over generic aesthetic skills. Not for greenfield brand invention or
  marketing storytelling.
---

# Design system fidelity

**Job:** Make agents implement *this product*, not a random pretty UI.

## Sources (attribution)

- **Project-local law:** whatever the repo names as design source of truth
  (`design/DESIGN-DIRECTION.md`, `frontend/docs/design-system.md`, `DESIGN.md`,
  `tokens.css`, theme `@theme` blocks, Storybook, Figma tokens).
- **Constraint-before-code practice** popularized by Anthropic’s frontend design
  skill write-up (*Improving frontend design through Skills*) — adapted here to
  mean “commit to *project* constraints,” not “pick a new aesthetic each time.”
- **Token + primitive discipline** common to mature design systems (no magic
  hex / arbitrary spacing in product UI).

## When to load

- Touching production UI in a repo that already has a look  
- Card detail, chat, dashboards, trade floors, pricing — product surfaces  
- Agent output keeps introducing Inter-only stacks, new purples, or off-token radii  

## Workflow

### 1. Locate the law (read before coding)

Search, in order, and **cite paths in your plan**:

1. `design/DESIGN-DIRECTION.md`, `DESIGN.md`, `docs/design*`  
2. `frontend/docs/design-system.md` or equivalent  
3. Token files: `tokens.css`, `theme/tokens.css`, `index.css` `@theme`  
4. Typography constants / shared layout components  
5. Canonical UI kit path (`components/ui/*`, design-system package)  

If none exist: draft a minimal token table *with the user* before freestyling —
or route to **html-design** for exploration only.

### 2. Lock the palette of moves

Before writing JSX/CSS, state:

| Decision | Rule |
|----------|------|
| Color | Only token classes / CSS variables |
| Type | Only project font stacks (e.g. serif H1 + mono prices) |
| Space | Spacing scale only — no `p-[13px]` |
| Radius | Token radii only |
| Components | Prefer kit primitives over new one-offs |
| Charts | Only approved chart shell/option builders if the repo has them |

### 3. Implement

- Reuse existing primitives; extend with variants, don’t fork  
- Match surface language: glossy interactive vs flat data panels if the system defines tiers  
- Keep brand accents for **stats/links/CTAs** if the system reserves them that way  

### 4. Self-check

- [ ] No new font families without explicit product decision  
- [ ] No raw hex in `className` (unless repo exempts chart canvas colors)  
- [ ] No parallel button/card styles when kit ones exist  
- [ ] Dark-first / theme parity respected if documented  
- [ ] ESLint design-system rules pass if present  

## SilphCo-shaped example (when that repo is the workspace)

If `design/DESIGN-DIRECTION.md` + `frontend/docs/design-system.md` are present:

- Brand: Master Ball Void purple + Literata / JetBrains Mono — **not** “ban purple”  
- Product: dual flagship chat + analytics; shared chart shell  
- Use `~/components/ui/*`, `PAGE_H1_CLASS`, chart tokens — not neo-brutalist experiments  

## Anti-patterns

- Loading generic “frontend-design” aesthetic skills that ban the brand color  
- “Refreshing” type/color because AI defaulted to Inter  
- One-off glass cards on marketing while product uses flat panels (or vice versa) without a system rule  

## Hand off

| Need | Next skill |
|------|------------|
| Density / polish after tokens | **product-ui-craft** |
| Mobile chrome | **mobile-product-ux** |
| Match a mockup | **mockup-implement** |
| A11y audit | **web-quality** |
