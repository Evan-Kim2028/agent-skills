# Exemplar — bake-off mode

Index: same task, parallel candidates, measured differential.

---

## Task

Run the same three queries: recent rows, array filter, filter + group aggregate.
Same window. Score latency and how much data each engine scanned.

### Query 1 — most recent rows

**Engine A.** Returned in ~2s; scanned a narrow tip of the table.  
**Engine B.** ~5s on the same shape.  
**Engine C.** Similar to B; UI slower to iterate.

### Query 2 — filter nested accounts

**Engine A.** Starts to pull ahead when the filter touches nested fields.  
**Engine B / C.** Correct results; higher scan and wall time.

### Query 3 — filter + groupby

**Engine A.** Clear win on this workload (~5s class vs ~15s class).  
The insight is not “A is best forever.” It is: **under aggregation-heavy shapes,
A’s engine/scan strategy dominates; for casual dashboard SQL, B may still be the
default because of ecosystem gravity.**
