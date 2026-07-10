---
name: writing-technical
description: >
  Technical writing form — multi-mode structures for findings, field logs,
  claim diaries, bake-offs, design briefs, concept maps, and forum notes.
  Mechanism-first, evidence objects, reframe insights, open gaps. Domain-agnostic
  (not only data/math). Prefer writing-docs for pure procedures; writing-prose for
  general human tone; writer-style + evan pack for full Evan cadence and mode
  routing; writing hub when unclear.
---

# Writing technical — form by job (multi-mode)

**Job:** Explain a system, result, design, or learning path so a technical reader
can **reproduce the reasoning** (and often the measurement or the map).

Aligns with Evan Kim’s public archive **presentation modes** — same mind, different
page shapes. Full mode cards: `writer-style/profiles/evan/modes.md`.

## When to load

- Technical articles that teach, report, compare, or design  
- Empirical notes, build logs, paper takeaways, tool bake-offs, design briefs  
- Any domain (infra, markets, math, agents, product internals)

**Not for:** pure runbooks (**writing-docs**), landing pages (**marketing**),
persona cosplay without a form (**writer-style** alone after form is set).

## Step 0 — Pick a mode (required)

| Job | Mode | Skeleton |
|-----|------|----------|
| Report a measured/observed result | **findings-note** | TL;DR → setup → results → reframe → open Q → appendix |
| What production taught you | **field-log** | Constraint → built → problem/fix/lesson → next |
| Digest a paper/theory in public | **claim-diary** | Frame → numbered claims-as-H2 → quote/gloss → open gaps |
| Argue design A vs B | **systems-essay** | Landscape → mech A → mech B → costed pick |
| Same task, multiple tools | **bake-off** | Task → parallel sections per candidate → differential |
| Narrative how-to with a visible result | **walkthrough** | Goal → steps + artifacts → what you should see → appendix |
| Pure install/runbook | → **writing-docs** | — |
| New lens on a structure | **concept-map** | Representation → worked example → properties → questions |
| Artifact + why that shape | **design-brief** | TL;DR bounds → constraints → technique → applications |
| Partial public research | **forum-fragment** | Observation → partial implication → **Open questions** |

Default if unclear: **findings-note**.  
Wrong mode > slightly off tone.

## Principles (all modes)

### 1. Structure does the thinking

Outline is the argument. Headings advance claims; parallel sections enable comparison.

### 2. Payload early

Finding, constraint, thesis, claim list, or representation rule in the first screen.

### 3. Evidence objects

Number+unit, quote, table, chart, query, error string, diagram, config — next to the claim.

### 4. Insight as reframe

Prefer incentive/structural implication, “slogan incomplete,” or “property falls out of the map” over mood (“concerning,” “exciting”).

### 5. Facts first

Fact-sheet for every quantitative or citation-sensitive claim; style after freeze.
Cross-check when two sources exist.

### 6. Open gaps stay open

Unproven bridges and next experiments are first-class — especially claim-diary and forum-fragment.

### 7. Conclusion discipline

If you close: **implication or next experiment**. Ban “In conclusion, we have shown…” restatements.

### 8. Voice handoff

House technical (this skill) or **writer-style** pack **evan** (loads `modes.md` + exemplars for the chosen mode).

## Anti-patterns

- Routing form by topic (“math = academic essay”) instead of job  
- Field-log scar cosplay on a paper diary  
- TL;DR theater with no findings  
- Academic filler connectives without new claims  
- Charts without stating what changed  
- Homogeneous sentence polish (AI default)  

## Hand off

| Need | Skill |
|------|--------|
| Install/runbook only | **writing-docs** |
| Full Evan cadence + mode exemplars | **writer-style** (evan) |
| Deslop only | **writing-prose** |
| Offer/landing | **marketing** |

## Done criteria

- [ ] Mode named and skeleton followed  
- [ ] Payload in first screen  
- [ ] Evidence objects on load-bearing claims  
- [ ] Reframe or open gap — not padded summary  
- [ ] Optional: evan voice pack if “sound like Evan” requested  
