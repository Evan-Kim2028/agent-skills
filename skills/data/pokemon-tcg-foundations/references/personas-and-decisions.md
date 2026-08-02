# Personas: who asks, and what answer is actually useful

The analysis in this skill is worthless if it comes back as a rank IC. Nobody buying cards has a Sharpe ratio. **The measurement is ours; the decision is theirs**, and the four people who ask are optimizing different things — sometimes opposite things.

Get the persona wrong and a technically correct answer is still the wrong answer.

---

## The four personas

| | **Collector** | **Flipper / trader** | **Vendor / dealer** | **Grader** |
|---|---|---|---|---|
| Optimizing | the collection | spread per flip | inventory turns | grade uplift |
| Horizon | years — often never sells | days to weeks | weeks, forced | 1–6 months (turnaround) |
| Worst outcome | overpaying on a grail; a reprint | dead inventory | capital stuck in slow stock | a 9 when they modelled a 10 |
| Cares about price? | as a *fairness* check | as the whole game | as a *margin* | only the raw↔slab gap |
| What kills them | reprint risk | no exit liquidity | 200 copies of a $2 card | pop-report inflation |
| Right output | "is this a fair ask right now" | "buy under $X, sell over $Y" | "what moves in <30 days" | "EV of grading vs raw price" |

### Collector

Buys to keep. Price matters as a **fairness check at the moment of purchase**, not as a return. Master-set completion means they will buy the card at *some* price eventually — so "wait for a better entry" is real advice, and "this will go up 8%" is noise to them.

**What they actually want:** is this ask above or below where this card has been clearing, and is it about to get cheaper.

**The error that hurts them:** telling them something is a good *investment*. They didn't ask. A collector who buys on your price signal and then watches a reprint halve it blames you correctly.

### Flipper / trader

The persona this skill was originally built for. Buys to sell, usually in person or same-platform, on a spread. Fees may be zero (cash, in person) or 13%+ (eBay).

**What they actually want:** a **buy-under price and a sell-over price**, plus an honest read on how long the exit takes.

**The error that hurts them:** a percentage. `+5%` on a $3 card is fifteen cents and not worth the drive. Always convert to **dollars per card**, and state the hit rate at their threshold — see the dollar-economics table in `SKILL.md`. This is why the reference implementation's decile tables report `$` and `% ≥$2` alongside `%`.

### Vendor / dealer

Holds inventory, has capital tied up, pays fees on every sale, and is judged on **turns, not appreciation**. Will happily take a 15% margin twelve times a year over a 60% margin once.

**What they actually want:** velocity. Sales-per-week at a given price, how deep the demand is, and what is *slowing* — the avoid-list matters more than the buy-list, because their failure mode is a shelf of unsellable commons.

**The error that hurts them:** ranking by expected return without liquidity. The top of a return ranking is frequently thin, illiquid stock with three sales a month. That's a great trade and a terrible inventory.

**This is the persona best served by the short side.** The reference implementation's composite is markedly stronger at picking losers than winners — for a trader that's an avoid-list, but for a vendor it is directly actionable: don't restock these.

### Grader

Buys raw, submits, sells slabbed. A pure spread business with a **long, uncertain lag** and a probability distribution over outcomes.

**What they actually want:** expected value of submitting, against the raw price:

```
EV = Σ_g  P(grade = g) × net_price(g)  −  grading_cost  −  fees  −  shipping
decide: EV vs (raw price now, sold today)
```

Every term is estimable except `P(grade = g)`, which depends on the physical card in hand. **This is where analysis must stop and defer** — condition assessment is a skill, not a column. What we *can* supply is `net_price(g)` per era (`sparsity-and-eras.md` §4) and the population context.

**The error that hurts them:** quoting a graded premium as if it were reliable. Graded legs have roughly double the card-to-card dispersion of condition legs (IQ spread 3.5–4.3 vs 1.5–2.0). A median PSA 10 multiple of 9× hides a p25–p75 range of 4.8×–16.6×. Give them the distribution or give them nothing.

---

## Translating their question into ours

People do not ask in factor language. The translation is usually lossy in one specific way — **they ask about a card, we can only answer about a cohort.**

| They say | They mean | We measure |
|---|---|---|
| "Is this a good buy?" | is the ask below fair value | current ask vs trailing clearing distribution for that card |
| "Is this card heating up?" | short-horizon direction | venue-neutral matched-model momentum, *and* the set's regime — the set usually dominates |
| "Is this set gonna pop off?" | set-level regime change | set trend + breadth + acceleration (`findings.md`) |
| "What's it worth?" | a single number | there isn't one — it's a distribution across condition, venue, and grade. Quote a median **and** a spread |
| "What are the comps?" | recent sold prices | last N *sold* (never asks), same condition, same venue, outlier-fenced |
| "Should I grade it?" | EV of submission | see above — and defer on `P(grade)` |
| "Is this cooked?" | has the run ended | negative acceleration with breadth still high = cooling, not dead |
| "Is it a good long-term hold?" | 3–10 year view | **we cannot answer this.** Our usable window is months. Say so |

**That last row is the important one.** The single most common question in this hobby is the one the data cannot support. A six-period panel says nothing about a five-year hold, and no amount of modeling changes that. Decline it explicitly rather than extrapolating a 14-day coefficient.

---

## Where their frame beats ours

Three things the culture knows that a price panel cannot see, and that should override a model output:

1. **Reprint risk.** Modern print runs respond to demand (`domain-knowledge.md`). A card can be cheap, trending, and about to be reprinted into oblivion — and no column in the tape knows the print schedule. A collector who says "I'm not touching that, it's in the next set" has better information than the model.
2. **Playability and rotation.** Tournament legality moves demand on a published calendar that is entirely exogenous to the tape.
3. **Condition in hand.** Every price we compute is conditioned on a *stated* grade from a listing. The person holding the card can see centering, whitening and print lines that no listing string captures.

**Treat all three as veto inputs, not features.** They are not in the data, they are knowable, and they are frequently decisive.

---

## Where our frame beats theirs

And three where the measurement wins, all documented in `methodology.md`:

1. **"Comps" are usually a biased sample.** Eyeballing the last few sold listings mixes venues, conditions and lots, and anchors hard on the most recent. Matched-model, venue-neutral, outlier-fenced is simply a better estimate of the same thing they are trying to estimate.
2. **Set beta is invisible from inside.** People attribute set-wide moves to individual cards constantly — "my Charizard is up 30%" when the whole set is up 28%. Roughly a third of forward variance is set-level. Within-set IC is the honest measure of card selection.
3. **Sticky prices masquerade as a stalled market.** More than half of cards show *exactly* 0% week-over-week on ask-driven venues. Weekly eyeballing therefore reads "dead" during a live move.
