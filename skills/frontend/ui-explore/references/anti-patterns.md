# HTML Design — Anti-patterns

## Scope explosions

| User said | Wrong output | Right output |
|-----------|--------------|--------------|
| "Minimal link from card → trade" | New card page with grade bands, draft tray, search | One secondary button on current header |
| "Show me the change" | Five unrelated redesigns | A = current, B = +delta |
| "Connect X to Y" | Rebuild X and Y | Entry point + destination seed only |

If you already shipped a heavy prototype and the user says "too drastic",
**stop defending it**. Mark rejected, ship A/B of the minimal delta.

## Visual noise

- Do not retheme the whole product "for fun" in a before/after of one CTA
- Do not add marketing copy that production doesn't have
- Do not animate everything — one subtle highlight on the delta is enough
- Do not require zooming a 4K full-page redesign to find a 44px button

## Process failures

- Markdown wireframes when the user needs to **see** UI
- Two separate HTML files without a switcher (user can't flick A↔B)
- Production PR before the user has a URL to judge
- Leaving rejected explorations as the default path in docs

## False "before"

Design A must be the **actual current** experience. Inventing a worse "before"
to make B look good is fraud. If current is ugly, A is still that ugly.

## Absorbed too early / never absorbed

- Implementing all variants in production "just in case"
- Leaving `design/*-ab.html` as the only source of truth forever with no prod follow-up
