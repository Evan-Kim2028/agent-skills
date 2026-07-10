---
name: writing-technical
description: >
  Technical writing for research notes, empirical posts, design explainers, and
  build logs — mechanism-first, numbers with units, problem/fix/lesson or
  findings-led structure. Use for technical articles that teach or report
  results (not pure install docs, not marketing). Prefer writing-docs for
  procedures/reference; writing-prose for general human tone; writer-style when
  Evan (or another) voice pack is required; writing hub when unclear.
---

# Writing technical — research, explainers, build logs

**Job:** Explain a system or result so a technical reader can **reproduce the
reasoning** (and often the measurement). Default house technical register aligns
with Evan Kim’s public archive (constraint-led, measured, incentive-aware).

## When to load

- Empirical crypto/data posts (rates, fees, inclusion, pipelines)  
- Protocol / mechanism explainers (AMM, MEV, markets)  
- Infra build logs (what failed at what RSS, what changed)  
- Paper takeaways with open questions  

**Not for:** pure runbooks (**writing-docs**), landing pages (**marketing**),
pure voice cosplay without technical spine.

## Default structure (pick one)

### A. Empirical result

1. **TL;DR / findings** — bullets with units and multiples  
2. **Setup** — window, sources, why dual-check  
3. **Results** — tables/charts; name the effect size  
4. **Mechanism / incentives** — why the number looks like that  
5. **Implications / open questions** — not soft restatement  
6. **Appendix** — SQL/code  

### B. Build log / infra

1. **Constraint stack** (scale + memory + topology)  
2. **What feeds the system** (heterogeneity)  
3. **Lessons** as *problem → fix → lesson*  
4. **Scar tissue** with measured peaks  
5. **What’s next**  

### C. Theory / paper notes

1. One-sentence frame (“I read X; takeaways”)  
2. **Numbered claims**  
3. Short quotes only when definitional  
4. **Open questions** left open  
5. Light personal digression only if it clarifies  

## Principles

### 1. Numbers with units early

Lead with the measurement that forces the design (GB, %, SOL, slots, ms, ×).

### 2. Facts first

Fact-sheet for every quantitative claim; style after freeze. Cross-check when
two public sources exist.

### 3. Mechanism over mood

Prefer “validators retain failed fees → weak disincentive” to “this is concerning.”

### 4. Comparative tooling

When recommending stack choices, show a measured contrast (latency, RAM, ops).

### 5. Show the artifact

Schema, registry row, SQL, config — enough to reproduce. Link repos.

### 6. Conclusion discipline

If you write a conclusion, add **implication or next experiment**. Ban
“In conclusion, we have shown…” restatements of the TL;DR.

### 7. Voice

Default: house technical (this skill) or **writer-style** with **evan** pack for
full Evan cadence. Sparse first person; seams = scars and constraints.

## Anti-patterns

- Academic filler connectives without new claims  
- Charts without stating what changed  
- Hiding the failure that taught the lesson  
- Marketing hero story before the metric  
- Homogeneous sentence length (AI polish)  

## Hand off

| Need | Skill |
|------|--------|
| Install/runbook only | **writing-docs** |
| Named Evan voice pass | **writer-style** (evan pack) |
| Deslop / human seam only | **writing-prose** |
| Offer/landing | **marketing** |

## Done criteria

- [ ] Structure matches empirical / build-log / theory  
- [ ] Units on headline numbers  
- [ ] Reproducible method or artifact  
- [ ] Implication or open question — not padded summary  
- [ ] Optional: evan voice pack if “sound like Evan” requested  
