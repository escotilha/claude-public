# /conta-cpo Scoring Framework

## Dimensions & Seat Weights

| Dimension                    | Default Weight | Primary Seats (2x)         | Secondary (1x)  |
| ---------------------------- | -------------- | -------------------------- | --------------- |
| **Regulatory & Compliance**  | 20%            | Sofia (6), Bruno (4)       | Paula (5)       |
| **Technical Integrity**      | 20%            | Rafael (3), Paula (5)      | Bruno (4)       |
| **Accountant UX**            | 20%            | Renata (2), Marcelo (7)    | Camila (1)      |
| **Feasibility**              | 15%            | Camila (1), Paula (5)      | Rafael (3)      |
| **Business Viability**       | 15%            | Camila (1), Marcelo (7)    | Zezé (8)        |
| **Reversibility & Risk**     | 10%            | Rafael (3), Sofia (6)      | Paula (5)       |

## Weight Adjustment by Decision Type

| Decision Type      | Regulatory | Tech Integrity | Accountant UX | Feasibility | Business Viability | Reversibility |
| ------------------ | ---------- | -------------- | ------------- | ----------- | ------------------ | ------------- |
| product-feature    | 15%        | 20%            | 25%           | 15%         | 15%                | 10%           |
| compliance         | 40%        | 15%            | 15%           | 10%         | 10%                | 10%           |
| pricing-gtm        | 10%        | 5%             | 15%           | 15%         | 40%                | 15%           |
| architecture       | 15%        | 35%            | 10%           | 15%         | 10%                | 15%           |
| crisis             | 20%        | 20%            | 10%           | 20%         | 10%                | 20%           |
| ux-flow            | 10%        | 15%            | 40%           | 15%         | 10%                | 10%           |
| general            | 20%        | 20%            | 20%           | 15%         | 15%                | 10%           |

## Auto-Detecting Decision Type

If the user didn't pass `--type`, detect from the decision statement:

| Signal in decision statement                                    | Type               |
| --------------------------------------------------------------- | ------------------ |
| "LGPD", "data protection", "audit trail", "retention", "ANPD"   | `compliance`       |
| "price", "plan", "tier", "GTM", "positioning", "competitor"     | `pricing-gtm`      |
| "migration", "refactor", "schema", "infrastructure", "RLS"      | `architecture`     |
| "outage", "incident", "broken", "leak", "stopped working"       | `crisis`           |
| "flow", "screen", "UX", "onboarding", "journey", "UI"           | `ux-flow`          |
| "feature", "ship", "build X", "release"                         | `product-feature`  |
| (no match)                                                      | `general`          |

## Scoring Algorithm

For each option O and dimension D:

1. Collect all council inputs relevant to D (from primary + secondary seats for that dimension)
2. Extract each relevant seat's position, concerns, conditions
3. Primary seat evaluations count 2x, secondary count 1x
4. Score each dimension 1-10 based on how well the option addresses the concerns raised by the relevant seats
5. Multiply by dimension weight (adjusted for decision type)
6. Sum across all 6 dimensions for weighted total (max 10.00)

## Anti-Corruption Checks

- **UNANIMITY WARNING:** If ALL seats score an option > 7 — flag as potential groupthink. Display: *"When everyone agrees, someone isn't thinking."*
- **KILL CONDITION FLAG:** If ANY dimension scores < 3 — this option has a critical weakness that must be addressed or the option should be eliminated.
- **GROUPTHINK WARNING:** If standard deviation across all seat positions < 1.5 — the council isn't producing genuinely diverse perspectives. Check persona prompts or reframe the decision.
- **MANDATORY DISSENT:** If no seat has `dissent_strength >= 5`, the orchestrator must construct a counter-argument to the leading option and present it to the user.
- **CONTEXT-BLOCK CHECK:** If the decision type is `compliance` or `architecture` and no seat's `reasoning` references Contably OS v3 state (tiers, risks, CTO verdicts), warn the user — the council may be deliberating in the abstract.
