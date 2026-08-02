# The asset class, for someone building models on it

`data-quality.md` covers defects in a given tape. `methodology.md` covers analytical traps. **This file covers neither — it is about what card markets *are*, structurally, and which standard modeling assumptions they violate.**

Written for someone arriving with an ML or quant background. Most of the surprises come from assumptions that are so safe in equities they are never stated.

> **Ref impl** — measurements below are from the Pokémon TCG lakehouse in [`reference-implementation.md`](reference-implementation.md). Magnitudes are order-of-magnitude priors; the structural properties are the transferable part.

---

## 1. It is a point process, not a time series

Prices arrive when someone happens to transact. There is no close, no fixed grid, no continuous quote. **Every "price series" in this domain is a grid you imposed on event data**, and the imposition is where most of the noise enters.

**Consequence.** Reaching for ARIMA / LSTM / temporal transformers means fitting a model to an artifact of your own bucketing. The genuinely native model classes are **hazard and survival models** (time-to-sale), **point processes** (arrival intensity), and **hierarchical cross-sectional models** — not sequence models on a resampled grid.

**Arrival intensity is itself a signal, and often a better one than price.** How *often* a card trades responds to demand faster than what it trades at. In the reference implementation, volume growth is one of only three factors that survived skip-testing, and it is nearly orthogonal to momentum (`corr = −0.021`).

## 2. Observation is endogenous — missingness correlates with the outcome

A card appears in your panel *because* someone wanted it. This is selection on the dependent variable, and it is not subtle.

> **Ref impl.** Does this period's return predict whether the card trades **at all** next period? Quintiles of 14-day return, ≥4 sales per cell:
>
> | Return quintile | Range | Trading next period |
> |---|---|---|
> | 1 (worst) | −662% … −30% | 93.6% |
> | 2 | −30% … −5% | 94.9% |
> | 3 | −5% … +2.9% | **95.4%** |
> | 4 | +2.9% … +16% | 94.7% |
> | 5 (best) | +16% … +510% | **89.3%** |
>
> **Inverted U — big movers in both directions disappear, and winners disappear most.** A card that just spiked is 6 points less likely to trade again than a flat one.
>
> Dropout also rises steeply with price, at nearly identical sales counts per cell:
>
> | Price band | Cells | Avg sales/cell | Trading next period |
> |---|---|---|---|
> | <$2 | 48,301 | 14.7 | 93.0% |
> | $2–10 | 25,327 | 19.4 | 90.5% |
> | $10–50 | 13,058 | 20.6 | 87.7% |
> | $50+ | 5,256 | 19.0 | **81.5%** |

**Two consequences, both serious.**

- Any model trained on `(features_t → return_{t+1})` is trained on the subsample that *traded again*, and that subsample is selected on both the signal and the price. Your backtest silently drops the spikes.
- **The panel systematically loses expensive cards** — exactly the ones with tradeable dollar spread (`SKILL.md`, dollar economics).

**What to do.** Model the hazard explicitly rather than filtering it away: a two-stage setup (P(trades again) × E[return | trades]) is honest where a single regression is not. At minimum, report dropout by signal decile so the selection is visible.

**And do not read a card ceasing to trade as a price decline.** It is equally consistent with supply withdrawal — holders pulling listings after a run. The data cannot distinguish these, which is a genuine identification problem, not a gap to paper over.

## 3. Cold start is the normal case, not an edge case

New sets release continuously. Every release is a batch of assets with **zero price history**, and they are frequently the most-demanded assets in the market.

> **Ref impl:** over just three months, 82.0% of cards present at the start were still present at the end, and **14.3% of the ending universe was new.**

**Consequence.** A model that requires 12 months of history to score a card cannot score the cards people most want scored. **Hierarchical / partial-pooling models earn their keep here specifically** — they give a new card its set's and rarity's prior instead of no answer at all.

## 4. The observed return distribution is mostly measurement error

> **Ref impl** — 14-day log returns, ≥4 sales both periods, 68,521 observations:
>
> | p01 | p25 | median | p75 | p99 | kurtosis | skew | exactly 0% |
> |---|---|---|---|---|---|---|---|
> | −239.6% | −20.3% | 0.00% | +11.4% | +155.5% | 9.0 | −1.22 | 4.9% |

An interquartile range of −20% to +11% over two weeks is not a description of how card prices move. **Split-half reliability for momentum is ~0.70** (`methodology.md` §7), so roughly 30% of that variance is sampling noise in the median, and the extreme tails are dominated by thin cells and variant contamination rather than by market moves.

**Consequences.**

- **Denoise or shrink before modeling.** Feeding raw cell medians to a flexible learner mostly teaches it the noise.
- **Evaluate against the reliability ceiling, not against zero.** At reliability 0.70 the maximum achievable correlation with true momentum is √0.70 ≈ 0.84. An IC of 0.25 against a 0.84 ceiling is a very different result from an IC of 0.25 against 1.0.
- Fat tails here are **mostly a data property, not a market property.** Do not build a tail-risk story on kurtosis 9 without first checking whether the tails are single-cell artifacts.

## 5. Your weighting choice can flip the sign of the answer

> **Ref impl**, same universe, same window, three defensible aggregations:
>
> | Equal-weight mean | Dollar-weight mean | Median |
> |---|---|---|
> | **−7.65%** | **+3.18%** | 0.00% |

**The market went down, up, or nowhere depending on a choice most people make without noticing.** Equal-weighting is dominated by the enormous population of cheap, thinly-traded cards; dollar-weighting reflects where money actually sits; the median says most cards did not move.

**None of these is wrong.** They answer different questions — "the typical card," "the typical dollar," "the typical outcome." **State which one you chose and why**, and if a headline result depends on the weighting, that is the finding.

## 6. Prices span ~6 orders of magnitude

> **Ref impl:** $0.01 to $8,414.90 across card-period medians; median $1.75, p99 $215.

**Consequences.** Log space is mandatory, not a preference. Squared-error loss in price space optimizes almost exclusively for the expensive tail and ignores the bulk of the catalogue. And any single scalar threshold — a $2 spread, a $20 cap — is meaningful only within a band.

## 7. Effective breadth collapses, twice over

Cards within a set move together, and sets are dominated by a handful of cards.

> **Ref impl:** ~34% of forward variance is set-level. And per set, the **top 3 cards hold a median 37.7% of dollar volume** (range 10.8% – 96.3%, 155 sets).

**A set index is frequently a three-card index.** Combined with `IR = IC × √breadth`, this means a panel of 25,000 card-periods does not give you anything like 25,000 independent bets — breadth is closer to the number of sets, and even that overstates it when one chase card drives the set.

**Consequence for model selection.** This is the core reason gradient boosting and deep nets underperform here: the effective sample is two to three orders of magnitude smaller than the row count, and those methods have no way to know that. Panel regression with set fixed effects and hierarchical models encode the correlation structure explicitly.

## 8. You cannot short, and there are no derivatives

No borrow, no options, no futures, no index products. **The only positions are long and flat.**

**Consequence.** The standard evaluation — long-short decile spread — reports a number you cannot monetize. In the reference implementation the short side is substantially stronger than the long side, which is a real finding but is only harvestable as *not buying* and, for a dealer, *not restocking*. Report long-leg-only performance alongside any spread, or the backtest overstates what is achievable.

## 9. The asset transmutes, and supply migrates between its forms

A raw card can be graded and become a PSA 10 — the same physical object moves to a different, higher-priced leg of the same identity. This is a **state transition, not a trade**, and it permanently removes supply from the raw pool.

**Consequences.** Card identity is not a fixed asset over time: the raw supply of old cards drains as the good copies get encapsulated. This is the mechanism behind the era structure in `sparsity-and-eras.md` — vintage raw NM share of ~29% is not an accident of collection, it is decades of the best copies migrating into slabs. Population reports only ratchet upward and drift further as slabs are cracked and resubmitted.

## 10. Supply is elastic and undisclosed for modern, fixed and unknown for vintage

Print runs are not published. Modern product is reprinted in response to demand; vintage supply is fixed and slowly shrinking. **There is no supply variable in any tape**, and for modern cards the supply response is partly *caused by* the price appreciation you are modeling.

**Consequence.** Sustained modern appreciation fights an endogenous supply response that your model cannot see. Treat reprint risk as a veto input (`domain-knowledge.md`), not as unexplained residual.

## 11. There is no consolidated tape, and history cannot be bought later

No NBBO, no regulator, no audit trail, no official print of record. Every dataset is a scrape of venues that each purge their own sold history — commonly on the order of **90 days**.

**This is the single most consequential fact for a research program.** You cannot back-fill what you did not collect. Deep history exists only where someone was already capturing it, and identity resolution against older rows degrades badly (in the reference implementation: <1% resolved before 2025, 55% in 2026).

**Consequences.**

- **Regime scarcity is structural, not temporary.** Card markets run multi-year boom/bust cycles; a tape that becomes joinable in one year contains one regime, and no modeling choice fixes that. Every coefficient in this skill carries that caveat for exactly this reason.
- **Start capturing now, broadly, before you know what you need.** Storage is far cheaper than a year of unrecoverable history. This is the highest-return decision available to anyone starting out — higher than any model choice.

## 12. Two leakage sources specific to this domain

- **Platform "market price" columns.** Most datasets carry a precomputed mark. It is derived from the same sales you are predicting, on an undisclosed lag and filter. Using it as a feature leaks; backtesting against it is circular. Re-derive from the sale-level tape.
- **Population and rollup aggregates** that are recomputed in place rather than snapshotted. If the column reflects *today's* value on a *historical* row, it is future information. Check whether any aggregate you use is point-in-time before it enters a feature set.

## 13. The largest price drivers leave no data footprint

Reprint announcements, format rotation, tournament results, a popular video, a celebrity opening packs. These move prices sharply and appear in **no column of any tape.**

**Consequence.** There is an irreducible error floor here that is not a modeling failure. Recognizing it is what keeps a research program from burning months chasing R² that does not exist. The tractable work is in the parts that *are* observable — cross-venue structure, condition ladders, arrival intensity — which is why those are what this skill documents.

---

## What this adds up to

**Small effective sample, heavy measurement error, endogenous observation, one regime, long-only, and unobservable primary drivers.**

That combination argues for a specific posture: simple, well-regularized, hierarchical models; features built from *disjoint transaction sets* so bounce cannot contaminate them; evaluation against a measured reliability ceiling; and honest reporting of which weighting and which universe produced the number.

It argues against flexible learners on a wide feature matrix, which will fit the noise convincingly and fail out of sample. That is not conservatism — it follows from the properties above, each of which is measurable on your own tape before you write a model.
