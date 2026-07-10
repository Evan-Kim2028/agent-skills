---
name: react-performance
description: >
  Apply React and SPA performance patterns — eliminate request waterfalls,
  shrink bundles, control re-renders, and keep charts/lists smooth. Use when
  optimizing frontend load time, fixing jank, code-splitting heavy libs
  (e.g. echarts), reviewing React Query/data fetching, or hitting performance
  budgets. Not for pure CSS aesthetics or a11y-only reviews.
---

# React performance

**Job:** Make product UI **fast enough** that craft work is usable.

## Sources (attribution)

- **Vercel Engineering React Best Practices** agent-skill lineage: prioritized
  rules around waterfalls, bundle size, server/client data fetching, and
  re-render hygiene (public `react-best-practices` skill pattern).
- Core Web Vitals orientation (LCP, INP/FID proxy, CLS) as used in product
  performance budgets.
- Chart/code-split practice common in analytics frontends (lazy heavy viz libs).

This file is a compact agent checklist, not a dump of Vercel’s full rule set.

## When to load

- Slow route transitions or chat streams that block input  
- Large main bundles / lighthouse or budget failures  
- Card grids, virtualized lists, ECharts/map libs  
- “Everything re-renders when one filter changes”  

## Priority order (fix highest impact first)

### 1. Eliminate waterfalls (critical)

- Prefer parallel fetches over await chains  
- Don’t block entire page on secondary panels  
- Use deferred/streaming patterns when the framework supports them  

**Smell:** Network waterfall in DevTools; time-to-first-content dominated by sequential API calls.

### 2. Bundle size (critical)

- Dynamic import heavy routes and libs (`echarts`, markdown, pdf, maps)  
- Avoid barrel-file imports that pull whole icon/component sets  
- Keep SSR/client entry lean; split admin/scanner/trade if route-isolated  

**Smell:** Main chunk jumps after adding one chart import.

### 3. Data fetching hygiene

- Cache with stable keys (React Query / router loaders)  
- Stale-while-revalidate for browse surfaces when product allows  
- Don’t refetch whole page for grade/timeframe toggles if partial data works  
- Cancel/ignore stale responses on rapid filter changes  

### 4. Re-render control (medium)

- State lives near consumers; avoid god-context for high-frequency values  
- Derived booleans over storing everything raw  
- Memoize **expensive** pure calc (chart option builders), not every component  
- Virtualize long lists (`@tanstack/react-virtual` or equivalent)  

### 5. Rendering performance

- Animate transform/opacity only  
- `content-visibility` for long offscreen sections when appropriate  
- Images: correct size/variant for thumbnails vs lightbox  

### 6. Charts (analytics-specific)

- One shared chart component contract (dispose on unmount)  
- Don’t rebuild full option objects on unrelated parent state  
- Separate chart chunk from app shell  

## Review output

State impact tier + fix:

```
CRITICAL — sequential grade-stats then sales fetch on card open; parallelize
HIGH — echarts imported from route root; dynamic import into Chart shell
MEDIUM — filter context re-renders entire PriceMatrix; split selection state
```

## Hand off

| Need | Next skill |
|------|------------|
| Tokens/layout | **design-system** / **product-ui-craft** |
| Prove no visual regression after split | **visual-verify** |
| Mobile jank from sticky+scroll | **mobile-product-ux** |
