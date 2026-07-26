---
name: high-retention-insight-reels-instagram
description: >
  High-retention insight Reels for Instagram (Silph Scope / SilphCo Analytics). Create or
  optimize faceless, AI-voice Pokémon TCG market insight Instagram Reels — price/volume
  analysis, myth-busting set narratives, concentration stats, collector mental models.
  Optimizes strictly for 2026 Instagram Reels ranking signals (skip rate / first 1–3s,
  watch time, DM shares, saves). Apply when writing Instagram Reel scripts, reviewing or
  ranking finished .mp4 Reels for algorithm impact, improving retention, designing share
  triggers, or generating new Silph Scope Instagram episodes. Routed from /instagram.
  When ranking which Instagram Reel will travel farthest, this skill overrides data-reels
  craft density. Use when the user runs /high-retention-insight-reels-instagram,
  /instagram, or mentions Instagram Reels, Silph Scope, or insight reels.
---

# High Retention Insight Reels — Instagram (Silph Scope)

## Goal

Produce faceless, AI-narrated Instagram Reels under the Silph Scope brand that maximize average watch time, completion rate, DM shares, and saves. Content is educational data storytelling for Pokémon TCG collectors and investors.

Default to the **myth-bust / belief-confrontation mechanism** (proven live by Ascended Heroes Mega Gengar — ~1.6k views, ~10 DM shares) — not a frame-clone of that one Reel. Secondary templates only when the data cannot support confrontation *and* you accept higher skip risk.

All output must work **faceless** with **AI voiceover** — no on-camera talent; cards, stamps, text, and animated data *are* the visuals.

### Live account gate (overrides generic craft)

**Your feed is currently punishing soft opens.** Clean comparisons, pure +% upside thumbs, and calm “NOT A SET / data layout” opens have posted **~70–80% skip** and died in the test pool. Gengar cleared the first gate with:

- Frame 0 dual-line belief attack (“DIDN’T CRASH” + “YOU’RE READING IT WRONG”)
- Red penalty chip (−28%) as pattern interrupt
- Emotional charge before the data cascade
- Portable rule after conflict

**Until skip is consistently &lt;~40–45%:** treat first 1.5–3s as the only ship-gate that matters. Do not ship “beautiful concentration” as the growth bet.

### Hook cover hold (hard pace law)

**Frame 0 must stay on screen ~3.0 seconds** to establish the claim. Flashing the cover for ~1–1.5s then cutting is a ship failure.

| Control | Value |
|---------|--------|
| Visual `#scene-hook` / hookLife | **≥3000ms** (full opacity through ~90%, then short fade) |
| Series sting | **after** hook hold (~2650–3000ms), not mid-hook |
| Audio | `hookHoldMs: 3000` in `buildVoMix`; s1 `gapAfterMs` so s2 starts after the hold |
| Do not | Sting at `s1_end − 80` when that is &lt;2s; empty sting wipe in the first 3s |

Closer VO must be a **complete rule** (e.g. “Volume is not safety.”) — never dangling “because—” loop bridges that IG does not seam.

### Skill conflict resolution (read first)

| Skill | Owns |
|-------|------|
| **This skill** | Silph Scope create + **distribution ranking** (shares, hook, tension, saves) |
| **data-reels** | Generic craft philosophy (density, cards command frame, ship-gate polish) |
| Project `REEL_PLAYBOOK.md` | Render paths, TTS IDs, CLI |

**When they disagree on rank:** this skill wins.  
**When they disagree on craft polish during production:** data-reels + playbook win.  
**Never** load data-reels alone for “which Reel performs best for the algorithm” — that path historically overweights Visual/Complete and underweights Share.

**Test:** if your #1 is the “cleanest card density” Reel while another has a stronger contradiction + share trigger + real low-skip data, you inverted the skills.

---

## DEFAULT: Storyboard analysis (mandatory for any local Reel .mp4)

**Never rank or “watch” a Reel from memory, filename, or sparse eyeball samples alone.** Replicate the site-Grok attachment pipeline first, every time.

### When this fires

- User attaches or points at one or more `.mp4` Reels
- User asks which Reel performs best / ranks for the algorithm
- Ship-gate / pre-publish review of a rendered episode
- Comparing variants (v1 vs v2, myth-bust vs concentration)

### Protocol (do this before scoring)

1. **Build a storyboard pack per video** (script: `scripts/storyboard_reel.py`):
   - Duration, 1080×1920, audio present
   - **~1 fps frames** from 0s through end (plus 0.05s hook frame)
   - **Timed VO transcript** (Whisper / faster-whisper) with second-level spans
   - Write `STORYBOARD.md`, `transcript.json`, `frames/*.jpg` under an output dir

2. **Read the pack like a human with a storyboard + script**:
   - Chronological frames
   - On-screen text, hierarchy, stamps, cards, charts per beat
   - Align VO timestamps to frames
   - Reconstruct arc, pacing, hook, visual density, retention cliffs

3. **Flag true dead air** — empty/logo-only frames *while* VO continues, or multi-second wipes with no new payoff. Do **not** auto-penalize intentional mid-arc text cards that *are* the story.

4. **Only then** score the rubric and rank. Cite beat times (e.g. “t=2s logo sting mid-VO”).

If tooling is missing (no ffmpeg / no whisper venv), install or use static ffmpeg + `faster-whisper` in a venv; do not skip the pack and “eyeball three frames.”

```bash
# Example
python scripts/storyboard_reel.py \
  --out /tmp/reel_storyboards \
  /path/to/reel.mp4
```

---

## 2026 Algorithm Priority Hierarchy

Optimize in this exact order (do not reverse). Full native UI map + bands live on the **instagram** hub — load that map on every Insights read.

1. **Skip rate / first 1–3s** — Gatekeeper. ~30–40% skip is healthy; **50–60%+ kills the test pool** before mid-reel is scored. Many analyses cite ~1.5–1.7s decide window. **Skip diagnoses the hook only** — not mid-reel craft.
2. **Share rate / DM sends per reach** — Strongest *distribution* signal for non-followers after the skip gate (often cited 3–5× a like). Native Insights lists share next after skip.
3. **Total watch time + replays** — Aggregate seconds and loops once past the gate (Mosseri-class).
4. **Saves** — Portable rules after conflict.
5. **Likes per reach + early velocity** — Secondary (likes appear high in the native six-rate list; do not optimize them over skip/share).
6. **Repost / comment rates** — Lowest reach levers in the native “What impacts your views” list; comment is not a DistScore input.
7. **Original / human-feeling** — Preferred over glossy “AI brochure” polish (2026 platform rhetoric).

**Diagnostic split:** high skip → rewrite frame 0. Low skip + mid retention cliff → cut dead air / retime payoffs. Do not confuse the two.

Length: **12–25s** preferred. ~21s OK for myth-bust cascade. **Length never fixes a 70% skip open.**

---

## Core Principles (Non-Negotiable)

- Overturn a misconception or show a counterintuitive divergence (price↓ volume↑, concentration, wrong #1, incomplete “crash” narratives).
- Information gap in the first 3s → resolve with data.
- One portable rule by the end (saves + shares).
- Explicit share triggers (“send this to anyone who thinks the set crashed”).
- Visual density: new text, stamp, number, or card reveal about every **3–5s** (faceless + silent).
- Proprietary / freshly analyzed SilphCo data only — no pure opinion dumps.
- AI VO clear, mobile-paced, synced to on-screen text. No long pauses without visual change.

---

## Primary Template — Myth-Bust Arc (default)

**Beat structure (target ~18–22s):**

| Beat | Time | Job |
|------|------|-----|
| Hook | 0–3s | Contrarian claim / dissonance |
| Surface | 3–8s | Data everyone sees + false assumption |
| Reject | 8–12s | REJECTED/WRONG stamp + counter-metric |
| Cascade | 12–18s | 1–2 more proofs or diverging graph |
| Rule | 18–end | One memorable rule + soft brand close |

Example hooks: “Ascended Heroes didn’t crash. You’re reading it wrong.” / “You’re not buying a set.”

Example rules: “Never read price without volume.” / “Buy the card, not the set.” / “Rank the gap, not the logo.”

---

## Secondary Templates

**Concentration / Volume Bomb (~12–16s)** — Extreme skew → buy-behavior implication. Highest pure completion. Use when one card owns disproportionate graded $ volume.

**Head-to-Head Gap (~14–18s)** — Perceived leader vs actual performance. “Rank the gap, not the logo.”

**Trend Divergence** — Price and sales opposite directions same window → chart → rule.

---

## Generation Pipeline (create mode)

1. Select counterintuitive SilphCo insight  
2. Name the misconception  
3. Map template (default myth-bust)  
4. 3–5 hooks → pick strongest (works as muted text)  
5. Timed VO + on-screen text + visual notes  
6. Caption + 5–8 hashtags + soft CTA  
7. Rubric until greenlight  
8. Output all of: timed VO, on-screen sequence, storyboard notes, caption, rubric scores, predicted primary strength (retention / share / save)

---

## Evaluation Rubric

### Scores (1–10)

| Dimension | Band | What to judge |
|-----------|------|----------------|
| Hook / first-3s | **Distribution** | Stop scroll muted + with audio |
| Narrative tension & resolution | **Distribution** | Assumption → reject → rule |
| Share / DM probability | **Distribution** | Would a collector send this? |
| Save value | **Distribution** | Portable rule / reference numbers |
| Predicted completion | Support | Hold + rewatch; **not** “short = auto high” |
| Originality / SilphCo data | Support | Fresh analysis, not generic advice |
| Visual density (faceless) | **Craft only** | Silent-legible; payoffs on story beats — **never used to set rank order** |

**DistScore** = mean(Hook, Tension, Share, Save) only.  
**CraftScore** = mean(Complete, Visual, Data) — ship-gate craft notes, not distribution rank.  
Greenlight for *publish craft*: DistScore ≥ 8 **and** no Distribution dimension &lt; 6. Craft scores below 6 are fix-notes, not automatic demotion below a weaker DistScore peer.

### Rank order (mandatory for multi-Reel compare)

1. Sort by **DistScore** descending  
2. Break ties with Share, then Hook, then real metrics (skip/sends if known)  
3. Report CraftScore separately as “polish / completion craft”  

**Never** sort by equal-weight average of all 7 rows. That is the documented failure mode.

### Required output shape (ranking)

```markdown
## Distribution rank
1. <name> — DistScore X.X — primary strength: share|hook|tension|save
2. ...

## Craft notes (not rank)
- <name>: Complete Y, Visual Z — true dead-air timestamps if any

## Do not invert check
- [ ] #1 has highest DistScore (not highest Visual)
- [ ] Text-card myth-bust middles not scored as empty
- [ ] Real skip/send data, if known, overrides predicted Complete
```

### Completion & visual scoring guardrails

- **Assumption → REJECTED / counter-metric text cards are the story**, not dead air. Score them as narrative payoffs. Only penalize *true* dead air: logo stings, empty gradients, or multi-second blanks with no new claim while VO continues aimlessly.
- **Byte-size “sparse frame” proxies are advisory only.** Low JPEG size ≠ empty story (text-on-dark frames compress small).
- **~18–22s myth-bust length is not a completion penalty** when the cascade needs those beats (AH is the cited example).
- **Real account metrics override predicted Complete/Visual.** If a Reel already showed low skip + strong sends/DMs, do not assign Complete ≤5 or treat it as “not that good.” Update predictions to match observed behavior.
- Concentration templates often win pure completion/save *craft*; myth-bust often wins **non-follower travel** via share psychology. Rank the *question asked*: distribution vs polish.

### Worked failure (do not repeat)

A myth-bust Reel scored Hook 9, Tension 9, Share 8, Save 9, Complete 5, Visual 4. Equal-weight average crowned a denser concentration Reel. **Wrong:** DistScore was ~8.8 (should rank #1 for distribution); Visual 4 was craft over-penalty on story text cards. Correct: report DistScore #1 for myth-bust; note craft separately; only ding Complete if true dead air or real high-skip data.

### Self-check before final rank

1. Is #1 the highest DistScore?  
2. Did I treat REJECTED/assumption cards as story, not sparse?  
3. Did real metrics override predicted Complete when available?  
4. Is Visual only in craft notes, not deciding order?

---

## Visual & Brand (Faceless / Silph Scope)

- Dark bg, high-contrast text, card art dominant  
- Stamps (REJECTED, WRONG), % fills, side-by-side, simple diverge graphs  
- Large final rule (screenshot/save)  
- Brand open/close without mid-reel logo stings that wipe content  
- Captions burned or available (muted default)  
- No face, hands, or lifestyle B-roll  

---

## Post-Performance Feedback Loop

After publish, run the **instagram hub post-publish diagnosis playbook** (single primary action). Do not freeform “improve everything.”

Quick map (first match wins — full table on hub):

| Pattern | Primary action |
|---------|----------------|
| Skip ≥ ~50–60% (or Silph soft-open ~70%+) | **rewrite-hook** |
| Skip OK, sends ≈ 0 | **add-share-trigger** |
| Skip OK, saves flat, no rule | **add-save-payload** |
| Skip OK, mid retention cliff | **cut-mid** |
| Soft comparison / calm open dies in test pool | **kill-template** for growth |
| Skip + sends strong | **clone-mechanism** (not frame-clone) |

Also log: avg % watched / replays → retention beats; profile visits / follows → authority.

Prefer structures that repeatedly clear **50%+ completion** and strong send rates on *this* account. Do not override proven arcs with generic “shorter always wins” dogma.

---

## Anti-Patterns

- Fact dumps with no tension or final rule  
- Hooks that take >3s or need prior context  
- Generic advice any TCG account could post  
- >30s without continuous payoffs  
- Missing share trigger  
- Visual monotony / true dead air mid-VO  
- Treating every text card as “sparse = bad” (only punish empty wipes)  
- **Equal-weight rubric averages that let Visual/Complete override Share+Hook+Tension+Save**  
- Ranking polish above topic heat + share psychology for live set narratives  
- Predicting Complete=5 on a myth-bust that already proved low skip + strong sends  
- Mid-reel brand stings that blank the frame while VO continues  
- Crowing concentration “cleaner” as auto-#1 when the ask is max distribution

---

## Relationship to other skills

| Skill | Role |
|-------|------|
| **data-reels** | Craft philosophy only; **does not set distribution rank** when this skill is in play |
| **marketing-going-viral** | Platform-native formats / Gold-Silver-Bronze research |
| **marketing-contagious** | Share psychology (STEPPS) |
| This skill | Silph Scope create + storyboard review + **DistScore rank** |
