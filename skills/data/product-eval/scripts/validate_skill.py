#!/usr/bin/env python3
"""Structural validation for data-product-eval. Exit 0 on pass."""
from __future__ import annotations

import re
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = SKILL_ROOT.parent
REPO_ROOT = DATA_ROOT.parent.parent

BANNED = re.compile(
    r"\b("
    r"ebay|fanatics|psa\b|pokemon|pokémon|onepiece|one-piece|tcgplayer|"
    r"mercari|silph|lake-of-rage|lake_of_rage|courtyard|beezie|goldsky|"
    r"130point|alt\.xyz|myslabs|renaiss|dyli"
    r")\b",
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
            if rest in (">", "|"):
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
    body = read(SKILL_ROOT / "SKILL.md")
    fm = parse_frontmatter(body)
    if fm.get("name") != "data-product-eval":
        failures.append(f"name: {fm.get('name')!r}")
    desc = fm.get("description", "")
    if len(desc) > 1024:
        failures.append(f"description length {len(desc)} > 1024")
    for needle in ("estimate", "frozen", "coverage", "Don't use"):
        if needle.lower() not in desc.lower():
            failures.append(f"description missing {needle!r}")
    if len(re.findall(r"\*\*Test:\*\*", body)) < 6:
        failures.append("need ≥6 **Test:** principles")
    if "references/eval-loop.md" not in body and "](references/eval-loop.md)" not in body:
        failures.append("SKILL.md must link references/eval-loop.md")
    if not (SKILL_ROOT / "references/eval-loop.md").is_file():
        failures.append("missing references/eval-loop.md")
    for path in SKILL_ROOT.rglob("*.md"):
        for m in BANNED.finditer(read(path)):
            failures.append(f"banned {m.group()!r} in {path.relative_to(SKILL_ROOT)}")
    hub = read(DATA_ROOT / "data" / "SKILL.md")
    if "data-product-eval" not in hub:
        failures.append("hub does not route to data-product-eval")
    readme = REPO_ROOT / "README.md"
    if readme.is_file() and "data-product-eval" not in read(readme):
        failures.append("README.md does not list data-product-eval")
    if failures:
        print("FAIL:")
        for f in failures:
            print(f"  - {f}")
        return 1
    print("PASS: data-product-eval")
    print(f"  description_len={len(desc)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
