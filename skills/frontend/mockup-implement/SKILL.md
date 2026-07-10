---
name: mockup-implement
description: >
  Port a signed-off mockup (HTML picker winner, Figma, screenshot) into
  production with fidelity — no freestyle redesign. Use only when a design is
  already chosen and the task is "match this." Prefer product-design when craft/explore path is unclear;
  frontend-design for full FE feature implementation. Not for open-ended exploration (ui-explore first)
  or inventing new visual systems (design-system / craft).
---

# Mockup → production implementation

**Job:** Ship the **agreed** design in production primitives — not a reinterpretation.

## Sources (attribution)

- **Design-to-code fidelity** practice from OpenAI/Figma “implement design”
  skill lineage: multi-state components, respect existing system, verify
  visually.
- **Repo `design/` workflows**: HTML pickers, `?design=` variants, selection
  JSON, DESIGN-DIRECTION locks (SilphCo-style and similar).
- **ui-explore** skill: exploration stays in throwaway HTML; this skill starts
  **after** a winner is chosen.

## When to load

- “Port Trade Floor v7 mockup” / “implement design B”  
- Figma frame → React  
- Screenshot parity tickets  
- Agents redesign while “implementing”  

## Preconditions

1. **Signed-off source** named (path, frame, or URL)  
2. **design-system** constraints known (tokens, kit)  
3. Out of scope listed (don’t “while we’re here” redesign nav)  

If not signed off → **ui-explore** (or Figma) first; do not implement fog.

## Workflow

### 1. Inventory the mockup

Extract a checklist:

| Concern | Notes |
|---------|--------|
| Layout regions | header / body / sticky / HUD |
| Typography | which roles (title, meta, mono price) |
| Components | map to kit (`Button`, `Sheet`, `Panel`…) |
| States | empty, loading, error, selected, disabled |
| Motion | none / subtle / explicit |
| Breakpoints | mobile vs desktop differences |
| Data | real fields vs placeholder |

### 2. Map mock → code

| Mock element | Production target |
|--------------|-------------------|
| Pretty div button | Kit `Button` variant |
| Hard-coded color | Token class / CSS var |
| Fake data | Real query + empty/error |
| Absolute artboard | Responsive layout + sticky rules |

Never paste mock CSS wholesale if it bypasses tokens.

### 3. Implement minimal delta

- Prefer smallest PR that matches the signed surface  
- Reuse routes/features; don’t new-page without need  
- Preserve existing analytics/a11y hooks  

### 4. Fidelity gate

Side-by-side:

1. Mockup (or HTML `?design=winner`)  
2. Local prod build  

Check:

- [ ] Structure/order of regions  
- [ ] Spacing rhythm within ~token step  
- [ ] Sticky/HUD behavior on mobile  
- [ ] Primary CTA placement  
- [ ] No extra chrome the mock lacks  
- [ ] No missing states the mock shows  

### 5. Verify

Use **browser-verify** (and **mobile-product-ux** if applicable). Update snapshots
only when intentional.

## Anti-patterns

- “Improved” colors/fonts during port  
- Shipping desktop mock only when mock specifies mobile  
- Leaving mock placeholder copy in production  
- New dependencies for something the kit already does  
- Scope creep into adjacent pages  

## Relation to ui-explore

```
ui-explore → pick winner → mockup-implement → product-ui-craft polish → browser-verify
```

## Hand off

| Need | Next skill |
|------|------------|
| Tokens/primitives | **design-system** |
| Post-port polish | **product-ui-craft** |
| Mobile sticky | **mobile-product-ux** |
| Browser proof | **browser-verify** |
