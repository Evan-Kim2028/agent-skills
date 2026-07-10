---
name: ui-explore
description: >
  Throwaway design exploration before production — standalone HTML A/B pickers,
  in-app multi-variant UI prototypes, or tiny terminal logic prototypes. Use when
  the user wants design options, compare A vs B, "prototype this", "try a few
  designs", or /html-design. Prefer product-design when multi-step product UX
  craft is unclear; frontend-design for full FE builds. Not for production ports
  (mockup-implement after pick), charts (tufte), marketing copy, or ship proof
  (quality-check / browser-verify). Aliases: html-design, prototype.
---

# UI explore

**Throwaway artifacts that answer a design or logic question** before committing
production. One skill, three shapes:

| Shape | Question | Detail |
|-------|----------|--------|
| **HTML A/B** | “Which pixels for this product delta?” | Standalone HTML + picker (default for product chrome deltas) |
| **In-app UI variants** | “What should this look like *in the app*?” | `?variant=` on a real route + floating bar |
| **Logic / terminal** | “Does this state model feel right?” | Tiny TUI over a pure reducer/machine |

## Pick a shape

1. **Logic / state / API feel** → [`references/logic-branch.md`](references/logic-branch.md)  
2. **Look & layout**  
   - Prefer **HTML A/B** for small product deltas and review without a full app boot  
   - Prefer **in-app variants** when judgment needs real chrome/data density  
   → [`references/ui-branch.md`](references/ui-branch.md) + HTML rules below  

If ambiguous and user is unreachable: product page → UI; backend module → logic.
State the assumption at the top of the artifact.

## Rules for every shape

1. **Throwaway and marked as such** (banner, path name `ui-explore`, title).  
2. **One command to run** (project runner or `python3 -m http.server`).  
3. **No production polish** (no full test suite, no gold-plating).  
4. **Surface state** after every action / variant switch.  
5. **Delete or absorb** when the question is answered; capture the verdict.  

## Shape 1 — Standalone HTML A/B (product deltas)

Inspired by [The unreasonable effectiveness of HTML](https://claude.com/blog/using-claude-code-the-unreasonable-effectiveness-of-html).

### Hard rules

1. **Match blast radius.** Small ask → Design A = current, Design B = current + only that delta.  
2. **HTML first**, production second.  
3. **One switcher surface** (floating picker / keys / `?design=`).  
4. **Serve + verify** the URL; give the user the link.  
5. **Record the pick** (one line: which design, what to implement).  

### Workflow

1. Frame one sentence question.  
2. Mode: A/B before–after (default) or multi-variant (max 5).  
3. Build one HTML file — scaffold [`templates/ab-compare.html`](templates/ab-compare.html); patterns [`references/patterns.md`](references/patterns.md); anti-patterns [`references/anti-patterns.md`](references/anti-patterns.md).  
4. Serve (`./design/serve.sh` or `python3 -m http.server 8765`).  
5. Verify switcher; user picks.  
6. Implement via **mockup-implement** only after sign-off.  

**Paths:** `design/<topic>-ab.html` when the repo has `design/`.

## Shape 2 — In-app UI variants

Full process: [`references/ui-branch.md`](references/ui-branch.md).

- Prefer embedding variants on an **existing route** with `?variant=` (real header/data).  
- Floating bottom bar; 3 variants default, max 5.  
- Mark route/file as prototype; delete or fold after decision.  

## Shape 3 — Logic terminal prototype

Full process: [`references/logic-branch.md`](references/logic-branch.md).

- Pure logic module + throwaway TUI.  
- One command; print full state after each action.  
- Lift validated logic into production; delete the TUI.  

## Done criteria

- [ ] User can run one command / open one URL  
- [ ] They can switch variants or drive cases without re-prompting  
- [ ] Verdict captured (which option / what we learned)  
- [ ] Production path named **or** explicit reject + delete plan  

## Hand off

| Next | Skill |
|------|--------|
| Port signed-off visual | **mockup-implement** |
| Polish after port | **product-ui-craft** (+ **mobile-product-ux**) |
| Tokens | **design-system** |
| Prove in browser | **browser-verify** / **quality-check** |
