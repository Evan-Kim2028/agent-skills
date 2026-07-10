#!/usr/bin/env python3
"""Structural validation for the shipped data-semantic-quality skill pack.

Reads real files from the skill tree (and sibling hub/api) — does not re-implement
skill content. Exit 0 on pass; print failures and exit 1 on fail.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = SKILL_ROOT.parent
REPO_ROOT = DATA_ROOT.parent.parent

# Product / marketplace / game nouns that must not appear in this portable skill.
# Methodology words (entity, cohort, trust) are allowed.
BANNED = re.compile(
    r"\b("
    r"ebay|fanatics|psa\b|pokemon|pokémon|onepiece|one-piece|tcgplayer|"
    r"mercari|silph|lake-of-rage|lake_of_rage|courtyard|beezie|goldsky|"
    r"130point|alt\.xyz|myslabs|renaiss|dyli"
    r")\b",
    re.IGNORECASE,
)

# grade_label as product guidance — allow only if not present; portable skill
# should not teach product column names as requirements.
BANNED_PRODUCT_COLUMNS = re.compile(
    r"\b(grade_label|include_in_verified_sales|pokemontcg_id)\b",
    re.IGNORECASE,
)


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---"):
        raise AssertionError("SKILL.md missing YAML frontmatter")
    end = text.find("\n---", 3)
    if end < 0:
        raise AssertionError("SKILL.md frontmatter not closed")
    block = text[3:end].strip()
    out: dict[str, str] = {}
    key = None
    acc: list[str] = []
    for line in block.splitlines():
        if re.match(r"^[a-zA-Z0-9_-]+:\s*", line) and not line.startswith(" "):
            if key is not None:
                out[key] = "\n".join(acc).strip().strip("\"'")
            key, _, rest = line.partition(":")
            key = key.strip()
            rest = rest.strip()
            if rest == ">" or rest == "|":
                acc = []
            else:
                acc = [rest] if rest else []
        else:
            acc.append(line.strip())
    if key is not None:
        out[key] = "\n".join(acc).strip().strip("\"'")
    return out


def main() -> int:
    failures: list[str] = []
    skill_md = SKILL_ROOT / "SKILL.md"
    if not skill_md.is_file():
        print(f"FAIL: missing {skill_md}")
        return 1

    body = read(skill_md)
    fm = parse_frontmatter(body)
    if fm.get("name") != "data-semantic-quality":
        failures.append(f"name: expected data-semantic-quality, got {fm.get('name')!r}")

    desc = fm.get("description", "")
    for needle in (
        "quality attributes",
        "trust ladder",
        "golden",
        "Don't use",
    ):
        if needle.lower() not in desc.lower() and needle not in desc:
            # allow multiline; check case-insensitive for phrases
            if needle.lower() not in desc.lower():
                failures.append(f"description missing trigger phrase: {needle!r}")

    # Negative triggers in description
    for neg in ("schema", "admission", "table-lifecycle", "domain"):
        if neg not in desc.lower():
            failures.append(f"description should mention negative/routing term: {neg!r}")

    test_count = len(re.findall(r"\*\*Test:\*\*", body))
    if test_count < 6:
        failures.append(f"need ≥6 **Test:** principles, found {test_count}")

    if "## Non-negotiables" not in body and "## Non-negotiable" not in body:
        failures.append("missing Non-negotiables section")

    for rel in (
        "references/quality-attributes.md",
        "references/rule-scoping.md",
    ):
        p = SKILL_ROOT / rel
        if not p.is_file():
            failures.append(f"missing reference {rel}")
        else:
            # one-level: SKILL must link directly
            if rel not in body and f"](references/{p.name})" not in body:
                if f"]({rel})" not in body:
                    failures.append(f"SKILL.md does not link one-level to {rel}")

    # Domain noun audit on skill prose only (not this validator's ban-list source).
    for path in SKILL_ROOT.rglob("*.md"):
        text = read(path)
        for m in BANNED.finditer(text):
            failures.append(f"banned domain token {m.group()!r} in {path.relative_to(SKILL_ROOT)}")
        for m in BANNED_PRODUCT_COLUMNS.finditer(text):
            failures.append(
                f"banned product column {m.group()!r} in {path.relative_to(SKILL_ROOT)}"
            )

    # Hub routes to specialist
    hub = DATA_ROOT / "data" / "SKILL.md"
    hub_text = read(hub)
    if "data-semantic-quality" not in hub_text:
        failures.append("hub does not route to data-semantic-quality")
    if "mechanical" not in hub_text.lower() or "semantic" not in hub_text.lower():
        failures.append("hub should distinguish mechanical vs semantic validation")

    # data-api consumption-time + sidecar
    api = DATA_ROOT / "data-api" / "SKILL.md"
    api_text = read(api)
    if "quality attribute" not in api_text.lower():
        failures.append("data-api SKILL.md missing quality attribute consumption guidance")
    if "sidecar" not in api_text.lower():
        failures.append("data-api SKILL.md missing publish-coupled sidecar pattern")

    serving = DATA_ROOT / "data-api" / "references" / "serving.md"
    serving_text = read(serving)
    if "quality attribute" not in serving_text.lower():
        failures.append("serving.md missing quality attributes section")
    if "sidecar" not in serving_text.lower():
        failures.append("serving.md missing sidecar section")

    readme = REPO_ROOT / "README.md"
    if readme.is_file():
        r = read(readme)
        if "data-semantic-quality" not in r:
            failures.append("README.md does not list data-semantic-quality")
        if "semantic-quality:data-semantic-quality" not in r and "semantic-quality" not in r:
            failures.append("README install path should mention semantic-quality")

    if failures:
        print("FAIL:")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("PASS: data-semantic-quality structural checks")
    print(f"  skill_root={SKILL_ROOT}")
    print(f"  name={fm.get('name')}")
    print(f"  test_principles={test_count}")
    print(f"  description_len={len(desc)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
