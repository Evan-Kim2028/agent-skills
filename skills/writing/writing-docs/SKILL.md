---
name: writing-docs
description: >
  Pure documentation and reference writing — runbooks, README install paths,
  API/tool reference, how-to procedures, operator notes. Scannable structure,
  prerequisites, failure modes, copy-paste commands. Use for docs that must be
  followed, not essays. Prefer writing-technical for research-style explainers;
  writing-prose for opinionated posts; writer-style for named voice; marketing
  for landing copy. Prefer writing hub when the writing path is unclear.
---

# Writing docs — procedures and reference

**Job:** Make something **followable**. Clarity beats personality. Personality
is allowed only as a one-line warning from production experience.

## When to load

- README, runbooks, install guides, operator playbooks  
- API/tool reference, config flags, schema contracts  
- “How do I run X?” / “What does this flag do?”  
- Migration steps, rollback, health checks  

**Not for:** blog essays, research narratives, marketing pages, voice cosplay.

## Principles

### 1. Task-first headings

Name the job: `Install`, `Configure`, `Run promote`, `Rollback`, `Troubleshoot`.
Not “Overview of our beautiful journey.”

### 2. Prerequisites before steps

State OS, versions, credentials, disk/RAM, and what must already exist.
Fail closed: if prerequisite missing, say what error they will see.

### 3. Numbered steps; one action each

Copy-pasteable commands in fenced blocks. Mark destructive steps.

### 4. Expected output + failure modes

After critical steps: what success looks like; common errors and fixes.
Tables for flags, exit codes, env vars.

### 5. Scannable density

Short paragraphs (often 1–3 sentences). Lists over prose. Bold the constraint
or default that operators miss.

### 6. No fake warmth

Skip “Welcome!”, “Simply…”, “Just run…”. Prefer “Run:” and “If this fails:”.

### 7. Facts freeze

Versions, ports, paths, memory caps — verify against the repo/code. Docs that
drift from code are worse than missing docs.

## Structure templates

### How-to

```
# <Task>
## Prerequisites
## Steps
## Verify
## Troubleshooting
```

### Reference

```
# <Component>
## Purpose
## Config / flags (table)
## Behavior / guarantees
## Limits / non-goals
## Related
```

### Runbook

```
# <Incident or job>
## Symptoms
## Immediate actions
## Diagnosis
## Mitigation / rollback
## Follow-ups
```

## Relationship to other writing skills

| Need | Skill |
|------|--------|
| Opinionated explainer / blog | **writing-technical** or **writing-prose** |
| Named author voice | **writer-style** |
| Landing / offer copy | **marketing** |
| Human deslop pass on long docs | light **writing-prose** after structure is right |

## Done criteria

- [ ] Reader can complete the task without side chat  
- [ ] Prerequisites and verify steps present  
- [ ] Commands match the repo  
- [ ] Failure modes for the sharp edges  
- [ ] No marketing filler  
