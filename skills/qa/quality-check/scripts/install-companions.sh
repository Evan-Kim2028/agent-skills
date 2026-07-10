#!/usr/bin/env bash
# Install quality-check + recommended companion skills as real directory copies
# (no symlinks). Gives attribution in stdout.
#
# Usage:
#   ./install-companions.sh              # tier A (minimum)
#   ./install-companions.sh --full       # tier B (full route coverage from known packs)
#   ./install-companions.sh --hub-only   # only quality-check from this repo
#
# Credits:
#   Evan-Kim2028/agent-skills  — hub, FE/data specialists
#   addyosmani/agent-skills    — browser-testing, doubt, ship, security, TDD lineage
#   mattpocock/skills          — tdd, diagnose, review, qa, triage, to-issues
#   check-work                 — Grok Build bundled (not cloned here)
set -euo pipefail

TIER="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# When this script lives in agent-skills: .../skills/qa/quality-check/scripts
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
if [[ ! -f "$REPO_ROOT/skills/qa/quality-check/SKILL.md" ]]; then
  # Fallback: treat CWD as agent-skills clone
  REPO_ROOT="$(pwd)"
fi

WORK="${TMPDIR:-/tmp}/quality-check-companions-$$"
mkdir -p "$WORK"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

ROOTS=()
for r in "${HOME}/.grok/skills" "${HOME}/.claude/skills"; do
  mkdir -p "$r"
  ROOTS+=("$r")
done

copy_skill() {
  local name="$1"
  local src_dir="$2"
  if [[ ! -f "$src_dir/SKILL.md" ]]; then
    echo "WARN: no SKILL.md at $src_dir — skip $name" >&2
    return 0
  fi
  for root in "${ROOTS[@]}"; do
    rm -rf "$root/$name"
    mkdir -p "$root/$name"
    cp -a "$src_dir"/. "$root/$name"/
    if [[ -L "$root/$name" ]]; then
      echo "ERROR: $root/$name is still a symlink" >&2
      exit 1
    fi
  done
  echo "installed $name  (from $src_dir)"
}

clone_depth() {
  local url="$1"
  local dest="$2"
  git clone --depth 1 "$url" "$dest"
}

echo "=== quality-check companion install (real copies) ==="
echo "Credit: Evan-Kim2028/agent-skills | addyosmani/agent-skills | mattpocock/skills"
echo "check-work: use Grok-bundled skill if present; hub has a fallback if not."
echo

# --- Hub from this repo (always) ---
copy_skill "quality-check" "$REPO_ROOT/skills/qa/quality-check"

if [[ "$TIER" == "--hub-only" ]]; then
  echo "Hub only. Done."
  exit 0
fi

# --- Tier A from this repo ---
for pair in \
  "frontend/visual-verify:visual-verify" \
  "frontend/web-quality:web-quality" \
  "frontend/frontend-design:frontend-design" \
  "data/semantic-quality:data-semantic-quality"
do
  src="${pair%%:*}"
  name="${pair##*:}"
  copy_skill "$name" "$REPO_ROOT/skills/$src"
done

if [[ "$TIER" == "--full" ]]; then
  for pair in \
    "frontend/design-system:design-system" \
    "frontend/product-ui-craft:product-ui-craft" \
    "frontend/mobile-product-ux:mobile-product-ux" \
    "frontend/mockup-implement:mockup-implement" \
    "frontend/react-performance:react-performance" \
    "data/data:data" \
    "marketing/marketing:marketing" \
    "design/html-design:html-design"
  do
    src="${pair%%:*}"
    name="${pair##*:}"
    copy_skill "$name" "$REPO_ROOT/skills/$src"
  done
fi

# --- Addy Osmani ---
AO="$WORK/addyosmani-agent-skills"
echo
echo "Cloning https://github.com/addyosmani/agent-skills (credit: Addy Osmani)..."
clone_depth "https://github.com/addyosmani/agent-skills.git" "$AO"
AO_NAMES=(
  browser-testing-with-devtools
  doubt-driven-development
  shipping-and-launch
  security-and-hardening
  code-review-and-quality
  debugging-and-error-recovery
  test-driven-development
)
if [[ "$TIER" == "--full" ]]; then
  AO_NAMES+=(spec-driven-development)
fi
for name in "${AO_NAMES[@]}"; do
  if [[ -d "$AO/skills/$name" ]]; then
    copy_skill "$name" "$AO/skills/$name"
  else
    echo "WARN: addyosmani/agent-skills has no skills/$name (layout may have changed)" >&2
  fi
done

# --- Matt Pocock ---
MP="$WORK/mattpocock-skills"
echo
echo "Cloning https://github.com/mattpocock/skills (credit: Matt Pocock / AI Hero)..."
clone_depth "https://github.com/mattpocock/skills.git" "$MP"
MP_NAMES=(tdd diagnose review qa)
if [[ "$TIER" == "--full" ]]; then
  MP_NAMES+=(triage to-issues setup-matt-pocock-skills)
fi
for name in "${MP_NAMES[@]}"; do
  found="$(find "$MP" -type f -path "*/$name/SKILL.md" 2>/dev/null | head -1 || true)"
  if [[ -n "$found" ]]; then
    copy_skill "$name" "$(dirname "$found")"
  else
    echo "WARN: mattpocock/skills has no $name/SKILL.md (layout may have changed)" >&2
  fi
done

echo
echo "=== Done ==="
echo "Install roots: ${ROOTS[*]}"
echo "Re-run this script after upstream updates (copies do not auto-update)."
echo
echo "Attribution:"
echo "  - https://github.com/Evan-Kim2028/agent-skills"
echo "  - https://github.com/addyosmani/agent-skills  (Addy Osmani)"
echo "  - https://github.com/mattpocock/skills         (Matt Pocock)"
echo "  - check-work: Grok Build bundled (if available)"
