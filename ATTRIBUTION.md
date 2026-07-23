# Attribution — external skills, books, and lineages

This pack **synthesizes** and **routes**. We do **not** re-host third-party skill
repos wholesale. When we **condense or adapt** an external practice into a file
here, we name the source below and in the skill’s own **Sources (attribution)**
section.

**License rule:** keep upstream licenses when you copy a third-party skill dir
into your install. Distilled book guidance must not quote long passages.

---

## Hubs (this pack)

| Skill | Credit |
|-------|--------|
| `data`, `product-design`, `frontend-design`, `marketing`, `writing`, `quality-check` | Evan-Kim2028/agent-skills — routing synthesis |

---

## Frontend / product (this pack)

| Skill | External lineage (attribution) | Bundled? |
|-------|--------------------------------|----------|
| **design-system** | Anthropic *Improving frontend design through Skills* (constraint-before-code idea); project DESIGN.md / token systems (e.g. Vercel-style product memory in-repo) | Original synthesis |
| **product-ui-craft** | *Impeccable* (Paul Bakaus / impeccable.style); *Make Interfaces Feel Better* (jakub.kr) craft principles | Original synthesis |
| **mobile-product-ux** | iOS HIG / Material density & safe-area practice (summarized) | Original synthesis |
| **web-quality** | Vercel *Web Interface Guidelines* / public web-design-guidelines skill pattern; WCAG 2.2 practical AA | Original synthesis |
| **react-performance** | Vercel Engineering *React Best Practices* agent-skill lineage | Original synthesis |
| **mockup-implement** | OpenAI/Figma “implement design” fidelity practice lineage | Original synthesis |
| **ui-explore** | Anthropic *Unreasonable effectiveness of HTML*; throwaway prototype branch pattern (logic/UI) | Original synthesis + in-repo templates |
| **browser-verify** | Playwright official model; webapp-testing agent skill patterns; **Chrome DevTools MCP** practice condensed from [Addy Osmani — agent-skills](https://github.com/addyosmani/agent-skills) (`browser-testing-with-devtools`) | **Yes** — condensed in `skills/frontend/browser-verify/references/devtools-mcp.md` |
| **tufte** | Edward Tufte, *The Visual Display of Quantitative Information* et al. | Optional separate install; we only **route** |
| **emil-design-eng** | Emil Kowalski — [emil-design-eng](https://www.ui-skills.com/skills/emilkowalski/emil-design-eng) / [animations.dev](https://animations.dev/) | Optional separate install; we only **route** |
| **make-interfaces-feel-better** | Jakub Krehel — [make-interfaces-feel-better](https://www.ui-skills.com/skills/jakubkrehel/make-interfaces-feel-better) / [interfaces.dev](https://interfaces.dev/), MIT | Optional separate install; we only **route** (condensed principles already summarized into `product-ui-craft` above) |
| **12-principles-of-animation** | Raphael Salaja — Disney's 12 principles adapted for web, MIT | Optional separate install; we only **route** |

### Aliases (redirect only)

`visual-verify`, `browser-testing-with-devtools` → **browser-verify**  
`html-design`, `prototype` → **ui-explore**

---

## Data (this pack)

| Skill | External lineage |
|-------|------------------|
| data-apache-lakehouse, data-duckdb, data-api, data-pipeline-operations, data-table-lifecycle, data-semantic-quality | Production lakehouse practice (measured cases in skill text); Iceberg/DuckDB/PyIceberg docs concepts — original synthesis, not a third-party skill copy |

---

## Writing (this pack)

| Skill | Credit | Bundled? |
|-------|--------|----------|
| **writer-style** | [solanabr/writer-style-skill](https://github.com/solanabr/writer-style-skill) — Superteam Brazil / Kaue (MIT). Two-layer voice engine, naturalness/deslop/facts-first rules, kaue pack, tools. | **Yes** — full skill under `skills/writing/writer-style/` with upstream `LICENSE` |
| **writer-style / profiles/evan/** | Voice pack synthesized from public corpus [Evan-Kim2028/evan_writings](https://github.com/Evan-Kim2028/evan_writings) (GitHub Pages: https://Evan-Kim2028.github.io/evan_writings). Domain-agnostic spine + multi-mode presentation (`modes.md`); original spine/card/exemplars. Default pack for this install. | **Yes** |
| **writing-prose** | House floor adapted from the same naturalness/deslop/facts-first principles for **non-persona** writing | Original synthesis; cites solanabr pack |
| **writing-docs** | Pure procedure/reference writing — original synthesis (operator docs practice) | Original |
| **writing-technical** | Research / build-log form aligned with the same corpus habits (numbers-first, problem→fix→lesson) | Original synthesis |
| **writing** (hub) | Evan-Kim2028/agent-skills router; defaults long-form technical voice to **evan** pack | Original |

Do not strip the MIT copyright notice from `skills/writing/writer-style/LICENSE`.

---

## Flutter (this pack)

| Skill | Credit |
|-------|--------|
| **flutter-pro-ux-review** | Original synthesis for agents. Rule themes and audit workflow shaped by public Flutter craft signals: Kamran Bekirov ([flutterpro.design](https://flutterpro.design) / [@kamranbekirovyz](https://x.com/kamranbekirovyz) micro-detail tips; his `kamranbekirovyz/skills` was WIP / not installable when this was written), Andrea Bizzotto (production feature completeness), Mitch Koko (UI hygiene), Roaa Khaddam (animation craft), Ethiel Adisso (spring / interactive motion), Luke Pighetti (prod UX gotchas), plus supporting signals from Filip Hráček, Elvira Leveque, Mike Rydstrom, Majid Hajian. **Not** a copy of any third-party skill repo or a dump of flutterpro.design articles. Complements official Flutter/Dart agent skills (architecture, tests, layout fixes, package guidelines) rather than replacing them. |

---

## Marketing (this pack)

| Skill | Primary source (book / framework) |
|-------|-----------------------------------|
| **marketing-storybrand** | Donald Miller, *Building a StoryBrand* (2017) |
| **marketing-offers** | Alex Hormozi, *$100M Offers* (2021) |
| **marketing-cashvertising** | Drew Eric Whitman, *Cashvertising Online* (2023) |
| **marketing-contagious** | Jonah Berger, *Contagious* (2013) |
| **marketing-going-viral** | Brendan Kane, *The Guide to Going Viral* (2024); hooks: Hormozi *$100M Playbook: Hooks* |
| **marketing** (hub) | Router + generic workflow — no single book |

---

## Quality companions (optional — not re-hosted)

Install from upstream; see `skills/qa/quality-check/references/companion-install.md`.

| Skill (typical name) | Pack / author |
|----------------------|---------------|
| tdd, diagnose, review, qa, triage | [mattpocock/skills](https://github.com/mattpocock/skills) (Matt Pocock / AI Hero) |
| doubt-driven-development, shipping-and-launch, security-and-hardening, code-review-and-quality, debugging-and-error-recovery | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (Addy Osmani) |
| check-work | Grok Build (xAI) bundled when present |

---

## Optional marketing / SEO packs (not re-hosted)

Large open packs exist for SEO, ads ops, page-type templates, etc. **Prefer install
from upstream** rather than merging 100+ skills into this repo:

| Pack | URL | Use when |
|------|-----|----------|
| kostja94/marketing-skills | https://github.com/kostja94/marketing-skills | SEO, social, paid ads, many page types |
| Community “marketing skills” lists | e.g. Composio / AI Builder Club roundups | Discover channel-specific skills |

When you install them, keep their licenses and do **not** replace this pack’s
StoryBrand / Offers / Cashvertising / Contagious / Viral **framework** specialists
unless you intentionally retire them.

---

## Condensed third-party content in this repo

| File | Source | Notes |
|------|--------|-------|
| `skills/frontend/browser-verify/references/devtools-mcp.md` | Addy Osmani *browser-testing-with-devtools* lineage | Condensed security + workflows; not a full file copy of upstream |

If you expand condensation from another pack, add a row here and a Sources block
on the consuming skill.
