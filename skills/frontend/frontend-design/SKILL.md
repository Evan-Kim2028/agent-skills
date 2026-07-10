---
name: frontend-design
description: >
  Routing hub for frontend UI work — picks the right specialist for design-system
  fidelity, product craft, a11y, React performance, mobile UX, mockup ports,
  HTML/prototype exploration, chart viz (tufte), and browser verification.
  Prefer this hub over frontend-ui-engineering for product UI. Use when building
  or polishing UI, card/chat/trade surfaces, charts, mobile chrome, landings, or
  when the right frontend skill is unclear. Do not use for pure backend APIs,
  data pipelines (use data), or marketing copy strategy (use marketing).
metadata:
  short-description: "FE hub — route design-system, craft, a11y, mobile, charts, verify"
---

# Frontend design — routing hub

Single entry point for frontend work. **Route first**, then load the specialist.
This hub carries **source attribution**, shared product-UI principles, and
anti-patterns that every specialist assumes.

When a specialist clearly fits, load it directly — skip re-reading this whole
file if you already know the lane.

**Prefer this pack over `frontend-ui-engineering`.** That mega-skill overlaps
tokens + craft + a11y + perf in one blob; the specialists below are sharper and
compose better. If both are available, follow this hub.

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Project tokens / design system / brand locks — stay on-rails | **design-system** | Implementing inside an existing product look |
| Spacing, density, hierarchy, polish — “works” → “crafted” | **product-ui-craft** | Micro-UX, chrome cleanup, app UI feel |
| A11y, focus, forms, touch targets, motion prefs — audit/fix | **web-quality** | Review or ship-quality pass |
| React/SPA performance — waterfalls, bundles, re-renders | **react-performance** | Slow UI, heavy charts, list virtualization |
| App-wide perf beyond React (CWV, SSR, caching strategy) | **performance-optimization** if installed | Broader than component React |
| Screenshots, e2e, visual regression, axe | **visual-verify** | Prove UI via Playwright / project harness |
| Live DOM, console, network, runtime paint | **browser-testing-with-devtools** | Chrome DevTools MCP debugging |
| Sticky bars, sheets, HUDs, safe areas, gestures, mobile density | **mobile-product-ux** | Phone/tablet product surfaces |
| Signed-off HTML/Figma/mockup → production code | **mockup-implement** | Port, don’t freestyle |
| Standalone HTML A/B before production | **html-design** | Throwaway compare pages / pickers |
| Throwaway in-app or multi-variant prototype | **prototype** | Sandbox before committing architecture |
| Quantitative charts, dashboards, data viz craft | **tufte** | Chart/graph/KPI/small-multiples quality |
| Unclear / multi-step FE change | **start here**, then hand off per phase below | Default |

### Multi-step default pipeline

For non-trivial product UI (new app surface, card chrome, chat, trade, dashboards):

1. **design-system** — lock tokens, components, bans  
2. **Explore if unsigned:** **html-design** and/or **prototype**  
3. **mockup-implement** once a design is signed off  
4. Implement with **product-ui-craft** (+ **mobile-product-ux** if touch matters)  
5. Charts/analytics panels → **tufte** + design-system chart tokens  
6. **web-quality** checklist  
7. **react-performance** if data-heavy / chart-heavy  
8. **visual-verify** and/or **browser-testing-with-devtools** before claiming done  

### Explore vs ship

```
explore (html-design | prototype)
    → pick winner
    → mockup-implement
    → product-ui-craft (+ mobile-product-ux)
    → web-quality
    → visual-verify | browser-testing-with-devtools
```

## Source attribution

Specialists synthesize public practice; they are **not** copies of third-party
repos. When a specialist encodes ideas from a known source, that source is named
on the specialist and summarized here.

| Skill | Primary sources (attribution) |
|-------|-------------------------------|
| **design-system** | Project-local design docs as law; Anthropic *Improving frontend design through Skills* (constraint-before-code); token/system discipline |
| **product-ui-craft** | *Impeccable* (Paul Bakaus / impeccable.style); *Make Interfaces Feel Better* (jakub.kr); classic hierarchy/spacing craft |
| **web-quality** | Vercel *Web Interface Guidelines* / `web-design-guidelines` lineage; WCAG 2.2; AccessLint-style contrast concerns |
| **react-performance** | Vercel Engineering *React Best Practices* skill lineage |
| **visual-verify** | Playwright; Anthropic/OpenAI webapp-testing patterns |
| **browser-testing-with-devtools** | Chrome DevTools MCP / live-browser verification practice (Addy Osmani skill lineage) |
| **mobile-product-ux** | Mobile HIG/Material density; production sticky/sheet patterns |
| **mockup-implement** | Figma implement-design skill lineage; repo `design/` HTML mockup workflows |
| **html-design** | Anthropic *Unreasonable effectiveness of HTML*; local design-picker patterns |
| **prototype** | Throwaway prototype branches (terminal vs UI variants) — agent-skills / agents pack |
| **tufte** | Edward Tufte — *Visual Display of Quantitative Information* et al. |
| **This hub** | Synthesis for routing + shared product-UI principles (Evan-Kim2028/agent-skills) |

Do **not** treat install counts or viral skill names as quality signals. Prefer
project constraints + verification over generic “anti-slop” packs when a design
system already exists. Prefer **this hub** over **frontend-ui-engineering**.

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

For sticky, gesture, overflow, or density work, **visual-verify** (Playwright)
and/or **browser-testing-with-devtools** (live DOM) before “done.”

### 7. Performance is UX

A beautiful chart that janks or ships a 2 MB main chunk fails. See
**react-performance** (and **tufte** for chart cognitive load).

### 8. Charts are a specialist domain

Quantitative viz is not “make it pretty.” Use **tufte** for chart craft and
**design-system** for project chart tokens/shells.

## Hard anti-patterns (hub-level)

- Using **frontend-ui-engineering** instead of this hub when specialists exist  
- Installing multiple *aesthetic* skills that fight each other mid-task  
- Using Anthropic-style “ban purple / ban Inter / pick neo-brutalism” guidance
  on a product that **already** chose brand purple + type  
- Freestyling production off a mockup “because it looks better”  
- Shipping without empty/error states  
- Desktop-only layouts for product flows that are mobile-critical  
- Claiming visual quality without opening the real viewport  
- Treating every chart as marketing illustration (skip **tufte**)  

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Marketing narrative, offers, hooks | `marketing` (+ sub-skills) |
| Data lakehouse / DuckDB / APIs | `data` (+ specialists) |
| Pure backend, no UI | no FE skill |
| Image generation / edit | `imagine` |
| Architecture design docs / PR plans | bundled `design` skill (docs), not UI |
| Module/API “design it twice” | `design-an-interface` / `api-and-interface-design` |

## Done criteria (any routed FE task)

- [ ] Correct specialist(s) used (or deliberate general path)  
- [ ] Project design-system constraints respected  
- [ ] Loading/empty/error covered for new async UI  
- [ ] Mobile considered if the surface is touch-reachable  
- [ ] Charts used **tufte** when quantitative display mattered  
- [ ] Lint/typecheck/tests per repo norms  
- [ ] Visual or browser proof when layout/gesture risk is non-trivial  
