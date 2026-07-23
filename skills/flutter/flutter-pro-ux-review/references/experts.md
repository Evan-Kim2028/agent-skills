# Expert personalities this skill synthesizes

**Do not load during audits** — attribution and design history only.

These are **public craft signals**, not endorsements or affiliation. The skill
does not impersonate anyone; it encodes recurring *judgment patterns* so an
agent can review Flutter apps the way seasoned shippers do.

---

## Core cluster (closest to this skill’s job)

### Kamran Bekirov (@kamranbekirovyz)

- **Signal:** flutterpro.design — “small details that build taste”; high-frequency
  X tips with code + edge cases (dead taps, null, haptics, human dates/phones,
  enter-slow-exit-fast, snackbar shake, keyboard actions).
- **Agent habit:** One defect = one rule. Detect with grep. Explain what the
  *user* feels. Severity + effort. Plan then implement with cheaper models.
- **Not his job here:** Framework architecture lectures.

### Andrea Bizzotto (@biz84 / codewithandrea)

- **Signal:** Production Flutter courses and tips — riverpod/architecture *and*
  complete feature paths (validation, loading, empty, error, retry).
- **Agent habit:** A screen is not done when it “looks right.” Flag missing
  async UI states (`async-ui-states`). Prefer robust UX over demo happy paths.

### Mitch Koko (@createdbykoko)

- **Signal:** Clean UI builds, practical tips, visual hygiene, theming.
- **Agent habit:** Prefer simple, readable widget fixes; kill ugly defaults;
  keep polish approachable (S-effort fixes first).

### Roaa Khaddam (@roaakdm)

- **Signal:** Flutter GDE; animation and interaction craft.
- **Agent habit:** Motion must be intentional. Prefer meaningful transitions
  over decorative spam; align with `enter-slow-exit-fast` and reduced motion.

### Ethiel Adisso (@enthusiastDev)

- **Signal:** Spring-driven, Apple-adjacent Flutter motion (blur, sheets,
  count-up, draggable polish).
- **Agent habit:** Finger-driven UI settles with springs; interactive motion ≠
  page-route defaults.

### Luke Pighetti (@luke_pighetti)

- **Signal:** Production war stories (e.g. keyboard not dismissing on outside tap).
- **Agent habit:** Hunt real device annoyances, not textbook purity.

---

## Supporting craft signals

| Person | Takeaway for rules |
|--------|--------------------|
| **Filip Hráček** (Flutter design-dev talks) | Restraint, hierarchy, “little things” compound |
| **Elvira Leveque** (micro-interactions) | Feedback loops on press/success/transition |
| **Mike Rydstrom (RydMike)** | Adaptive Material/Cupertino; theme consistency |
| **Majid Hajian (@mhadaily)** | Production engineering taste; ship-quality bar |
| **Romain Rastel** (flutter_slidable etc.) | Gesture affordances must be discoverable |
| **Craig Labenz / Flutter team educators** | Platform conventions matter; don’t fight HIG/Material blindly |

---

## How personalities map to hunt surfaces

| Surface | Primary voices |
|---------|----------------|
| Touch / hit testing | Kamran, Luke |
| Human-readable data | Kamran |
| Forms / keyboard | Kamran, Andrea, Luke |
| Scroll / layout stability | Kamran, Filip |
| Async feature completeness | Andrea |
| Motion / springs | Roaa, Ethiel, Elvira |
| Haptics / snackbars | Kamran, Elvira |
| Adaptive platform chrome | RydMike, Flutter educators |
| Visual cleanliness | Mitch, Filip |

---

## Relationship to kamranbekirovyz/skills

That repo’s `/flutter-pro-design-review` (WIP as of mid-2026: DETAILS.md only,
install “Coming soon”) aims at the same *audit* product shape. This skill is
an **independent synthesis** for the Evan-Kim2028/agent-skills pack: original
rule text, multi-expert coverage, and installable `SKILL.md` now. When Kamran’s
pack ships, treat it as a sibling catalog — do not assume identical slugs.
