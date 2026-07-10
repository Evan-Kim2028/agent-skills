---
name: html-design
description: >
  Iterate product UI with standalone HTML design prototypes — before/after A/B
  compare pages, multi-variant switchers, floating picker bars, and local serve —
  before committing production code. Prefer HTML over Markdown for visual product
  decisions (see Anthropic "unreasonable effectiveness of HTML"). Use when the
  user wants design options, before/after of a UI change, HTML mockups, design
  A vs B, switchable variants, visual product review, or runs /html-design.
  Also trigger for "compare designs", "mock this up in HTML", "show me before
  and after", or "design iteration". Not for production React routes (use
  prototype skill UI branch) or data viz charts (use tufte).
---

# HTML Design

Standalone **HTML artifacts** for product design iteration. The user judges
pixels in a browser, not prose in a chat. Default output is a single local HTML
file (or a small folder under `design/`) with an **A/B or multi-variant switcher**.

Inspired by [The unreasonable effectiveness of HTML](https://claude.com/blog/using-claude-code-the-unreasonable-effectiveness-of-html)
and repo `design/` compare patterns (e.g. floating A/B picker + `?design=`).

## When to use

| Use this skill | Not this skill |
|----------------|----------------|
| Before/after of a small product delta | Full production implementation |
| 2–5 visual options, switchable in one tab | Markdown design docs |
| Faithful mock of an existing page + one change | Speculative full redesign when user asked for minimal |
| Shareable local URL for review | In-app React `?variant=` routes → prefer `prototype` UI branch |

## Hard rules

1. **Match the ask's blast radius.** "Minimal connect" ≠ new page shell. If the
   user wants a small delta, **Design A = current**, **Design B = current +
   only that delta**. Highlight the delta; do not invent chrome.
2. **HTML first, code second.** Ship a viewable file before rewriting production.
3. **One surface to switch.** Floating picker or segment control — not separate
   files the user must open in two windows (optional dual links are fine as
   secondary).
4. **Mark throwaway.** Banner or title: prototype / design exploration.
5. **Serve and verify.** Start a local server, open the URL, confirm switcher
   works (keyboard + click). Paste the URL to the user.
6. **Capture the verdict.** When the user picks A/B/C, write one line into a
   nearby NOTES or chat: which design won and what to implement in prod.

## Workflow

### 1. Frame the question (one sentence)

Examples:
- "Does **Add to trade** on the existing card header feel right?"
- "Which settings density: compact list vs cards?"

If the user already rejected a direction, **do not revive it** as an option.

### 2. Choose compare mode

| Mode | When | URL pattern |
|------|------|-------------|
| **A/B before–after** | Change to an existing surface | `?design=a` / `?design=b` |
| **Multi-variant** | Exploring unknowns | `?design=a\|b\|c` (max 5) |
| **Side-by-side** | Need simultaneous view | CSS grid of iframes or split panes |

Default: **A/B before–after** for product deltas.

### 3. Build the artifact

Prefer **one HTML file** with:

1. Short top banner: question + what differs between designs
2. Faithful mock of the **real** page (copy structure, type scale, spacing,
   existing labels — pull from production components when available)
3. Variant surfaces toggled via `document.documentElement.dataset.design`
4. Fixed bottom **picker bar**: `A · Before` / `B · After` (+ C…)
5. Keyboard: `A`/`B`/`1`/`2`, optional deep-link `?design=`

Scaffold from [templates/ab-compare.html](templates/ab-compare.html).
Patterns and CSS snippets: [references/patterns.md](references/patterns.md).
What not to do: [references/anti-patterns.md](references/anti-patterns.md).

**Where to put files**

| Context | Path |
|---------|------|
| Repo has `design/` | `design/<topic>-ab.html` or `design/<topic>/` |
| No design folder | `design/<topic>-ab.html` at repo root, or `/tmp/<topic>-ab.html` |
| Grok / Claude session scratch | User-visible path under the workspace |

### 4. Serve

```bash
# Prefer project design server if present
./design/serve.sh          # often http://localhost:8765/design/...

# Generic fallback
python3 -m http.server 8765 --directory <parent-of-html>
```

Tell the user the full URL, e.g.  
`http://localhost:8765/design/<topic>-ab.html?design=a`

### 5. Verify in browser

- Load Design A — matches current product (no false "before")
- Switch to B — **only** intended delta appears
- Keys and picker both work; `?design=` sticky via `history.replaceState`
- Screenshot optional; URL is required

### 6. Iterate or absorb

- User feedback → edit the HTML (still not production)
- User accepts → implement the minimal production delta (e.g. one button + deep link)
- User rejects a branch → mark that HTML **REJECTED** in a one-line README note;
  do not keep pushing the heavy design

## Minimal delta checklist (before you claim "after")

- [ ] Design A has zero "NEW" affordances for the feature
- [ ] Design B changes only the agreed surface (e.g. one header action)
- [ ] Rest of page is shared chrome / placeholders, not a redesign
- [ ] Production path after accept is named (file + one-liner)

## Relation to other skills

| Skill | Relationship |
|-------|----------------|
| `prototype` | In-app / framework routes and logic sandboxes |
| `html-design` | **Standalone HTML** compare artifacts for product judgment |
| `tufte` | Quantitative charts — not general product chrome |
| `frontend-ui-engineering` | Production UI after a design is chosen |

## Done criteria

- User has a clickable local URL
- They can switch designs without asking you again
- Chosen design maps to a small, named production change (or explicit reject)
