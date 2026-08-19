# Clarity — characters and actions

Williams’s first move: readers look for **characters** in **subjects** and
**actions** in **verbs**. Academic and LLM prose hide both.

## Diagnose

For each heavy sentence:

1. Underline the grammatical subject (through the first verb).
2. Circle the main verb.
3. Ask: is the subject a character (person, team, system, named agent)?
4. Ask: is the verb the real action, or a placeholder (`is`, `has`, `make`,
   `involve`, `occur`, `exist`)?

If the real actor is in a *by*-phrase, a possessive, or a *of*-phrase, and
the real action is a noun, revise.

## Nominalizations

Actions stuffed into nouns: *implementation, decision, analysis, failure,
movement, resistance, comparison, assumption*.

| Hidden | Revised |
|--------|---------|
| The implementation of the cache was completed by the team. | The team implemented the cache. |
| Our assumption was that the queue would drain. | We assumed the queue would drain. |
| There was a failure of the job during replay. | The job failed during replay. |

Keep a nominalization when it is:

- already known, and you want it as the **topic** (`That failure forced a rewrite.`)
- a technical term the reader expects (`this migration`, `the join`)
- shorter than the unpacked clause without costing a character

Do not unpack every *-tion*. Unpack the ones that stole the verb.

## Empty verbs and dummy subjects

`There is` / `it is` / `the existence of` usually hide a character.

| Hidden | Revised |
|--------|---------|
| There was a rapid increase in lag. | Lag increased rapidly. |
| It is possible that the lock is stale. | The lock may be stale. |
| The existence of a retry loop is an indication of flakiness. | A retry loop indicates flakiness. |

## When passive is clearer

Use passive (or keep it) when:

- the receiver is the paragraph’s topic
- the actor is unknown or irrelevant
- naming the actor would bury the point

`The leak was patched in 1.4.` is right in a release note about the leak.
`We patched the leak in 1.4.` is right in a field log about the team.

Blind “always active” is folklore. See [usage-real-vs-folk.md](usage-real-vs-folk.md).

## Characters that are not people

Systems count: the compiler, the runtime, the market, the test suite.
Pick one character and stay with it for a stretch. Switching from
*we* to *the system* to *one* to *it* in four sentences costs cohesion.
