# Presentation modes — Evan (domain-agnostic)

The **spine** (`evan.md`) is constant: how meaning is made.  
**Modes** are page shapes. Pick by **job**, never by topic (not “data vs math”).

Load this file when drafting. Secondary craft still routes in `ROUTING.md`.

---

## Mode index

| Mode id | Job | Open with | Insight lands as |
|---------|-----|-----------|------------------|
| `findings-note` | Report a measured or observed result | TL;DR / findings bullets | Fact → reframe (conversely / corollary) → open Q |
| `field-log` | Transfer what production taught you | Constraint stack or “build log of…” | Scar → change → named lesson |
| `claim-diary` | Learn a text / theory in public | “I read…” / “quest to understand…” | Numbered claims as H2 + quote/gloss + open gap |
| `systems-essay` | Argue which design/system wins | Landscape + stakes | Side-by-side mechanisms → costed pick |
| `bake-off` | Choose among options under same load | Task definition | Differential grid (A vs B vs C) |
| `walkthrough` | Make the reader able to do the path | “How we build / run…” | Procedure; insight = what becomes visible |
| `concept-map` | Make a structure legible via a lens | Representation rule | Property that falls out of the map |
| `design-brief` | Explain an artifact and why that shape | TL;DR capability + bounds | Constraint forces technique |
| `forum-fragment` | Move a public conversation | Partial observation | Data + **open questions** as the ending |

Default when unclear and technical: **`findings-note`**.  
Default when “what I built / ran”: **`field-log`**.  
Default when pure procedure: prefer **writing-docs** skill (not this pack’s full voice).

---

## Shared presentation rules (all modes)

1. **Structure does the thinking** — outline is argument, not decoration.  
2. **Evidence object next to claim** — number, quote, table, chart, query, error string, diagram.  
3. **Insight = reframe** when possible — not “this is concerning,” but who benefits / what is incomplete / what the map implies.  
4. **Gaps stay open** — “deeper dive needed,” “no clean bridge yet,” open questions.  
5. **No soft conclusion loop** — if you close, add implication or next experiment; ban “In conclusion, we have shown…” restating the open.  
6. **Topic is irrelevant to mode choice** — same mode for markets, math, infra, product, agents.

---

## Mode cards

### `findings-note`

```
TL;DR / findings (payload first)
Setup / window / sources (cross-check if two exist)
Results (effect size named)
Reframe / mechanism / incentives
Open questions or further work
Appendix (method artifact)
```

- Bullets carry units and multiples early.  
- “Although X looks like tax, conversely Y…” is on-register.  
- First person sparse.  
- Exemplars: `02-tldr-empirical.md`

### `field-log`

```
Constraint or motivation (scale, cap, “what I tried”)
What exists / what you built
Lesson blocks: problem → fix → lesson  (or Learnings list)
What’s next
```

- Scar with a measured peak beats abstract advice.  
- “X is incomplete” after naming the real condition.  
- Higher first person OK.  
- Exemplars: `01-constraint-opener.md`, `03-problem-fix-lesson.md`

### `claim-diary`

```
One-line frame (source + intent)
## N — Full-sentence claim as heading
  quote if definitional
  gloss in plain language
  personal bridge or open question
…
```

- Headings **are** claims, not “Background / Methodology.”  
- Personal digression only if it clarifies (history of a term, affine analogy).  
- Leave unproven bridges open.  
- Exemplars: `04-claim-diary.md` (alias of paper takeaways)

### `systems-essay`

```
1.0 Landscape / problem
2.0 System A mechanism
3.0 System B mechanism
4.0 Comparison + pick (or spectrum)
```

- Numbered outline structure is fine and on-register.  
- Win condition is mechanism/incentives, not brand story.  
- Longer stamina; keep sections advancing the pick.  
- Exemplars: `05-systems-compare.md`

### `bake-off`

```
Task definition (same workload for all)
Option / query / step 1
  Candidate A | B | C  (parallel subsections)
Option / query / step 2
  …
Comparative conclusion (measured differential)
```

- Rhythm is **identical subsections** across candidates.  
- Insight is the table of differences (latency, cost, DX, failure).  
- Exemplars: `06-bake-off.md`

### `walkthrough`

```
What you’ll build / see
Prerequisites (brief)
Steps with artifacts
What success looks like
Appendix commands / SQL / config
```

- Prefer **writing-docs** if pure runbook with no narrative.  
- In-voice walkthrough still shows an observed output, not only steps.  
- Exemplars: `07-walkthrough-insight.md`

### `concept-map`

```
Representation rule (X as graph / definition / lens)
Worked example
Properties that fall out
Questions the map raises for design
```

- Insight = **legibility**, not a measurement.  
- Diagrams or explicit structure paths welcome.  
- Exemplars: `08-concept-map.md`

### `design-brief`

```
TL;DR (capability + hard bounds if any)
Part I — Problem / constraints
Part II — Method / implementation choices
Part III — Applications or API surface
Limits / references
```

- “Constraint forces technique” is the spine of each part.  
- Dense bullets for constraints OK; still freeze facts first.  
- Exemplars: `09-design-constraint.md`

### `forum-fragment`

```
Observation / data slice
Implication (partial)
## Open Questions
```

- Ending on questions is success, not incomplete writing.  
- Collaborative “we” OK.  
- Don’t force Lesson 1/2/3 or hero arc.  
- Exemplars: `10-open-questions.md`

---

## Anti-modes (not Evan)

| Fake mode | Why |
|-----------|-----|
| Marketing hero journey | Reader isn’t the hero; the claim/system is |
| Soft both-sides essay with no costed pick | When arguing, pick or leave open honestly |
| Academic connective padding without new claims | Moreover/Furthermore/In conclusion restatement |
| Uniform polished “blog voice” | Uneven rhythm; seams real |
| Forcing field-log scars onto a paper diary | Wrong mode for the job |

---

## Quick chooser

```
Measured a result?              → findings-note
Built/ran something hard?       → field-log
Digesting a paper/idea?         → claim-diary
Arguing design A vs B?          → systems-essay
Same task, multiple tools?      → bake-off
Reader must execute steps?      → walkthrough (or writing-docs)
New lens on a familiar object?  → concept-map
Shipping/explaining an artifact?→ design-brief
Public unfinished research Q?   → forum-fragment
```
