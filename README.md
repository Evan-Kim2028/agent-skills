# agent-skills

A personal, growing collection of [agent skills](https://docs.claude.com/en/docs/claude-code/skills) — portable, model-agnostic knowledge packs I use across coding agents (Claude Code, Cursor, etc.).

This started as data/lakehouse work and will accumulate whatever domains I happen to be working in.

## Layout

Each skill is a directory containing a `SKILL.md`, following the
[Agent Skills spec](https://docs.claude.com/en/docs/claude-code/skills). This is what
makes a skill discoverable and installable — a bare `.md` file is not.

```
skills/
  <category>/
    <skill-name>/
      SKILL.md          # YAML frontmatter (name + description) and the skill body
      references/       # optional: bulky, on-demand material kept out of SKILL.md
```

## Skills

| Skill | What it's for |
|-------|---------------|
| [`data`](skills/data/data/SKILL.md) | Routing hub for data-engineering pipelines + the shared cross-cutting principles (idempotency, watermarks, schema fencing, resilience, bounded memory, layered enforcement). Routes to `data-apache-lakehouse`, `data-api`, `data-duckdb`, `data-pipeline-operations`, `data-table-lifecycle`, and `data-semantic-quality`. |
| [`data-apache-lakehouse`](skills/data/apache-lakehouse/SKILL.md) | Designing, modifying, and debugging Apache Iceberg lakehouses — PyIceberg + Polars/DuckDB medallion writes, catalog choice, maintenance, CDC, branching/WAP, schema evolution. Includes single-host operations (bounded-RAM writes, adaptive batching, systemd-timer maintenance, OCC retry, circuit-breaker/DLQ) and version-sensitive PyIceberg capabilities as bundled `references/`. |
| [`data-api`](skills/data/data-api/SKILL.md) | Consuming external APIs for ingestion (rate limits, backoff, pagination, response validation, idempotent landing) and serving gold data over HTTP (FastAPI + DuckDB, pushdown, keyset pagination, cache invalidation, honor of write-time quality attributes, publish-coupled serving sidecars, bounded/thread-safe caches, factory routers). |
| [`data-duckdb`](skills/data/duckdb/SKILL.md) | DuckDB as a single-node analytical engine — memory/thread tuning, larger-than-memory spilling and its limits, Parquet read/write layout (pushdown, PER_THREAD_OUTPUT, row groups, the partitioned-write trap), connection-as-cache, EXPLAIN ANALYZE. |
| [`data-pipeline-operations`](skills/data/pipeline-operations/SKILL.md) | Running multiple pipelines on shared single-host infrastructure — claims-based memory admission control, capacity pools, queue-not-skip with bounded wait, subprocess/systemd-run scope accounting, and the capacity ratchet loop (observe → cap generously → tighten on evidence). |
| [`data-table-lifecycle`](skills/data/table-lifecycle/SKILL.md) | The consumers-or-deprecate discipline for table/artifact retirement — adversarial consumer sweeps, the drop-durability (auto-resurrection) trap, metadata-vs-physical drop cleanup, and catalog-generated maintenance coverage. |
| [`data-semantic-quality`](skills/data/semantic-quality/SKILL.md) | Portable **semantic** (row-truth) data quality methodology — write-time quality attributes, single-sourced scoring, entity-scoped rules, provenance trust ladders, cohort-relative fences, golden packs with dual error budgets. Domain thresholds stay in product-repo skills. |
| [`marketing`](skills/marketing/marketing/SKILL.md) | General marketing skill for positioning, websites, email, ads, sales copy, lead magnets, testimonials, referral loops, launches, and internal mission messaging. Routes to more specific marketing skills when they fit. |
| [`marketing-offers`](skills/marketing/offers/SKILL.md) | Source: Alex Hormozi, *$100M Offers*. Offer architecture for value proposition, pricing, bonuses, guarantees, scarcity, urgency, and naming. |
| [`marketing-storybrand`](skills/marketing/storybrand/SKILL.md) | Source: Donald Miller, *Building a StoryBrand*. Customer-narrative messaging for clarifying offers, one-liners, landing pages, CTAs, lead magnets, email sequences, testimonials, and internal mission narratives. |
| [`marketing-cashvertising`](skills/marketing/cashvertising/SKILL.md) | Source: Drew Eric Whitman, *Cashvertising Online*. Buyer-psychology and direct-response checks for ads, CTAs, opt-ins, credibility, pricing, and conversion pages. |
| [`marketing-contagious`](skills/marketing/contagious/SKILL.md) | Source: Jonah Berger, *Contagious*. STEPPS-based word-of-mouth, sharing, referral, PR, campaign, and valuable-virality strategy. |
| [`marketing-going-viral`](skills/marketing/going-viral/SKILL.md) | Sources: Brendan Kane, *The Guide to Going Viral*; Alex Hormozi, *$100M Playbook: Hooks*. Social content strategy using viral formats, Gold/Silver/Bronze research, hooks, retention, and performance-driver iteration. |
| [`frontend-design`](skills/frontend/frontend-design/SKILL.md) | Routing hub for frontend UI — design-system, product-ui-craft, web-quality, react-performance, visual-verify, mobile-product-ux, mockup-implement; also routes to html-design, prototype, tufte, browser-testing-with-devtools. Prefer over frontend-ui-engineering. |
| [`design-system`](skills/frontend/design-system/SKILL.md) | Stay on project tokens, typography, components, and brand locks; prefer over generic aesthetic skills when a design system exists. |
| [`product-ui-craft`](skills/frontend/product-ui-craft/SKILL.md) | Product micro-craft: spacing, hierarchy, density, states, restrained motion (Impeccable / make-interfaces-feel-better lineage). |
| [`web-quality`](skills/frontend/web-quality/SKILL.md) | A11y and interaction quality audits (Vercel web-interface-guidelines / WCAG practical checks). |
| [`react-performance`](skills/frontend/react-performance/SKILL.md) | React/SPA performance: waterfalls, bundles, re-renders, chart code-splitting (Vercel react-best-practices lineage). |
| [`visual-verify`](skills/frontend/visual-verify/SKILL.md) | Playwright e2e / visual snapshots / axe proof loops before claiming UI done. |
| [`mobile-product-ux`](skills/frontend/mobile-product-ux/SKILL.md) | Sticky chrome, sheets, safe areas, gestures, one-thumb product flows. |
| [`mockup-implement`](skills/frontend/mockup-implement/SKILL.md) | Port signed-off HTML/Figma/mockups into production with fidelity (no freestyle redesign). |
| [`html-design`](skills/design/html-design/SKILL.md) | Standalone HTML product-design iteration: before/after A/B compare pages, multi-variant switchers, floating picker bars — explore before production UI. |
| [`quality`](skills/qa/quality/SKILL.md) | **QA routing hub** — progressive disclosure into TDD, diagnose, browser/visual verify, web-quality, doubt-driven review, check-work, PR review, ship checklists, conversational issue filing (`qa`), data-semantic-quality. Shared principles for consumer interaction races (debounce × URL). |

## Install

Symlink (or copy) any skill directory into your agent's skills folder. For Claude Code / Grok:

```bash
git clone https://github.com/Evan-Kim2028/agent-skills.git
cd agent-skills

# Data pack (family-prefixed names match SKILL.md `name:`; dirs need not match)
for pair in \
  "data/data:data" \
  "data/apache-lakehouse:data-apache-lakehouse" \
  "data/data-api:data-api" \
  "data/duckdb:data-duckdb" \
  "data/pipeline-operations:data-pipeline-operations" \
  "data/table-lifecycle:data-table-lifecycle" \
  "data/semantic-quality:data-semantic-quality"
do
  src="${pair%%:*}"; name="${pair##*:}"
  ln -sfn "$PWD/skills/$src" ~/.claude/skills/"$name"
  ln -sfn "$PWD/skills/$src" ~/.grok/skills/"$name"
done

# Frontend pack (router + specialists) — Claude Code + Grok Build
for s in frontend-design design-system product-ui-craft web-quality \
         react-performance visual-verify mobile-product-ux mockup-implement; do
  ln -sfn "$PWD/skills/frontend/$s" ~/.claude/skills/$s
  ln -sfn "$PWD/skills/frontend/$s" ~/.grok/skills/$s
done

# Also route from frontend-design (install separately if present on machine):
#   html-design, tufte, prototype, browser-testing-with-devtools

# QA / quality pack (router only in this repo — specialists often live elsewhere)
ln -sfn "$PWD/skills/qa/quality" ~/.claude/skills/quality
ln -sfn "$PWD/skills/qa/quality" ~/.grok/skills/quality
# Specialists the hub routes to (install if not already present):
#   tdd, diagnose, doubt-driven-development, check-work, review,
#   visual-verify, browser-testing-with-devtools, web-quality, qa (issue filing),
#   implement-until-green, shipping-and-launch, security-and-hardening,
#   data-semantic-quality, ship-feature
```

The `name:` field in each `SKILL.md` is the skill's identifier; the directory is organizational and need not match it (e.g. `skills/data/duckdb/` → `name: data-duckdb`).

Install **frontend-design** alone if you only want the FE router (agents still need specialist dirs available to open). Prefer this hub over **frontend-ui-engineering**. For product apps with an existing brand, prefer **design-system** as the default specialist over generic public “anti-slop” frontend skills.

Install **quality** alone if you want the QA router. Invoke with `/quality` or natural language (“QA this”, “verify before ship”, “regression”). The hub only routes — specialists must be installed separately (same model as frontend-design → visual-verify).
