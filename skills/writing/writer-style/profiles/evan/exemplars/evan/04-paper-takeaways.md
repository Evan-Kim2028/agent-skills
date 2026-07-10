# Exemplar — paper takeaways (theory notes)

Index: numbered claims, open questions, light personal digression.

---

I read a 2013 paper by Othman et al. that characterizes AMMs by three properties:
path independence, translation invariance, and liquidity sensitivity. These are
my takeaways.

## 1 — Three properties, not product branding

Path independence says the trader’s cost does not depend on splitting one trade
into many. Translation invariance shrinks spreads toward zero for the LP.
Liquidity sensitivity ties price impact to activity/volatility.

## 2 — You only get two of three

THEOREM 2.9: no pricing rule is translation invariant, path independent, **and**
liquidity sensitive. LMSR gets the first two and gives up the third.

## 3 — Open question left open

How does this map cleanly onto impermanent loss in CFMMs? I could not find a
direct bridge in the literature I checked. Closest pointers are concave LP
portfolio-value results — still not a full answer.
