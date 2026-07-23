# Pass: data

### Never let users see "null"

`never-show-null` · Critical · Effort: S  
Fix in one phrase: never render null/empty/`"null"` as user-visible text; use placeholder or hide the row.

**Detect:** `Text(...toString())`, string interpolation of nullable fields, or display of API strings that can be the literal `"null"`.

**Hunt:** grep `Text\([^)]*toString` and nullable model fields in widgets; check for missing guards.

**Why:** the word “null” is developer debris; empty holes look equally broken.

**Gotchas:** debug-only overlays and logger output are fine. Zero as a valid number is not null. Secondary metadata → still Critical if user-visible; lower only if clearly debug.

---

### Format dates for humans

`human-dates` · Noticeable · Effort: S  
Fix in one phrase: locale-aware relative or medium dates — never raw ISO/`DateTime.toString()` in UI.

**Detect:** `DateTime` / ISO-8601 strings shown via `toString()`, `toIso8601String()`, or fixed `yyyy-MM-ddTHH:mm` in widgets.

**Hunt:** grep `toIso8601String|DateTime\.now\(\)\.toString|Text\([^)]*DateTime`.

**Why:** ISO timestamps are for machines; users need human dates by context.

**Gotchas:** logs, filenames, and API payloads are not UI. Pick relative vs absolute from context (chat vs invoice).

---

### Format phone numbers for humans

`human-phones` · Noticeable · Effort: S  
Fix in one phrase: display phones with grouping; store digits separately if needed.

**Detect:** phone fields or list tiles showing continuous digit strings (8+ digits) with no spaces/dashes/parens formatting.

**Hunt:** grep `phone|mobile|tel` in UI; check `Text(` near those fields.

**Why:** raw digit blobs are hard to read and mistype.

**Gotchas:** don’t break `tel:` URIs or deep links that need E.164.

---

### Format numbers for humans + tabular figures

`human-numbers-tabular` · Noticeable · Effort: S  
Fix in one phrase: group thousands by locale; use tabular figures for values that tick or align in columns.

**Detect:** prices/counts via bare `toString()`; animated or column numbers without tabular figures when digit width shifts layout.

**Hunt:** grep price/amount/balance/count `Text(` and `toString()`; check changing metrics in headers.

**Why:** layout jumps when “9” becomes “10”; misaligned columns destroy scanability.

**Gotchas:** decorative one-off numbers in marketing copy may stay proportional.
