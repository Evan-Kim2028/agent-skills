---
name: writing
description: >
  Routing hub for writing that sounds human and stays coherent — Evan default
  voice pack, house anti-slop prose, technical articles, pure docs, and marketing
  handoff. Use when drafting or editing lessons, posts, threads, essays, docs,
  research notes, or anything that must not read like generic AI; when the user
  wants Evan's voice or a specific persona; or when the right writing skill is
  unclear. Routes to writer-style (default pack: evan), writing-prose,
  writing-technical, writing-docs, marketing. Prefer product-design for product
  UI craft; quality-check for ship/e2e.
metadata:
  short-description: "Writing hub — Evan voice, prose, technical, docs"
---

# Writing — routing hub

**Sound like a person. Mean something. Stay correct.**

Default long-form technical voice for this install: **Evan Kim**
(`writer-style` pack `profiles/evan/`), mined from
[evan_writings](https://github.com/Evan-Kim2028/evan_writings).

LLM default prose fails three ways this hub blocks:

1. **Uniform polish** — no human seams  
2. **Fake opinion** — wordy both-sides with no spine  
3. **Style before facts** — warm voice, wrong numbers  

**Route first → open one specialist → write.** Max 1–3 skills.

```
writing
  → writer-style (evan default | other pack)
  → writing-prose (house human, no persona)
  → writing-technical (research / build-log form)
  → writing-docs (procedures / reference)
  → marketing/* (conversion frameworks only)
```

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Sound like **Evan** (or “my voice” / default technical blog) | **writer-style** + pack **evan** | Lessons, research posts, build logs in his cadence |
| Named other author / new voice pack | **writer-style** + that pack | Persona work |
| House human tone, no persona | **writing-prose** | Docs-ish posts, edits, “less AI” |
| Research / empirical / mechanism explainer form | **writing-technical** | Structure + numbers; optional evan voice after |
| README, runbook, API reference, how-to | **writing-docs** | Followable procedures |
| Offer / StoryBrand / ads / viral | **marketing** | Conversion, not voice |
| Unclear multi-step writing | **start here** | Default |

### Pipelines

#### A. Evan voice technical post

1. **Pick presentation mode** (job, not topic) — see `writer-style/profiles/evan/modes.md`  
2. **writing-technical** for that mode’s skeleton (or outline yourself)  
3. Fact-sheet (voice OFF)  
4. **writer-style** pack **evan** — load mode exemplars per `ROUTING.md`; restyle, don’t re-derive  
5. Naturalness + deslop + fact diff (`validate_voice.py` if available)  

#### B. Pure docs

1. **writing-docs** only  
2. Optional light **writing-prose** if prose got corporate  

#### C. Marketing asset

1. **marketing** frameworks first  
2. Optional **writing-prose** so it doesn’t sound like LLM brochureware  
3. Do not force Evan research-voice onto ads unless asked  

## Shared principles

1. **Facts first** on technical claims  
2. **Naturalness over polish** (uneven rhythm, real seams)  
3. **Opinion with a spine** (costed pick)  
4. **Paragraph dependence** (no reshuffle-safe modules)  
5. **Deslop subtractive** (keep hard specifics)  
6. **Original, not impersonation** (primary idiolect only)  

## Evan default (quick)

**Constant spine** (all modes): structure-forward · payload early · evidence objects ·
insight as reframe · open gaps · no soft conclusion loops.

**Mode by job** (not topic): findings-note · field-log · claim-diary · systems-essay ·
bake-off · walkthrough · concept-map · design-brief · forum-fragment.

| Job | Mode |
|-----|------|
| Measured result | findings-note |
| Production scars / build log | field-log |
| Paper / theory takeaways | claim-diary |
| Design A vs B argument | systems-essay |
| Same task, many tools | bake-off |
| Narrative how-to | walkthrough |
| Pure runbook | **writing-docs** |
| Lens / representation | concept-map |
| Artifact + constraints | design-brief |
| Unfinished public Q | forum-fragment |

Full spine: `writer-style/profiles/evan/evan.md` · modes: `.../modes.md`.

## Sources (attribution)

| Piece | Credit |
|-------|--------|
| **writer-style** engine | [solanabr/writer-style-skill](https://github.com/solanabr/writer-style-skill) MIT Superteam Brazil / Kaue |
| **evan** pack | Synthesis of [Evan-Kim2028/evan_writings](https://github.com/Evan-Kim2028/evan_writings) public corpus |
| **writing-prose / docs / technical** | Evan-Kim2028/agent-skills |

See [ATTRIBUTION.md](../../../ATTRIBUTION.md).

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Product UI craft | **product-design** |
| Implement SPA | **frontend-design** |
| Prove / e2e | **quality-check** |
| Data pipelines | **data** |

## Done criteria

- [ ] Right specialist (voice vs house vs technical form vs docs vs marketing)  
- [ ] Technical facts verified before styling when relevant  
- [ ] Human seam / unevenness if prose (not pure reference tables)  
- [ ] Thesis/spine clear if the piece argues  
- [ ] Evan pack used when user asked for his voice / default blog voice  
