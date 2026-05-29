# agent-skills

A personal, growing collection of [agent skills](https://docs.claude.com/en/docs/claude-code/skills) — portable, model-agnostic knowledge packs I use across coding agents (Claude Code, Cursor, etc.).

This started as data/lakehouse work and will accumulate whatever domains I happen to be working in.

## Layout

```
skills/
  <skill-name>/
    SKILL.md      # frontmatter (name + description) and the skill body
```

## Skills

| Skill | What it's for |
|-------|---------------|
| [`apache-lakehouse`](skills/apache-lakehouse/SKILL.md) | Designing, modifying, and debugging Apache Iceberg lakehouses — PyIceberg + Polars/DuckDB medallion writes, catalog choice, maintenance, CDC, branching/WAP, schema evolution. |

