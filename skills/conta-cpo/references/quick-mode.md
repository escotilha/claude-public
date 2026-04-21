# /conta-cpo Quick Mode — Executive Committee (4 Seats)

## Seats

| Seat | Archetype                   | Why Included                                    |
| ---- | --------------------------- | ----------------------------------------------- |
| 1    | Head of Product (Camila)    | Tier discipline, business viability, shipping   |
| 3    | Principal Backend Eng (Rafael) | Technical integrity, RLS, async invariants  |
| 5    | QA & Release (Paula)        | Regression surface, staging/prod parity         |
| 7    | Accountant-in-Residence (Marcelo) | Contador voice — the real user           |

## When to Use

- `product-feature` decisions scoped to one module
- Time-sensitive decisions where the full 8-seat council is too slow
- Low-compliance-surface decisions (otherwise pull in Sofia → use full mode)
- Budget-constrained deliberations (~$1.50-3 vs $4-7 for full)
- Quick gut-check before committing to a full session

## When NOT to Use

- `compliance` decisions (missing Sofia = blind to LGPD)
- `ux-flow` decisions (missing Renata = missing accountant-workflow lens)
- Integration-heavy decisions (missing Bruno = blind to provider reality)
- `pricing-gtm` decisions (missing the skeptic + comedian = missing Zezé)
- Any decision where "we all agree" is already suspicious (quick mode amplifies groupthink)

## Scoring (4 dimensions only)

| Dimension             | Weight | Primary Seat |
| --------------------- | ------ | ------------ |
| Technical Integrity   | 30%    | Rafael       |
| Accountant UX         | 30%    | Marcelo      |
| Feasibility           | 25%    | Paula        |
| Business Viability    | 15%    | Camila       |

Regulatory, Reversibility are out of scope in quick mode — use full mode if they matter.

## Execution

- Spawn all 4 subagents in 1 parallel batch
- Skip adversarial pairing — 4 seats rarely produce material contradictions worth debating
- Collision mapping simplified: 3+ seat agreement (strong signal) and 2-seat contradiction
- Generate 2-3 options maximum
- Retrospective still recommended — track batting average even in quick mode

## Opus 4.7 Fan-Out Instruction (for orchestrator)

*Do not spawn a subagent for work you can complete directly in a single response. Spawn the 4 quick-mode seats in parallel in the same turn.*
