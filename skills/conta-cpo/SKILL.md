---
name: conta-cpo
description: "Contably advisory council — 8-seat product/UX/engineering deliberation board grounded in Contably OS v3 state. Blind input, scored options, retrospective tracking. Triggers on: conta cpo, contably council, product council, contably advisory."
argument-hint: "<decision or problem> [--mode full|quick] [--type product-feature|compliance|pricing-gtm|architecture|crisis|ux-flow|general] [retro <decision-id>]"
user-invocable: true
paths:
  - "**/contably/**"
  - "**/contably-*/**"
  - "**/.claude/contably/**"
context: fork
model: opus
effort: high
alwaysThinkingEnabled: true
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
  - AskUserQuestion
  - mcp__sequential-thinking__sequentialthinking
memory: user
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
  Read: { readOnlyHint: true, idempotentHint: true }
  Glob: { readOnlyHint: true, idempotentHint: true }
  Grep: { readOnlyHint: true, idempotentHint: true }
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

# /conta-cpo — Contably Advisory Council

An 8-seat advisory council of Contably-domain experts (product, UX, engineering, data/integrations, QA, LGPD, accountant-in-residence, comedian) that deliberates on product / UX / engineering / pricing-GTM decisions using the /vibc deliberation engine adapted for Contably.

This is the Contably-scoped counterpart to the generic `/vibc`. Use `/conta-cpo` when the decision is specific to the Contably product, codebase, or GTM. Use `/vibc` for anything else.

## Context

Contably is an AI-powered accounting SaaS for Brazilian SMBs and their accountants. The stack:

- **Backend:** FastAPI (Python 3.11/3.12), SQLAlchemy async, Alembic migrations, Celery (5 priority queues)
- **Frontend:** React admin (Vite), Next.js client portal, mobile app
- **Database:** MySQL 8.0 (migrated from PostgreSQL), app-layer RLS via ContextVar, fail-closed
- **AI:** Claude for extraction + conversation, OpenAI embeddings, Gemini vision fallback
- **Infra:** OCI (OKE, OCIR), LB 137.131.156.136, namespaces `contably-staging` + `contably` (prod)
- **Auth:** JWT + optional TOTP MFA, company-scoped tokens, Redis token blocklist
- **Integrations:** Pluggy (Open Finance), SPED, SERPRO, NF-e providers — abstract adapter pattern

### Why this council exists

`/vibc` uses life-archetypes (combat veteran, rabbi, ER physician) that are powerful for general decisions but thin on Brazilian fintech domain knowledge. Contably decisions need people who know:

- **LGPD** (General Data Protection Law) and how it constrains customer data flows
- **Accountant workflows** — the real user of the platform is usually a contador, not the SMB
- **Brazilian fintech integrations** — Pluggy quirks, SERPRO/eCAC, SPED file formats, NF-e schemas
- **Contably OS v3** state — the autonomous dev orchestrator's active tasks, risks, and capacity
- **Roadmap tier discipline** — Tier 0 ships first; "infrastructure perfectionism" is an anti-pattern

## The 8 Seats

| Seat | Archetype                      | Name        | Primary Lens                                             |
| ---- | ------------------------------ | ----------- | -------------------------------------------------------- |
| 1    | Head of Product                | Camila      | Roadmap tier discipline, customer value, shipping        |
| 2    | UX Lead (accountant-workflow)  | Renata      | Accountant daily workflow, LGPD-aware design             |
| 3    | Principal Backend Engineer     | Rafael      | FastAPI/Async/RLS, data integrity, async-first patterns  |
| 4    | Data & Integrations Engineer   | Bruno       | Pluggy/SERPRO/SPED reality, edge-cases, retries          |
| 5    | QA & Release Manager           | Paula       | Gate discipline, regression surface, staging/prod parity |
| 6    | LGPD & Compliance Specialist   | Dr. Sofia   | LGPD, data minimization, audit trail, subject rights     |
| 7    | Accountant-in-Residence (user) | Marcelo     | The contador voice, monthly closing reality              |
| 8    | Comedian (devil's advocate)    | Zezé        | Sacred cows, absurdity detection, jargon calling         |

**Quick mode (4 seats):** {1, 3, 5, 7} = Camila · Rafael · Paula · Marcelo — product, eng, quality, user.

## Scoring Dimensions (Contably-weighted)

Unlike /vibc's generic dimensions, /conta-cpo scores on 6 Contably-specific dimensions. Per-type weights live in `references/scoring.md`.

| Dimension                 | Default | Primary Seats (2x)          | Secondary (1x)        |
| ------------------------- | ------- | --------------------------- | --------------------- |
| **Regulatory & Compliance** | 20%   | Sofia (6), Bruno (4)        | Paula (5)             |
| **Technical Integrity**   | 20%     | Rafael (3), Paula (5)       | Bruno (4)             |
| **Accountant UX**         | 20%     | Renata (2), Marcelo (7)     | Camila (1)            |
| **Feasibility**           | 15%     | Camila (1), Paula (5)       | Rafael (3)            |
| **Business Viability**    | 15%     | Camila (1), Marcelo (7)     | Zezé (8)              |
| **Reversibility & Risk**  | 10%     | Rafael (3), Sofia (6)       | Paula (5)             |

**7 decision types:** `product-feature`, `compliance`, `pricing-gtm`, `architecture`, `crisis`, `ux-flow`, `general`. Each adjusts dimension weights — see `references/scoring.md`.

## Execution Flow

### Step 0 — Mode & Type Detection

Parse the user's input:

1. **Retrospective mode:** if input starts with `retro` followed by a UUID, jump to Phase 8
2. **Mode:** `--mode full` (8 seats, default) or `--mode quick` (4 seats)
3. **Decision type:** `--type` flag, or auto-detect from content (see `references/scoring.md` for heuristics)
4. **Decision statement:** the remaining text

If mode is `quick`, read `references/quick-mode.md` and use only seats 1, 3, 5, 7.

### Phase 0.5 — Load Contably OS v3 Context

**This phase is what makes /conta-cpo different from /vibc.** Before framing the decision, load the current state of Contably so personas ground their opinions in reality, not generic priors.

**Cache check:**

```bash
CACHE="/Volumes/AI/Code/contably-hr061-sqlite/.contably-os/context-block.cached.md"
AGE_HOURS=$(( ( $(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0) ) / 3600 ))
if [ -f "$CACHE" ] && [ "$AGE_HOURS" -lt 24 ]; then
  echo "Using cached context block (age: ${AGE_HOURS}h)"
else
  echo "Rebuilding context block (cache missing or stale)"
fi
```

**If cache is missing or stale (>24h):** read all six Contably OS v3 tracker files and distill into an ~800-token context block:

- `docs/contably-os-v3/00-deep-plan-brief.md` — original intent
- `docs/contably-os-v3/01-design.md` — architecture + component diagram
- `docs/contably-os-v3/02-implementation-plan.md` — phases, kill criteria
- `docs/contably-os-v3/03-research-addendum.md` — evidence base
- `docs/contably-os-v3/04-risk-register.md` — open risks (R-OS3-NNN codes)
- `docs/contably-os-v3/05-cto-review.md` — CTO synthesis

Resolve path by checking both `/Volumes/AI/Code/contably-hr061-sqlite/` and `/Volumes/AI/Code/contably/` (whichever has the `contably-os-v3` subdir).

**Context block format** (write to the cache file):

```markdown
# Contably OS v3 — Shared Context Block

**Captured:** {ISO8601}
**Sources:** contably-os-v3/00..05
**Budget:** ~800 tokens — distilled for council personas

## Current state
{1-paragraph: what Contably OS v3 is doing right now, what tier is active, what's shipped, what's blocked}

## Active roadmap tiers
- **Tier 0 (live):** {list}
- **Tier 1 (in-flight):** {list}
- **Tier 2 (planned):** {list}

## Open risks (from 04-risk-register)
- R-OS3-XXX: {title} — prob {low|medium|high}, impact {low|medium|high}
  ...

## Recent CTO verdicts (from 05-cto-review)
- {top 3-5 verdicts that affect pending decisions}

## Key constraints
- Budget cap: $250/day
- SSH bridge VPS→mini required
- RLS at ORM layer, fail-closed
- LGPD: data minimization, subject-access rights, audit trail required
```

**Insert `context_block_hash` into `conta_cpo_decisions.context_block_hash`** so retrospectives can trace which OS state informed which decision.

### Phase 1 — Decision Framing

Craft a neutral framing identical to /vibc's protocol (see `references/quick-mode.md` for quick-mode variant). The framing MUST NOT:

- Include preliminary opinions or recommendations
- Anchor toward a particular option
- Use loaded language that favors one direction

The framing MUST include:

- Decision statement in clear, neutral terms
- Relevant Contably context (from the context block): what tier it affects, what it integrates with, what constraints apply
- Decision type and why it matters
- Explicit instruction: *"You are one of 8 Contably council members. Give YOUR perspective from YOUR domain expertise. Do not try to represent 'balance' — be authentically yourself. Use the Contably OS v3 context block to ground your opinion in current reality, not hypotheticals."*

**Database init:** if `~/.claude-setup/data/conta-cpo.db` does not exist, run `sqlite3 ~/.claude-setup/data/conta-cpo.db < ~/.claude-setup/skills/conta-cpo/schema.sql` first. Then insert a new row into `conta_cpo_decisions` with `status='deliberating'` and a fresh UUIDv4.

Present the framing to the user: *"Does this framing accurately capture your decision? Anything to adjust before the council convenes?"* Wait for confirmation.

### Phase 2 — Blind Deliberation

Spawn council members as parallel subagents. Each receives: persona prompt + Contably context block + decision framing + JSON output schema.

**Full mode (8 seats):** spawn in 2 batches of 4 using `Agent` with `model: "sonnet"`:

- Batch 1: Seats 1-4 (Camila, Renata, Rafael, Bruno)
- Batch 2: Seats 5-8 (Paula, Sofia, Marcelo, Zezé)

**Quick mode (4 seats):** spawn all 4 in one batch (seats 1, 3, 5, 7).

Each subagent prompt:

```
{Content of personas/seat-NN-*.md}

---

## Contably OS v3 Context (current state)

{Context block from Phase 0.5}

---

## The Decision Before You

{Decision framing from Phase 1}

---

Respond ONLY with the JSON structure specified in the Output Format section above. No text before or after.
```

**Opus 4.7 fan-out instruction (add to the orchestrator's own context):** *Do not spawn a subagent for work you can complete directly. Spawn 4 subagents in parallel in a single turn for each batch of this phase.*

Collect responses, parse JSON. If invalid, attempt extraction; on failure, mark the seat `abstained` and continue. **Insert each valid response into `conta_cpo_board_inputs`.**

**Anti-corruption check:** if ALL seats have `dissent_strength < 2`, trigger UNANIMITY WARNING.

### Phase 3 — Collision Mapping

Use `mcp__sequential-thinking__sequentialthinking` to work through collision analysis.

**3a — Agreements:** positions where 3+ seats (quick: 2+) align. Note shared position, which seats, confidence range.

**3b — Contradictions:** 2+ seats directly oppose on a material point. Note positions, nature of disagreement (values vs facts vs time horizons), material impact, seat distance.

**3c — Orphan Insights:** perspectives raised by only ONE seat. Often the most valuable output — they're the blind spots of the other 7.

**Store:** `UPDATE conta_cpo_decisions SET collision_map = ? WHERE id = ?` with JSON.

Display to user per /vibc's format.

### Phase 4 — Adversarial Pairing

Select top 1-3 contradictions for steelman debates. Read `references/adversarial.md`. Skip if quick mode or no material contradictions.

For each pair, spawn 2 sequential sonnet subagents using the template in `references/adversarial.md`. Determine resolution: `synthesis`, `clear_winner`, `conditional`, or `trade-off`.

### Phase 5 — Option Generation

Synthesize collision map + adversarial results into 2-4 concrete options (quick: 2-3).

Each option MUST include:

- **Title** — short, memorable
- **Description** — 1-2 sentences
- **Core bets** — what must be true for success (from agreements + resolved contradictions)
- **Kill conditions** — observable signals of failure (drawn from board concerns)
- **Reversibility score** 1-10 (informed by Rafael + Sofia)
- **Supporting seats** / **Opposing seats**

Options should be genuinely different approaches, not variations. At least one option should incorporate an orphan insight.

### Phase 6 — Decision Scoring

Read `references/scoring.md` for framework.

For each option, score across 6 dimensions (4 in quick mode):

1. Load dimension weights for the decision type (see table in `references/scoring.md`)
2. For each dimension, evaluate how well the option addresses concerns raised by primary + secondary seats
3. Primary seat evaluations count 2x, secondary 1x
4. Score each dimension 1-10
5. Compute weighted total

**Anti-corruption checks:**

- UNANIMITY WARNING: all dimensions > 7 for any option → *"When everyone agrees, someone isn't thinking."*
- KILL CONDITION FLAG: any dimension < 3 → must be addressed or option eliminated
- GROUPTHINK WARNING: std dev across options < 1.5

**Insert each option into `conta_cpo_options`** with scores and `weighted_total`.

Display ranked options with the dimension breakdown table from `references/report-template.md`.

### Phase 7 — Report & Persist

1. Read `references/report-template.md`
2. Fill in with deliberation results
3. Write to `conta-cpo-report-{decision-id-short}.md` in `/Volumes/AI/Code/contably-hr061-sqlite/docs/contably-os-v3/decisions/` (create dir if missing). Fallback to CWD if neither Contably repo is accessible.
4. `UPDATE conta_cpo_decisions SET status='scored', decided_at=datetime('now') WHERE id = ?`
5. Query `conta_cpo_batting_average` view; include if retrospectives exist

Present to user:

- Executive summary (top recommendation with score)
- The top concern that nearly killed the top option
- The orphan insight most worth investigating
- Path: *"To track this decision, run `/conta-cpo retro {decision-id}` when the outcome is known."*

Ask which option they're leaning toward. Record in `conta_cpo_decisions.user_choice`.

### Phase 8 — Retrospective Mode

Triggered by `/conta-cpo retro <decision-id>`.

1. Fetch decision from `conta_cpo_decisions`
2. Fetch inputs from `conta_cpo_board_inputs`, options from `conta_cpo_options`
3. Display original decision, chosen option, council predictions

Ask the user:

- What actually happened? (actual outcome)
- Rate the outcome 1-10
- Which seat's prediction was most accurate?
- Which was least accurate?
- What surprised you that nobody anticipated?

4. Insert into `conta_cpo_retrospectives`
5. `UPDATE conta_cpo_decisions SET status='closed'`
6. Query `conta_cpo_batting_average` and display

## Cost Estimates

| Mode  | Seats | Adversarial Pairs | Estimated Cost |
| ----- | ----- | ----------------- | -------------- |
| Full  | 8     | 1-3               | $4-7           |
| Quick | 4     | 0                 | $1.50-3        |
| Retro | 0     | 0                 | $0.30-0.50     |

~50% of /vibc's cost at full (smaller council) and comparable quality for Contably-specific decisions due to domain grounding.

## Key Principles

1. **Blind independence is sacred.** Council members NEVER see each other's input during Phase 2. Agent spawning (not TeamCreate/SendMessage) preserves this.
2. **Ground opinions in Contably OS v3 reality.** The context block is mandatory — personas must reference active tiers / open risks / CTO verdicts, not hypothetical scenarios.
3. **Orphan insights are the most valuable output.** The thing only Marcelo (the accountant) sees is usually the real user concern nobody else would name.
4. **Unanimity is a warning, not a success.** If Sofia (LGPD) agrees with Zezé (comedian) without dissent, check the persona prompts.
5. **The steelman is the test.** If Rafael can't articulate Renata's UX concern better than she did, the debate was shallow.
6. **Retrospectives close the loop.** Without them, /conta-cpo is just a fancy prompt. Batting average is the feedback signal that improves persona design over time.

## Skill Positioning

| Use /conta-cpo when | Use /vibc when | Use /cto when | Use /deep-plan when |
| ------------------- | -------------- | ------------- | ------------------- |
| Contably product/UX/eng/pricing decision | Generic life or business decision | Architecture/security/perf review of code | Research→plan→implement a feature |
| Need domain-grounded deliberation | Need diverse life-archetype views | Need cross-concern technical synthesis | Need phased plan with implementation |
| Decision affects accountant workflow, LGPD, or a Tier N roadmap item | Decision is not Contably-specific | Decision is about *how* to build, not *whether* | Decision is already made; now execute |

## Output Artifacts

- Report markdown: `docs/contably-os-v3/decisions/conta-cpo-report-{decision-id-short}.md`
- DB rows: `~/.claude-setup/data/conta-cpo.db` (tables `conta_cpo_*`)
- Context block cache: `.contably-os/context-block.cached.md` (24h TTL)
