---
name: vibc
description: "Variety Independent Board Council — 12-seat advisory board of maximally diverse archetypes for structured decision deliberation. Simulates blind input, collision mapping, adversarial steelman debates, scored option generation, and retrospective tracking. Triggers on: vibc, board council, advisory board, decision council, variety board."
argument-hint: "<decision or problem> [--mode full|quick] [--type binary|strategy|ethical|crisis|resource-allocation] [retro <decision-id>]"
user-invocable: true
context: fork
model: opus
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - TaskOutput
  - AskUserQuestion
  - mcp__postgres__query
  - mcp__sequential-thinking__sequentialthinking
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
  mcp__postgres__query: { destructiveHint: false, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
    outputFormat: structured
---

# VIBC — Variety Independent Board Council

A 12-seat advisory board of maximally diverse human archetypes that deliberates on any decision through structured phases: blind input, collision mapping, adversarial steelman debates, scored option generation, and retrospective tracking.

## The 12 Seats

| Seat | Archetype                | Name      | Primary Lens                        |
| ---- | ------------------------ | --------- | ----------------------------------- |
| 1    | Combat Veteran           | Marcus    | Risk, worst-case, contingency       |
| 2    | Social Worker            | Denise    | Human impact, unintended harm       |
| 3    | Rabbi                    | Yosef     | Ethics, precedent, dialectics       |
| 4    | Pastor                   | James     | Community, narrative, moral clarity |
| 5    | Trial Lawyer             | Elena     | Evidence, adversarial testing       |
| 6    | Farmer                   | Dale      | Long-term sustainability, patience  |
| 7    | ER Physician             | Amara     | Triage, urgency, reversibility      |
| 8    | Jazz Musician            | Theo      | Creative alternatives, emergence    |
| 9    | Intelligence Analyst     | Catherine | Hidden variables, second-order      |
| 10   | Immigrant Business Owner | Fatima    | Resourcefulness, survival           |
| 11   | Hospice Nurse            | Margaret  | Ultimate significance, regret       |
| 12   | Comedian                 | Ray       | Absurdity, sacred cows, truth       |

## Execution Flow

### Step 0: Mode Detection

Parse the user's input to determine:

1. **Retrospective mode:** If input starts with `retro` followed by a UUID, jump to Phase 8
2. **Mode:** `--mode full` (12 seats, default) or `--mode quick` (4 seats)
3. **Decision type:** `--type` flag or auto-detect from content:
   - `binary` — yes/no, go/no-go
   - `strategy` — direction, approach, long-term
   - `ethical` — right/wrong, moral dimension
   - `crisis` — urgent, time-sensitive
   - `resource-allocation` — budget, headcount, priorities
   - `general` — default if unclear
4. **Decision statement:** Everything else is the decision to deliberate on

If mode is `quick`, read `references/quick-mode.md` and use only seats 1, 5, 6, 7.

### Phase 1: Decision Framing

Craft a neutral framing of the decision. This framing goes to ALL board members identically. The framing MUST NOT:

- Include any preliminary opinion or recommendation
- Anchor toward a particular option
- Use loaded language that favors one direction

The framing MUST include:

- The decision statement in clear, neutral terms
- Relevant context (who is affected, what constraints exist, what's been tried)
- The decision type and why it matters
- Explicit instruction: "You are one of 12 independent board members. Give YOUR perspective from YOUR life experience. Do not try to represent 'balance' — be authentically yourself."

**Database:** Ensure the VIBC schema exists by running the SQL from `schema.sql` wrapped in IF NOT EXISTS checks. Then insert a new row into `vibc_decisions` with status='deliberating'.

Present the framing to the user and ask: "Does this framing accurately capture your decision? Should I adjust anything before the board convenes?"

Wait for user confirmation before proceeding.

### Phase 2: Blind Deliberation

Spawn board members as parallel subagents. Each receives the persona prompt (from `personas/seat-NN-*.md`) plus the decision framing plus the JSON output format.

**Full mode (12 seats):** Spawn in 3 batches of 4 using the Agent tool with `model: "sonnet"`:

- Batch 1: Seats 1-4 (all parallel)
- Batch 2: Seats 5-8 (all parallel, after batch 1 completes)
- Batch 3: Seats 9-12 (all parallel, after batch 2 completes)

**Quick mode (4 seats):** Spawn all 4 in one batch (seats 1, 5, 6, 7).

Each subagent's prompt:

```
{Content of the persona file}

---

## The Decision Before You

{Decision framing from Phase 1}

---

Respond ONLY with the JSON structure specified in the Output Format section above. Do not add any text before or after the JSON.
```

Collect all responses. Parse each JSON response. If any agent returns invalid JSON, attempt to extract the JSON from the response. If that fails, note the seat as "abstained" and continue.

**Insert into database:** For each valid response, insert into `vibc_board_inputs`.

**Anti-corruption check:** If ALL seats have dissent_strength < 2, trigger UNANIMITY WARNING.

Display a brief summary to the user: "The board has spoken. {N} of {12|4} seats responded. Proceeding to collision mapping."

### Phase 3: Collision Mapping

Analyze all board inputs to produce the collision map. Use sequential thinking (mcp**sequential-thinking**sequentialthinking) to work through this systematically.

**Step 3a — Find Agreements:**
Identify positions where 3+ seats (quick: 2+) align on the same core recommendation. These are strong signals. For each agreement, note:

- The shared position
- Which seats agree
- The confidence range across agreeing seats

**Step 3b — Find Contradictions:**
Identify positions where 2+ seats directly oppose each other on a point that materially affects the recommendation. For each contradiction, note:

- Seat A's position vs Seat B's position
- Why they disagree (different values? different facts? different time horizons?)
- Material impact: does resolving this change the recommendation?
- Seat distance: how epistemically different are these two archetypes?

**Step 3c — Find Orphan Insights:**
Identify perspectives raised by only ONE seat that no other seat mentioned. These are often the most valuable — they represent the blind spots of the other 11 members.

**Store:** Update `vibc_decisions.collision_map` with the structured collision map as JSONB.

**Display to user:**

```
## Collision Map

### Agreements (strong signals)
- [agreement 1]: Seats X, Y, Z agree that...
- [agreement 2]: ...

### Contradictions (to be resolved)
- [contradiction 1]: Seat X says "..." but Seat Y says "..."
- [contradiction 2]: ...

### Orphan Insights (unique perspectives)
- Seat X (Archetype): [unique insight]
- Seat Y (Archetype): [unique insight]
```

### Phase 4: Adversarial Pairing

Select the top 1-3 contradictions for steelman debates. Read `references/adversarial.md` for the protocol.

**Selection criteria (prioritized):**

1. Impact on final decision
2. Seat distance (prefer epistemically distant pairs)
3. Novelty of the disagreement

**Skip this phase if:** No material contradictions found, or quick mode with no contradictions.

For each selected contradiction, spawn 2 sequential sonnet subagents:

**Agent A (Seat X steelmanning Seat Y):**

```
You are {Seat X archetype name}. In a board deliberation about: {decision summary}

Your position: {Seat X's position}

Another board member ({Seat Y archetype}) holds this opposing position:
{Seat Y's position}
Their reasoning: {Seat Y's reasoning}

RULES:
1. FIRST: Present the STRONGEST possible version of THEIR argument. What are they right about? Under what conditions would their position be correct?
2. THEN: Present your rebuttal. Why is your position ultimately stronger?

Respond as JSON:
{
  "steelman_of_opponent": "The strongest version of their argument...",
  "conditions_opponent_is_right": ["condition 1", "condition 2"],
  "rebuttal": "Why my position is stronger...",
  "confidence_after_exchange": 7
}
```

**Agent B:** Same template, reversed perspectives.

**Determine resolution:**

- If both sides lower confidence after steelmanning → `synthesis` likely
- If one side's steelman reveals a fatal flaw → `clear_winner`
- If both sides identify valid conditions → `conditional` (testable hypothesis)
- If both maintain high confidence after genuine steelmanning → `trade-off`

Display results to user with the key insight from each exchange.

### Phase 5: Option Generation

Synthesize the collision map + adversarial results into 2-4 concrete options (quick mode: 2-3).

Each option MUST include:

- **Title:** Short, memorable name
- **Description:** 1-2 sentences
- **Core bets:** What must be true for this option to succeed (from the agreements and resolved contradictions)
- **Kill conditions:** Observable signals that this option is failing (drawn from the board's concerns)
- **Reversibility score:** 1-10 (1 = irreversible, 10 = fully reversible) — informed by ER Physician and Farmer perspectives
- **Supporting seats:** Which board members would champion this option
- **Opposing seats:** Which board members would oppose this option

Options should be genuinely different approaches, not variations of the same idea. At least one option should incorporate orphan insights.

### Phase 6: Decision Scoring

Read `references/scoring.md` for the framework.

For each option, score across 6 dimensions (4 in quick mode):

1. Load dimension weights based on decision type
2. For each dimension, evaluate how well the option addresses the concerns raised by the primary and secondary seats for that dimension
3. Primary seat evaluations count 2x, secondary count 1x
4. Score each dimension 1-10
5. Compute weighted total

**Anti-corruption checks:**

- UNANIMITY WARNING: All dimensions > 7 for any option
- KILL CONDITION FLAG: Any dimension < 3
- GROUPTHINK WARNING: Standard deviation across options < 1.5

**Insert into database:** Insert each option into `vibc_options` with scores and weighted_total.

**Display ranked options** with full dimensional breakdown using the table format from the report template.

### Phase 7: Report & Persist

1. Read `references/report-template.md`
2. Fill in the template with all deliberation results
3. Write the report to `vibc-report-{decision-id-short}.md` in the current working directory
4. Update `vibc_decisions` status to 'scored'
5. Query `vibc_batting_average` view and include historical data if available

**Present to user:**

- Executive summary (top recommendation with score)
- The top concern that almost killed the top option
- The orphan insight most worth investigating
- Path: "To track this decision's outcome, run `/vibc retro {decision-id}` when the outcome is known."

**Ask the user** which option they're leaning toward (or if they want to combine elements). Record their choice in `vibc_decisions.user_choice`.

### Phase 8: Retrospective Mode

Triggered by: `/vibc retro <decision-id>`

1. Fetch the decision from `vibc_decisions` by ID
2. Fetch all board inputs from `vibc_board_inputs`
3. Fetch all options from `vibc_options`
4. Display the original decision, chosen option, and board predictions

**Ask the user:**

- What actually happened? (actual outcome)
- Rate the outcome 1-10 (1 = disaster, 10 = outstanding)
- Which board member's prediction was most accurate?
- Which was least accurate?
- What surprised you that nobody on the board anticipated?

5. Insert into `vibc_retrospectives`
6. Update `vibc_decisions` status to 'closed'
7. Query and display updated `vibc_batting_average`
8. If patterns emerge (e.g., one seat is consistently the best predictor for a decision type), note it in the report

**Display:** Updated batting average table showing which archetypes are most and least accurate over time.

## Cost Estimates

| Mode  | Seats | Adversarial Pairs | Estimated Cost |
| ----- | ----- | ----------------- | -------------- |
| Full  | 12    | 1-3               | $8-15          |
| Quick | 4     | 0                 | $3-5           |
| Retro | 0     | 0                 | $0.50          |

## Key Principles

1. **Blind independence is sacred.** Board members NEVER see each other's input during Phase 2
2. **The framing must be neutral.** No anchoring, no loaded language, no preliminary opinion
3. **Orphan insights are the most valuable output.** The thing only one person sees is usually the blind spot
4. **Unanimity is a warning, not a success.** "When everyone agrees, someone isn't thinking"
5. **The steelman is the test.** If you can't present the opposition's argument better than they can, you don't understand the issue
6. **Measure what matters.** Retrospectives close the loop. Without them, VIBC is just a fancy prompt
