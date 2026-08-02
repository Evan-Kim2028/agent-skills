# Domain knowledge: language, market structure, and folk claims

Two jobs. First, **translate the hobby's vocabulary into columns**, so a question in native language reaches the right measurement. Second, **hold the received wisdom to the same standard as everything else in this skill** — tested where testable, marked untested where not.

Written for Pokémon TCG; most of it transfers to sports cards and MTG with different nouns.

---

## 1. Language → measurable

Terms that carry a specific measurement, not just flavour.

### Rarity and card types

| Term | Means | Measurement note |
|---|---|---|
| **Hit** | a card worth pulling from a pack | operationally: top decile by price within its set |
| **Chase card** | the card driving demand for the set | top 1–3 by price; usually sets the set's whole narrative |
| **Alt art / AA** | alternate full-art printing | a *distinct product* from the base card. Confirm your identity key separates them |
| **IR / SIR** | Illustration Rare / Special Illustration Rare | modern chase tiers |
| **Secret rare** | numbered above the set's stated size | e.g. card 199/195 |
| **Reverse holo** | holo-foiled on the non-art area | **the #1 variant-contamination source.** Trades at a different price to the same card's normal printing |
| **Master set** | every card *including* reverse holos | why reverse holos have independent demand |
| **Grail** | someone's personal top target | price-insensitive demand — a fairness check, not an investment thesis |
| **Singles / sealed** | individual cards / unopened product | this skill covers **singles only**; sealed is a different market with different dynamics |

### Condition and grading

| Term | Means | Measurement note |
|---|---|---|
| **Raw** | ungraded | `grader IS NULL OR grader='RAW'` |
| **Slab / slabbed** | encapsulated by a grader | PSA, BGS, CGC, TAG, ACE |
| **NM / LP / MP / HP / DMG** | the raw condition ladder | Near Mint → Damaged. Ratios in `sparsity-and-eras.md` §4 |
| **Pack fresh** | straight from the pack, ungraded | a *claim*, not a grade |
| **Gem mint / PSA 10** | top grade | commands a large but **highly dispersed** multiple |
| **Centering, whitening, print lines, edgewear** | the physical defects that decide a grade | **none of these are in the tape.** They are why grade prediction must defer to the person holding the card |
| **Pop / pop report** | population — how many exist at each grade | scarcity denominator. Verify freshness; in the reference implementation the PSA population table is *empty* while PSA *prices* are abundant |
| **Crack / regrade** | break a slab, resubmit for a better grade | makes population counts drift upward over time |
| **Bump** | grading up a tier on resubmission | — |

### Market and trading

| Term | Means | Measurement note |
|---|---|---|
| **Comps** | recent sold prices | **sold, never asks.** Same condition, same venue, outlier-fenced |
| **Market price** | a platform's own computed mark | someone else's filter choices. Circular if you backtest against it. Re-derive |
| **Spread** | buy price vs sell price | the flipper's entire business |
| **BIN / OBO** | Buy It Now / Or Best Offer | BIN prices are asks; OBO means the ask is soft |
| **Cooking / cooked** | rising fast / the run has ended | maps to acceleration: positive = cooking, negative with high breadth = cooling, not dead |
| **Moonshot** | speculative long-shot buy | — |
| **LGS** | local game store | in-person channel — **near-zero fees**, which changes every threshold |
| **Buylist** | the price a dealer pays | structurally well below market; that gap is the dealer's margin |
| **PC** | personal collection | signals the card is not for sale — removes supply |
| **Rotation** | sets leaving tournament legality | scheduled, exogenous, moves playable cards only |

**The translation that matters most:** when someone says *"what's it worth"*, they want one number, and there isn't one. A card has a price distribution across condition × venue × grade. Quoting a single median without a spread is the most common way to be confidently wrong in this hobby.

---

## 2. Market structure facts

These shape prices and **none of them are in any column.** Treat as priors and veto inputs.

> **Verify before quoting.** Fee schedules, grading tiers and rotation dates change. The numbers below are approximate as of 2026 and are here to convey *magnitude*, not to be cited.

### Supply is elastic for modern, fixed for vintage

**The single most important asymmetry in this market.** Modern sets are printed to meet demand and popular product gets reprinted; vintage print runs ended decades ago and only shrink as cards are damaged or graded away.

Consequences:

- A modern card that runs up **invites its own supply response.** Sustained modern appreciation fights the printer.
- Vintage scarcity is real and monotone. Supply only ratchets down.
- **Reprint risk has no column.** A cheap, trending modern card scheduled for reprint is a trap the model cannot see.

This is a mechanism-level reason to expect the vintage/modern split that shows up empirically in `sparsity-and-eras.md` — and, as §3 below shows, in returns.

### The fee stack decides whether a spread is real

Roughly, per sale:

| Channel | Take | Note |
|---|---|---|
| eBay | ~13% + fixed fee | plus promoted-listing fees if used |
| TCGplayer | ~10% + processing | seller-level dependent |
| In person / LGS / cash | ~0% | why in-person flipping tolerates far thinner spreads |

**A 15% gross spread is zero on eBay and real in person.** Any threshold in this skill — the $2 spread the reference implementation uses — is a *channel-specific* number. State the channel.

### Grading economics

Per card, roughly: **$15–25+ at bulk tiers, months of turnaround, plus shipping and insurance both ways.** Two consequences:

- **A fixed cost imposes a price floor.** Grading a $5 card cannot work regardless of the multiple; the multiple has to clear a dollar cost, not a percentage.
- **Turnaround is real duration risk.** You are long the card for months with no ability to exit. A 60-day momentum signal does not survive a 120-day lag.

### Rotation and playability

Standard-format rotation removes older sets from tournament play on a published annual schedule. It moves **playable** cards; collectible chase cards are largely insensitive. If a cohort is behaving strangely, check whether it is playable before reaching for a market explanation.

### Regional markets are separate markets

Japanese and English printings are different products with different prices, and non-US venues frequently price in another currency. The reference implementation excludes `ebay_hk` for exactly this reason — ~3× lower and 99.7% FX-converted. **Do not pool regions to gain sample.** That is the sparsity trap wearing a disguise.

---

## 3. Folk claims register

Received wisdom, held to the same standard as everything else here. **Status is the point of this table** — most of it has not been tested, and saying so is the useful contribution.

| Claim | Status | Evidence |
|---|---|---|
| "eBay is the better price reference for chase cards; TCGplayer for cheap ones" | **Confirmed** | The anchor migrates with price band. eBay's volume share runs 75% → 91% from `<$10` to `$250+`, and TCGplayer's share of the error correction rises 4% → 38%. It never fully flips. `findings.md` |
| "Vintage is the scarce, appreciating end of the market" | **Confirmed, and strong** | Sets 10+ years old returned **+2.19%/14d (eBay) and +1.39% (TCGplayer)** against +0.33% / 0.00% for everything younger. 84–85 sets, confirmed independently on both venues. See §4 |
| "Old cards barely exist in raw NM" | **Confirmed** | Raw-NM share is 29.4% (vintage) and 30.3% (mid era) against ~65% for the two newest eras — with the mechanism visible in the graded premium (PSA 10 at **68.8×** NM for vintage vs 9.35× modern). For old cards the graded market *is* the market |
| "New sets bleed for months after release, then stabilize" | **UNTESTED — do not repeat as fact** | Only 3 sets in the reference window are under 6 months old, and all three are Mega Evolution. Set age and cohort are the same variable; the apparent −2.3%/14d for fresh sets is one cohort's drawdown, not a decay curve. Needs a window spanning several release cycles |
| "Cheap laggards mean-revert toward their set" | **Retracted** | Tested and false in this window. `corr(trailing, forward) = +0.20` — continuation, not reversion |
| "Grading is free money on a clean copy" | **Untestable here, and structurally doubtful** | The multiple is real but hugely dispersed (PSA 10 p25–p75 = 4.8×–16.6×), and `P(grade)` is not in the data. The fixed cost also floors the viable card price |
| "Sealed product beats singles long-term" | **Out of scope** | No sealed data in the reference implementation. Do not extrapolate from singles |
| "Population reports tell you scarcity" | **Use with care** | Populations only ratchet up, cracking and regrading make them drift, and at least one grader's table is empty in the reference implementation |

---

## 4. The set-age result

Measured 2026-08-02, matched-model and venue-neutral, `pd 5–11`, cards with ≥4 sales per venue-period.

| Set age | Venue | Obs | Sets | Median %/14d | % up |
|---|---|---|---|---|---|
| 10+ yr | ebay | 13,050 | 84 | **+2.19%** | 53.0% |
| under 10 yr | ebay | 22,762 | 66 | +0.33% | 52.7% |
| 10+ yr | tcgplayer | 9,928 | 85 | **+1.39%** | 54.0% |
| under 10 yr | tcgplayer | 48,498 | 69 | 0.00% | 43.3% |

**What this supports:** a vintage/modern split in returns, on 84–85 sets, present independently on both venues (the standing rule from `methodology.md` §2).

**What it does not support:** a smooth decay curve in set age. The intermediate buckets are flat — 6–11 mo `+0.03%`, 1–2 yr `+0.12%`, 2–5 yr `0.00%`. **The effect is a step at the vintage end, not a gradient.** Anyone selling you a "sets decay for N months then recover" curve is fitting noise to three sets.

**Standing caveats apply in full** (`methodology.md`): one regime, six periods, no observed drawdown. A vintage bull market and a vintage risk premium look identical over three months.
