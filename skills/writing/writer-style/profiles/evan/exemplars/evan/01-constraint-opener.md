# Exemplar — constraint + scale opener

Index: payload-early, measured-constraint. Works for field-log / findings / design-brief.
Domain-agnostic shape (numbers are illustrative).

---

Three numbers set the problem before any architecture diagram: **170GB** on
object storage, **9** production pipelines, and an **8GB** writer memory cap
shared by ingest and promotion on one machine.

Heterogeneous marketplaces only make that cap tighter — no two sources share a
row shape, a cadence, or the same idea of what a “sale” is. The rest of the
design is about converging those writers without OOMing the box.
