---
name: mobile-product-ux
description: >
  Mobile product UX — sticky chrome, bottom bars, sheets, safe areas, gesture
  conflicts, one-thumb density. Use only when phone/tablet chrome is the focus
  (sticky misbehaving, sheet vs keyboard, adapting desktop product UI to mobile).
  Prefer product-design when multi-step product UX is unclear (it routes here).
  Prefer frontend-design for full FE feature builds. Not for marketing landings
  only, pure desktop dashboards, general polish (product-ui-craft), or browser
  proof loops (browser-verify / quality-check).
---

# Mobile product UX

**Job:** Make product surfaces **usable with a thumb** without discarding desktop power.

## Sources (attribution)

- Mobile platform practice (safe areas, bottom reachability, sheet patterns)
  aligned with iOS HIG / Material guidance — summarized for agents.
- Production patterns from dense product apps: sticky filter docks, floating
  action HUDs, grade/tool bars that must track matrix height, chat action bars.
- Gesture hygiene: don’t let swipe containers steal sliders/scroll.

Original synthesis for agent-skills; not a copy of a single upstream skill.

## When to load

- Card detail sticky grade bars, mobile action rows  
- Chat history/share density on small screens  
- Trade floor floating HUD / Accept placement  
- Filter docks, bottom sheets, share sheets  
- “Works on desktop, broken on iPhone”  

## Design rules

### 1. Viewports are requirements

Always consider at least:

- ~390×844 (phone)  
- Safe-area insets (`env(safe-area-inset-*)`)  
- Landscape only if product cares  

### 2. Chrome model

| Element | Guidance |
|---------|----------|
| Top sticky | Thin; must not eat content; respect notch |
| Bottom sticky / HUD | Clear primary action; pad for home indicator |
| Dual stickies | Content padding **both** ends; test scroll range |
| Sheets | Drag handle affordance; focus trap; dismiss ≠ error |

### 3. Touch

- Min ~44×44 px targets  
- Separate destructive vs primary  
- Avoid hover-only tooltips for critical info  
- Haptics (if project has a shared helper) only for meaningful commits  

### 4. Gesture conflicts

Before shipping swipeable panels:

- [ ] Horizontal swipe doesn’t steal slider/range inputs  
- [ ] Vertical scroll wins inside lists  
- [ ] Nested scroll areas have clear ownership  
- [ ] Pull-to-refresh (if any) doesn’t fight chat scroll  

### 5. Density on small screens

- Prefer **numbers-first** expandable rows over walls of labels  
- Collapse secondary actions into menus / overflow  
- One primary CTA visible without scroll when possible  
- Don’t clone desktop multi-column toolbars — re-prioritize  

### 6. Content visibility

- Sticky bars must remain stuck for the **full** scroll region they claim  
- Keyboard open: composer/chat stays usable (visual viewport)  
- Fixed footers never permanently hide the last list items  

## Implementation checklist

- [ ] `pb-safe` / padding uses safe-area tokens if project defines them  
- [ ] `position: sticky` parent overflow not breaking stick  
- [ ] z-index layers documented for HUD vs sheet vs nav  
- [ ] Mobile nav items match product priorities (drop low-value tabs)  
- [ ] Share sheet dismiss treated as cancel, not failure toast  

## Verify (required for sticky/gesture work)

Route to **browser-verify**:

- Mobile project or 390-wide snapshot  
- Scroll through full matrix/list with sticky claimed  
- Open sheet + dismiss  
- Primary CTA reachable with one thumb  

## Hand off

| Need | Next skill |
|------|------------|
| Token/type system | **design-system** |
| General density polish | **product-ui-craft** |
| A11y focus in sheets | **web-quality** |
| Jank while scrolling | **react-performance** |
