# Exemplar — problem / fix / lesson (scar tissue)

Index: measured failure, write-shape fix, named lesson.

---

## Lesson 2

*Iceberg pays off on incremental, multi-namespace gold — only after silver can finish.*

**The problem.** Courtyard silver holds ~**8.4M** rows. Promote ticks died before
commit: **6.6GB RSS** on silver publish; ~**7GB** when upsert fell back to
copy-on-write; ~**5GB** reading wide columns when the curate step needed four.

**The fix.** Write-shape changes on the path to gold — column projection and
streaming reads (~5GB → ~1.5GB), partition overwrite instead of upsert where
bronze is append-only, day-bucket generators instead of materializing every
bucket, shorter per-lane timeouts while backlog exists.

**The lesson.** “Use Iceberg” is incomplete. Incremental commits and snapshot
isolation only pay off when every layer writes **bounded deltas** silver can
actually land — otherwise gold never advances.
