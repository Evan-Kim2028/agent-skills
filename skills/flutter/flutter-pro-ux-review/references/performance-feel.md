# Pass: perf

Conservative static rules only. Prefer primary lists. Do not demand micro-opts without evidence.

### Primary lists should scroll smoothly

`list-scroll-basics` · Noticeable on long primary feeds · Effort: M  
Fix in one phrase: long lists use builder constructors, avoid huge unsplit columns of widgets, prefer `ListView.builder` / slivers over `Column`+`map` of hundreds of children.

**Detect:** `Column(children: items.map` or `ListView(children: [...])` with large/dynamic collections on home/feed.

**Hunt:** grep `ListView(` without `.builder` / `.separated` near feeds; `Column` + `.map` in scroll views.

**Why:** jank and high memory feel like a cheap app.

**Gotchas:** short static sections (3–10 tiles) are fine as explicit children.

---

### Images: bound decode cost when possible

`image-decode-bounds` · Noticeable in image-heavy lists · Effort: S  
Fix in one phrase: pass `cacheWidth`/`cacheHeight` (or package equivalents) for list thumbnails so full-res decodes don’t thrash memory.

**Detect:** `Image.network` / cached image widgets in lists without cache size hints.

**Hunt:** image widgets inside `itemBuilder`s.

**Why:** decode jank and memory spikes on scroll.

**Gotchas:** full-screen heroes may intentionally load large images; focus on grid/list thumbnails.

---

### Avoid rebuild storms on trivial input (light touch)

`rebuild-scope` · Subtle–Noticeable · Effort: M  
Fix in one phrase: don’t wrap entire scaffolds in coarse `setState`/watch for a single field when a smaller subtree would do — flag only egregious cases.

**Detect:** whole-page `setState` on each keystroke for large forms; `AnimatedBuilder`/`watch` at root rebuilding heavy lists.

**Hunt:** large `StatefulWidget` screens with `onChanged: (_) => setState`; Riverpod `watch` at top of huge build methods for tiny fields.

**Why:** typing lag destroys form UX.

**Gotchas:** do not demand architecture rewrites; suggest local state or selecting narrower providers only.
