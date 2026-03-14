# Plan: VIBC — Variety Independent Board Council

**Date:** 2026-03-14
**Based on:** research.md
**Estimated files to change:** 17 new files, 0 modified

## Approach

Build VIBC as a Claude Code skill at `~/.claude-setup/skills/vibc/` that orchestrates 12 diverse persona agents for structured decision deliberation. The orchestrator (opus) frames the decision, spawns 12 parallel sonnet subagents for blind input, performs collision mapping, runs adversarial steelman debates on top contradictions, generates scored options, and persists everything to Supabase for retrospective tracking. The architecture uses Task subagents (not Agent Teams) for the 12-seat blind deliberation — since members don't cross-talk, Agent Teams overhead is wasteful — and optionally uses Agent Teams for the 2-3 adversarial pair debates where back-and-forth is valuable.

## Trade-offs Considered

| Option                             | Pros                              | Cons                                                                              | Verdict                                    |
| ---------------------------------- | --------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------ |
| Agent Teams for all 12 seats       | Real-time cross-talk possible     | 12 context windows = token explosion (~$20+), members shouldn't cross-talk anyway | **Rejected**                               |
| Task subagents for all 12 seats    | Cheap, parallel, blind isolation  | No cross-talk for adversarial phase                                               | **Selected** (with hybrid for adversarial) |
| Single-agent simulating 12 voices  | Cheapest (~$2), simplest          | Correlated outputs, no genuine independence, persona bleed                        | **Rejected**                               |
| 12 individual persona files        | Maximum customization per persona | More files to maintain, harder to update collectively                             | **Selected** (isolation ensures quality)   |
| Inline persona prompts in SKILL.md | Single file, easy to edit         | SKILL.md becomes 2000+ lines, hard to iterate per persona                         | **Rejected**                               |

## Implementation Steps

### Step 1: Create directory structure

**Files:** `~/.claude-setup/skills/vibc/` (directory), `personas/` (subdirectory), `references/` (subdirectory)
**What:** Create the skill directory and subdirectories.
**Why:** Follows the existing skill structure pattern (cto/, cpo/, fulltest-skill/ all have subdirectories for references and subagents).

```bash
mkdir -p ~/.claude-setup/skills/vibc/personas
mkdir -p ~/.claude-setup/skills/vibc/references
```

### Step 2: Create the Supabase schema file

**File:** `~/.claude-setup/skills/vibc/schema.sql`
**What:** SQL schema for the 4 tables: `vibc_decisions`, `vibc_board_inputs`, `vibc_options`, `vibc_retrospectives`.
**Why:** Persistent decision tracking with batting average calculation. Namespaced with `vibc_` to avoid collisions in shared database.

```sql
-- VIBC Schema: Variety Independent Board Council
-- Run once against the target Supabase/Postgres instance

CREATE TABLE IF NOT EXISTS vibc_decisions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  decision_type VARCHAR(30) NOT NULL DEFAULT 'general',
  -- binary, multi-option, strategy, resource-allocation, crisis, ethical, general
  mode VARCHAR(10) NOT NULL DEFAULT 'full',
  -- full (12 seats), quick (4 seats)
  status VARCHAR(20) NOT NULL DEFAULT 'deliberating',
  -- deliberating, scored, decided, retrospective, closed
  framing JSONB NOT NULL DEFAULT '{}',
  -- The exact framing sent to all board members
  collision_map JSONB DEFAULT '{}',
  -- agreements, contradictions, orphan insights
  selected_option_id UUID,
  dimension_weights JSONB DEFAULT '{}',
  -- Per-dimension weight overrides for this decision
  final_score NUMERIC(4,2),
  user_choice TEXT,
  -- What the user actually decided
  created_at TIMESTAMPTZ DEFAULT NOW(),
  decided_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS vibc_board_inputs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  decision_id UUID NOT NULL REFERENCES vibc_decisions(id) ON DELETE CASCADE,
  seat_number INTEGER NOT NULL CHECK (seat_number BETWEEN 1 AND 12),
  archetype VARCHAR(50) NOT NULL,
  position TEXT NOT NULL,
  -- The board member's core recommendation
  reasoning TEXT NOT NULL,
  -- Why they hold this position
  concerns TEXT[],
  -- Specific risks or worries
  conditions TEXT[],
  -- "I'd support this IF..."
  confidence INTEGER CHECK (confidence BETWEEN 1 AND 10),
  dissent_strength INTEGER CHECK (dissent_strength BETWEEN 0 AND 10),
  -- 0 = full agreement, 10 = strong dissent
  key_quote TEXT,
  -- One memorable line that captures this persona's view
  raw_response JSONB DEFAULT '{}',
  -- Full structured response from the subagent
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(decision_id, seat_number)
);

CREATE TABLE IF NOT EXISTS vibc_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  decision_id UUID NOT NULL REFERENCES vibc_decisions(id) ON DELETE CASCADE,
  option_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  core_bets TEXT[] NOT NULL,
  -- What must be true for this option to succeed
  kill_conditions TEXT[] NOT NULL,
  -- Observable signals that this option is failing
  reversibility_score INTEGER NOT NULL CHECK (reversibility_score BETWEEN 1 AND 10),
  -- 1 = irreversible, 10 = fully reversible
  scores JSONB NOT NULL DEFAULT '{}',
  -- { risk: N, ethics: N, feasibility: N, creativity: N, sustainability: N, clarity: N }
  weighted_total NUMERIC(4,2),
  supporting_seats INTEGER[],
  -- Which seat numbers support this option
  opposing_seats INTEGER[],
  -- Which seat numbers oppose this option
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(decision_id, option_number)
);

CREATE TABLE IF NOT EXISTS vibc_retrospectives (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  decision_id UUID NOT NULL REFERENCES vibc_decisions(id) ON DELETE CASCADE,
  actual_outcome TEXT NOT NULL,
  outcome_rating INTEGER CHECK (outcome_rating BETWEEN 1 AND 10),
  -- 1 = disaster, 10 = outstanding
  prediction_accuracy INTEGER CHECK (prediction_accuracy BETWEEN 1 AND 10),
  -- How well did the board predict the outcome?
  best_predictor_seat INTEGER,
  -- Which seat's input was most prescient?
  worst_predictor_seat INTEGER,
  -- Which seat was most wrong?
  lessons_learned TEXT[],
  surprise_factors TEXT[],
  -- What nobody on the board anticipated
  retrospective_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(decision_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_vibc_board_inputs_decision ON vibc_board_inputs(decision_id);
CREATE INDEX IF NOT EXISTS idx_vibc_options_decision ON vibc_options(decision_id);
CREATE INDEX IF NOT EXISTS idx_vibc_decisions_status ON vibc_decisions(status);
CREATE INDEX IF NOT EXISTS idx_vibc_decisions_created ON vibc_decisions(created_at DESC);

-- View: Board batting average (per seat)
CREATE OR REPLACE VIEW vibc_batting_average AS
SELECT
  bi.seat_number,
  bi.archetype,
  COUNT(DISTINCT r.decision_id) AS decisions_reviewed,
  AVG(r.prediction_accuracy) AS avg_prediction_accuracy,
  COUNT(*) FILTER (WHERE r.best_predictor_seat = bi.seat_number) AS times_best_predictor,
  COUNT(*) FILTER (WHERE r.worst_predictor_seat = bi.seat_number) AS times_worst_predictor
FROM vibc_board_inputs bi
JOIN vibc_retrospectives r ON r.decision_id = bi.decision_id
GROUP BY bi.seat_number, bi.archetype
ORDER BY avg_prediction_accuracy DESC;
```

### Step 3: Create persona prompt files (seats 1-4)

**Files:** `~/.claude-setup/skills/vibc/personas/seat-01-combat-veteran.md` through `seat-04-pastor.md`
**What:** System prompt files for the first 4 board members (Combat Veteran, Social Worker, Rabbi, Pastor).
**Why:** Each persona needs a carefully crafted prompt that produces genuinely independent reasoning. Separate files allow per-persona iteration without touching others.

Each file follows this structure:

```markdown
# Seat N: [Archetype]

## Identity

You are [name], a [archetype description with 2-3 sentences of specific background].

## Your Lens

[What you notice first, what you prioritize, what keeps you up at night]

## How You Think

[Specific reasoning patterns, decision-making heuristics from this life experience]

## What You Distrust

[What makes you skeptical, what red flags you watch for]

## Output Format

Respond with EXACTLY this JSON structure:
{json structure}
```

### Step 4: Create persona prompt files (seats 5-8)

**Files:** `seat-05-trial-lawyer.md` through `seat-08-jazz-musician.md`
**What:** System prompts for Trial Lawyer, Farmer, ER Physician, Jazz Musician.
**Why:** Same rationale as Step 3. These four cover adversarial thinking, long-term sustainability, urgency calibration, and creative alternatives.

### Step 5: Create persona prompt files (seats 9-12)

**Files:** `seat-09-intelligence-analyst.md` through `seat-12-comedian.md`
**What:** System prompts for Intelligence Analyst, Immigrant Business Owner, Hospice Nurse, Comedian.
**Why:** Same rationale as Step 3. These four cover pattern recognition, resourcefulness, regret minimization, and absurdity detection.

### Step 6: Create the scoring reference file

**File:** `~/.claude-setup/skills/vibc/references/scoring.md`
**What:** The 6-dimension scoring framework with seat-to-dimension mappings, weight adjustment rules by decision type, and the scoring algorithm.
**Why:** The orchestrator needs a reference for how to compute weighted scores. This keeps the scoring logic out of the main SKILL.md and allows independent iteration.

```markdown
# VIBC Scoring Framework

## Dimensions & Seat Weights

| Dimension      | Weight | Primary Seats (2x weight)           | Secondary Seats (1x) |
| -------------- | ------ | ----------------------------------- | -------------------- |
| Risk           | 20%    | Veteran (1), Intel Analyst (9)      | ER Physician (7)     |
| Ethics         | 15%    | Rabbi (3), Pastor (4)               | Social Worker (2)    |
| Feasibility    | 20%    | Farmer (6), Immigrant Owner (10)    | ER Physician (7)     |
| Creativity     | 10%    | Jazz Musician (8), Comedian (12)    | Immigrant Owner (10) |
| Sustainability | 20%    | Farmer (6), Hospice Nurse (11)      | Social Worker (2)    |
| Clarity        | 15%    | Trial Lawyer (5), Intel Analyst (9) | Comedian (12)        |

## Weight Adjustment by Decision Type

| Decision Type       | Risk | Ethics | Feasibility | Creativity | Sustainability | Clarity |
| ------------------- | ---- | ------ | ----------- | ---------- | -------------- | ------- |
| crisis              | 30%  | 10%    | 25%         | 5%         | 10%            | 20%     |
| ethical             | 10%  | 30%    | 15%         | 10%        | 25%            | 10%     |
| resource-allocation | 15%  | 10%    | 30%         | 10%        | 20%            | 15%     |
| strategy            | 15%  | 10%    | 20%         | 15%        | 25%            | 15%     |
| binary              | 20%  | 15%    | 20%         | 10%        | 15%            | 20%     |
| general             | 20%  | 15%    | 20%         | 10%        | 20%            | 15%     |

## Scoring Algorithm

For each option O and dimension D:

1. Collect all board inputs relevant to D (from primary and secondary seats)
2. Primary seat scores count 2x, secondary count 1x
3. Normalize to 1-10 scale
4. Multiply by dimension weight
5. Sum across all 6 dimensions for weighted total

## Anti-Corruption Checks

- If ALL 12 seats score an option > 7: UNANIMITY WARNING
- If ANY dimension scores < 3: KILL CONDITION FLAG
- If standard deviation across seats < 1.5: GROUPTHINK WARNING
```

### Step 7: Create the adversarial pairing reference

**File:** `~/.claude-setup/skills/vibc/references/adversarial.md`
**What:** Protocol for steelman debates when board members contradict each other.
**Why:** The adversarial phase is where VIBC produces its highest-value insights. This protocol ensures genuine steelmanning, not straw-manning.

```markdown
# Adversarial Pairing Protocol

## When to Trigger

Run adversarial pairing when:

1. Two or more seats directly contradict each other on the same point
2. The contradiction has material impact on the final recommendation
3. Neither position is trivially correct

Maximum 3 pairs per decision (cost constraint).

## Steelman Rules

Each side MUST:

1. State the opposing position in the STRONGEST possible terms
2. Identify the BEST evidence supporting the opposing position
3. Name the CONDITIONS under which the opposing position would be correct
4. Only THEN present their own rebuttal

If a debater cannot steelman the opposition (presents a straw man), the moderator discards that round and notes the failure.

## Output Format

Each pair produces:

- Steelman A (Side A's best version of B's argument)
- Steelman B (Side B's best version of A's argument)
- Resolution: "synthesis" | "A wins" | "B wins" | "irreducible tension"
- Key insight discovered through the exchange
```

### Step 8: Create the quick-mode reference

**File:** `~/.claude-setup/skills/vibc/references/quick-mode.md`
**What:** 4-seat executive committee configuration for simpler decisions.
**Why:** Full 12-seat deliberation costs $8-15. Quick mode costs ~$3-5. For simpler decisions, 4 seats covering risk, argument quality, sustainability, and urgency provide sufficient diversity.

```markdown
# VIBC Quick Mode — Executive Committee (4 Seats)

## Seats

| Seat | Archetype      | Why Included                |
| ---- | -------------- | --------------------------- |
| 1    | Combat Veteran | Risk assessment             |
| 5    | Trial Lawyer   | Argument quality, evidence  |
| 6    | Farmer         | Long-term sustainability    |
| 7    | ER Physician   | Urgency calibration, triage |

## When to Use

- Binary decisions (yes/no)
- Time-sensitive decisions
- Decisions where ethical/creative dimensions are secondary
- Budget-constrained sessions

## Scoring (4 dimensions only)

| Dimension      | Weight | Seat         |
| -------------- | ------ | ------------ |
| Risk           | 30%    | Veteran      |
| Clarity        | 25%    | Trial Lawyer |
| Sustainability | 25%    | Farmer       |
| Feasibility    | 20%    | ER Physician |
```

### Step 9: Create the main SKILL.md (YAML frontmatter + Phase 1: Framing)

**File:** `~/.claude-setup/skills/vibc/SKILL.md`
**What:** The core skill definition including YAML frontmatter, mode selection, and Phase 1 (Decision Framing).
**Why:** This is the primary orchestrator file. Building it incrementally across Steps 9-14 keeps each step under 5 minutes and allows verification.

The YAML frontmatter follows the established pattern:

```yaml
---
name: vibc
description: "Variety Independent Board Council — 12-seat advisory board of maximally diverse archetypes. Simulates blind deliberation, collision mapping, adversarial steelman debates, and scored option generation for any decision. Persists to Supabase for retrospective tracking and batting average. Triggers on: vibc, board council, advisory board, decision council, variety board."
argument-hint: "<decision or problem> [--mode full|quick] [--type binary|strategy|ethical|crisis|resource-allocation]"
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
  - TeamCreate
  - TeamDelete
  - SendMessage
  - AskUserQuestion
  - mcp__postgres__query
  - mcp__memory__*
  - mcp__sequential-thinking__sequentialthinking
memory: user
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
  mcp__postgres__query: { destructiveHint: false, idempotentHint: true }
  mcp__memory__delete_entities: { destructiveHint: true, idempotentHint: true }
  mcp__memory__create_entities: { readOnlyHint: false, idempotentHint: false }
  TeamDelete: { destructiveHint: true, idempotentHint: true }
  SendMessage: { openWorldHint: true, idempotentHint: false }
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
```

Phase 1 in SKILL.md:

- Parse the user's input (decision statement, mode, decision type)
- Auto-detect decision type if not specified
- Write the framing document (neutral, no anchoring)
- Ensure schema exists in database
- Create `vibc_decisions` row
- Present framing to user for confirmation before proceeding

### Step 10: Write SKILL.md Phase 2 (Blind Deliberation)

**File:** `~/.claude-setup/skills/vibc/SKILL.md` (append)
**What:** Phase 2 — spawn 12 (or 4 in quick mode) parallel Task subagents, each receiving the persona prompt + decision framing, returning structured JSON.
**Why:** This is the core deliberation engine. Must enforce blind independence.

Key implementation details:

- Spawn in 3 batches of 4 (or 1 batch of 4 in quick mode) using TaskCreate with `run_in_background: true`
- Each subagent gets: persona file content + decision framing + output format instructions
- Model: sonnet for all persona agents
- Collect results, parse JSON, insert into `vibc_board_inputs`
- Mandatory dissent detection: if all positions align, trigger unanimity warning

### Step 11: Write SKILL.md Phase 3 (Collision Mapping)

**File:** `~/.claude-setup/skills/vibc/SKILL.md` (append)
**What:** Phase 3 — the orchestrator analyzes all 12 inputs to produce the collision map: agreements, contradictions, and orphan insights.
**Why:** This is where the orchestrator earns its Opus cost. It must find genuine conflicts and surprising alignments across 12 diverse perspectives.

Key implementation details:

- Use `mcp__sequential-thinking__sequentialthinking` for structured analysis
- Agreement: 6+ seats align on the same conclusion (strong signal)
- Contradiction: 2+ seats directly oppose each other with material impact
- Orphan insight: unique perspective from a single seat that no one else raised
- Store collision map in `vibc_decisions.collision_map`
- Display collision map to user before proceeding to adversarial phase

### Step 12: Write SKILL.md Phase 4 (Adversarial Pairing)

**File:** `~/.claude-setup/skills/vibc/SKILL.md` (append)
**What:** Phase 4 — select top 1-3 contradictions and run steelman debates.
**Why:** Adversarial pairing is the mechanism that prevents VIBC from being a fancy poll. It forces deep examination of the strongest disagreements.

Key implementation details:

- Select top contradictions from collision map (max 3, prioritized by impact)
- For each pair, spawn 2 sonnet subagents via Task:
  - Agent A: receives Persona X's position, must steelman Persona Y's position first
  - Agent B: receives Persona Y's position, must steelman Persona X's position first
- Collect results, check for straw-man failures
- Resolution categories: synthesis, clear winner, irreducible tension
- Skip this phase if collision map shows no material contradictions

### Step 13: Write SKILL.md Phase 5-6 (Option Generation + Decision Scoring)

**File:** `~/.claude-setup/skills/vibc/SKILL.md` (append)
**What:** Phases 5 and 6 — generate 2-4 concrete options with core bets, kill conditions, and reversibility scores, then score each option across 6 dimensions weighted by board seat expertise.
**Why:** These phases transform raw deliberation into actionable recommendations.

Key implementation details:

- Option generation: orchestrator synthesizes from collision map + adversarial results
- Each option must have: title, description, core bets (what must be true), kill conditions (observable failure signals), reversibility score (1-10)
- Scoring: load `references/scoring.md`, apply dimension weights based on decision type, compute weighted totals
- Insert options into `vibc_options` table
- Present ranked options with dimensional breakdown

### Step 14: Write SKILL.md Phases 7-8 (Persist + Retrospective)

**File:** `~/.claude-setup/skills/vibc/SKILL.md` (append)
**What:** Phase 7 — present final report and persist to database. Phase 8 — retrospective mode triggered by `/vibc retro <id>`.
**Why:** Retrospective tracking is what makes VIBC improve over time. Without it, it's just a fancy prompt.

Key implementation details:

- Write full report to `vibc-report-<decision-id>.md` in project root
- Update `vibc_decisions` status to 'scored'
- Present summary in chat with option ranking
- Retrospective mode: user reports actual outcome, system compares to board predictions
- Update `vibc_retrospectives` table, recalculate batting average
- Memory MCP: store patterns from retrospectives as `tech-insight:vibc-*` entities

### Step 15: Create the symlink

**File:** `~/.claude/skills/vibc` (symlink)
**What:** Symlink from `~/.claude/skills/vibc/` to `~/.claude-setup/skills/vibc/` so Claude Code discovers the skill.
**Why:** All skills use this symlink pattern for discovery.

```bash
ln -sf ~/.claude-setup/skills/vibc ~/.claude/skills/vibc
```

### Step 16: Write the report template

**File:** `~/.claude-setup/skills/vibc/references/report-template.md`
**What:** Template for the final decision report written to the project root.
**Why:** Consistent output format across all VIBC runs. Similar to how CTO writes its executive report.

```markdown
# VIBC Report: [Decision Title]

**Decision ID:** [uuid]
**Date:** [date]
**Mode:** [full|quick] | **Type:** [decision_type]
**Board Size:** [12|4] seats

---

## Decision Framing

[The neutral framing sent to all board members]

---

## Board Deliberation Summary

### Agreements (N/12 seats align)

[What the board broadly agrees on]

### Contradictions (N pairs)

[Key disagreements and their resolution via steelman debates]

### Orphan Insights

[Unique perspectives raised by only one seat]

### Anti-Corruption Flags

- [ ] Unanimity detected (groupthink risk)
- [ ] Mandatory dissent triggered
- [ ] Low variance warning

---

## Options

### Option 1: [Title] — Score: X.XX/10

**Core Bets:** [what must be true]
**Kill Conditions:** [when to abandon]
**Reversibility:** X/10

| Dimension      | Score | Weight | Weighted |
| -------------- | ----- | ------ | -------- |
| Risk           | X     | X%     | X.XX     |
| Ethics         | X     | X%     | X.XX     |
| Feasibility    | X     | X%     | X.XX     |
| Creativity     | X     | X%     | X.XX     |
| Sustainability | X     | X%     | X.XX     |
| Clarity        | X     | X%     | X.XX     |
| **Total**      |       |        | **X.XX** |

### Option 2: ...

---

## Board Batting Average

[Historical accuracy from vibc_batting_average view, if retrospectives exist]

---

## Raw Board Input

[Collapsed/expandable section with each seat's full response]
```

### Step 17: Integration test checklist

**File:** N/A (manual verification)
**What:** Verify the skill works end-to-end.
**Why:** Cannot ship without testing.

- [ ] `claude /vibc "Should I hire a CTO or promote from within?"` activates the skill
- [ ] Schema creates successfully in Postgres
- [ ] 12 subagents spawn and return structured JSON
- [ ] Collision mapping produces meaningful agreements/contradictions
- [ ] Adversarial pairing runs on at least 1 contradiction
- [ ] Options are scored and ranked
- [ ] Report is written to file
- [ ] Database rows are created
- [ ] `/vibc retro <id>` works for retrospective
- [ ] Quick mode (`--mode quick`) runs with 4 seats only

## Files to Create

| File                                                                       | Purpose                              |
| -------------------------------------------------------------------------- | ------------------------------------ |
| `~/.claude-setup/skills/vibc/SKILL.md`                                     | Main skill orchestrator (~800 lines) |
| `~/.claude-setup/skills/vibc/schema.sql`                                   | Supabase schema (4 tables + 1 view)  |
| `~/.claude-setup/skills/vibc/personas/seat-01-combat-veteran.md`           | Persona: Combat Veteran              |
| `~/.claude-setup/skills/vibc/personas/seat-02-social-worker.md`            | Persona: Social Worker               |
| `~/.claude-setup/skills/vibc/personas/seat-03-rabbi.md`                    | Persona: Rabbi                       |
| `~/.claude-setup/skills/vibc/personas/seat-04-pastor.md`                   | Persona: Pastor                      |
| `~/.claude-setup/skills/vibc/personas/seat-05-trial-lawyer.md`             | Persona: Trial Lawyer                |
| `~/.claude-setup/skills/vibc/personas/seat-06-farmer.md`                   | Persona: Farmer                      |
| `~/.claude-setup/skills/vibc/personas/seat-07-er-physician.md`             | Persona: ER Physician                |
| `~/.claude-setup/skills/vibc/personas/seat-08-jazz-musician.md`            | Persona: Jazz Musician               |
| `~/.claude-setup/skills/vibc/personas/seat-09-intelligence-analyst.md`     | Persona: Intelligence Analyst        |
| `~/.claude-setup/skills/vibc/personas/seat-10-immigrant-business-owner.md` | Persona: Immigrant Business Owner    |
| `~/.claude-setup/skills/vibc/personas/seat-11-hospice-nurse.md`            | Persona: Hospice Nurse               |
| `~/.claude-setup/skills/vibc/personas/seat-12-comedian.md`                 | Persona: Comedian                    |
| `~/.claude-setup/skills/vibc/references/scoring.md`                        | Scoring framework                    |
| `~/.claude-setup/skills/vibc/references/adversarial.md`                    | Steelman debate protocol             |
| `~/.claude-setup/skills/vibc/references/quick-mode.md`                     | 4-seat executive committee config    |
| `~/.claude-setup/skills/vibc/references/report-template.md`                | Output report template               |

## Files to Modify

| File   | Change | Lines |
| ------ | ------ | ----- |
| (none) |        |       |

## Files to Delete

| File            | Reason |
| --------------- | ------ |
| (none expected) |        |

## Testing Strategy

- [ ] Dry-run SKILL.md parsing: verify YAML frontmatter is valid
- [ ] Schema test: run schema.sql against a test Postgres instance
- [ ] Persona test: feed a sample decision to each persona file and verify JSON output
- [ ] Integration test: run full `/vibc` on a simple binary decision
- [ ] Quick mode test: run `/vibc --mode quick` and verify only 4 seats spawn
- [ ] Retrospective test: create a decision, then run `/vibc retro <id>`

## Rollback Plan

Delete the `~/.claude-setup/skills/vibc/` directory and remove the symlink at `~/.claude/skills/vibc`. Drop the 4 `vibc_*` tables from Supabase. No other files are modified.

```bash
rm -rf ~/.claude-setup/skills/vibc
rm -f ~/.claude/skills/vibc
# In Postgres:
# DROP TABLE IF EXISTS vibc_retrospectives, vibc_options, vibc_board_inputs, vibc_decisions CASCADE;
# DROP VIEW IF EXISTS vibc_batting_average;
```

## Anti-Patterns to Avoid

- No persona prompts that are just "You are a [role]. Give your opinion." — each persona needs specific background, reasoning patterns, and distrust signals
- No single-agent simulation of multiple personas — defeats the blind independence requirement
- No hardcoded database connection strings — use mcp**postgres**query or detect from environment
- No unnecessary comments or jsdocs in the SKILL.md
- No `any` types in JSON schemas — every field must be typed
- Verify schema exists before first insert (idempotent CREATE IF NOT EXISTS)
