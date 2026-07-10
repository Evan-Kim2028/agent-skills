---
name: writing
description: >
  Routing hub for writing that sounds human and stays coherent — voice packs,
  anti-slop / naturalness, facts-first technical prose, and opinionated structure
  without LLM word-soup. Use when drafting or editing lessons, posts, threads,
  essays, docs, or anything that must not read like generic AI; when the user
  wants a specific person's voice; or when the right writing skill is unclear.
  Routes to writer-style (persona voice), writing-prose (house human + opinion
  floor), marketing (conversion frameworks). Prefer product-design for product
  UI craft; quality-check for ship/e2e. Prefer this hub over loading marketing
  copy skills when the problem is voice/tone, not offer design.
metadata:
  short-description: "Writing hub — human voice, anti-slop, facts-first"
---

# Writing — routing hub

**Sound like a person. Mean something. Stay correct.**

LLM default prose fails three ways this hub exists to block:

1. **Uniform polish** — even cadence, no human seams (AI tell #1)  
2. **Fake opinion** — wordy “balanced” takes with no spine or cost  
3. **Style before facts** — confident wrong numbers in warm voice  

**Route first → open one specialist → write.** Load at most 1–3 skills.

```
writing (this hub)
    → writer-style     (named voice pack)
    → writing-prose    (house human + opinion floor, no persona)
    → marketing/*      (offer / story / ads — not voice)
    → facts-first always for technical claims
```

## Routing table

| Your task | Skill | Load when |
|-----------|--------|-----------|
| Sound like a **named author** (Kaue pack or custom voice) | **writer-style** | “in my voice”, persona, Superteam-style lesson |
| House writing: human, tight, opinionated, not AI-slop | **writing-prose** | Blog, docs, post, no persona required |
| Offer / StoryBrand / ads / viral frameworks | **marketing** (+ specialists) | Conversion copy, not tone |
| Technical article: verify claims before styling | **writer-style** or **writing-prose** + facts-first | Always for numbers/APIs/code |
| Build a new voice pack | **writer-style** (persona builder / pack tools) | New author corpus |
| Product UI copy in the app | **product-design** | Labels, empty states — not long-form |
| Unclear multi-step writing | **start here** | Default |

### Default pipelines

#### A. Named voice (educational / long-form)

1. Open **writer-style**  
2. Facts OFF → verify → freeze  
3. Voice ON (primary + routed secondary craft)  
4. Naturalness floor + deslop + fact-preservation diff  
5. `validate_voice.py` when available  

#### B. House style (no persona)

1. Open **writing-prose**  
2. Take a position (one spine)  
3. Facts first if technical  
4. Human seams + uneven rhythm  
5. Deslop pass; paragraph-dependence check  

#### C. Marketing asset

1. **marketing** hub (offers → storybrand → cashvertising …)  
2. Optional **writing-prose** pass so the draft doesn’t sound like LLM brochureware  
3. Do **not** apply a celebrity voice pack to ads unless asked  

## Shared principles (every writing path)

### 1. Facts first on technical content

Establish numbers, APIs, code in neutral prose; style after freeze. Voice never invents facts.

**Test:** Can you diff every number/identifier pre/post voice and find zero mutations?

### 2. Naturalness over polish

Uneven sentence length, one human seam per passage, calm≠clean. Even tidiness is the machine tell.

**Test:** Read aloud — does any stretch sound like a press release?

### 3. Opinion with a spine, not LLM “nuance theater”

Take a stand. Name the tradeoff. Cut both-sides padding that doesn’t change the recommendation.

**Test:** Could you state the thesis in one sentence? Does every section serve it?

### 4. Logical dependence

Each paragraph needs the previous (number, thread, stake). Interchangeable modules = AI outline.

**Test:** Swap two body paragraphs — if the piece still “works,” add real connective tissue.

### 5. Deslop is subtractive

Cut clusters of tells (em-dash piles, “delve/robust/landscape”, fake profundity). Don’t sand off specific hard detail.

**Test:** Did you remove filler *and* keep the weird concrete number only a human would keep?

### 6. Original, not impersonation

Named voice: reproduce **primary** idiolect only; secondary masters contribute **craft**, never costume.

**Test:** Would a fan of the secondary author claim you forged them? If yes, strip their surface tics.

## Sources (attribution)

| Piece | Credit |
|-------|--------|
| **writer-style** engine + kaue pack + tools | [solanabr/writer-style-skill](https://github.com/solanabr/writer-style-skill) (MIT — Superteam Brazil / Kaue). Vendored under `skills/writing/writer-style/` with LICENSE. |
| Naturalness, deslop, facts-first rules | Same pack (`rules/*.md`) |
| **writing-prose** | This pack — synthesis of those floors for non-persona house writing |
| **marketing** frameworks | See marketing hub / ATTRIBUTION.md (books) |

Full index: [ATTRIBUTION.md](../../../ATTRIBUTION.md).

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Product app UI craft | **product-design** |
| Implement SPA feature | **frontend-design** |
| Offer packaging / StoryBrand / ads psychology | **marketing** (then optional prose pass) |
| Prove / e2e | **quality-check** |
| Data pipelines | **data** |

## Done criteria

- [ ] Right specialist opened (voice vs house prose vs marketing)  
- [ ] Technical claims verified before styling when relevant  
- [ ] Human seam / unevenness present (not uniform polish)  
- [ ] Thesis/spine clear if the piece claims a take  
- [ ] Deslop pass done; no fact mutation under voice  
