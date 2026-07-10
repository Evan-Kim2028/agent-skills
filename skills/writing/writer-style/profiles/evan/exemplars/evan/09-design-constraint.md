# Exemplar — design-brief mode

Index: constraint forces technique; capability bound early.

---

## TL;DR

Offline we fit a near-optimal rational approximation; on-chain we evaluate it in
fixed-point Horner form. Error bound on the order of **1e-9** for the CDF path—
not “fast enough vibes,” a stated tolerance.

## Part I — The constraint

No floats. Inverse functions amplify error. Randomness must be uniform enough
that the transform does not paint artifacts into prices. Those three constraints
kill “just call SciPy on-chain.”

## Part II — Technique that fits the constraint

AAA (or equivalent) chooses nodes/weights offline against a high-precision
baseline. On-chain code only evaluates the frozen rational form. Transcendentals
in the same pipeline philosophy: approximate once, evaluate cheaply, keep the
bound explicit.

## Part III — Why this shape

Oracles and off-chain pricing dodge the constraint; they also reintroduce trust
and latency. If the product needs atomic on-chain evaluation, the approximation
pipeline is not optional cleverness—it is the only shape that survives the
constraint set.
