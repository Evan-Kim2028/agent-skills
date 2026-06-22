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
| [`apache-lakehouse`](skills/data/apache-lakehouse/SKILL.md) | Designing, modifying, and debugging Apache Iceberg lakehouses — PyIceberg + Polars/DuckDB medallion writes, catalog choice, maintenance, CDC, branching/WAP, schema evolution. Includes single-host operations (bounded-RAM writes, adaptive batching, systemd-timer maintenance, OCC retry, circuit-breaker/DLQ) and version-sensitive PyIceberg capabilities as bundled `references/`. |
| [`marketing`](skills/marketing/marketing/SKILL.md) | General marketing skill for positioning, websites, email, ads, sales copy, lead magnets, testimonials, referral loops, launches, and internal mission messaging. Routes to more specific marketing skills when they fit. |
| [`marketing/storybrand`](skills/marketing/storybrand/SKILL.md) | StoryBrand-style customer-narrative messaging skill for clarifying offers, one-liners, landing pages, CTAs, lead magnets, email sequences, testimonials, and internal mission narratives. |

## Install

Symlink (or copy) any skill directory into your agent's skills folder. For Claude Code:

```bash
git clone https://github.com/Evan-Kim2028/agent-skills.git
ln -s "$PWD/agent-skills/skills/data/apache-lakehouse" ~/.claude/skills/apache-lakehouse
```

The directory name becomes the skill name, so it must match the `name:` in the frontmatter.

