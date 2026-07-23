---
name: flutter
description: >
  Routing hub for Flutter app work — structure vs polish vs tests vs layout
  fixes. Use when the task is Flutter/Dart mobile UI and the right specialist
  is unclear, or user says /flutter. Routes to official flutter-* architecture,
  test, layout skills when present, and flutter-pro-ux-review for production UX
  polish. Not for React/web product craft (product-design) or pure backend.
---

# Flutter — routing hub

**Route first → one specialist → do the work.** Do not load every Flutter skill.

```
flutter (this hub)
  → flutter-apply-architecture-best-practices   # layers / feature structure
  → flutter-setup-declarative-routing           # go_router / URLs
  → flutter-fix-layout-issues                   # overflows / constraints
  → flutter-pro-ux-review                       # production UX polish audit
  → flutter-add-widget-test / integration       # prove widgets / flows
  → dart-run-static-analysis                    # analyzer
  → quality-check                               # ship / e2e proof
```

## Routing table

| Task | Skill |
|------|--------|
| New feature structure, MVVM, repositories | **flutter-apply-architecture-best-practices** (if installed) |
| go_router / deep links setup | **flutter-setup-declarative-routing** |
| RenderFlex, unbounded height | **flutter-fix-layout-issues** |
| Polish, dead taps, null, a11y, keyboard, haptics, “feels off”, release UX | **flutter-pro-ux-review** |
| Widget / integration tests | **flutter-add-widget-test** / **flutter-add-integration-test** |
| HTTP / JSON plumbing | **flutter-use-http-package** / **flutter-implement-json-serialization** |
| Localization setup | **flutter-setup-localization** |
| Unclear multi-step *craft on Flutter UI* | **flutter-pro-ux-review** after structure exists |
| React/web density (not Flutter) | **product-design** hub |

## Default pipelines

**New feature**

1. Architecture / routing skills if structure missing  
2. Implement with project patterns  
3. Analyzer + widget tests  
4. **flutter-pro-ux-review** on touched surfaces  
5. quality-check if shipping  

**Polish-only**

1. **flutter-pro-ux-review** (`mode: review`)  
2. User picks findings → `plan` → `fix`  

## Notes

- Official `flutter-*` / `dart-*` skills may live outside this pack; route by name when present.  
- **flutter-pro-ux-review** is the bundled polish auditor in this pack.  
- Do not use **product-ui-craft** / **mobile-product-ux** as the primary skill for Flutter widgets (those are web/CSS-oriented).
