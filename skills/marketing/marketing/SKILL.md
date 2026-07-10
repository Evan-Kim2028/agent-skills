---
name: marketing
description: >
  Routing hub for marketing — offers, StoryBrand messaging, direct-response ads,
  word-of-mouth, and social virality. Use when creating or reviewing landing pages,
  pricing, emails, ads, lead magnets, launches, referral loops, or social content,
  or when the right marketing skill is unclear. Routes to marketing-offers,
  marketing-storybrand, marketing-cashvertising, marketing-contagious,
  marketing-going-viral. Prefer product-design for product app UI craft; quality-check
  for ship/e2e; data for pipelines. Prefer this hub over loading all marketing
  specialists at once.
metadata:
  short-description: "Marketing hub — offers, message, ads, WOM, social"
---

# Marketing — routing hub

**Clear offer + customer story + action.** Route first, then open **one** framework
specialist (or two when stacking offer → message → conversion).

Load at most **1–3** specialists. Do not spray every book skill on one asset.

## Routing table

| Your task | Skill | When |
|-----------|--------|------|
| Package, pricing, bonuses, guarantee, value equation | **marketing-offers** | Offer is weak or unclear |
| One-liner, website story, CTA, lead magnet narrative | **marketing-storybrand** | Company-centric or confusing copy |
| Ads, email promo, opt-in, CTA/psychology, cart recovery | **marketing-cashvertising** | Message clear; response weak |
| Referral, PR, shareability, STEPPS | **marketing-contagious** | Need talk/share, not just clarity |
| Social hooks, formats, Gold/Silver/Bronze, retention | **marketing-going-viral** | Social content strategy |
| Brand voice / long-form author voice | **writer-style** if installed | Voice pack, not offer design |
| Product app UI density/mobile | **product-design** | Not a landing-page problem |
| Unclear multi-step marketing | **start here** | Default |

### Default pipeline (most assets)

```
1. marketing-offers     → is the offer valuable enough?
2. marketing-storybrand → is the customer story clear?
3. marketing-cashvertising → will the ad/email/page get response?
4. marketing-contagious and/or marketing-going-viral → share/social if needed
```

Skip steps that already pass. Do **not** start with viral hooks if the offer is mud.

### Landing page mini-pipeline

1. **offers** — value, guarantee, price frame  
2. **storybrand** — hero problem, guide, plan, CTA  
3. **cashvertising** — headline/proof/CTA friction  
4. **product-design** only for *app* chrome on marketing site if needed  

## General workflow (when no specialist fits)

1. Audience, offer, single desired action.  
2. Problem in the customer’s language.  
3. Features → outcomes; cut vanity features.  
4. One primary CTA.  
5. Draft plain language.  
6. Review: clarity, proof, friction.  

## General review checks

- Can a buyer tell what is offered without jargon?  
- Audience specific enough?  
- Value concrete?  
- One CTA?  
- Proof matches the claim?  
- One main idea?  

## Sources (attribution) — this pack

| Skill | Primary source |
|-------|----------------|
| **marketing-offers** | Alex Hormozi, *$100M Offers* (2021) |
| **marketing-storybrand** | Donald Miller, *Building a StoryBrand* (2017) |
| **marketing-cashvertising** | Drew Eric Whitman, *Cashvertising Online* (2023) |
| **marketing-contagious** | Jonah Berger, *Contagious* (2013) |
| **marketing-going-viral** | Brendan Kane, *Guide to Going Viral* (2024); Hormozi *Hooks* playbook |
| **This hub** | Evan-Kim2028/agent-skills router |

Do not quote books at length. Cite which framework each claim uses when stacking skills.

Full index: [ATTRIBUTION.md](../../../ATTRIBUTION.md).

## Gaps & optional external packs (install, don’t re-host)

This pack is strong on **framework marketing** (offer, story, psych, WOM, social).
It is **not** a 160-skill SEO/ads-ops library. For those, install upstream and keep
their licenses:

| Need | Example external packs | Rule |
|------|------------------------|------|
| SEO / content page types / channel playbooks | [kostja94/marketing-skills](https://github.com/kostja94/marketing-skills) and similar open “marketing skills” lists | Install optionally; do not replace StoryBrand/Offers specialists |
| Paid ads ops (Google/Meta account structure) | Community Claude marketing skill lists (Composio / roundups) | Prefer live data + your account SOPs over generic prompts |
| Long-form voice | **writer-style** (if installed on Grok) | Not a substitute for offer clarity |

**Do not** bulk-merge huge SEO packs into this repo — discovery noise and license
surface. Route: hub → framework specialist → optional external skill for channel ops.

### Worth adding later (only if you use them weekly)

| Candidate | Why | Prefer |
|-----------|-----|--------|
| Thin **marketing-seo** specialist | Keyword/intent/on-page checklist | Or external SEO pack |
| Thin **marketing-email-nurture** | Sequence beyond StoryBrand lead magnet | StoryBrand first |
| **marketing-landing-structure** | Section order without full Cashvertising | StoryBrand + Cashvertising already cover most |

Ship a new specialist only after the same framework appears in real work 3+ times
(same bar as data-semantic-quality).

## When *not* to use this hub

| Task | Use instead |
|------|-------------|
| Product app UI craft | **product-design** |
| Implement SPA feature | **frontend-design** |
| Prove / e2e / ship | **quality-check** |
| Data pipelines | **data** |

## Done criteria

- [ ] Correct framework specialist(s) opened  
- [ ] Offer and customer problem stated  
- [ ] Single primary CTA  
- [ ] Proof present for the main claim  
- [ ] External SEO/ads packs only if channel work actually needs them  
