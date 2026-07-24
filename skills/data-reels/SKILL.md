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

## 1.5 Format follows story shape

The rejection-cascade (section 1) is not the only valid format — it's the right format for one
specific story shape (a contradiction or anomaly being corrected in a sequence of beats). Match
the format to the story, don't force every insight through the same template:

- **Contradiction/anomaly** ("this looks like X, it's not") -> rejection-cascade: scene-swapped
  beats, each stating a plausible-but-wrong read then rejecting it with proof.
- **Comparison/duel** (A vs B, "bigger than," "beats") -> **one composition evolving, not
  scene-swaps.** Build a persistent split/scale layout that stays on screen the whole reel;
  elements transform in place — a number ticks up, a bar or beam tips, one side visibly
  overtakes the other — rather than cutting between two separate scenes for A and B. The reel's
  entire job is showing one continuous transformation, not a sequence of discrete reveals.
- **Ranked list** (top N) -> countdown, frontloaded: put the strongest item first, not last —
  short-form retention drops before a slow build to a big finish pays off.

The generalizable principle: a scene-swap format asks the viewer to remember beat 1 while
watching beat 3. A comparison story doesn't need that memory load — both sides can just stay
visible and change value/position in front of the viewer, which is both easier to follow and
better matches what a comparison *is* (a single relationship, not a sequence of separate facts).
When a story is fundamentally "A vs B, and here's the moment B overtakes A," resist the urge to
default to whatever format was used last — the composition-evolves shape will read as smoother
and better-paced than forcing it into cascading scene cuts, which read as rushed/rough for this
specific story shape (confirmed via user feedback on a rejection-cascade cut of a comparison
story that was rebuilt as a persistent-composition format afterward).

Pacing implication: a comparison/duel format needs room for a single climax to breathe (place it
around 60-70% through the runtime, give it the longest beat window) and strictly soft transitions
between beats (500-700ms crossfades/eases, never a hard cut) — since nothing ever leaves the
screen, an abrupt transition on any single element reads as jarring in a way it wouldn't in a
scene-swap format where cuts are the expected rhythm.

## 1.6 Format classes beyond rejection-cascade and head-to-head

Measured competitor research on out-of-niche data-story accounts (geography/history/map creators) surfaced additional format classes worth matching to story shape, beyond the two above:

- **Single-transformation reel.** One continuous, wordless, self-explanatory visual change (a map redraw, a silhouette shrink, a region wipe), 6-15s, with **no pacing scaffolding** — no chapter cards, no VO, sometimes not even a caption beyond a one-line title. The strongest measured example ran 6 seconds and hit 41x its account's own median view-to-follower ratio. **Key insight: duration is not the retention lever here — a single continuously-evolving self-explanatory visual is.** Don't assume every short-form idea needs beats, hooks, or narration scaffolding; if the transformation itself is legible and dramatic, let it carry the entire reel unassisted.
- **Timeline biography.** An era-scrub playhead traveling across a horizontal/vertical timeline with milestone markers popping in at key dates — the "life story of a subject" shape (a market, a product line, an institution). The persistent progress cue doubles as a completion-satisfaction driver.
- **True-size / nesting comparison.** A layered-silhouette overlay: a full-scale shape with a smaller shape shrinking/nesting inside it to true relative scale. Fits any "X is bigger/rarer/smaller than you think" claim — population counts, print runs, market caps as overlapping silhouettes instead of plain bar charts.
- **Bar-chart race.** Ranked bars swap order and animate width/position continuously over a long time span. **Duration caps do not apply when the animation itself IS the story** — a measured 175-second bar-race reel (vs. a typical 15-30s target) still hit a strong outlier ratio, because viewers watch a long unbroken race for the rank-churn payoff itself, not despite its length. This format only works when the racing entities are already familiar to the viewer (well-known cities, countries, brands) — it's a poor fit for a single unfamiliar entity with no "cast" to recognize.
- **Chapter story.** Self-aware, comedic "oversimplified version" framing with numbered chapter cards and a "part 2" tease at the close — lowers perceived stakes so viewers forgive compressed nuance. Carries genuine off-brand/tonal risk: it borrows a parody-documentary voice that may clash with a data-authority brand identity. Use deliberately, don't default to it.

## 1.7 Share/save triggers

Distinct psychological drivers behind why a data-story reel gets forwarded vs. bookmarked — worth naming separately because they call for different production choices:

- **Identity signaling.** Rivalry/team framing ("team X vs team Y," fandom-vs-fandom) lets a viewer self-insert and tag someone on "the other side." **Identity-signaling rivalries are the strongest share trigger for fandom data** — it converts a data claim into a social move (tagging a friend), which is a stronger distribution mechanism than the data being merely interesting.
- **Nostalgia arcs.** "Then vs now" / vintage framing triggers a documented dopamine/belonging response and reliably outperforms polished, hyper-modern content on feeds.
- **Completion satisfaction.** Timelines, countdowns, and races resolve an open information loop; visible progress (playheads, milestone markers) intensifies the pull to watch to the end.
- **Reference-utility end cards ("save this").** A reel that holds its final numbers static for a beat reads as a re-checkable artifact worth bookmarking rather than a one-time watch — long runtime combined with a low like-to-view ratio is the empirical signature of this behavior (people watch fully to save, not to react).
- **The "whoa" transformation gasp.** A single wordless visual payoff is forwarded on its own visual strength with zero domain context required — this is a share trigger, not a save trigger, and correlates with low like-to-view ratios (high reach via algorithmic pass-along, not deep engagement).

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

## 11. Polish tier — the finishing standard

A format and a pacing choice being correct isn't enough — a shipped reel also needs a
baseline level of craft and a disciplined verification order. These generalize across
projects; the concrete implementation (specific CSS classes, specific voice IDs, specific
render scripts) belongs in your project's own playbook.

- **Signature motion set.** Pick a small set of motion techniques and apply them
  consistently across every reel unless the format explicitly contradicts one — e.g. a
  glint/sheen sweep on hero-object landings, subtle depth/tilt on hero elements, a
  settle-pulse on any counter/stat the instant it finishes animating, continuous
  background drift so nothing is ever fully static behind the foreground, kinetic
  word-reveal on any caption (excepting a frame-0 static hook headline, since that's the
  cover thumbnail), and an emotional color/tone shift at any story turn. Signature motion
  is a brand-consistency lever, not decoration — repeating the same techniques across
  reels is what makes a format read as a deliberate house style rather than a one-off.
- **Pacing floors.** Beats should land in the low single-digit seconds for fact/list
  formats (aim ≤3.5s); any counter or stat fill should finish well before the format's
  overall budget is spent (≤3s is a reasonable target); no stretch of the reel should sit
  fully static for more than ~1s; total runtime caps apply *unless the animation itself
  IS the story* (see section 1.6's bar-chart-race exception); and the single dramatic
  peak of a reel that has one belongs around 60-70% through the runtime, not earlier or
  saved for the very end.
- **Never a static outro.** The single most consistently reported retention-killing
  mistake is a dedicated "brand card" or static end-scene that outlives the content. Two
  acceptable endings: a genuine loop seam (the reel visually returns toward its own
  opening state), or a hard cut immediately after the final voiceover line ends (within a
  few hundred milliseconds — a very tight ceiling, not "soon after"). A brand mark and any
  scope/date chip belong *inside* the final active composition as overlays, not as their
  own trailing scene.
- **Phoneme-level pronunciation control, with an STT caveat.** Off-the-shelf TTS
  mispronounces proper nouns and invented words by reading them literally, and this can
  persist even after switching *voices* if the underlying *model* doesn't honor
  phoneme-tag SSML — diagnose by testing an explicit phonetic tag (e.g. ARPAbet) against
  the specific model, not just by trying a different voice preset. A speech-to-text
  round-trip is a useful automated check, but treat it as validating that a word wasn't
  dropped or substituted (the consonant skeleton / rough identity), not as proof the
  vowels and stress pattern are actually correct — STT is lenient on vowel quality in a
  way a human ear isn't. A flagged name still needs a human listen-through as the final
  gate, even after a clean STT pass.
- **Ship-gate ordering.** Verification steps have a cost order, and running them out of
  order wastes the expensive steps on preventable failures. Cheapest-to-most-expensive,
  in order: (1) a headless single-frame check of the specific timestamps/states a change
  could break, before spending a full render; (2) the full render itself, run to
  completion in the foreground, to a fresh/unique output path (never overwrite a
  same-name output mid-flight — that produces silent race-condition corruption); (3) a
  full decode scan of the rendered file (not just a handful of sampled frames) to catch
  any corrupt segment; (4) a container/stream spec check (resolution, frame rate,
  expected stream types); (5) an audio loudness check (no clipping, levels in the
  expected band); (6) a silence-gap check (no unintended dead air, and specifically that
  the ending satisfies the never-static-outro rule above); (7) a multi-frame visual
  review at actual small-screen scale, including a crop to whatever safe-viewing-area
  applies on the target platform; (8) a data-traceability pass — every on-screen number
  checked against its literal source field, not against the narration (narration often
  rounds differently); (9) a freshness check that the underlying data is current as of
  the actual publish date, re-running the data step if it's gone stale since the reel was
  built. Skipping ahead to the visual/data checks before the cheap frame-level and decode
  checks means expensive re-renders get spent re-discovering cheap-to-catch bugs.

## 12. Robustness systems — generated timelines, data contracts, golden frames

Three structural principles, generalized from a concrete pipeline hardening pass, for any
project mature enough to have shipped a broken/wrong reel at least once. Keep the concrete
implementation (a specific compiler script, a specific JSON schema, a specific diff tool) in
your project playbook — these are the invariants worth carrying to a new project from
scratch.

- **Generate timing from a single source of truth; never hand-author overlapping
  animations.** Two "stacked animation bug classes" recur across every hand-authored
  animation pipeline: (1) two separate `animation:`/keyframe declarations landing on the
  same element/property, where an earlier one lacks a "hold" fill-mode and silently reverts
  before the later one starts; (2) keyframe percentages hand-computed against a duration
  that has since changed elsewhere, so the visual timing quietly drifts from the intended
  ms offsets. The fix is structural, not "be more careful": declare every element's
  enter/hold/exit window in one ms-denominated timeline document, and generate exactly one
  keyframe/animation per element from it. A compiler that emits ONE animation per element
  has nothing left to stack, and every percentage is computed from the same ms values a
  human edited, so drift becomes impossible instead of just less likely. Extend the same
  document with a **slot budget** — every persistent on-screen element declares which
  screen-region/"slot" it owns for its active window — and make it a compile-time error for
  two elements to claim the same slot with overlapping windows without an explicit,
  authored hand-off. This turns "did two things silently collide on screen" from a
  frame-by-frame visual QA question into a build-time check.
- **Data contracts: every displayed number carries scope and freshness, not just a value.**
  A bare number is not enough provenance once a metric can be read at more than one scope
  (all-time vs. a recent window, one category vs. all categories, one grading tier vs. all
  grades) — the same underlying fact can produce two "correct" numbers that contradict each
  other on screen, and a viewer (or a future editor) can't tell which scope they're looking
  at. Require a **scope caption** alongside any number whose unit is inherently
  scope-ambiguous (a volume, a market cap, a percent change — anything where "compared to
  what, over what window, across what population" changes the number), and treat a missing
  scope caption on that class of metric as a hard failure, not a style nit. Separately,
  require every displayed number to declare an **as-of date and a freshness ceiling**
  (how many days old it's allowed to be before publish) — and gate publishing on that
  ceiling automatically rather than trusting a human to remember to re-check. A contract
  gate that fails should say exactly what to re-run, not just that something is stale.
  Where the underlying data source has itself been reorganized or partially retired (a
  table split into a live surface and a frozen snapshot, a warehouse migration, etc.),
  encode that as a guard at the query layer — refuse queries that read drift-prone fields
  from the retired/frozen surface, and let read-only/stable fields still be queried with a
  warning, so the mistake is caught at the point of query, not after it's already on
  screen.
- **Golden-frame regression, not just "does it render."** A render pipeline succeeding
  (correct codec, correct duration, no decode errors) says nothing about whether the
  content *looks the same as it did yesterday* — a broken CSS change, a stale asset, or a
  timing regression can all produce a technically-valid render that's visually wrong, and
  spot-checking a handful of QA frames only catches it if the sampled timestamp happens to
  land on the broken moment. Bless a small set of reference frames at fixed timestamps from
  a render a human has actually reviewed, tag them with a hash of the *source* (not the
  video bytes, so "did the source change" is answerable independent of a re-encode), and
  diff every subsequent render against them with a perceptual similarity metric (structural
  similarity or an equivalent pixel-difference measure — exact-pixel diffing is too brittle
  against encoder noise). Any similarity drop at a timestamp NOT inside a deliberately
  declared "this is an intentional change" window is a regression, full stop — this is the
  automatable equivalent of "would a human who reviewed the last version notice this
  changed," applied to every future render for free. Re-bless deliberately, after review,
  whenever a change is intentional — goldens are a regression fence, not a permanent lock.

## 13. Editorial standards — laws, not style preferences

Two rules that generalize beyond any one project's reel pipeline, worth carrying to a new
project from day one rather than rediscovering after a viewer catches an ambiguous or
inconsistent-feeling reel:

- **No naked percentages — the price is the fact, the % is the flavor.** Any reel that
  displays or narrates a percent change on top of a real-world quantity (a price, a value,
  a market size) must show the actual underlying number on screen alongside it, scoped to
  whatever grade/tier/window the number applies to (e.g. "PSA 10 · $1,675", not just
  "+62%"). A percentage with no anchoring value is unverifiable and reads as marketing
  spin rather than data — it's the same ambiguity class as an unscoped volume/mcap number
  (section 12's data-contracts principle), applied specifically to price moves. Treat this
  as a hard gate, not a style nit: whatever contract/validation layer your project already
  runs before publish should refuse to ship a percent-change display that lacks a paired,
  scoped price value for the same subject. Voiceover is exempt from having to *say* the
  scope out loud — the on-screen chip carries that job — but the price itself must always
  be visible whenever a % move is.
- **One canonical series intro, owned by the template.** If a project has recurring
  episodic branding (a sting, a bumper, a title card), there should be exactly ONE
  implementation of it, living in the shared template layer, not hand-rolled per episode.
  Copy-pasting or re-authoring a "one-off variant" per episode is how the same bug gets
  reintroduced repeatedly (a stacked-animation/fill-mode regression, a timing drift, a
  visual inconsistency between episodes that undermines the "this is a series" feeling).
  Prefer a single-lifecycle-keyframe pattern for the intro's visibility (one animation
  entry owning the wrapper's opacity for its entire life, immune to the composite-order
  trap from section 12), parameterized only by a start-offset/duration pair so new episodes
  never need to touch its CSS/HTML — only pass the two numbers. Verify it mechanically (a
  headless check that the intro's key visual element is actually visible at its
  mid-window), not by eyeballing a sampled frame.

## Relationship to your project's reel playbook

This skill stays generic on purpose. It does not hardcode a render pipeline, asset paths, CLI invocations, or a specific TTS voice ID. Your project's reel playbook is where those live — treat it as the executable counterpart to the principles above. When the two disagree on a *principle* (not a command), prefer this skill; when you need to know *how* to actually run something, go to the project playbook.

## Hooks: the number-forward contradiction

Pick ONE hook shape and repeat it until it's a brand signature — consistency of format compounds; rotating hook styles reads as an account still finding itself. The strongest shape for data content: state the two most contradictory real numbers in the dataset, flat, in the first two seconds ("Price down 28%. Sales up 21%."). It is simultaneously a thesis-first claim, a curiosity gap (the contradiction is an open loop), and data-backed by construction. Rules: every clause traces to a real field; close the gap within 5-15 seconds or it reads as manipulation; the hook's only job is buying the next 10-15 seconds of watch time. Pattern interrupt, bold claim, direct question, and pain-point framings all work for faceless data brands; first-person story hooks do not. Hook A/B tests are the cheapest experiment available when audio is per-sentence: only the first sentence and thesis text change.

Validation note (2026-07-22, single-project eyeball A/B — treat as directional): the number-forward hook won as a *countable bold claim* ("9 of the 10 biggest X are Y"); the same numbers phrased as a direct question read weaker than a pattern-interrupt claim. Prefer declarative number-claims over question forms until posted retention data says otherwise.
