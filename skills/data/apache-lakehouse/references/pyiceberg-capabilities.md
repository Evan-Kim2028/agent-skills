# PyIceberg capability matrix (version-sensitive)

> **Verified:** 2026-05-28 against PyIceberg 0.11.1, pyiceberg-core 0.8.0, Iceberg spec V2/V3.
>
> This file holds the claims most likely to age as PyIceberg releases. It is split out of
> `SKILL.md` on purpose: the architectural principles in the skill age slowly, but the table
> below ages every release. Re-check it against your installed version (`pip show pyiceberg`)
> before trusting it. The **Verify by** column turns "is this still true?" into a few seconds
> of grep/doc-check against your installed version.

When any of these changes in a future release, update **this table** and the **Verified** date
above — the prose in `SKILL.md` points back here rather than restating versions.

| Capability | Status `[v0.11.1 · 2026-05]` | Verify by |
|---|---|---|
| `expire_snapshots` | ✅ exists, but **metadata-only — does NOT physically delete orphaned data files** | `pyiceberg/table/maintenance.py`; the builder's `_commit` emits only `RemoveSnapshotsUpdate`, no `io.delete_file` |
| `remove_orphan_files` | ❌ absent — physical file GC still needs Spark/Trino/managed | `rg remove_orphan <site-packages>/pyiceberg` returns nothing |
| `rewrite_data_files` / compaction | ❌ not in PyIceberg | docs / `rg rewrite_data_files` |
| `rewrite_manifests` | ❌ not in PyIceberg | same |
| Equality delete read **or** write | ❌ unreliable — use COW upsert from Python, or a Spark/Flink hop for MOR | release notes; do not assume the Rust core changed this |
| Position delete read (MOR) | ⚠️ applied on read, but compact mixed-engine MOR before PyIceberg consumes | docs |
| `incrementalAppendScan` | ❌ Java-only; use a watermark column from Python | docs |
| Bucket / Truncate partition **write** | ❌ — do initial layout via Spark/Trino | docs |
| Branches & tags (`manage_snapshots`) | ✅ since 0.8 | `pyiceberg/table/__init__.py` |
| Puffin / Theta-sketch read/write | ❌ — don't pin a `COUNT DISTINCT` SLA to it | docs |
| `pyiceberg-core` (Rust) | ✅ dependency (0.8.0, pinned `<0.9`) — accelerates Parquet/Avro/metadata parsing under the hood; **does not** add delete-vector authoring or change the equality-delete limits above | `pip show pyiceberg-core`; `Requires-Dist` in pyiceberg METADATA |

**Re-verifying version-sensitive claims:** the fastest check is grepping the installed package — e.g.
`rg 'def expire_snapshot|remove_orphan' "$(python -c 'import pyiceberg,os;print(os.path.dirname(pyiceberg.__file__))')"`.
That is exactly how the matrix above was confirmed; redo it and update the **Verified** date when you bump PyIceberg.

## Additional gotchas — verified 2026-07-02, live production, PyIceberg 0.11.1

Found and reproduced during a production stabilization engagement, separate from the table above (that
table's own **Verified: 2026-05-28** stands for its own rows — these are additions, not a re-check of it).

| Capability / behavior | Status `[v0.11.1, live-verified 2026-07-02]` | Workaround / verify by |
|---|---|---|
| `table.inspect.all_files()` on high-snapshot-count tables | ⚠️ materializes stats columns across **all snapshots**, not just current — OOM'd a 3G cgroup on a 3,300-snapshot table | Stream file paths per **unique manifest** instead (manifests dedupe across snapshots: 331 manifests vs 3,300 snapshots in the measured table). Peak dropped from 3.0G+1G swap to 124–151MB (~24x headroom). Match `discard_deleted=True` semantics if replacing `all_files()` exactly. |
| `table.inspect.all_files()` on zero-manifest tables | ❌ raises pyarrow `ArrowInvalid: Must pass at least one table` | A zero-row `append()` creates a snapshot with 0 manifests. Guard the call, or catch `ArrowInvalid` and treat as an empty result. |
| `Table.dynamic_partition_overwrite` on non-identity transforms | ❌ raises `ValueError` on e.g. `MonthTransform` partitions | Use `table.overwrite(overwrite_filter=<row-predicate>)` scoped to the partition boundary (e.g. month-scoped read-merge-overwrite) instead — idempotent and safe at month boundaries. |
| Compaction via `UpdateSnapshot.overwrite()` | ⚠️ stamps `operation=overwrite`, **not** `operation=replace` | Snapshot-diff / data-only filters that must exclude compaction noise need to key on the rewrite-strategy summary marker, not bare `operation`. Foreign engines (Spark) expect `operation=replace` for compaction — the mismatch breaks cross-engine diff tooling that assumes it. |

**Verify by:** reproduce directly — `all_files()` OOM and the zero-manifest `ArrowInvalid` are both a
few lines against any table with the stated snapshot/manifest shape; the `dynamic_partition_overwrite`
`ValueError` reproduces on any table partitioned by a non-identity transform.
