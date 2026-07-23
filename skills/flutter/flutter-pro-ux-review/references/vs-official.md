# Complements official Flutter / Dart agent skills

Official (and ecosystem) Flutter skills teach **how to build correctly**.
This skill teaches **what still feels wrong to users after it builds**.

## Typical official / GDE skill lanes (already on many machines)

Examples under `~/.grok/skills` / Flutter agent packs:

| Skill family | Job |
|--------------|-----|
| `flutter-apply-architecture-best-practices` | Layers: UI / ViewModel / Repository / services |
| `flutter-setup-declarative-routing` | go_router / URL strategy |
| `flutter-add-widget-test` / integration tests | Prove widgets and flows |
| `flutter-fix-layout-issues` | Constraints, overflow, unbounded height |
| `flutter-use-http-package` / JSON serialization | Data plumbing |
| `flutter-setup-localization` | i18n plumbing |
| `dart-run-static-analysis` / mocks / coverage | Code health |
| Google / Serverpod **package skills** (`skills get`) | Framework & package APIs, guidelines |

These are necessary. They are **not** a substitute for a production UX audit.

## Division of labor

```
official Flutter skills          flutter-pro-ux-review
──────────────────────          ─────────────────────
How to structure features       How features feel on-device
How to test widgets             What users mis-tap / mis-read
How to fix RenderFlex           Why the last list item feels crushed
How to wire HTTP/JSON           Why the UI showed "null"
Material/Cupertino APIs         When adaptive choice is inconsistent
Package usage guidelines        Ranked polish backlog + PLAN.md
```

## Suggested pipeline

1. **Structure** — architecture / routing skills  
2. **Implement feature** — project patterns + HTTP/state skills  
3. **Correctness** — analyzer, widget tests, layout-fix skill  
4. **Polish audit** — **`flutter-pro-ux-review`** (this skill)  
5. **Ship proof** — integration tests / quality-check / device run  

## What Kamran said publicly (product positioning)

When asked how a design-review skill differs from official Flutter skills, the
framing was: official ≈ **guidelines**; design-review ≈ **find UX issues**.
This pack adopts that split deliberately.

## Do not duplicate

When this skill is active, **do not**:

- Re-explain MVVM or folder structure  
- Rewrite the app to a different state-management library mid-audit  
- Turn the review into a general Flutter tutorial  

Hand those tasks back to the official skills listed above.
