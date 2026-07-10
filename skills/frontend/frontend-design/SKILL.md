---
name: frontend-design
description: >
  Routing hub for frontend UI work — picks the right specialist skill for product
  craft, design-system fidelity, web quality/a11y, React performance, visual
  verification, mobile product UX, or mockup→production implementation. Use when
  building or polishing UI, card/chat/trade-style product surfaces, mobile chrome,
  charts shells, landing/pricing pages, or when the right frontend skill is unclear.
  Do not use for pure backend APIs, data pipelines, marketing copy strategy
  (use marketing), or standalone HTML design exploration (use html-design).
---

# Frontend design — routing hub

Single entry point for frontend work. **Route first**, then load the specialist.
This hub carries **source attribution**, shared product-UI principles, and
anti-patterns that every specialist assumes.

When a specialist clearly fits, load it directly — skip re-reading this whole
file if you already know the lane.

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Project already has tokens / design system / brand locks — stay on-rails | **design-system** | Implementing inside an existing product look |
| Spacing, density, hierarchy, polish — “works” → “crafted” | **product-ui-craft** | Micro-UX, chrome cleanup, app UI feel |
| A11y, focus, forms, touch targets, motion prefs — audit/fix | **web-quality** | Review or ship-quality pass |
| React/Next performance — waterfalls, bundles, re-renders | **react-performance** | Slow UI, heavy charts, list virtualization |
| Screenshots, e2e, visual regression, axe | **visual-verify** | Prove UI in a real browser |
| Sticky bars, sheets, HUDs, safe areas, gestures, mobile density | **mobile-product-ux** | Phone/tablet product surfaces |
| HTML/Figma/mockup → production code, match not freestyle | **mockup-implement** | Porting a signed-off design |
| Standalone HTML A/B before production | **html-design** (design category) | Explore options in throwaway HTML first |
| Unclear / multi-step FE change | **start here**, then hand off per phase below | Default |

### Multi-step default pipeline

For non-trivial product UI (new app surface, card chrome, chat, trade, dashboards):

1. **design-system** — lock tokens, components, bans  
2. **mockup-implement** *or* **html-design** — if design is not signed off yet, explore first  
3. Implement with **product-ui-craft** (+ **mobile-product-ux** if touch/viewport matters)  
4. **web-quality** checklist  
5. **react-performance** if data-heavy / chart-heavy  
6. **visual-verify** before claiming done  

## Source attribution

Specialists synthesize public practice; they are **not** copies of third-party
repos. When a specialist encodes ideas from a known source, that source is named
on the specialist and summarized here.

| Skill | Primary sources (attribution) |
|-------|-------------------------------|
| **design-system** | Project-local design docs as law; Anthropic *Improving frontend design through Skills* (constraint-before-code); token/system discipline common to mature design systems |
| **product-ui-craft** | Product-mode craft checklists popularized by community skills such as *Impeccable* (Paul Bakaus / impeccable.style) and *Make Interfaces Feel Better* (jakub.kr); classic hierarchy/spacing craft |
| **web-quality** | Vercel *Web Interface Guidelines* / `web-design-guidelines` skill lineage; WCAG 2.2 practical checks; AccessLint-style contrast/color-only concerns |
| **react-performance** | Vercel Engineering *React Best Practices* agent skill lineage (waterfalls, bundles, re-renders) |
| **visual-verify** | Playwright official testing model; Anthropic/OpenAI webapp-testing skill patterns; visual capture + iterate loops |
| **mobile-product-ux** | Mobile HIG/Material density practice; safe-area / sticky chrome patterns from production product apps |
| **mockup-implement** | Design-to-code fidelity practice (Figma implement-design skill lineage); repo `design/` HTML mockup workflows |
| **html-design** | Anthropic *Unreasonable effectiveness of HTML*; local design-picker patterns |
| **This hub** | Synthesis for routing + shared product-UI principles (Evan-Kim2028/agent-skills) |

Do **not** treat install counts or viral skill names as quality signals. Prefer
project constraints + verification over generic “anti-slop” packs when a design
system already exists.

## Shared principles (every FE specialist)

### 1. Project constraints beat generic taste

If the repo has `DESIGN.md`, `design/DESIGN-DIRECTION.md`, `frontend/docs/design-system.md`,
token CSS, or brand locks — **those win**. Do not invent new fonts, palettes, or
“bold aesthetic directions” that fight them.

**Test:** Would a design-system owner accept this PR without a rebrand fight?

### 2. Product UI ≠ marketing UI

Marketing may use bold hero treatments. Product surfaces (tables, chat, trade
HUDs, matrices, filters) optimize for **scan speed, density, trust, and states**
(loading/empty/error). Do not apply landing-page maximalism to data chrome.

### 3. One visual system, one component kit

Reuse existing primitives (`Button`, `Sheet`, `Panel`, chart shells). Do not
spawn one-off cards with magic hex and `p-[13px]`.

### 4. States are part of the design

Every async surface needs loading, empty, error, and success. Missing states
are bugs, not polish later.

### 5. Mobile is a first viewport, not a shrink

If users hit sticky bars, sheets, or bottom actions on phone, design those
explicitly. See **mobile-product-ux**.

### 6. Prove it in a browser when pixels matter

For sticky, gesture, overflow, or density work, **visual-verify** (or project
Playwright/visual scripts) before “done.”

### 7. Performance is UX

A beautiful chart that janks or ships a 2 MB main chunk fails. See
**react-performance**.

## Hard anti-patterns (hub-level)

- Installing multiple *aesthetic* skills that fight each other mid-task  
- Using Anthropic-style “ban purple / ban Inter / pick neo-brutalism” guidance
  on a product that **already** chose brand purple + type  
- Freestyling production off a mockup “because it looks better”  
- Shipping without empty/error states  
- Desktop-only layouts for product flows that are mobile-critical  
- Claiming visual quality without opening the real viewport  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Marketing narrative, offers, hooks | `marketing` (+ sub-skills) |
| Data lakehouse / DuckDB / APIs | `data` (+ specialists) |
| Pure backend, no UI | no FE skill |
| Chart *theory* / quantitative viz principles | `tufte` if available; else design-system chart tokens |

## Done criteria (any routed FE task)

- [ ] Correct specialist(s) used (or deliberate general path)  
- [ ] Project design-system constraints respected  
- [ ] Loading/empty/error covered for new async UI  
- [ ] Mobile considered if the surface is touch-reachable  
- [ ] Lint/typecheck/tests per repo norms  
- [ ] Visual or e2e proof when layout/gesture risk is non-trivial  
