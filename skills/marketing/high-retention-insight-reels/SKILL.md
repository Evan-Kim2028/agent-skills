---
name: high-retention-insight-reels
description: >
  Create or optimize high-performing Instagram Reels for SilphCo Analytics (Silph Scope).
  Use for faceless, AI-voice Pokémon TCG market insight shorts — price/volume analysis,
  myth-busting set narratives, concentration stats, and collector mental models. Optimizes
  strictly for 2026 Reels ranking signals (watch time, DM shares, saves). Apply when writing
  Reel scripts, reviewing or ranking finished .mp4 Reels for algorithm impact, improving
  retention, designing share triggers, or generating new Silph Scope episodes. When ranking
  which Reel will travel farthest, this skill overrides data-reels craft density. Use when
  the user runs /high-retention-insight-reels or mentions Silph Scope / insight reels.
---

# High Retention Insight Reels (Silph Scope)

## Goal

Produce faceless, AI-narrated Instagram Reels under the Silph Scope brand that maximize average watch time, completion rate, DM shares, and saves. Content is educational data storytelling for Pokémon TCG collectors and investors.

Default to the **myth-bust narrative** (Gengar / Ascended Heroes style) for the strongest mix of narrative retention + shareable mental models. Secondary templates exist when the data fits better.

All output must work **faceless** with **AI voiceover** — no on-camera talent; cards, stamps, text, and animated data *are* the visuals.

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

Optimize in this exact order (do not reverse):

1. **First 3 seconds retention** — Decide in ~1–2s. Drop-off here kills distribution.
2. **Full narrative completion + replays** — Hold past 50%; rewatches are explosive.
3. **DM sends / shares per reach** — Highest weight for non-follower discovery.
4. **Saves** — High-intent lasting value (portable rules).
5. **Likes per reach + early velocity** — Secondary (first ~30–60 min test pool).
6. **Originality / authority** — Fresh SilphCo data; no watermarks / reposts.

Length: **12–25s** preferred. Extend only when each second advances the arc or a new visual/text payoff. ~21s is fine when a contradiction needs a cascade (AH-style).

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

After publish, map metrics → template:

- Avg % watched / replays → retention beats  
- Sends / saves → share & save triggers  
- Profile visits / follows → authority  

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
