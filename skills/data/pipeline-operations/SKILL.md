---
name: data-pipeline-operations
description: Use when running multiple data pipelines/services on shared single-host infrastructure and reasoning about memory admission, concurrency caps, or capacity — sizing systemd MemoryMax/cgroup limits, building an admission gate that queues instead of skipping work, diagnosing OOM kills that only appear when several individually-fine pipelines coexist, or right-sizing caps from measured evidence instead of folklore. Covers subprocess/systemd-run scope accounting, wait-budget-vs-unit-timeout races, and the capacity ratchet loop (observe → cap generously → tighten on evidence). Don't use for single-pipeline internal memory tuning — that's the engine-specific skill (data-duckdb for DuckDB, data-apache-lakehouse's single-host section for PyIceberg writes) — or for Kubernetes/cluster resource management, which has different primitives than one host running several systemd-managed pipelines.
---

# Data pipeline operations — running N pipelines on shared infrastructure

Every pipeline skill in this family assumes it owns the host. It doesn't — it shares RAM, disk, and
CPU with every other pipeline and service on the box. This skill is the discipline for that
coexistence: admission control, capacity budgeting, and the operational failure modes that only show
up when several individually-correct pipelines run together. It's the multi-pipeline expression of
the **data** hub's cross-cutting principles, not a replacement for them.

> Verified 2026-07-02 during a production multi-pipeline stabilization engagement (systemd 252+,
> cgroup v2, one VPS running 15+ scheduled pipelines on 15G RAM). Code & the admission-v2 design:
> [`references/admission-and-budgets.md`](references/admission-and-budgets.md).

## When to invoke this skill

- Designing or debugging an admission gate that decides whether a pipeline run is allowed to start.
- OOM kills that don't reproduce when a pipeline runs alone — only under real scheduling.
- Sizing `MemoryMax` / cgroup caps for a systemd unit, or deciding whether to tighten an existing cap.
- A lock/queue wait that silently disappears — the run never errors, it's just gone.
- Any pipeline that spawns a subprocess or `systemd-run --scope` child and you're not sure what bounds its memory.
- Reviewing timers/schedules for a host running more than a couple of pipelines.

## Principles

Each is paired with a falsifiable test — if you can't pass it, the principle is violated, not "applied differently."

### Admission is claims-based, and claims are measured, not folklore

A pipeline declares how much memory it needs before it runs; an admission gate uses that claim to
decide whether there's room. A claim divorced from measurement is worse than no admission control at
all — it creates false confidence. Measured case: an admission gate believed a "10G" declared claim
while the unit's actual peak was 3.5G, and separately let a 7GiB claim consume an entire 7G pool
outright, starving every other pipeline in that pool for hours despite a code comment promising "one
at a time."

**Test:** is the declared claim within 1.5× of the unit's measured `MemoryPeak`? If it's off by more
than that, the claim is folklore, not a budget.

### Queue, don't skip — with a wait budget under the unit timeout

When there's no room, a well-behaved pipeline queues and waits for headroom rather than silently
skipping its run. But the wait itself needs a budget, and that budget must be strictly less than the
unit's own timeout, with margin. Measured failures at both ends: a 30-minute lock wait under a
20-minute `TimeoutStartSec` got the waiter reaped by systemd with no error signal beyond a bare exit;
separately, a 2-hour `TimeoutStartSec` killed a 602-day-long rebuild 3 minutes 46 seconds after its
staging phase had actually completed.

**Test:** is `wait_budget < TimeoutStartSec - margin` (production margin: 120s)? If not, a queued
waiter can be silently reaped by the unit timeout before it ever gets a verdict.

### Headroom-check before claim — never wait while holding one

Check for available headroom *before* taking a claim, not after. A pipeline that takes a claim and
then blocks waiting for something else can itself be the reason headroom never frees up — the
claim-equals-pool-starvation failure above is exactly this: the waiter took the claim first, then had
nothing left to give back.

**Test:** does the code check headroom and only then acquire, or acquire and then wait? If it waits
while holding a claim, that claim is unavailable to everyone, including a retry of the same run.

### Subprocess scopes escape cgroup accounting

A `systemd-run --scope` (or any child placed in its own scope) leaves the parent unit's cgroup. The
parent's `MemoryMax` and any admission claim sized to the parent silently stop covering that child —
memory it uses isn't counted against the budget that was supposed to bound it. This was found via
repo comment history describing defensive claim bumps made to compensate. Fix is one of two: size the
claim to cover the scope's own `MemoryMax` explicitly, or give the scope its own cap and account for
it as a separate budget line item — never assume the parent's claim covers it.

**Test:** does killing or capping the parent unit's cgroup actually bound memory used by its
`systemd-run --scope` children? If the children have their own cgroup, no — the claim or a scope-level
cap must cover them explicitly.

### Capacity ratchet: observe, cap generously, tighten on evidence

Day-one caps should be generous headroom, not a guess dialed tight. Tighten only when measured
evidence says so, and never while a congestion signal is red. Eligibility is a peak-vs-cap ratio
(<40% of cap = flag over-provisioned; >85% = flag under-provisioned) plus a stability window (RSS
slope <5%/24h sustained over 72h); congestion indicators — admission-timeout counts, PSI mem-full,
rising swap — are the back-pressure signal that overrides a tightening decision even when the ratio
looks fine. A deployed weekly ratchet run found a 23× over-provisioned unit (254 MB measured peak
against a 6G cap) on its first day.

**Test:** run the ratchet check on this unit. Is peak/cap < 0.40 with a stable 72h RSS slope and no
congestion signal red? Then it's a tightening candidate — otherwise leave the cap alone.

### Coexistence failure modes (no single pipeline shows these)

Each of these passes every per-pipeline test and only appears when pipelines run together on the same
host.

| Failure mode | Symptom | Measured evidence |
|---|---|---|
| Timer stacking | Schedules overlap; theoretical peak demand sums past host RAM even though each pipeline is individually fine | 9 OOM kills/24h from schedules stacking 25–40G theoretical demand on 15G RAM |
| Sum-of-caps > RAM | Per-unit `MemoryMax` caps are each individually reasonable, but the sum exceeds host RAM | Slice caps summed to 17G on a 15G-RAM host |
| Claim-equals-pool starvation | A single claim sized to (or exceeding) an entire pool's budget blocks every other admission in that pool | A 7GiB claim equaled the entire fast-pool budget → 100% self-starvation for hours |
| Waiter reaped by unit timeout | A queued wait silently disappears — no error beyond a bare exit code, no alert | 30-min wait under a 20-min `TimeoutStartSec`; a 2h timeout also killed a 602-day rebuild 3m46s after staging completed |

## References

- **Admission control & capacity budgets** — the v2 admission design (pools, queue-not-skip, headroom
  check, claim-TTL crash recovery, runtime guard refusing capless units, distinct timeout exit code),
  the `verify_ratchets` capacity-tightening pattern, and SeaweedFS coexistence notes:
  [`references/admission-and-budgets.md`](references/admission-and-budgets.md)
- Shared cross-cutting principles (idempotency, resilience, bounded memory) → **data** hub.
- Single-host PyIceberg memory discipline for one pipeline's own writes → **data-apache-lakehouse**.
- DuckDB memory/thread budgeting for one pipeline's own queries → **data-duckdb**.
- Whether a table this pipeline writes should still exist → **data-table-lifecycle**.
