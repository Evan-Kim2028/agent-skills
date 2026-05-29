# agent-skills

A personal, growing collection of [agent skills](https://docs.claude.com/en/docs/claude-code/skills) — portable, model-agnostic knowledge packs I use across coding agents (Claude Code, Cursor, etc.). Each skill is a self-contained folder with a `SKILL.md` that an agent loads on demand when its description matches the task at hand.

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

## Using a skill

Skills follow the open `SKILL.md` convention. To use one with Claude Code, drop the folder into `~/.claude/skills/` (global) or `.claude/skills/` (per-project). Other agents that support the format can point at the folder directly.

## License

MIT — see [LICENSE](LICENSE).
