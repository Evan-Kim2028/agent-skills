# Exemplar — walkthrough mode (narrative how-to)

Index: steps + what becomes visible. Not a pure runbook.

---

## What we’re building

A small pipeline that reads one slot, extracts tip-like transfers, and plots where
they sit in the block. The point is not the library choice—it is seeing **position
structure** you cannot guess from a summary table.

### Step 1 — fetch the block

Pull block + transactions for a single slot from a free RPC. Freeze the slot id
in the notebook so reruns compare equal.

### Step 2 — extract the fee/tip fields

Walk instructions; keep only the accounts and lamports that match the tip pattern.
If the pattern misses, log the miss rate—silent empty charts are worse than a
partial extract.

### Step 3 — chart index vs amount

What shows up: tips are not uniform. A cluster often sits toward the end of the
block. That visibility is the deliverable; the code is the means.

## Appendix shape

Keep the full extract function and the slot id next to the post so someone else
can reproduce the chart—not only the conclusion.
