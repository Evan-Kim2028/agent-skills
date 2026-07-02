# Admission control & capacity budgets — multi-pipeline coexistence

> Working design (v2, deployed) for admitting N pipelines onto one host's shared memory budget.
> Supersedes a v1 "budget flock" that treated claims as advisory — measured 10G declared vs 3.5G
> actual peak — and let one 7GiB claim starve an entire 7G pool for hours. Code shown for Python
> 3.11+ against systemd 252+ / cgroup v2; adapt paths and `systemctl show` field names on other
> systemd versions.

## Pools — partition the host budget, don't share one number

One shared "is there room" check across every pipeline lets a light job and a heavy job fight over
the same headroom. Partition the budget into pools sized to the pipeline classes that actually run:

```python
POOLS = {
    "fast":  {"budget_bytes": 7 * 2**30, "used": 0},   # short, frequent promotes
    "heavy": {"budget_bytes": 6 * 2**30, "used": 0},   # gold rebuilds, compaction
    "light": {"budget_bytes": 2 * 2**30, "used": 0},   # ingestion, small jobs
}
```

Sum of pool budgets must stay under host RAM with margin for the OS and non-admitted services — this
is the sum-of-caps failure mode from `SKILL.md`, and partitioning doesn't fix it by itself; someone
still has to check `sum(p["budget_bytes"] for p in POOLS.values()) < host_ram_bytes`.

## Runtime guards — refuse what can't be accounted for

```python
import subprocess

def _systemctl_show(unit: str, field: str) -> str:
    out = subprocess.run(["systemctl", "show", unit, "-p", field],
                          capture_output=True, text=True, check=True).stdout
    return out.strip().split("=", 1)[1]

def require_memory_max(unit: str) -> int:
    """Runtime guard: admission refuses to run units it cannot account for."""
    raw = _systemctl_show(unit, "MemoryMax")
    if raw in ("", "infinity"):
        raise RuntimeError(f"{unit} has no MemoryMax — admission refuses capless units")
    return int(raw)

def unit_timeout_s(unit: str) -> int:
    raw = _systemctl_show(unit, "TimeoutStartUSec")
    if raw in ("", "infinity"):
        raise RuntimeError(f"{unit} has no TimeoutStartSec — refusing admission (runtime guard)")
    return _systemd_time_to_s(raw)
```

A unit with no `MemoryMax` can't have a meaningful claim in the first place — refusing it at
admission time is cheaper than discovering it during the next coexistence OOM.

## Acquire — headroom check before claim, queue-not-skip, bounded wait

```python
import os, time, random, json, pathlib

CLAIM_DIR = pathlib.Path("/run/lake/claims")
WAIT_MARGIN_S = 120                 # keep wait budget under TimeoutStartSec by this much
ADMISSION_TIMEOUT_EXIT = 75         # distinct exit code -> OnFailure= alerts specifically on this

def headroom_bytes(pool: str) -> int:
    p = POOLS[pool]
    return p["budget_bytes"] - p["used"]

def acquire(pool: str, claim_bytes: int, unit: str) -> "Claim":
    require_memory_max(unit)                          # runtime guard, checked once per admission
    wait_budget = unit_timeout_s(unit) - WAIT_MARGIN_S
    if wait_budget <= 0:
        raise RuntimeError(f"{unit} timeout too tight to leave a wait budget after margin")
    deadline, backoff = time.monotonic() + wait_budget, 1.0
    while True:
        # headroom is checked BEFORE the claim is taken — never wait while already holding one
        if headroom_bytes(pool) >= claim_bytes:
            return _take_claim(pool, claim_bytes, unit)
        if time.monotonic() > deadline:
            # queue-not-skip: this is a distinct, alertable failure, not a silent no-op
            raise SystemExit(ADMISSION_TIMEOUT_EXIT)
        time.sleep(backoff * (1 + 0.25 * random.random()))   # jittered backoff
        backoff = min(backoff * 1.5, 15.0)

def _take_claim(pool: str, claim_bytes: int, unit: str) -> "Claim":
    POOLS[pool]["used"] += claim_bytes
    claim_id = f"{pool}-{unit}-{int(time.time() * 1000)}"
    CLAIM_DIR.mkdir(parents=True, exist_ok=True)
    (CLAIM_DIR / f"{claim_id}.json").write_text(json.dumps({
        "pool": pool, "bytes": claim_bytes, "unit": unit, "pid": os.getpid(),
        "ts": time.time(), "ttl_s": 3600,          # crash recovery: a reaper drops stale claims
    }))
    return Claim(claim_id, pool, claim_bytes)

def release(claim: "Claim") -> None:
    POOLS[claim.pool]["used"] -= claim.claim_bytes
    (CLAIM_DIR / f"{claim.claim_id}.json").unlink(missing_ok=True)
```

`SystemExit(75)` rather than a swallowed skip is the queue-not-skip contract made concrete: the caller
(a systemd `ExecStart` wrapper) sees a distinct exit code, `OnFailure=` fires an alert, and nothing
about the run looks like a quiet success.

## Claim-TTL crash recovery (reaper)

A process that dies holding a claim never calls `release()`. A periodic reaper drops claims past
their TTL so the pool doesn't slowly starve from crashed holders:

```python
def reap_stale_claims(now: float | None = None) -> int:
    now = now or time.time()
    reaped = 0
    for f in CLAIM_DIR.glob("*.json"):
        c = json.loads(f.read_text())
        if now - c["ts"] > c["ttl_s"]:
            POOLS[c["pool"]]["used"] -= c["bytes"]
            f.unlink()
            reaped += 1
    return reaped
```

## Subprocess scopes — claims must cover them explicitly

A `systemd-run --scope` child leaves the *parent* unit's cgroup. The parent's `MemoryMax` and any
claim sized to the parent no longer bound that child's memory — this was found via repo comment
history documenting defensive claim bumps made after the fact. Size the claim to the scope's own cap,
not the parent's expected footprint:

```python
def run_scoped(cmd: list[str], memory_max_gb: int) -> None:
    subprocess.run(["systemd-run", "--scope", "--quiet",
                     f"--property=MemoryMax={memory_max_gb}G",
                     "--property=MemorySwapMax=0", *cmd], check=True)

# claim_bytes passed to acquire() must be >= memory_max_gb here, not the parent process's own RSS —
# the scope is accounted separately by the kernel and the claim has to match that reality.
```

## Capacity ratchet — `verify_ratchets` pattern (weekly timer)

Cap generously on day one; tighten only on measured evidence, never while a congestion signal is red.

| Signal | Source | Threshold |
|---|---|---|
| Peak/cap ratio | `MemoryPeak` history JSONL (one line per run) | <40% → flag over-provisioned; >85% → flag under-provisioned |
| RSS slope | rolling window over the history JSONL | <5%/24h growth sustained over 72h = stable, eligible to tighten |
| PSI mem-full | `/proc/pressure/memory`, `full avg10` | any sustained nonzero value = congestion, do not tighten |
| Swap trend | `/proc/meminfo` `SwapFree` delta over the window | rising = congestion, do not tighten |
| Admission timeouts | count of exit-75 in the period | >0 = congestion (queue is backing up), do not tighten |

```python
def eligible_to_tighten(history: list[dict]) -> bool:
    """history: JSONL records with mem_peak, mem_max, ts, admission_exit_75 per run."""
    peak, cap = max(h["mem_peak"] for h in history), history[-1]["mem_max"]
    ratio = peak / cap
    slope = rss_slope_pct_per_day(history, window_h=72)     # implementation: linear fit over window
    congested = (read_psi_full_avg10() > 0
                 or swap_trend(history) > 0
                 or sum(h.get("admission_exit_75", 0) for h in history) > 0)
    return ratio < 0.40 and slope < 5.0 and not congested
```

Run this weekly as its own systemd timer, appending to the same history JSONL the admission gate
already writes `MemoryPeak` into. It found a 23× over-provisioned unit — 254 MB measured peak against
a 6G cap — on the first day it ran; the flag alone paid for building the loop.

## SeaweedFS coexistence notes

Object-store notes specific to running SeaweedFS alongside these pipelines on the same host — the
same "measured, not folklore" discipline applies to storage as to memory.

- **`GOMEMLIMIT` is a soft GC target, not a hard cap.** It does not bound mmap or other native
  allocations. Pair it with a cgroup `MemoryMax` backstop set *above* the historical peak first, and
  tighten only after a soak period — the same ratchet discipline as pipeline caps above.
- **Two `-dir` volumes on the same filesystem give 2× volume *slots*, zero extra capacity.** Combined
  with `volumeSizeLimitMB × max slots`, this can vastly overcommit the disk with no soft ceiling —
  the slot count looks like headroom that isn't there.
- **Deletes only tombstone; disk space returns at `volume.vacuum -garbageThreshold`.** The default
  threshold (0.3) means a volume under 30% garbage never reclaims space on its own — tune the
  threshold to actual delete/churn rate, don't leave it at the default and assume space comes back.
