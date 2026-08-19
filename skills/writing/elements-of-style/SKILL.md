---
name: elements-of-style
description: >
  Mechanical and compositional edit pass from William Strunk Jr.'s 1920
  Elements of Style — usage, punctuation, active/positive/concrete prose,
  omit needless words, parallel construction. Use when tightening sentences,
  fixing comma splices, dangling modifiers, vague diction, or when the user
  cites Strunk, Elements of Style, or asks for a usage/concision pass. Prefer
  writing-prose for anti-slop / human tone; style-clarity-grace for turgid
  syntax; writer-style for a named voice; writing-technical for form;
  writing-docs for procedures. Prefer the writing hub when the writing path
  is unclear.
---

# Elements of Style — usage + composition pass

**Job:** Make the sentences correct, concrete, and tight. Do not restyle voice.

Source: William Strunk Jr., *The Elements of Style* (Harcourt, 1920). Public
domain. This skill distills the 1920 rules into an agent checklist. It is
**not** the 4th edition (Strunk & White, 1999/2000, still copyrighted).

Full 1920 text: [references/strunk-1920.md](references/strunk-1920.md)  
Usage detail: [references/usage.md](references/usage.md)  
Composition detail: [references/composition.md](references/composition.md)  
Padding words: [references/misused-words.md](references/misused-words.md)

## When to load

- Edit pass after a draft exists (hub pipeline D)
- “Tighten this,” “Strunk this,” “fix the grammar,” “omit needless words”
- Comma splices, dangling modifiers, mushy abstracts, padded *the fact that*

**Not for:** inventing a voice, picking a blog mode, writing a runbook from
scratch, or landing-page conversion.

## Do not fight the other writing skills

| Keep | Do not “Strunk away” |
|------|----------------------|
| Intentional short punches (`writing-prose`) | Accidental fragments that read like errors |
| Passive when the receiver is the topic | Dummy *there is* / *it was* |
| Human seams, specifics, mixed feeling | Padding that pretends to be a seam |
| Frozen facts / numbers | Rewrites that change a claim |

Strunk himself: break a rule only when the sentence gains a compensating merit.

Skip as hard fails (dated or house-overridden): *shall/will* person rules,
split-infinitive ban, *data* must be plural, *can* vs *may* in informal prose.

## Core rule

Every word should tell. Prefer the specific to the general, the definite to
the vague, the concrete to the abstract. Put the actor in the subject and
the action in the verb. Put the stress at the end.

## Edit workflow

Copy and track:

```
Elements pass:
- [ ] Usage (1–7)
- [ ] Composition (8–18)
- [ ] Padding words
- [ ] Facts unchanged
```

1. Do not restyle first. Scan, then fix.
2. **Usage** — possessives, series comma, paired parenthetic commas, comma
   before a coordinating conjunction, no comma splice (semicolon or period),
   no accidental fragment, opener participle refers to the subject.
3. **Composition** — one topic per paragraph; active when the actor matters;
   positive form; concrete nouns; cut needless words; break *and/but/so*
   sing-song; parallel lists; keep related words together; one tense in a
   summary; emphatic words last.
4. **Padding** — cut *the fact that*, *case/factor/feature/nature/character*,
   *one of the most*, *interesting*, *along these lines*, *very*, *worth while*.
5. Return the edited text. List material changes in one short bullet list.

## Fast checks (most drafts fail these)

1. **Needless words** — *the question as to whether* → *whether*; *owing to
   the fact that* → *since*; *he is a man who* → *he*; *in a hasty manner* →
   *hastily*.
2. **Dummy subjects** — *There were dead leaves on the ground* → *Dead leaves
   covered the ground*.
3. **Not-evasion** — *he was not often on time* → *he usually came late*.
4. **Dangler** — *On arriving in Chicago, his friends met him* → *When he
   arrived…*
5. **Comma splice** — two complete clauses need a semicolon, a period, or
   *and/but/for* plus a comma.
6. **Parallelism** — *to swim, to bike, and running* → *to swim, to bike,
   and to run*.
7. **Related words** — don’t split a verb from its object with a long aside.

## Hand off

| Need | Skill |
|------|--------|
| Turgid / nominalized / no actor | **style-clarity-grace** |
| Human tone / anti-slop, no persona | **writing-prose** |
| Named voice (default: Evan) | **writer-style** |
| Research / build-log form | **writing-technical** |
| Runbook / API reference | **writing-docs** |
| Offer / landing | **marketing** |
| Unclear writing path | **writing** hub |

## Done criteria

- [ ] Usage errors that change meaning or look like mistakes are gone
- [ ] Actors in subjects, actions in verbs, except when topic requires passive
- [ ] Concrete where the draft was abstract
- [ ] Needless words cut; facts and numbers untouched
- [ ] Intentional fragments and voice seams still stand
