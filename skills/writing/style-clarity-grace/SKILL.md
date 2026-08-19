---
name: style-clarity-grace
description: >
  Reader-based revision from Joseph Williams's Style: Toward Clarity and
  Grace — characters as subjects, actions as verbs, topic/stress, cohesion,
  paragraph point, concision. Use when prose is turgid, academic, nominalized,
  or hard to follow even if "correct"; when the user cites Williams, clarity
  and grace, or asks why a sentence is muddy. Prefer elements-of-style for
  punctuation/usage; writing-prose for anti-slop tone; writer-style for a
  named voice; writing-technical for form. Prefer the writing hub when the
  writing path is unclear.
---

# Style — clarity and grace

**Job:** Make the reader see who did what, in an order they can follow.
Do not restyle voice. Do not change frozen facts.

Source: Joseph M. Williams, *Style: Toward Clarity and Grace* (University
of Chicago Press, 1990; two chapters with Gregory G. Colomb). This skill
distills the revision system. Do not quote the book or reproduce its
examples at length.

Clarity: [references/clarity.md](references/clarity.md)  
Cohesion + emphasis: [references/cohesion-emphasis.md](references/cohesion-emphasis.md)  
Paragraph / document: [references/coherence.md](references/coherence.md)  
Concision + long sentences: [references/concision-shape.md](references/concision-shape.md)  
Real rules vs folklore: [references/usage-real-vs-folk.md](references/usage-real-vs-folk.md)

## When to load

- Draft exists and reads heavy, abstract, or “correct but exhausting”
- “This is muddy,” “too academic,” “can’t see the actor,” “Williams pass”
- After form/voice, before or instead of a blind Strunk cut

**Not for:** inventing a persona, picking a blog mode, writing a runbook
from scratch, or landing-page conversion.

## Core rule

Readers parse easily when **subjects name characters** and **verbs name
actions**, **familiar matter sits left** (topic), and **new/important
matter sits right** (stress). Telling someone “be clear” is useless.
Diagnose the syntax, then revise it.

Passive is not the enemy. A dummy subject, a buried character, and a
nominalized action are.

## Revision workflow

Copy and track:

```
Williams pass:
- [ ] Diagnose subjects/verbs
- [ ] Characters → subjects, actions → verbs
- [ ] Topic left, stress right
- [ ] Paragraph has a point
- [ ] Concision (after shape)
- [ ] Facts unchanged
```

1. **Diagnose.** In each load-bearing sentence, mark the grammatical
   subject and the main verb. If the subject is an abstraction
   (`the implementation of…`, `there is`) and the verb is empty
   (`is`, `involves`, `has`, `occurs`), the sentence is turgid.
2. **Characters / actions.** Who is doing what? Lift the character
   (person, system, named agent) into the subject. Lift the action
   (often a noun in *-tion / -ment / -ance / -ing*) into the verb.
   See [clarity.md](references/clarity.md).
3. **Cohesion.** End of sentence N should make the start of N+1 feel
   expected. Old/familiar → left. New/stress → right.
   See [cohesion-emphasis.md](references/cohesion-emphasis.md).
4. **Coherence.** A reader should be able to say the paragraph’s point
   in one sentence. Topics across the paragraph should be a short
   consistent set. See [coherence.md](references/coherence.md).
5. **Concision last.** Cut after the bones are right. Blind cutting
   makes unclear prose shorter, not clearer.
   See [concision-shape.md](references/concision-shape.md).
6. Return the edited text. List material syntactic changes, not every
   comma.

## Fast checks (most turgid drafts fail these)

1. **Subject is a nominalization** — `The analysis of the logs was
   performed by the on-call` → `The on-call analyzed the logs.`
2. **Empty verb** — `A decision was made to…` → `We decided to…`
3. **Backwards information** — new claim first, context last. Flip:
   context/topic left, payoff right.
4. **Subject–verb gap** — a long aside between them. Move the aside
   or split the sentence.
5. **No paragraph point** — a stack of true sentences that never land.
   Add or move the point sentence.
6. **Folklore enforcement** — do not “fix” split infinitives, ending
   prepositions, or every passive. See
   [usage-real-vs-folk.md](references/usage-real-vs-folk.md).

## Do not fight the other writing skills

| Keep | Do not “Williams away” |
|------|------------------------|
| Frozen numbers, APIs, quotes | Smoother syntax that changes a claim |
| `writing-prose` punches / seams | Uniform elegance |
| Passive when the receiver is the topic | Blind active-voice conversion |
| Useful nominalizations (already-known events used as topics) | Unpacking every *-tion* |

Clarity first, then cohesion, then concision, then (rarely) elegance.
Never chase balance before the reader can see the actor.

## Vs `elements-of-style`

| | **style-clarity-grace** | **elements-of-style** |
|--|-------------------------|------------------------|
| Job | How readers parse; revise syntax | Usage + Strunk commandments |
| Passive | Keep when it topics the right thing | Prefer active, with the same exception |
| Concision | After characters/actions are right | Cut needless words as a first move |
| Load | Muddy / nominalized / hard to follow | Comma splices, danglers, padding |

Typical stack: this skill for shape, then **elements-of-style** for leftover
mechanics.

## Hand off

| Need | Skill |
|------|--------|
| Punctuation / danglers / series comma | **elements-of-style** |
| Human tone / anti-slop | **writing-prose** |
| Named voice (default: Evan) | **writer-style** |
| Research / build-log form | **writing-technical** |
| Runbook / API reference | **writing-docs** |
| Offer / landing | **marketing** |
| Unclear writing path | **writing** hub |

## Done criteria

- [ ] Load-bearing sentences: character in the subject, action in the verb
- [ ] Topic left, stress right; sentences chain
- [ ] Each paragraph has a namable point
- [ ] Shorter only where words did no work
- [ ] Facts and voice seams intact
