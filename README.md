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
| [`data`](skills/data/data/SKILL.md) | Routing hub for data-engineering pipelines + the shared cross-cutting principles (idempotency, watermarks, schema fencing, resilience, bounded memory). Routes to `data-apache-lakehouse`, `data-api`, and `data-duckdb`. |
| [`data-apache-lakehouse`](skills/data/apache-lakehouse/SKILL.md) | Designing, modifying, and debugging Apache Iceberg lakehouses — PyIceberg + Polars/DuckDB medallion writes, catalog choice, maintenance, CDC, branching/WAP, schema evolution. Includes single-host operations (bounded-RAM writes, adaptive batching, systemd-timer maintenance, OCC retry, circuit-breaker/DLQ) and version-sensitive PyIceberg capabilities as bundled `references/`. |
| [`data-api`](skills/data/data-api/SKILL.md) | Consuming external APIs for ingestion (rate limits, backoff, pagination, response validation, idempotent landing) and serving gold data over HTTP (FastAPI + DuckDB, pushdown, keyset pagination, cache invalidation, factory routers). |
| [`data-duckdb`](skills/data/duckdb/SKILL.md) | DuckDB as a single-node analytical engine — memory/thread tuning, larger-than-memory spilling and its limits, Parquet read/write layout (pushdown, PER_THREAD_OUTPUT, row groups, the partitioned-write trap), connection-as-cache, EXPLAIN ANALYZE. |
| [`marketing`](skills/marketing/marketing/SKILL.md) | General marketing skill for positioning, websites, email, ads, sales copy, lead magnets, testimonials, referral loops, launches, and internal mission messaging. Routes to more specific marketing skills when they fit. |
| [`marketing-offers`](skills/marketing/offers/SKILL.md) | Source: Alex Hormozi, *$100M Offers*. Offer architecture for value proposition, pricing, bonuses, guarantees, scarcity, urgency, and naming. |
| [`marketing-storybrand`](skills/marketing/storybrand/SKILL.md) | Source: Donald Miller, *Building a StoryBrand*. Customer-narrative messaging for clarifying offers, one-liners, landing pages, CTAs, lead magnets, email sequences, testimonials, and internal mission narratives. |
| [`marketing-cashvertising`](skills/marketing/cashvertising/SKILL.md) | Source: Drew Eric Whitman, *Cashvertising Online*. Buyer-psychology and direct-response checks for ads, CTAs, opt-ins, credibility, pricing, and conversion pages. |
| [`marketing-contagious`](skills/marketing/contagious/SKILL.md) | Source: Jonah Berger, *Contagious*. STEPPS-based word-of-mouth, sharing, referral, PR, campaign, and valuable-virality strategy. |
| [`marketing-going-viral`](skills/marketing/going-viral/SKILL.md) | Sources: Brendan Kane, *The Guide to Going Viral*; Alex Hormozi, *$100M Playbook: Hooks*. Social content strategy using viral formats, Gold/Silver/Bronze research, hooks, retention, and performance-driver iteration. |

## Install

Symlink (or copy) any skill directory into your agent's skills folder. For Claude Code:

```bash
git clone https://github.com/Evan-Kim2028/agent-skills.git
ln -s "$PWD/agent-skills/skills/data/apache-lakehouse" ~/.claude/skills/data-apache-lakehouse
```

The `name:` field in each `SKILL.md` is the skill's identifier; the directory is organizational and need not match it (e.g. `skills/data/duckdb/` → `name: data-duckdb`).

