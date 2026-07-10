# Specialist sources & credit

Third-party skill **bodies are not re-hosted** in this pack. Install from upstream
and keep their licenses. Full paths, tiers, and a one-shot installer:

→ **[`companion-install.md`](companion-install.md)**  
→ **[`../scripts/install-companions.sh`](../scripts/install-companions.sh)**

## Packs

| Pack | Author | Repository | Role for quality-check |
|------|--------|------------|------------------------|
| **agent-skills** | [Evan-Kim2028](https://github.com/Evan-Kim2028) | [github.com/Evan-Kim2028/agent-skills](https://github.com/Evan-Kim2028/agent-skills) | Hub (`quality-check`), FE specialists (`frontend-design`, `browser-verify`, `web-quality`, …), `data-semantic-quality` |
| **agent-skills** | [Addy Osmani](https://addyosmani.com/) | [github.com/addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Optional companions: `doubt-driven-development`, `shipping-and-launch`, `security-and-hardening`, `code-review-and-quality`, `debugging-and-error-recovery`, `test-driven-development` (DevTools practice is now **bundled** in this pack’s `browser-verify`) |
| **skills** | [Matt Pocock](https://www.mattpocock.com/) / AI Hero | [github.com/mattpocock/skills](https://github.com/mattpocock/skills) | `tdd`, `diagnose`, `review`, `qa`, `triage`, `to-issues`, `setup-matt-pocock-skills` |
| **check-work** | Grok Build (xAI) | Product-bundled | Session self-verify; hub fallback if missing |

## Default routing → credit (quick)

| Hub default | Credit |
|-------------|--------|
| tdd | Matt Pocock — mattpocock/skills |
| diagnose | Matt Pocock — mattpocock/skills |
| review | Matt Pocock — mattpocock/skills |
| qa | Matt Pocock — mattpocock/skills |
| browser-verify | Evan-Kim2028/agent-skills (Playwright + condensed DevTools MCP) |
| doubt-driven-development | Addy Osmani — addyosmani/agent-skills |
| shipping-and-launch | Addy Osmani — addyosmani/agent-skills |
| security-and-hardening | Addy Osmani — addyosmani/agent-skills |
| web-quality, frontend-design, ui-explore | Evan-Kim2028/agent-skills |
| data-semantic-quality | Evan-Kim2028/agent-skills |
| check-work | Grok Build bundled |
| quality-check (this hub) | Evan-Kim2028/agent-skills — routing + interaction-race gotchas |

## Lineage notes (non-code)

- **browser-verify** — Playwright + webapp-testing lineage; DevTools MCP practice condensed from Addy Osmani pack (now in-repo).  
- **web-quality** — Vercel Web Interface Guidelines / WCAG practical checks.  
- **ui-explore** — HTML design pickers + throwaway prototype branches.  
- **doubt-driven-development** — fresh-context adversarial review (Addy Osmani pack).  
- **tdd / diagnose** — real-engineering workflows (Matt Pocock pack).  

Optional community QA libraries (e.g. petrkindlmann/qa-skills) are **not** required; do not treat as a second router over **quality-check**.
