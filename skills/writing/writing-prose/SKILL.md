---
name: writing-prose
description: >
  House writing floor — human naturalness, anti-slop, coherent opinionated
  structure without persona cosplay or LLM word-soup. Use when drafting or
  editing posts, docs, essays, threads, READMEs, or technical explainers that
  should sound like a sharp human, not generic AI, and no named voice pack is
  required. Prefer writer-style (default pack: evan) for a named voice.
  Prefer writing-technical for research/build-log form; writing-docs for pure
  procedures. Prefer marketing for offer/story/ad frameworks. Prefer writing
  hub when the writing path is unclear.
---

# Writing prose — human, opinionated, coherent

**Job:** Kill default LLM prose. Keep the take sharp and the logic tight.

This is **not** a celebrity voice pack. For “sound like Evan / Kaue / person X”
use **writer-style** (this install defaults to the **evan** pack). This skill is
the **house floor** when no persona is loaded.

Lineage: naturalness + deslop + facts-first principles from
[solanabr/writer-style-skill](https://github.com/solanabr/writer-style-skill)
(MIT, Superteam Brazil / Kaue), adapted for non-persona writing. Full engine:
**writer-style**. Pack credits: [ATTRIBUTION.md](../../../ATTRIBUTION.md).

## When to load

- “Make this less AI” / “tighter” / “more human”  
- Blog, docs, internal essay, changelog, thread without a named voice  
- Technical post that must stay correct **and** readable  
- Edit pass after marketing draft still sounds corporate-LLM  

## Non-negotiables

### 1. One spine

Before drafting: one sentence thesis or job (“argue X”, “teach how Y works”, “recommend Z because …”).

Every section must earn its keep against that spine. Cut “on the other hand” blocks that never change the recommendation.

**Bad LLM opinion:** long balanced paragraphs that end in “it depends” with no costed pick.  
**Good opinion:** pick, name the tradeoff, say who should ignore you.

### 2. Facts first (technical)

Neutral fact-sheet for every number, API, flag, version. Style after freeze. Never invent certainty.

If unverified: say so. Confident wrong is worse than plain uncertain.

### 3. Naturalness floor (always)

From the writer-style naturalness rules (always-on spirit):

- **Uneven rhythm** — long calm runs + short punches; punches *clump*, not metronome  
- **One human seam per passage** — real number from use, named credit, small confession, loose run-on  
- **Calm ≠ clean** — don’t over-tidy; over-smooth is the tell  
- **One mood per piece** — confessional / dry / mentor / builder — don’t sample every register  

Seams ≠ catchphrases. Humanity is structure and rhythm, not forced slang.

### 4. Deslop (subtractive)

Cut clusters of tells (not single innocent words):

- Em-dash decoration piles, “delve / landscape / robust / nuanced / pivotal”  
- Fake profundity (“X is the language of trust”) → concrete fact instead  
- Restatement loops (“In other words… Essentially… At its core…”)  
- Modular paragraphs you could reshuffle with no damage  

**Preserve:** specific hard-to-fake detail, mixed feelings, real asides. Don’t sand those off.

### 5. Logical coherence

- Each paragraph **depends** on the last (setup → payoff)  
- No treadmill: every block must add information  
- Claims have warrants; metaphors don’t replace mechanism  
- End with a verdict or next action, not a summary of summaries  

### 6. Length discipline

Default shorter than the model wants. If a section doesn’t change the reader’s action or understanding, delete it.

## Workflow

```
1. Spine sentence + audience + form (post / docs / thread)
2. Fact-sheet if technical (voice OFF)
3. Draft in house prose (spine + seams + unevenness)
4. Reshuffle test + treadmill cut
5. Deslop pass
6. Read aloud; kill press-release lines
```

## Quick checklist

- [ ] Thesis in one sentence  
- [ ] Technical facts frozen / sourced  
- [ ] Uneven sentences; not all 18 words  
- [ ] ≥1 real seam (specifics, not filler slang)  
- [ ] No paragraph reshuffle-safe  
- [ ] Opinion has a costed pick if the piece argues  
- [ ] No AI-tell cluster  
- [ ] Shorter than first draft  

## Anti-patterns (LLM opinionated style)

| Failure | Fix |
|---------|-----|
| Wordy both-sides theater | Pick + tradeoff in two sentences |
| Even, polished “blog voice” | Flatten body; spike only at seams/verdicts |
| Aphorism without fact | Ground or cut |
| Section headings as decoration | Each section must advance the spine |
| Confidence without source | Verify or hedge honestly |
| Applying Hotz/Vitalik *costume* | Use **writer-style** craft layers properly, or stay house prose |

## Hand off

| Need | Skill |
|------|--------|
| Named author voice (default: Evan) | **writer-style** |
| Research / empirical / build-log form | **writing-technical** |
| Runbook / API reference / how-to | **writing-docs** |
| Offers / StoryBrand / ads | **marketing** |
| Product UI microcopy | **product-design** |
| Validate voice markers / tools | **writer-style** tools (`validate_voice.py`) |
