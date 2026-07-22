---
name: data-reels
description: Principles for high-retention short-form data video (Instagram Reels, TikTok, Shorts) built from measured competitor research on data-viz and stats accounts. Use when making or reviewing data-driven short-form video, reels, TikToks, voiceover-timed data animations, retention/format questions for social video, or when a project's own reel playbook needs a philosophy layer to sit on top of. This is concepts, not commands — pair with your project's own reel playbook (operational scripts, render pipeline, asset paths) for execution.
---

# Data Reels

Principles for turning quantitative content into short-form video that holds attention, distilled from measured competitor research (view-to-follower ratios, outlier analysis, transcripts) across data-viz and stats Instagram accounts. This skill is the philosophy layer — the "why" and the invariants. Your project's own reel playbook (e.g. `social_media/REEL_PLAYBOOK.md`) is the operational layer — the "how": render pipelines, asset-fetch scripts, exact CLI commands. Reference that project playbook for execution; use this skill for judgment calls.

## 1. The rejection-cascade / one-insight format

The best-measured format is not a countdown. It's:

- **0-2s — thesis claim.** State the plain-language claim or question immediately. No throat-clearing, no "hey guys," no title card that isn't the claim itself.
- **3-4 beats — assumption → correction, with visual proof each time.** Each beat states a plausible-but-wrong read, then shows the visual that rejects it ("X? No — [proof]"). Screen recording, animated chart, or overlay — never just narration.
- **Close — one crisp rule, no CTA.** A single quotable takeaway that could stand alone as a tweet. No "follow for more," no cliffhanger, no ask.

This beat structure measurably outperformed 5-item countdown formats in the same niche. The whole video *is* the payoff, delivered as a sequence of corrections — not a tease building to a reveal.

## 2. Consistency over virality

The best pure-data account measured had **zero statistical outliers** — its top reel was only 1.35x its own median. Every post performs; none spike, none flop. That is the deliberate trade: template consistency as the strategy, not "swing for a viral outlier."

Contrast: an account chasing viral highlight moments had one reel at 96x its own median — and that reel had nothing to do with the account's core format (it was a lucky highlight clip with a caption, not the data format at all). Outlier-chasing accounts get carried by non-repeatable moments; consistency accounts get carried by the template itself being the product.

Implication: judge a reel template by whether it can hit the same beat structure every time, not by whether any single instance could go viral. If a crossover/fandom hook is available and honest, it can lift a single reel's ceiling — but don't build the core format around hoping for one.

## 3. Voice sets the pace — voiceover-first workflow

Never fit voice to animation. The order is:

1. Write the script.
2. Generate the audio per sentence and measure actual duration (e.g. one file per sentence via TTS, `ffprobe` the runtime).
3. Time animations/beat-starts to the measured sentence durations — not the other way around.

Natural spoken rate is roughly 180 wpm, but pauses between beats bring the *elapsed* rate down to roughly 110-130 wpm across a full reel. If a script runs long, **shorten the script** — do not speed up the voice track. A rushed voice reads as low-quality and undermines the 5th-grade comprehension target below.

## 4. The 5th-grade rule

Optimize for both comprehension and reading speed simultaneously:

- ~40-50 word total script for a short reel.
- ≤6 words per on-screen text element.
- Every key stat, number, or rule line holds on screen ≥2.5s before the scene advances.
- Charts and big numbers carry the story; on-screen text only labels what's already visually obvious — it should never be the only place an idea lives.

If a viewer would need to pause to re-read a card, cut it down or extend its hold.

## 5. Duration

- Silent (voiceless) reels: 14-20s, biased toward 15-19s.
- Voiced reels: ~22-26s (measured hold times push voiced reels a few seconds past the silent target — that's expected, not scope creep).
- One insight per reel. Don't stack multiple claims into one video hoping for more value; a richer source (e.g. a full blog post) becomes *several* reels, each with its own single insight.

## 6. Data integrity

Every spoken or shown number must trace back to a real data source — no invented stats, no "roughly right" placeholders left in for polish later. When a number is rounded for spoken delivery, say "about" or let the rounding be obviously approximate (e.g. "twenty-eight percent" for a true 27.9%) — never present a rounded number as exact. Keep a written trace from script number → source field/table for every stat that appears, spoken or on-screen.

## 7. TTS craft — phonetic respelling map

Off-the-shelf TTS mispronounces proper nouns, brand names, and acronyms by reading them literally. Maintain a phonetic respelling map (proper nouns, brand names like "TCGplayer" → "T C G player", acronyms like "SIR" → "S I R", spoken letter-by-letter for suffixes like "ex" → "E X"):

- Apply respellings to the **spoken** script text fed to the TTS engine only. On-screen captions always keep the correct/official spelling — never show the respelling to the viewer.
- Generate and sanity-check new respellings individually before using them in a full script (synthesize the single term, check the resulting duration is plausible for its syllable count).
- Produce **per-sentence audio files**, not one monolithic voice track. This makes fixing a single mispronounced line cheap — regenerate that one file and re-splice, instead of re-rendering the whole VO.
- Keep the map itself as a living document per project (term → respelling → note) so it compounds across reels instead of being re-derived each time.

## 8. Visual identity

- **Dark, near-black background** is the default for data reels: it maximizes contrast against data colors (chart lines, highlight colors, ticking numbers), suits night/OLED viewing, makes hero product imagery pop against the frame, and reads as a "terminal aesthetic" that signals technical trustworthiness for a data-driven brand.
- **Hero product/subject imagery** (the actual card, chart, product, etc.) should be sourced at the highest resolution obtainable — check what a source CDN actually serves (don't assume a legacy asset pattern still works; verify with a resolution/HTTP-status check before building around it) and fall back gracefully if a preferred size 403s.
- **Consistent brand typography**, with **tabular figures** (fixed-width digits) for any number that ticks or animates — proportional digits cause visual jitter as a number counts up or down.
- **Hero object outranks the data visuals in size.** In any scene built around a physical/visual subject (the card, the product, the collectible), that hero object should read as the single largest element — the thing a new viewer's eye lands on first. Charts, price tiles, and stat lines are supporting evidence, sized and placed after/around the hero, not competing with it for dominance. The one exception is a scene whose entire job is showing a relationship in the data (e.g. a divergence chart) — there, the chart becomes the argument and takes the readability priority, but the hero object should still stay present (smaller, dimmed, or in the background) so the visual identity doesn't whiplash between scenes.

## 9. Measure, don't guess — competitor research principles

Before committing to a format, run comparative research instead of copying whatever looks impressive:

- **Views-to-follower ratio as a retention proxy.** Raw view counts favor big accounts; median views divided by follower count normalizes for audience size and approximates how well a format actually retains/reaches relative to its base.
- **Outlier-vs-median analysis, per account.** Compute each account's own median and flag reels that are a multiple of it (e.g. >2x). An account with zero outliers is telling you its format itself is the asset. An account that's outlier-driven is telling you its median performance is not representative — don't copy its "hits."
- **Negative controls.** Include accounts and formats you expect to fail (long-form talking-head, brand-name-adjacent content that isn't actually the format you think it is). A negative control that indeed underperforms validates your metric; a negative control that doesn't behave as predicted means your metric or your assumption is wrong.
- Sample both in-niche and out-of-niche/structural comps — a structurally similar out-of-niche account (same format, different subject) is often a better format donor than a same-niche competitor with a worse format.
- Keep this tooling-agnostic: whatever API or manual method you use to pull views/followers/durations, the principles above (ratio not raw count, per-account outlier detection, negative controls) transfer.

## 10. Verification discipline

Before calling a reel done:

- **Frame-extraction QA with a readability judgment.** Pull frames at each beat's on-screen-text-settle timestamp and actually judge legibility — contrast, size, hold duration — not just "did it render without erroring."
- **Audio silence checks.** Confirm the voice track isn't silent or clipped at any beat boundary (a botched TTS render can silently produce empty audio for a line).
- **Foreground renders.** Render the final video in the foreground and watch/inspect it directly before publishing — don't trust a pipeline's exit code alone as proof the output looks right.

## Relationship to your project's reel playbook

This skill stays generic on purpose. It does not hardcode a render pipeline, asset paths, CLI invocations, or a specific TTS voice ID. Your project's reel playbook is where those live — treat it as the executable counterpart to the principles above. When the two disagree on a *principle* (not a command), prefer this skill; when you need to know *how* to actually run something, go to the project playbook.

## Hooks: the number-forward contradiction

Pick ONE hook shape and repeat it until it's a brand signature — consistency of format compounds; rotating hook styles reads as an account still finding itself. The strongest shape for data content: state the two most contradictory real numbers in the dataset, flat, in the first two seconds ("Price down 28%. Sales up 21%."). It is simultaneously a thesis-first claim, a curiosity gap (the contradiction is an open loop), and data-backed by construction. Rules: every clause traces to a real field; close the gap within 5-15 seconds or it reads as manipulation; the hook's only job is buying the next 10-15 seconds of watch time. Pattern interrupt, bold claim, direct question, and pain-point framings all work for faceless data brands; first-person story hooks do not. Hook A/B tests are the cheapest experiment available when audio is per-sentence: only the first sentence and thesis text change.

Validation note (2026-07-22, single-project eyeball A/B — treat as directional): the number-forward hook won as a *countable bold claim* ("9 of the 10 biggest X are Y"); the same numbers phrased as a direct question read weaker than a pattern-interrupt claim. Prefer declarative number-claims over question forms until posted retention data says otherwise.
