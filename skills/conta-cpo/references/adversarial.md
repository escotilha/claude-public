# Adversarial Pairing Protocol — /conta-cpo

## When to Trigger

Run adversarial pairing when:

1. Two or more seats directly contradict each other on the same point
2. The contradiction has material impact on the final recommendation
3. Neither position is trivially correct

Maximum 3 pairs per decision (cost constraint). Skip entirely in quick mode.

## Steelman Rules

Each side MUST:

1. State the opposing position in the STRONGEST possible terms
2. Identify the BEST evidence supporting the opposing position (draw on Contably OS v3 context where relevant)
3. Name the CONDITIONS under which the opposing position would be correct
4. Only THEN present their own rebuttal

If a debater cannot steelman the opposition (presents a straw man), the orchestrator discards that round and notes the failure.

## Pairing Selection Priority

When the collision map reveals more than 3 contradictions, prioritize by:

1. **Impact on final decision:** Does resolving this change the recommended option?
2. **Domain distance:** Contradictions between epistemically distant seats (e.g., Sofia vs Zezé, or Rafael vs Marcelo) are more valuable than between adjacent seats (e.g., Paula vs Rafael — both eng-quality).
3. **Novelty:** Contradictions that reveal hidden Contably assumptions (roadmap tier, LGPD basis, provider edge case) outweigh disagreements about known trade-offs.

## Output Format

Each pair produces:

- **Steelman A:** Side A's best version of B's argument
- **Steelman B:** Side B's best version of A's argument
- **Steelman quality:** Did each side genuinely engage, or straw-man?
- **Resolution:** one of
  - `synthesis` — both are true; the real answer integrates them
  - `conditional` — "A is right if X, B is right if Y" (becomes a testable hypothesis)
  - `trade-off` — genuine tension; choice depends on values, not facts
  - `clear_winner` — one side's argument is materially stronger
- **Key insight:** the one thing discovered through this exchange that neither side articulated alone

## Spawn Prompt Template

For each adversarial pair, spawn two sequential Agent subagents with `model: "sonnet"`:

**Agent A (Seat X defending, steelmanning Seat Y):**

```
You are {Seat X archetype name} ({first name}). In a Contably council deliberation, you hold this position:
{Seat X position}

Another council member ({Seat Y archetype} — {first name}) holds this opposing position:
{Seat Y position}

Contably OS v3 context (current state):
{Context block from Phase 0.5 — abbreviated to ~200 tokens}

FIRST: Present the STRONGEST possible version of their argument. What are they right about? Under what Contably conditions would their position be correct?

THEN: Present your rebuttal. Why is your position ultimately stronger given the current state of Contably OS v3?

Respond as JSON:
{
  "steelman_of_opponent": "...",
  "conditions_opponent_is_right": ["..."],
  "rebuttal": "...",
  "confidence_after_exchange": 1-10
}
```

**Agent B (Seat Y defending, steelmanning Seat X):**
Same template, reversed.

## Why the Context Block Is Passed to Adversarial Agents

Unlike /vibc, /conta-cpo adversarial debates need Contably grounding. If Rafael (backend) and Camila (product) disagree about a migration's cost, the debate is meaningless without knowing which tier the migration supports and what Phase of contably-os-v3 is active. Inject the abbreviated context block to keep both sides anchored in reality.
