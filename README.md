# agent-skills

A personal, growing collection of [agent skills](https://docs.claude.com/en/docs/claude-code/skills) — portable, model-agnostic knowledge packs I use across coding agents (Claude Code, Cursor, etc.).

This started as data/lakehouse work and will accumulate whatever domains I happen to be working in.

## How install works (no automatic download)

**Nothing auto-downloads** when you open another repo or machine. Agents only see skills that are **already installed** under that environment’s skills folder (e.g. `~/.claude/skills`, `~/.grok/skills`).

| Situation | What happens |
|-----------|----------------|
| New computer / fresh agent | Empty skills dir until you clone this repo and run the install steps below |
| Another git repo on the same machine | Same global skills folder — already-installed skills apply; no per-repo fetch |
| After `git pull` on this repo | **Copies do not update themselves** — re-run install (or re-copy the skill dirs you care about) |
| Symlink install | Edits in this clone show up immediately; break if the clone path moves |

You choose which packs to install. Specialists stay on disk for progressive disclosure; **you only need to remember the four hubs**.

## Remember these four hubs

| Hub | Say this when… | Routes to |
|-----|----------------|-----------|
| **`data`** | Pipelines, lakehouse, DuckDB, ingest/serve APIs, ops, table lifecycle, row-truth quality | data-* specialists |
| **`frontend-design`** | Build / redesign product UI (tokens, craft, mobile, mockups, charts) | FE specialists |
| **`marketing`** | Offers, messaging, ads, viral, word-of-mouth | marketing-* specialists |
| **`quality-check`** | Prove it — TDD, diagnose, e2e/visual, review, ship, regressions | QA specialists (+ FE verify) |

**Build vs prove:** multi-step product features → `frontend-design` while implementing → `quality-check` before claiming done.

Specialist descriptions defer broad routing to these hubs so discovery does not fire five FE skills on “build a card page.”

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
| [`quality-check`](skills/qa/quality-check/SKILL.md) | **QA routing hub** (`/quality-check`) — route to TDD, diagnose, browser/visual verify, web-quality, doubt-driven, check-work, review, ship; L3 race-matrix. Portable hub + [companion install](skills/qa/quality-check/references/companion-install.md) with credit to [mattpocock/skills](https://github.com/mattpocock/skills), [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills), and this pack. |

## Install

**Copy** skill directories into the agent skills folder (real dirs — not symlinks).
Symlinks break when the clone moves and confuse some skill loaders.

```bash
git clone https://github.com/Evan-Kim2028/agent-skills.git
cd agent-skills

install_skill() {
  # usage: install_skill <src-relative-to-skills/> <installed-name>
  local src="$PWD/skills/$1"
  local name="$2"
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
    mkdir -p "$root"
    rm -rf "$root/$name"
    mkdir -p "$root/$name"
    cp -a "$src"/. "$root/$name"/
  done
  echo "installed $name"
}

# Data pack (family-prefixed names match SKILL.md `name:`)
for pair in \
  "data/data:data" \
  "data/apache-lakehouse:data-apache-lakehouse" \
  "data/data-api:data-api" \
  "data/duckdb:data-duckdb" \
  "data/pipeline-operations:data-pipeline-operations" \
  "data/table-lifecycle:data-table-lifecycle" \
  "data/semantic-quality:data-semantic-quality"
do
  install_skill "${pair%%:*}" "${pair##*:}"
done

# Frontend pack (router + specialists)
for s in frontend-design design-system product-ui-craft web-quality \
         react-performance visual-verify mobile-product-ux mockup-implement; do
  install_skill "frontend/$s" "$s"
done

# Also useful with frontend-design (install if present in this repo / machine):
#   html-design, tufte, prototype, browser-testing-with-devtools

# QA router — real copy into ~/.grok/skills/quality-check
install_skill "qa/quality-check" "quality-check"

# Recommended companions (Matt Pocock + Addy Osmani + FE specialists from this pack).
# Credits and tiers: skills/qa/quality-check/references/companion-install.md
bash skills/qa/quality-check/scripts/install-companions.sh        # minimum tier
# bash skills/qa/quality-check/scripts/install-companions.sh --full
```

Re-copy after pulling updates (copies do not auto-update).

### Companion packs (attribution)

| Pack | Credit | Repo |
|------|--------|------|
| This pack | Evan-Kim2028 | https://github.com/Evan-Kim2028/agent-skills |
| Engineering / TDD / diagnose / qa | Matt Pocock | https://github.com/mattpocock/skills |
| Browser DevTools, doubt, ship, security | Addy Osmani | https://github.com/addyosmani/agent-skills |
| check-work | Grok Build (bundled) | Product install |

The `name:` field in each `SKILL.md` is the skill's identifier; the directory is organizational and need not match it (e.g. `skills/data/duckdb/` → `name: data-duckdb`).

Install **frontend-design** alone if you only want the FE router (agents still need specialist dirs available to open). Prefer this hub over **frontend-ui-engineering**. For product apps with an existing brand, prefer **design-system** as the default specialist over generic public “anti-slop” frontend skills.

Install **quality-check** alone if you want the QA router. Invoke with `/quality-check` or natural language (“QA this”, “verify before ship”, “regression”). The hub only routes — specialists must be installed separately (same model as frontend-design → visual-verify). If a specialist is missing, the hub’s **If specialist missing** table defines fallbacks so the agent still executes a minimal proof path.
