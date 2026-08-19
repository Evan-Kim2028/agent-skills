# Cohesion and emphasis — topic left, stress right

A sentence can be locally clear and still stop the reader if it starts
with news and ends with setup.

## Two positions

- **Topic** (left / first words): what this sentence is about. Prefer
  something the reader already has.
- **Stress** (right / last words): what you want remembered. Put the
  new, the contrast, the number, the verdict here.

`The queue stalled because the consumer lost its lease.`
Topic = the queue (already in play). Stress = lost its lease (the news).

Backwards: `A lost lease on the consumer is the reason for the queue stall.`
The news hits first; the familiar word comes last. Flip it.

## Cohesion between sentences

The end of sentence N should make the start of N+1 feel prepared.

```
The job writes a checkpoint every 30s. That checkpoint is what
replay reads.
```

Not:

```
The job writes a checkpoint every 30s. Replay, on restart, is the
component that reads it.
```

Techniques: repeat a stress word as the next topic; use a pronoun or
summary noun (`that failure`, `this limit`); keep the character stable.

## Don’t confuse cohesion with throat-clearing

`It is important to note that…` / `As mentioned above…` glue sentences
without adding a topic. Cut the glue; put the old information in a real
noun.

## Emphasis is not italics

If everything is stressed, nothing is. One stress per sentence. Don’t
put a throwaway hedge in the stress slot (`…which is interesting.`).

## Long asides kill both positions

A clause jammed between subject and verb steals the topic and delays
the action. Move the aside to the end, or split.

`The job, after three retries and a silent metadata mismatch that
only showed up in staging, failed.`
→ `After three retries, the job failed: a silent metadata mismatch
that only showed up in staging.`
