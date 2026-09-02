---
name: tb-difficulty-calibration
description: Measuring and tuning Terminal-Bench task difficulty against real agent trials — the evidence ladder (nop/oracle → cheap-model saturation canary → k>=3 mid-tier trials → frontier trials), reading agent CoT to diagnose why a discriminant survived, when to harden vs wait, expert-time estimates. Use when deciding if a TB task is too easy/too hard/saturated, analyzing trial transcripts, or planning trial runs. Don't use for designing the task (tb-task-design) or verifier mechanics (tb-verifier-craft). Prefer the tb-tasks hub when unclear.
---

# TB Difficulty Calibration

Calibration is empirical, not designed-in. You do not know a task's real
difficulty until agents have actually attempted it and you have read what
they did. This skill is the discipline for running that ladder honestly and
resisting the urge to harden a task off one data point.

## 1. The evidence ladder

Run cheapest-first. Never skip a rung — a saturated task doesn't deserve a
frontier trial budget, and a broken verifier doesn't deserve a model trial at
all.

1. **`make nop TASK=<slug>`** → reward must be `0.0`. **`make oracle
   TASK=<slug>`** → reward must be `1.0`. Non-negotiable floor: this proves
   the reward channel actually discriminates pass from fail before any model
   touches the task. A task that fails either is not ready for a model, it's
   broken.
2. **Cheap-model pilot = saturation canary.** `make glm-flash TASK=<slug>`
   (model `openrouter/z-ai/glm-5.3-flash`). If a flash-tier model passes,
   the task is **dead for frontier submission** — drop or redesign it, don't
   patch around the pass. Concrete precedent from
   `docs/TASK-PORTFOLIO.md`: `tasks/bootstrap-merge-resume` was dropped
   because "GLM 5.3 flash solved (13/13). Too easy for frontier bar."
   `tasks/schema-evolution-cdc` was dropped as "flash-saturated" with a thin
   3-test verifier, kept only as a decoy source. A single flash pass is
   sufficient evidence to drop — you don't need k>=3 here, because
   saturation is a one-sided bar (any clean solve is disqualifying).
3. **Mid-tier calibration, k>=3.** `make glm53 TASK=<slug>` (GLM 5.3 max,
   `openrouter/z-ai/glm-5.3`, reasoning=max) run at least three times. This
   is signal, not a submission gate — it tells you whether the discriminant
   is even in the right difficulty band before you spend frontier budget.
4. **Frontier trials = the real bar.** `make frontier-claude TASK=<slug>`
   (Claude Code + `anthropic/claude-opus-5`, reasoning=max, ×`FRONTIER_ATTEMPTS`
   default 3) and `make frontier-codex TASK=<slug>` (Codex +
   `openai/gpt-5.6-sol`, reasoning=xhigh, ×3). Per
   `docs/TB3-SUBMISSION-CHECKLIST.md`, all required trials of both
   agent/model pairs must fail (reward 0) for a submission-grade hard task.
   If any frontier trial passes, the task is not hard enough yet — that is
   real signal, not a bug to route around.
5. **Adversarial cheat trials must stay reward 0.** `make cheat TASK=<slug>`
   (or `make glm-cheat`) runs the same agent with
   `docs/prompts/hack-trial-prompt.md` injected — deliberate reward hacking
   (stub pytest, patch hooks, inflate pass counts). Reward must stay `0.0`.
   Precedent: a GLM 5.3 cheat trial on `lakehouse-publish-recovery` scored
   17/18 tests "passed" but reward `0.0` was preserved only because the
   verifier neutralizes pytest-hook injection
   (`conftest` disables `_close_hooks`, sets
   `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1`). A cheat trial that scores nonzero
   reward is a verifier bug, not a difficulty data point — send it to
   `tb-verifier-craft`, don't touch difficulty knobs.

Don't reorder this ladder to save time. A frontier trial run before nop/oracle
pass is wasted budget on an unproven reward channel; a frontier trial run
before the flash canary risks discovering saturation the expensive way.

## 2. Trial postmortem method

Read the transcript, don't just read the reward. Source pattern:
`docs/internal/lakehouse-glm53-trial-20260901.md` and
`lakehouse-glm53-trial-trojan-20260901.md`.

1. **Break the run into phases with step ranges.** Typical shape: Phase 1
   Discovery (reads DESIGN.md, maps the environment, runs the public
   smoke/replay) → Phase 2 Targeted fixes (patches bugs the instruction text
   directly points at) → Phase 3 Custom-harness era (agent builds its own
   `/tmp/h/*` or `tests/t_*.py` fuzz/validation script and starts trusting
   that instead of the real verifier — this is where self-validation
   diverges from ground truth) → Phase 4 Premature submit (agent declares
   "all tests pass" against its own harness, never runs the actual hidden
   verifier or reads the real hidden test file).
2. **Name the exact reason the discriminant survived.** Don't settle for
   "the agent failed" — classify precisely:
   - *Never looked at the file* — the target module was never opened or
     edited at all.
   - *Looked but wrong mental model* — the agent edited the right file but
     misread the contract. Cite the exact step and the exact wrong
     assertion (example: step 38, agent asserts reused epoch ids
     `[1,2,3,4,5]` are "schema compatible" against a verifier that actually
     requires `epochs[1].isdisjoint(epochs[2])`).
   - *Wrong lever / decoy* — the agent edited a plausible-looking adjacent
     module instead of the real target (example: touched
     `schema_compat.py` instead of `schema.py`).
   - *Own harness reinforced a wrong model* — the agent's custom
     validation script passed because it encoded the same misunderstanding
     as the fix, so the agent had false confidence going into submit.
3. **Count tests passed vs. total**, and separate that from reward. A trial
   can pass 17/18 hidden tests and still be reward `0.0` (cheat-trial
   pytest-hook case above) — pass count is diagnostic, reward is the only
   thing that matters for the bar.
4. **Distinguish real model failure from infra noise.** Rate limits,
   `CancelledError`, agent timeout hit for infra reasons (not reasoning
   exhaustion), sandbox flakiness — these do **not** count as evidence
   toward "the task is hard" or "the task is easy." Re-run them; don't bank
   them either direction.
5. Use `harbor analyze jobs/<job-id> -m sonnet -r
   docs/prompts/trial-analysis.toml --job-prompt
   docs/prompts/trial-analysis-job.txt` to get a structured postmortem
   instead of hand-reading raw transcripts for every trial. The rubric
   scores 6 criteria (task_specification, reward_hacking, difficulty_crux,
   near_miss, refusals, low_timeout) as PASS/FAIL/NOT_APPLICABLE — run it
   after every non-trivial trial batch, not just when something looks
   wrong.

## Miniature frontier probe (before full build)

Before building a full task around a new wedge, build a miniature (core trap
only, ~6 hidden tests, no side axes) and run ONE frontier attempt with a
short cap (45 min via `--agent-timeout-multiplier`, ~$15 on Claude Code
OAuth). Fail with the predicted miss → build the full task. Pass → read the
trajectory and redesign or kill; do not build on an unprobed wedge. Write the
predicted failure mode in the design doc first so the probe is falsifiable.
Rationale: a full task costs days; the probe kills bad wedges for $15.
Precedent: lakehouse-publish-recovery was built fully, then Opus solved it
on the first 45-min probe.

## 3. Hardening discipline

**Never harden on a single trial.** Quoted from the source postmortems:
*"Not 'saturated.' 75% partial pass on one trial ≠ model family solved.
Need k>=3 on GLM 5.3 + flash + frontier before tuning difficulty."* and
*"Do not harden yet based on this single run... worth k>=3 before adding
more decoys."*

- Wait for **k>=3 independent runs** before touching the verifier or
  environment in response to a pass/near-pass.
- Only harden if the pattern **clusters** — the same discriminant missed
  the same way across multiple runs. One run touching `schema_compat.py`
  and a different run failing for an unrelated reason is not a cluster; it's
  noise until it repeats.
- If pass rate stays `0` and the miss is the **same miss** every time
  (same discriminant, same wrong mental model), the task is calibrated.
  **Stop.** Adding more decoys or bugs at that point is churn, not
  hardening — you already have the evidence you need.
- **Decoys don't move pass rate — don't count them as hardening.** Empirical
  finding from the GLM 5.3 trojan-garden rollout: reward stayed `0.0` both
  pre- and post-decoy, with the *identical* discriminant failure
  (`schema_compat.py` edited instead of `schema.py`) in both conditions.
  Decoys cost the agent steps (time spent chasing red herrings) but did not
  change whether the task passed or failed. Treat decoys as a realism/
  step-cost device (see `tb-task-design` §5), never as evidence you can cite
  for "I made this harder."

## 4. Difficulty must be human-grounded

- The task must be **solvable by an expert in a few hours** of actual
  implementation, even if it took much longer to *figure out* what to do.
  "Hard to see, fast to fix once seen" is the target shape — not "takes an
  expert a week."
- `expert_time_estimate_hours` in `task.toml` must be a plausible
  best-case estimate, consistent with the prose in
  `difficulty_explanation`. Don't inflate it to justify a hard task, or
  deflate it to look approachable. Upstream range across
  `harbor-framework/terminal-bench`'s `tasks/` (local clone commonly at
  `/tmp/tb-ref` — ephemeral, re-clone if gone) is 0.75-60h; the bulk of tasks
  cluster **2-6h**, median around 3-5h.
  Outliers exist but are rare and domain-specific — e.g. `takens-embedding
  -lean` at 60h for a Lean proof. If your estimate lands far outside the
  2-6h cluster, that's a signal to re-examine the estimate, not evidence
  the task is appropriately hard.
- Difficulty must come from **professional reasoning** — coupled
  invariants, subtle failure modes, real domain expertise (see
  `tb-task-design` §3 hardness mechanisms) — never from LLM quirks,
  formatting minutiae, ambiguous phrasing, or obscure trivia a domain
  expert wouldn't need to know either.
- **Not googleable, but open-internet is mandatory.** Upstream
  `CONTRIBUTING.md`: *"Terminal-Bench is an open-internet benchmark... 
  disabling network access is not a valid way to make a task difficult."*
  and *"solutions to your task shouldn't be easily findable online (besides
  oracle solutions in this repo)."* Never set `allow_internet=false` as a
  difficulty lever — that's a `tb-verifier-craft` / static-check violation,
  not a calibration knob. Also avoid the adversarial-cherry-pick trap:
  *"we run the risk of finding trivial corners of capability gaps specific
  to the current models that are quickly remedied in the next model
  release"* — calibrate against reasoning difficulty that should hold up
  across model generations, not against today's specific blind spot.

## 5. Tooling quick reference

Trial ladder make targets (`eval_tasks/Makefile`, `RUNNING.md`):

| Target | Purpose |
|---|---|
| `static` / `static-all` | No-API static checks (canary, field shape, no-internet, instruction suffix) |
| `smoke` / `smoke-all` | Docker build + static |
| `oracle` | Must score reward `1.0` |
| `nop` | Must score reward `0.0` |
| `validate-all` | Parallel static + oracle + nop |
| `glm` / `glm53` | GLM 5.3 max, `openrouter/z-ai/glm-5.3`, reasoning=max |
| `glm-flash` / `glm-flash-all` | GLM 5.3 flash saturation canary, `openrouter/z-ai/glm-5.3-flash`, reasoning=high, cost cap $4.95; `-all` parallelizes over `GLM_TASKS` |
| `glm-cheat` | GLM 5.3 max + `docs/prompts/hack-trial-prompt.md` injected |
| `frontier-claude` / `frontier-claude-once` | Claude Code + `anthropic/claude-opus-5`, reasoning=max, ×`FRONTIER_ATTEMPTS` (default 3) / ×1 pilot |
| `frontier-codex` | Codex + `openai/gpt-5.6-sol`, reasoning=xhigh, ×3 |
| `cheat` | Generic `AGENT`/`MODEL` + hack-trial-prompt; expect reward 0 |
| `rubric-check` | `harbor check -r docs/prompts/task-implementation.toml` |
| `analyze` | `harbor analyze jobs/<id> -m sonnet -r docs/prompts/trial-analysis.toml --job-prompt docs/prompts/trial-analysis-job.txt` |

Required trial matrix before submission: see `docs/TB3-SUBMISSION-CHECKLIST.md`
in full — static, smoke, oracle=1.0, nop=0.0, rubric check, GLM 5.3 max
honest (expect 0), GLM 5.3 max cheat (expect 0), 3x frontier-claude, 3x
frontier-codex (all must fail), plus adversarial `/cheat` on both frontier
pairs (reward must be 0). TB4-era convention: flat `28800s` timeout, frontier
pair limited to Opus 5 max + GPT-5.6 Sol xhigh only.

Job artifact layout (`eval_tasks/jobs/<job-id>/<task-name>__<trial-id>/`):

- `verifier/reward.txt` — the number that matters
- `verifier/ctrf.json` — structured test results
- `verifier/test-stdout.txt` — raw test output
- `agent/trajectory.json` (or `<agent-name>.trajectory.json`) — full agent
  CoT/transcript, this is what you read for the postmortem in §2
- `artifacts/` — task output artifacts, `manifest.json`
- `result.json`, `config.json`, `trial.log` — trial metadata and log

## Related skills

- **tb-task-design** — ideation, hardness mechanisms, decoy archetypes,
  portfolio discipline. Go here before a task exists to calibrate.
- **tb-verifier-craft** — verifier code, replay fixtures, cheat-resistance
  (pytest hook neutralization). Go here when a cheat trial scores nonzero
  reward — that's a verifier bug, not a difficulty finding.
- **tb-submission-gates** — static checks, rubric scoring, final submission
  checklist. Go here once the ladder in §1 is fully green/red as required.
- **tb-tasks** (hub) — routes between the above when the right specialist
  isn't obvious.
