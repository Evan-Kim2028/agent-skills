# agent-skills

Portable agent skills for Claude Code, Grok Build, Cursor, and similar tools.

**Clone this repo → you get every skill under `skills/`.** Nothing else is required for the hubs and their specialists in this pack. You do **not** need to clone Addy Osmani, Matt Pocock, or other repos first. Optional external packs only fill *non-bundled* QA companions (e.g. `tdd`, `diagnose`) or large SEO/ads libraries — see `skills/qa/quality-check/references/companion-install.md` and **[ATTRIBUTION.md](ATTRIBUTION.md)**.

---

## Start here: six hubs

**Remember only these.** Say the hub name (or describe the job). The agent should load the hub first, then one specialist.

| Hub | Use for |
|-----|---------|
| **`data`** | Pipelines / lakehouse / APIs / ops / row quality |
| **`product-design`** | Product UI/UX craft — density, mobile chrome, tokens, a11y, explore |
| **`frontend-design`** | Implement product UI in code (perf, SPA build path) |
| **`marketing`** | Offers / messaging / ads / viral (frameworks) |
| **`writing`** | Human voice, Evan default pack, technical form, pure docs (tone ≠ offer design) |
| **`quality-check`** | Prove it — TDD, e2e, review, ship, regressions |

### Craft vs build vs prove vs write

```
product-design   →  craft / mobile UX / “feels off”
frontend-design  →  implement the feature in code
marketing        →  offer / story / ads frameworks
writing          →  sound like a human; Evan voice / technical form / pure docs
quality-check    →  prove it before “done”
```

### Install the hubs (and their specialists)

```bash
git clone https://github.com/Evan-Kim2028/agent-skills.git
cd agent-skills

install_skill() {
  local src="$PWD/skills/$1"
  local name="$2"
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
    mkdir -p "$root"
    rm -rf "$root/$name"
    mkdir -p "$root/$name"
    cp -a "$src"/. "$root/$name"/
  done
  echo "installed $name"
}

# --- hubs ---
install_skill "data/data" "data"
install_skill "frontend/product-design" "product-design"   # craft hub
install_skill "frontend/frontend-design" "frontend-design" # implement hub
install_skill "marketing/marketing" "marketing"
install_skill "writing/writing" "writing"
install_skill "qa/quality-check" "quality-check"

# --- data specialists (hub routes here) ---
for pair in \
  "data/apache-lakehouse:data-apache-lakehouse" \
  "data/data-api:data-api" \
  "data/duckdb:data-duckdb" \
  "data/pipeline-operations:data-pipeline-operations" \
  "data/table-lifecycle:data-table-lifecycle" \
  "data/semantic-quality:data-semantic-quality"
do install_skill "${pair%%:*}" "${pair##*:}"; done

# --- product / frontend specialists ---
for pair in \
  "frontend/design-system:design-system" \
  "frontend/product-ui-craft:product-ui-craft" \
  "frontend/web-quality:web-quality" \
  "frontend/react-performance:react-performance" \
  "frontend/mobile-product-ux:mobile-product-ux" \
  "frontend/mobile-blog-chart-visual:mobile-blog-chart-visual" \
  "frontend/mobile-app-echarts-visual:mobile-app-echarts-visual" \
  "frontend/mockup-implement:mockup-implement" \
  "frontend/ui-explore:ui-explore" \
  "frontend/browser-verify:browser-verify"
do install_skill "${pair%%:*}" "${pair##*:}"; done

# Optional aliases (old names → thin redirects)
for pair in \
  "frontend/visual-verify:visual-verify" \
  "frontend/browser-testing-with-devtools:browser-testing-with-devtools" \
  "frontend/prototype:prototype" \
  "design/html-design:html-design" \
  "frontend/mobile-chart-visual:mobile-chart-visual"
do install_skill "${pair%%:*}" "${pair##*:}"; done

# --- marketing specialists ---
for pair in \
  "marketing/offers:marketing-offers" \
  "marketing/storybrand:marketing-storybrand" \
  "marketing/cashvertising:marketing-cashvertising" \
  "marketing/contagious:marketing-contagious" \
  "marketing/going-viral:marketing-going-viral"
do install_skill "${pair%%:*}" "${pair##*:}"; done

# --- writing (Evan voice + form specialists) ---
install_skill "writing/writing-prose" "writing-prose"
install_skill "writing/writing-docs" "writing-docs"
install_skill "writing/writing-technical" "writing-technical"
install_skill "writing/writer-style" "writer-style"   # engine + evan pack + kaue pack (MIT engine)

# --- flutter (complements official Flutter/Dart skills) ---
install_skill "flutter/flutter-pro-ux-review" "flutter-pro-ux-review"
```

Re-run install after `git pull` if you use **copies** (they do not auto-update).  
**Symlinks** to this clone update live when the clone path stays fixed.

**Nothing auto-downloads** when you open another git repo or machine — only what is already installed under `~/.claude/skills` / `~/.grok/skills` is visible to the agent.

---

## What’s in this clone (self-contained)

| Pack | Skills (all under `skills/`) |
|------|------------------------------|
| **data** | hub + lakehouse, api, duckdb, pipeline-ops, table-lifecycle, semantic-quality |
| **frontend** | **product-design** + **frontend-design** hubs + design-system, craft, web-quality, react-performance, mobile-product-ux, **mobile-blog-chart-visual**, **mobile-app-echarts-visual**, mockup-implement, **ui-explore**, **browser-verify** (+ thin aliases) |
| **marketing** | hub + offers, storybrand, cashvertising, contagious, going-viral |
| **writing** | **writing** hub + **writing-prose** + **writing-docs** + **writing-technical** + **writer-style** (vendored [solanabr/writer-style-skill](https://github.com/solanabr/writer-style-skill) MIT engine; **default pack `evan`** from [evan_writings](https://github.com/Evan-Kim2028/evan_writings); kaue pack retained) |
| **qa** | **quality-check** hub (+ install docs for optional external companions) |
| **flutter** | **flutter-pro-ux-review** — production UX polish audit (complements official Flutter architecture/test skills) |

### Merged specialists (use the new names)

| New skill | Replaces |
|-----------|----------|
| **`browser-verify`** | `visual-verify` + `browser-testing-with-devtools` (Playwright **and** DevTools MCP) |
| **`ui-explore`** | `html-design` + `prototype` (HTML A/B **and** throwaway UI/logic prototypes) |

Old names remain as **aliases** (redirect stubs) so existing prompts still resolve.

### Optional / not in this repo

| Skill | Notes |
|-------|--------|
| **tufte** | Charts — install separately if you use it; FE hub still routes there when present |
| **emil-design-eng** | Emil Kowalski design-engineering — install separately; `product-design` hub routes there when present |
| **make-interfaces-feel-better** | Jakub Krehel micro-interaction/feel checklist — install separately; `product-design` hub routes there when present |
| **12-principles-of-animation** | Disney's 12 principles adapted for web (Raphael Salaja) — install separately; `product-design` hub routes there when present |
| **tdd**, **diagnose**, **check-work**, **review**, … | QA companions — may live in other packs or Grok built-ins; hub documents fallbacks when missing |

You do **not** need those optionals for data / marketing / core FE craft.  
`quality-check` still works with fallbacks if a companion is missing.

---

## Specialist map (only if you already know the lane)

### data →

`data-apache-lakehouse` · `data-api` · `data-duckdb` · `data-pipeline-operations` · `data-table-lifecycle` · `data-semantic-quality`

### product-design →

`design-system` · `product-ui-craft` · `mobile-product-ux` · `web-quality` · `ui-explore` · `mockup-implement` · `browser-verify` · (`tufte`, `emil-design-eng`, `make-interfaces-feel-better`, `12-principles-of-animation` if installed)

### frontend-design →

same craft specialists + **`react-performance`** · full implement pipeline · hand off craft-only asks to **product-design**

### marketing →

`marketing-offers` · `marketing-storybrand` · `marketing-cashvertising` · `marketing-contagious` · `marketing-going-viral`

### writing →

`writer-style` (**default pack: evan**; kaue optional) · `writing-technical` (research / build-log form) · `writing-docs` (runbooks / reference) · `writing-prose` (house human, no persona) · hand off conversion frameworks to **marketing**

### quality-check →

`tdd` · `diagnose` · `browser-verify` · `web-quality` · `check-work` · `review` · … (see hub) · `data-semantic-quality` · hand off **frontend-design** for build phase

### flutter →

`flutter-pro-ux-review` — ranked production UX findings (dead taps, null, haptics, keyboard, motion). Use **after** official Flutter architecture/test skills; not a substitute for them.

---

## Layout

```
skills/
  data/           # hub + specialists
  frontend/       # product-design + frontend-design hubs + specialists
  flutter/        # production Flutter UX review (complements official Flutter skills)
  marketing/      # hub + specialists
  writing/        # hub + writer-style (evan/kaue) + prose/docs/technical
  qa/             # quality-check hub
  design/         # html-design alias only
```

Each skill is a directory with `SKILL.md` ([Agent Skills](https://agentskills.io) / Claude skills format). The `name:` field is the skill id; the directory is organizational.

---

## Spec

Follow [agentskills.io](https://agentskills.io) / Claude skill authoring: third-person `description` with triggers; progressive disclosure via `references/`; specialists defer broad routing to hubs.
