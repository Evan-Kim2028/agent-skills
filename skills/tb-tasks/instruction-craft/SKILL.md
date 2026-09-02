---
name: tb-instruction-craft
description: Writing agent-visible text for Terminal-Bench tasks — instruction.md, in-environment contracts (DESIGN.md-style), and README explanation fields — within TB standards. Use when drafting or reviewing what the agent will read, fixing instruction-related static checks or rubric criteria, or balancing spec completeness against difficulty. Don't use for verifier internals (tb-verifier-craft), overall task shape (tb-task-design), or the full gate ladder (tb-submission-gates). Prefer the tb-tasks hub when unclear.
---

# TB instruction craft

The agent-visible text is part of the difficulty design, not packaging. The
same environment can be a frontier-hard task or a reading-comprehension
exercise depending on what the prose gives away. This skill covers the three
agent-visible artifacts: `instruction.md`, any in-environment contract doc
(e.g. `DESIGN.md`), and the README explanation fields reviewers read.

## Hard constraints (static-check enforced)

These fail CI, not taste:

| Rule | Check |
|---|---|
| `instruction.md` ends with the byte-exact trailer: `You have N seconds to complete this task. Do not cheat by using online solutions or hints specific to this task.` where N = `int([agent].timeout_sec)` | `check-instruction-suffix.sh` |
| All paths absolute (`/app/...`), never relative | `check-task-absolute-path.sh` |
| Every output file the verifier or oracle references must be named in `instruction.md` | `check-test-file-references.sh` |
| Canary comment present | `check-canary.sh` |

## Rubric criteria that grade instructions

From `docs/prompts/task-implementation.toml` (`harbor check` judges these):
`well_specified` — an expert could determine the required end state;
`instruction_concision` — no padding, no roleplay, no restating the
environment; `test_instruction_alignment` — nothing the hidden tests require
is absent from agent-visible material, and nothing promised is untested;
`typos`; `agentic` — the task needs multi-step terminal work, not a zero-shot
answer the instruction already contains.

## Form

- 2–3 paragraphs. Upstream TB4 median is ~15 lines (range 5–55; long ones
  exist only to embed exact output schemas). Length does not add difficulty —
  it usually removes it.
- Describe the **end state**, never the steps. "Repair the publisher so a
  finished recovery is observationally equivalent to an uninterrupted serial
  run" — not "first fix the checkpoint, then rebuild frames."
- No tool or library hints. Name the entrypoints the agent must exercise
  (`python -m warehouse.cli`), not the techniques to use.
- Name every deliverable path and any schema it must match exactly.
- Disclose dishonest state honestly: if status files lie, say they are not
  authoritative. Fairness requires the disclaimer; difficulty survives it.
- State that the contract doc governs and that editing it changes nothing:
  "`DESIGN.md` is the contract; changing either file does not change what the
  separate verifier requires."

## The completeness lever (calibration-critical)

Two floors and a ceiling:

- **Fairness floor:** every hidden-test requirement must be derivable from
  agent-visible material. A test that fails an agent for a rule it could not
  have known is a task bug. Trace each hidden test back to a visible clause
  before shipping (tb-task-design owns this audit).
- **The ceiling you must not hit:** a complete, enumerable prose spec turns
  the task into spec comprehension — reading, tracing, and satisfying clauses
  one by one. Frontier models are superhuman at exactly that. Empirical
  precedent: lakehouse-publish-recovery had every hidden test traceable to a
  DESIGN.md sentence; Opus 5 solved it in ~35 minutes on the first attempt.
- **The resolution:** write obligations that are *universally quantified*,
  not enumerable. "Equivalent to a serial run under any crash/retry
  interleaving," "holds for every variant of the input class," "within the
  stated budget on unseen data." The clause is short, honest, and fully
  visible — but satisfying it requires engineering certainty the agent cannot
  read its way to. Certainty lives in the environment (replayable evidence,
  concurrency, held-out variants), not in more prose. Tasks that survive
  frontier models (`wal-recovery-ordering`, `bun-sourcemap-leak`,
  `session-window-debug` in harbor-framework/terminal-bench) all have short
  instructions with quantified obligations.

Rule of thumb: if you can check every contract clause off a list by reading
the code, the instruction is doing the agent's work. If a clause forces the
agent to *prove* something about all executions, it is carrying difficulty.

## Anti-patterns

- Enumerated bug lists or bug counts anywhere agent-visible.
- Hints that name the file or function to fix, in prose or code comments.
- Roleplay framing ("You are a senior engineer at...") — cut it.
- Promising context the environment does not contain.
- Instruction drift: hardening the verifier without re-reading the
  instruction. Every hardening pass re-runs the fairness trace.
- Restating environment facts the agent can `ls` and `cat` for itself.

## README explanation fields

`## Difficulty explanation`, `## Solution explanation`,
`## Verification explanation`, `## Relevant experience` — human-authored,
reviewer-facing, mirrored from `task.toml` metadata. Difficulty explanation
must justify `expert_time_estimate_hours` with the actual hard part, not the
task's size. Solution explanation names the discriminant and why partial
fixes fail. Verification explanation covers reward derivation and anti-cheat.
No `[AUTHOR TODO]` at submission.

## Checklist before hand-off to tb-submission-gates

1. Trailer byte-exact against `[agent].timeout_sec`.
2. All paths absolute; all deliverables named; schemas embedded if exact.
3. Every hidden test traceable to visible text (fairness floor).
4. At least one obligation is universally quantified, not enumerable
   (difficulty ceiling).
5. No steps, no tool hints, no bug enumeration, no roleplay.
6. README explanation fields filled, no TODOs.
