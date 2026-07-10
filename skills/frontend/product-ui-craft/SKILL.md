---
name: product-ui-craft
description: >
  Raise product UI craft — spacing, hierarchy, density, radii, states, and
  restrained motion so chrome feels designed. Use only when polishing already
  structured UI ("works but feels off"), not as the default for any UI task.
  When the right frontend skill is unclear or work spans tokens/mobile/verify,
  use frontend-design first. Not for brand invention, marketing landings,
  design-system token definition (design-system), mobile sticky/sheet systems
  (mobile-product-ux), or ship/e2e proof (quality-check / visual-verify).
---

# Product UI craft

**Job:** Turn working UI into **refined product UI** without changing brand identity.

## Sources (attribution)

- **Product-mode craft** ideas aligned with community skills such as
  [Impeccable](https://impeccable.style/) (Paul Bakaus) — especially separating
  **product** density from **brand/marketing** maximalism, and directional
  polish passes (`quieter` / `bolder` mental model).
- **Micro-detail checklists** in the spirit of *Make Interfaces Feel Better*
  (jakub.kr / UI polish principles): spacing, type, alignment, hierarchy,
  radii, subtle motion.
- Classic product design craft (scanability, grouping, consistent rhythm) —
  applied as agent checklists, not a redesign brief.

This skill is **original synthesis** for agents; it is not a vendor dump of those
repos.

## When to load

- “Looks fine but cheap / uneven / sparse / noisy”  
- Chat shells, toolbars, filter bars, tables, empty states  
- After **design-system** constraints are clear  

## Craft pass (run in order)

### 1. Hierarchy

- One primary action per region  
- Type steps: page title → section → body → meta (mono for numbers if system says so)  
- Don’t bold everything; don’t mute the primary metric  

### 2. Spacing rhythm

- Prefer a single scale (4/8 or project tokens)  
- Related items: tighter; unrelated groups: looser  
- Kill accidental 1-off gaps that break the grid  

### 3. Alignment

- Columns share edges; icons and labels share baselines  
- Trailing numbers/tabular figures when comparing prices  
- Sticky headers align with scroll body, not “almost”  

### 4. Density

- Product data surfaces: prefer **information density** over marketing whitespace  
- Collapse chrome before shrinking type below readable  
- Prefer progressive disclosure over walls of equal-weight controls  

### 5. Surfaces & radii

- Consistent elevation language (flat panels vs glossy controls if defined)  
- One radius family; don’t mix pill + sharp + random 10px  
- Borders: prefer token borders over heavy shadows for data UI  

### 6. States

For each interactive/async region:

| State | Must have |
|-------|-----------|
| Loading | Skeleton/spinner + `aria-busy` on container |
| Empty | What & next action |
| Error | Recoverable message + retry if applicable |
| Success | Stable layout (no jump) |

### 7. Motion

- Prefer **one** orchestrated moment over many micro-wiggles  
- 150–300ms transitions for UI chrome  
- Honor `prefers-reduced-motion`  
- Don’t animate layout of dense tables unless essential  

### 8. Directional polish (optional pass names)

Use as self-instructions when iterating:

| Pass | Do |
|------|-----|
| **Quieter** | Reduce borders, shadows, competing accents |
| **Bolder** | Strengthen primary CTA/metric only |
| **Tighter** | Reduce vertical waste in lists/toolbars |
| **Clearer** | Labels, contrast, grouping |

## Anti-patterns

- “Polish” that changes brand fonts/colors  
- Decorating every card with gradients and glow  
- Equal visual weight on 8 actions  
- Hover-only affordances on mobile-critical controls  

## Hand off

| Need | Next skill |
|------|------------|
| Tokens/components wrong | **design-system** |
| Phone sticky/gestures | **mobile-product-ux** |
| A11y/focus | **web-quality** |
| Prove pixels | **visual-verify** |
