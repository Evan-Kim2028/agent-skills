# quality-check — companion install & attribution

The **quality-check** hub is self-contained in this repo. Specialists it routes
to live in other packs. This document is the **portable companion set**: install
sources, credit, and a copy-based install (no symlinks).

Hub alone still works via **If specialist missing** fallbacks in `SKILL.md`.
Companions make progressive disclosure fully usable.

## License & credit summary

| Pack | Author / org | Repo | Typical license | Used for |
|------|--------------|------|-----------------|----------|
| **agent-skills** (this pack) | [Evan-Kim2028](https://github.com/Evan-Kim2028) | [Evan-Kim2028/agent-skills](https://github.com/Evan-Kim2028/agent-skills) | See repo `LICENSE` | Hub + FE/data specialists |
| **agent-skills** (Addy Osmani) | [Addy Osmani](https://github.com/addyosmani) | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | See repo license | Browser DevTools, TDD lineage, doubt, ship, security, code-review |
| **skills** (Matt Pocock) | [Matt Pocock](https://github.com/mattpocock) / AI Hero | [mattpocock/skills](https://github.com/mattpocock/skills) | See repo license | tdd, diagnose, review, qa, triage, to-issues, setup |
| **check-work** | Grok Build / xAI (bundled) | Product install — not in this repo | Vendor terms | Session self-verify |

**Respect upstream licenses.** When you copy skills, keep their `SKILL.md` and any
LICENSE files intact. Do not relicense third-party skill bodies under this pack
without permission.

---

## Tier A — Minimum companion set (recommended)

Enough for the hub’s **pipeline A/B** (consumer UI + bug fix) on a clean machine.

| Skill name (install as) | Source pack | Path in source repo | Credit |
|-------------------------|-------------|---------------------|--------|
| **quality-check** | Evan-Kim2028/agent-skills | `skills/qa/quality-check/` | This hub |
| **browser-verify** | Evan-Kim2028/agent-skills | `skills/frontend/browser-verify/` | In-repo (Playwright + DevTools) |
| **web-quality** | Evan-Kim2028/agent-skills | `skills/frontend/web-quality/` | Evan-Kim2028/agent-skills |
| **frontend-design** | Evan-Kim2028/agent-skills | `skills/frontend/frontend-design/` | Evan-Kim2028/agent-skills |
| **tdd** | mattpocock/skills | `skills/engineering/tdd/` (path may vary by release) | Matt Pocock — [mattpocock/skills](https://github.com/mattpocock/skills) |
| **diagnose** | mattpocock/skills | `skills/engineering/diagnose/` | Matt Pocock — [mattpocock/skills](https://github.com/mattpocock/skills) |
| **doubt-driven-development** | addyosmani/agent-skills | `skills/doubt-driven-development/` | Addy Osmani — [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| **check-work** | Grok Build bundle | Preinstalled on Grok; else use hub fallback | xAI / Grok Build |

Optional but useful on the same machine:

| Skill | Source | Credit |
|-------|--------|--------|
| **data-semantic-quality** | Evan-Kim2028/agent-skills `skills/data/semantic-quality/` | Evan-Kim2028/agent-skills |
| **review** | mattpocock/skills | Matt Pocock |
| **qa** (issue filing) | mattpocock/skills | Matt Pocock |

---

## Tier B — Full route coverage

Everything the hub’s routing table may name.

### From Evan-Kim2028/agent-skills

| Install name | Path |
|--------------|------|
| quality-check | `skills/qa/quality-check/` |
| frontend-design | `skills/frontend/frontend-design/` |
| browser-verify | `skills/frontend/browser-verify/` |
| ui-explore | `skills/frontend/ui-explore/` |
| web-quality | `skills/frontend/web-quality/` |
| design-system | `skills/frontend/design-system/` |
| product-ui-craft | `skills/frontend/product-ui-craft/` |
| mobile-product-ux | `skills/frontend/mobile-product-ux/` |
| mockup-implement | `skills/frontend/mockup-implement/` |
| react-performance | `skills/frontend/react-performance/` |
| data | `skills/data/data/` |
| data-semantic-quality | `skills/data/semantic-quality/` |
| marketing | `skills/marketing/marketing/` |
| visual-verify (alias) | `skills/frontend/visual-verify/` |
| html-design (alias) | `skills/design/html-design/` |

**Credit:** [Evan-Kim2028/agent-skills](https://github.com/Evan-Kim2028/agent-skills) — personal skill pack (data, FE hubs, quality-check).

### From addyosmani/agent-skills

| Install name | Typical path under `skills/` |
|--------------|------------------------------|
| browser-testing-with-devtools | `browser-testing-with-devtools/` |
| doubt-driven-development | `doubt-driven-development/` |
| test-driven-development | `test-driven-development/` (alias for TDD lineage; hub default remains **tdd** from Matt’s pack when both exist) |
| shipping-and-launch | `shipping-and-launch/` |
| security-and-hardening | `security-and-hardening/` |
| code-review-and-quality | `code-review-and-quality/` (hub default **review** prefers Matt’s skill when installed) |
| debugging-and-error-recovery | `debugging-and-error-recovery/` |
| spec-driven-development | `spec-driven-development/` |
| ship | `.claude/commands/ship.md` or pack equivalent if present |

**Credit:** [Addy Osmani](https://addyosmani.com/) — [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)  
Production-grade engineering skills for AI coding agents (TDD/prove-it lineage, shipping, security, DevTools browser testing, doubt-driven review).

Install (HTTPS; marketplace optional):

```bash
git clone https://github.com/addyosmani/agent-skills.git
# see that repo’s README for Claude marketplace / Cursor paths
```

### From mattpocock/skills

| Install name | Role in quality-check |
|--------------|------------------------|
| tdd | Default TDD / Prove-It path |
| diagnose | Hard-bug diagnosis loop |
| review | Two-axis PR review (standards + spec) |
| qa | Conversational bug filing (not fix path) |
| triage | Issue state machine |
| to-issues | Plan → vertical-slice issues |
| setup-matt-pocock-skills | Repo issue-tracker / triage / domain config |

**Credit:** [Matt Pocock](https://www.mattpocock.com/) / AI Hero — [mattpocock/skills](https://github.com/mattpocock/skills)  
“Skills for Real Engineers” — TDD, diagnose, triage, to-issues, review, qa session.

Paths under that repo are typically under `skills/engineering/` (confirm against current tree when installing).

```bash
git clone https://github.com/mattpocock/skills.git
```

After install, run **setup-matt-pocock-skills** once per product repo so issue-tracker skills know GitHub vs local markdown.

### Vendor / product

| Skill | Credit | Notes |
|-------|--------|--------|
| **check-work** | Grok Build (xAI) bundled skill | Session verifier subagent. If absent, hub fallback: diff + build/test + re-read user ask. |

### Optional / environment-specific

| Skill | Notes |
|-------|--------|
| **implement-until-green**, **ship-feature** | Often project-local Cursor workflows; not required for hub core. Use hub fallbacks or install if your environment provides them. |
| **prototype**, **tufte** | FE hub adjacencies; install from agent-skills or local packs when needed. |

---

## One-shot install (copy, not symlink)

From a machine with `git` and `bash`:

```bash
# Or: bash /path/to/agent-skills/skills/qa/quality-check/scripts/install-companions.sh
bash "$(dirname "$0")/../scripts/install-companions.sh"   # when run from scripts/
```

Manual equivalent:

```bash
set -euo pipefail
WORKDIR="${TMPDIR:-/tmp}/quality-check-companions-$$"
mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT

clone_copy() {
  local repo_url="$1" dest_name="$2" src_subpath="$3"
  local clone="$WORKDIR/$dest_name"
  git clone --depth 1 "$repo_url" "$clone"
  for root in "${HOME}/.grok/skills" "${HOME}/.claude/skills"; do
    mkdir -p "$root"
    rm -rf "$root/$dest_name"
    mkdir -p "$root/$dest_name"
    cp -a "$clone/$src_subpath"/. "$root/$dest_name"/
    echo "installed $dest_name -> $root/$dest_name (from $repo_url)"
  done
}

# This pack (hub + FE specialists used by quality-check)
AS="$WORKDIR/agent-skills"
git clone --depth 1 https://github.com/Evan-Kim2028/agent-skills.git "$AS"
for pair in \
  "qa/quality-check:quality-check" \
  "frontend/visual-verify:visual-verify" \
  "frontend/web-quality:web-quality" \
  "frontend/frontend-design:frontend-design" \
  "data/semantic-quality:data-semantic-quality"
do
  src="${pair%%:*}"; name="${pair##*:}"
  for root in "${HOME}/.grok/skills" "${HOME}/.claude/skills"; do
    mkdir -p "$root"
    rm -rf "$root/$name"
    mkdir -p "$root/$name"
    cp -a "$AS/skills/$src"/. "$root/$name"/
  done
  echo "installed $name from Evan-Kim2028/agent-skills"
done

# Addy Osmani pack (subset)
AO="$WORKDIR/addyosmani-agent-skills"
git clone --depth 1 https://github.com/addyosmani/agent-skills.git "$AO"
for name in browser-testing-with-devtools doubt-driven-development \
            shipping-and-launch security-and-hardening \
            code-review-and-quality debugging-and-error-recovery \
            test-driven-development; do
  if [ -d "$AO/skills/$name" ]; then
    for root in "${HOME}/.grok/skills" "${HOME}/.claude/skills"; do
      rm -rf "$root/$name"
      mkdir -p "$root/$name"
      cp -a "$AO/skills/$name"/. "$root/$name"/
    done
    echo "installed $name from addyosmani/agent-skills"
  else
    echo "WARN: $name not found under addyosmani/agent-skills/skills/ (tree may have moved)"
  fi
done

# Matt Pocock pack (subset) — paths vary; script searches
MP="$WORKDIR/mattpocock-skills"
git clone --depth 1 https://github.com/mattpocock/skills.git "$MP"
for name in tdd diagnose review qa triage to-issues setup-matt-pocock-skills; do
  found=$(find "$MP" -type d -name "$name" | head -1)
  if [ -n "$found" ] && [ -f "$found/SKILL.md" ]; then
    for root in "${HOME}/.grok/skills" "${HOME}/.claude/skills"; do
      rm -rf "$root/$name"
      mkdir -p "$root/$name"
      cp -a "$found"/. "$root/$name"/
    done
    echo "installed $name from mattpocock/skills ($found)"
  else
    echo "WARN: $name not found in mattpocock/skills"
  fi
done

echo "Done. Re-copy after upstream updates (copies do not auto-update)."
echo "Credit: Evan-Kim2028/agent-skills, addyosmani/agent-skills, mattpocock/skills; check-work is Grok-bundled if present."
```

---

## How the hub uses companions

1. Prefer installed specialist `SKILL.md` when the routing table names it.  
2. If missing → hub **If specialist missing** fallback (no invented skill bodies).  
3. Do not re-host third-party skill text inside this pack; **link and install** with credit.

## Updating

```bash
# After git pull on each upstream clone, re-run install-companions.sh
# or re-cp -a the changed skill folders into ~/.grok/skills/<name>/
```
