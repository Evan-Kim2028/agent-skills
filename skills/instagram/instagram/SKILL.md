---
name: instagram
description: >
  Instagram routing hub for SilphCo / Silph Scope. Use when the user runs /instagram
  or asks about Instagram Reels, Reels ranking, skip rate, shares, captions,
  Insights diagnosis, or which Instagram short to ship. Owns the native metrics
  map (skip/share/like/save/repost/comment) and post-publish primary-action
  decision tree. Routes to high-retention-insight-reels-instagram for faceless
  TCG insight Reels create/review/rank. Prefer this hub for any Instagram-first
  task so specialists stay discoverable under one slash command.
metadata:
  short-description: "Instagram hub — Reels, ranking, Silph Scope"
---

# Instagram — routing hub

**One entry point for Instagram work.** Load this hub first on `/instagram`, then
open **one** specialist (default below).

## Routing table

| Task | Skill | When |
|------|--------|------|
| Silph Scope insight Reels (script, storyboard, DistScore rank, ship-gate) | **high-retention-insight-reels-instagram** | Default for almost all Reels work |
| Generic data-short craft philosophy | **data-reels** | Density / ship-gate polish only — **not** distribution rank |
| Social virality research (Gold/Silver/Bronze, multi-platform) | **marketing-going-viral** | Format research outside Silph mono template |
| Share psychology (STEPPS) | **marketing-contagious** | Designing send triggers only |
| Virality/retention mechanics for concept design + why-it-travels judgments (optional live recon appendix) | **instagram-virality-insights** | Distilled mechanics + evidence for new concepts or judging why a reel travels/stalls |

### Default path (`/instagram` with no extra args)

```
1. Apply native metrics map + (if Insights) post-publish diagnosis from this hub
2. Load high-retention-insight-reels-instagram
3. If local .mp4s: storyboard first (1fps + VO), then DistScore rank
4. If create/rewrite: myth-bust mechanism default; protect first 1.5–3s
5. Report: ship / hold / rewrite-hook (or other primary action) — never equal-weight craft over share
```

## Live account law (Silph Scope)

**Handle:** `@silphco_pokemon` (`silphco_analytics` is dead). 32 followers as of 2026-08-26. Scoring is per-video.

**Traveler (Jul 23, `DbI0ETpu-Qa`):** Mega Gengar, 1,687 views, 1,214 viewers, **11 shares**, 2 saves, 99.3% non-followers, 1 follow. Local: `social_media/5_overrated_series/volumes/ascended-heroes/v2/variant-c-voiced/` (22.3s). Cover: Gengar + red −28% + “DIDN'T CRASH / YOU'RE READING IT WRONG.” Caption was a **poll**. Shares came from the argument.

**Gold-delta clone (Aug 20–26):** 12–20s, WRONG stamp, send-asks already in `CAPTION.md`, views 7–145. Cover: `NAME` + `THAT $XK WAS THE TEN/TOP` + `WRONG`. Send-ask + short + WRONG did **not** leave the test pool. Next-best after Gengar: Mega Charizard Aug 13, 376 views, 2 shares, 0 follows.

**2026-08-12:** 12/21 July reels had confrontational *wording* and still died at ~150–215. Wording ≠ mechanism.

### Why Gengar traveled (replicate this, not the poster)

| Piece | Gengar | Gold-delta clone (died) |
|-------|--------|-------------------------|
| Live fight | People were saying the **set crashed** | Nobody is fighting a Groudon PSA print this week |
| Cover | Opens the fight; **does not state the sales punchline** | States the conclusion (`WAS THE TEN WRONG`) |
| Hero | One familiar monster | One card, same poster, new name |
| Proof | Cascade: Gengar, then Charizard + Feraligatr | No cascade — the cover was the whole movie |
| Rule | After conflict: watch sales, not just price | Readable at t=0 |

**Resolved-cover law:** if a muted scroller can read the ending in one glance, they skip. Frame 0 names a fight or a question. The counter-metric lands *after* the hold.

Until skip on new posts is consistently under ~40–45% (web proxy: **leave the ~150–220 view band**):

1. **Gate = first 1–3s** (skip). Nothing mid-reel matters if bounce is 60%+.
2. **Frame-0 / cover hold ≥ ~3.0s** — do not fade the thumbnail after ~1s. Hook cover stays until ~3s (sting/main after). `hookHoldMs: 3000` + s1 `gapAfterMs` in `build_audio` / `scope` mix.
3. Prefer **belief confrontation** over clean insight density on frame 0.
4. Prefer **visual rejection** (WRONG / DIDN'T CRASH / red penalty chip) over calm +green badges.
5. **Portable complete rule** at the end (no dangling “because—”).
6. Innovate *inside* confrontation energy — do not clone Gengar frame-for-frame; do not revert to soft data layouts as the open.
7. **Do not ship another one-card “WAS THE TEN WRONG” poster** as a growth bet (Aug 2026 gold-delta batch). New topic, new loop family, or a *set/class* claim with a cascade.

### CTA law: send beats poll (does not fix skip)

Every growth-bet Reel still needs **one recipient-named DM-send ask in the CAPTION** (never spoken VO / on-screen; scope lint RULE C). A poll may coexist; it must not replace the send-ask.

**Do not treat the send-ask as the traveler.** Gengar’s 11 shares happened on a poll caption. The gold-delta batch already had send-asks and died at ~150 views — the ask never got a non-follower pool. Skip first, then share.

- **2026-08-13 render audit:** EP23–28 rendered 36–64s (long_form budgets). Duration is a ship-gate: 12–25s for growth bets; >30s data reels are the measured losing band.

---

## Native metrics map (always apply)

Instagram Reels Insights order under **“What impacts your views”** (rates listed by importance to reach). Use this table on every create, rank, and postmortem — do not invent a different priority order.

### Skip vs retention (diagnostic split)

| Metric | Window | Diagnoses |
|--------|--------|-----------|
| **Skip rate** | Leave in first **~3s** | **Hook only** — frame 0 claim, text, motion, pattern interrupt |
| **Retention / avg % watched / curve** | After 3s through end | **Story + pacing** — mid beats, dead air, payoff timing, length |

A low skip with a steep mid drop is **not** a hook problem. A high skip with fine mid craft is **only** a hook problem — rewrite open, do not polish the cascade first.

### Reach-impact order (native UI)

| # | Rate | What it measures | Healthy (industry / Silph) | Kill / weak |
|---|------|------------------|----------------------------|-------------|
| 1 | **Skip rate** | % scroll away in first ~3s | **~30–40%** skip; Silph gate until **&lt;~40–45%** | **≥50–60%** — dies in test pool |
| 2 | **Share rate** | Sends / shares per reach (DMs count hardest) | Explicit send trigger + portable conflict | Near-zero sends on non-follower push |
| 3 | **Like rate** | Likes per reach | Secondary social proof | Chase likes alone = wrong optimization |
| 4 | **Save rate** | Saves per reach | Final **portable rule** / reference numbers | No rule, pure opinion dump |
| 5 | **Repost rate** | Public reposts per reach | Same drivers as share when content is “for the timeline” | Ignore unless Insights shows it as a lever |
| 6 | **Comment rate** | Comments per reach | Lowest of the six for *reach*; use for conversation, not rank #1 | Do not over-optimize CTAs that hurt retention |

### Stack that sits *under* those rates

| Signal | Role |
|--------|------|
| **Total watch time + replays** | Once past skip gate — aggregate seconds and loops (Mosseri-class) |
| **Sends per reach (DM)** | Strongest *distribution* share form; often cited ~3–5× a like for non-followers |
| **Completion / watch-through** | Support metric on short Reels; not a free pass if skip is 70% |
| **Early velocity / test pool** | Weak first-pool skip+share → throttled; strong → expanded |

**Ship hierarchy for Silph (do not reverse):** skip gate → share/DM → save → watch/replays/completion → likes → repost/comment.

**DistScore** (specialist) = Hook + Tension + Share + Save. Map: Hook↔skip, Share↔share/DM, Save↔save; Tension feeds retention after the gate.

---

## Post-publish diagnosis playbook

Run after any published Reel with Insights (or user-reported rates). Output **one primary action** — do not stack “fix everything.”

### Inputs to collect

Skip rate · share/sends (count or rate) · save rate · likes · avg % watched or retention notes · reposts/comments if shown · template used (myth-bust / concentration / H2H / other).

**Note:** skip rate and retention curve are visible only in the mobile app Insights ("What impacts your views"); web/desktop Insights shows views/interactions/shares/saves but **not** skip or watch-time. Collect skip via the app before running the tree; without it, use the account's view-band heuristic (test-pool band ~150–220 views on this account ≈ failed skip gate).

### Decision tree (first matching row wins)

| If | Then primary action | Do *not* |
|----|---------------------|----------|
| **Skip ≥ ~50–60%** (or Silph soft-open pattern ~70%+) | **rewrite-hook** — frame 0 belief attack, visual rejection, muted-legible claim in ≤1.5–3s | Polish mid-reel density, length, or end CTA first |
| **Skip OK (≲40–45%)** but **sends/shares ≈ 0** and weak travel | **add-share-trigger** — name the wrong belief + “send to anyone who thinks…”; make the rule quotable | Assume “needs more data density” |
| **Skip OK, some watch**, **saves flat**, no memorable rule | **add-save-payload** — one portable rule + hold final numbers as screenshot bait | Add more facts without a single rule |
| **Skip OK**, **steep drop mid-reel** (retention cliff after ~3s) | **cut-mid** — kill true dead air, logo stings, multi-second wipes; retime payoffs every ~3–5s | Rewrite a working hook |
| **Skip OK, mid OK**, **completion soft** only because length | **tighten-or-split** — one insight per Reel; trim after the rule | Default “always shorter” dogma if cascade needs ~18–22s and skip already clears |
| **All rates weak** on a soft comparison / calm +% open | **kill-template** for growth bets — switch to myth-bust / confrontation until skip clears account gate | Ship another concentration-as-growth open |
| **Skip + sends strong** (Gengar-class: travel + DMs) | **clone-mechanism not frames** — keep confrontation energy + share trigger; new data/topic | Frame-clone art; or revert to soft opens because “variety” |
| **Likes high, skip or share bad** | Ignore vanity — fix skip or share per rows above | Optimize for more likes |

### Silph template read

| Pattern | Read |
|---------|------|
| Myth-bust / belief confrontation clears skip + earns DMs | Default growth template; innovate *inside* it |
| Concentration / clean H2H / number-upside dies at 70%+ skip | Hold as polish/save craft only until account skip gate clears |
| Same template, skip OK once then skip high next | Hook/topic heat failed — rewrite-hook, not abandon mechanism |

### Required postmortem shape

```markdown
## Insights read
- Skip: X% → hook: pass|fail
- Share/sends: … → travel: pass|fail
- Save: … · avg watched / cliffs: …
- Template: …

## Primary action
rewrite-hook | add-share-trigger | add-save-payload | cut-mid | tighten-or-split | kill-template | clone-mechanism

## Next ship constraint
- One sentence (e.g. "Frame 0 must reject a named belief; no calm +green open.")
```

---

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Offers / landing / email | **marketing** hub |
| Product app UI | **product-design** |
| Data pipelines | **data** |

## Done criteria

- [ ] Correct Instagram specialist loaded  
- [ ] Local Reels storyboarded if ranking  
- [ ] DistScore (not Visual) decides distribution order  
- [ ] First-3s / skip risk named explicitly  
- [ ] Metrics map order respected (skip before mid-craft)  
- [ ] If post-publish: one primary action from the diagnosis tree  
- [ ] Send-ask present in the caption, recipient-named, never spoken VO (poll never replaces it)  
- [ ] VO.md committed for the shipped episode  
