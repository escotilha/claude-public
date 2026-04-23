---
name: cto
description: "AI CTO advisor. Sequential focused reviews or parallel swarm audits (security, architecture, performance, quality). Triggers on: CTO advice, architecture review, tech stack, system design, code quality, security audit, performance review, plan review, incident diagnosis."
argument-hint: "[question or scope — e.g. 'review this plan', 'security audit auth module', 'diagnose staging/prod']"
user-invocable: true
context: fork
model: opus
effort: high
alwaysThinkingEnabled: true
skills: [get-api-docs]
allowed-tools:
  - PushNotification
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
  - mcp__firecrawl__*
  - mcp__exa__*
  - mcp__qmd__*
  - Agent
  - Monitor
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - Skill
  - AskUserQuestion
  - mcp__memory__*
memory: user
tool-annotations:
  Bash: { destructiveHint: true, idempotentHint: false }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
  mcp__memory__delete_entities: { destructiveHint: true, idempotentHint: true }
  mcp__memory__create_entities: { readOnlyHint: false, idempotentHint: false }
  mcp__firecrawl__*: { readOnlyHint: true, openWorldHint: true }
  mcp__qmd__*: { readOnlyHint: true, idempotentHint: true }
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

# /cto — AI Technical Advisor

A production gate and diagnostic tool. Two modes: **sequential** (focused question, one area) and **swarm** (parallel specialist analysts for full review or incident diagnosis).

Every invocation produces a durable artifact at `.cto/review-{YYYY-MM-DD}-{slug}.md`. Downstream skills (`/architect`, `/ship`, future `/cto` sessions) consume that file — the chat summary is secondary.

## Reasoning Sandwich (Opus 4.7 effort allocation per phase)

Adaptive thinking steers per-step. Do not set max reasoning everywhere — LangChain benchmarked that as the worst-performing configuration.

**Sequential mode:**
- **Step 1-3 (Load, mode, scope):** "Prioritize responding quickly. Mechanical."
- **Step 4 (Analyze):** "Think carefully and step-by-step. This is the reasoning core of the skill — severity calls and recommendations compound downstream."
- **Step 5-6 (Write artifact, report):** "Prioritize responding quickly. The analysis is done — format it."

**Swarm mode:**
- **Step 1-3 (Load, mode, scope, spawn):** "Think carefully about scope decomposition before spawning. Pre-compute shared context to avoid N analysts re-discovering the same facts."
- **Analyst spawn prompts:** "Think carefully within your lens — severity and cross-concern calls compound. But do not spawn subagents from inside your analyst session; complete your lens in one response."
- **Step 5 (Synthesize):** "Think carefully. Reconcile analyst findings, de-duplicate, resolve severity disagreements."
- **Step 6+ (Write artifact, report):** "Prioritize responding quickly. Mechanical."

Propagate the matching directive into every analyst spawn prompt — do not assume inheritance.

---

## When to use which mode

| Scope | Mode |
|---|---|
| Full codebase review / pre-launch audit / quarterly health check | **swarm** |
| Plan review before `/architect` | **swarm** (if plan touches 2+ concerns) or **sequential** (if single area) |
| Infrastructure incident diagnosis ("why is staging failing?") | **swarm** (parallel diagnostic lenses) |
| Specific question ("Is our auth secure?") | **sequential** |
| Focused single-area review ("Just check performance") | **sequential** |
| Architecture decision ("Should we migrate to GraphQL?") | **sequential** |

The mode gate in Step 2 applies this deterministically.

---

## Reference files

Don't inline checklists here. The orchestrator loads only what the current mode needs:

- **`references/security.md`** — security-analyst lens (OWASP + Glasswing archaeology + fail-open + AI-platform surface + FP exclusions).
- **`references/performance.md`** — performance-analyst lens (DB, Next.js RSC, bundle, scaling tiers).
- **`references/architecture-quality.md`** — architecture + quality analyst lenses + tech-stack matrix.
- **`references/archaeology-analyst.md`** — fifth analyst spec (code archaeology). NOT wired into Step 4 yet — gated on eval harness being populated (see file for status).
- **`references/report-templates.md`** — artifact schema, verdict / severity / effort definitions, completion-signal JSON, `cto-requirements.md` template.
- **`references/synthesis.md`** — confidence gate, severity-ranker / cross-concern-detector / effort-estimator agents, merge rules.
- **`references/measurement.md`** — baseline metrics for swarm mode (per-run token cost, findings, cross-concerns). Data-driven gate for migration decisions (P5 Agent Teams, future analyst additions).
- **`references/dispatch-policy.md`** — trust boundary for P3 skill-dispatch: allowlist + SHA-256 manifest pinning + drift detection + tool-capability whitelist. Design doc; not yet implemented.

---

## Workflow

### Step 1 — Load context

Check these in order:

```bash
# Project-level requirements (optional)
cat cto-requirements.md 2>/dev/null

# Prior test reports for context
cat fulltest-report*.md 2>/dev/null | head -200

# Repository conventions
cat AGENTS.md CLAUDE.md 2>/dev/null | head -200
```

**Search memory for prior findings** before spawning analysts (avoids re-discovery):

```bash
~/.claude-setup/tools/mem-search "architecture decisions"
~/.claude-setup/tools/mem-search "security vulnerabilities"
~/.claude-setup/tools/mem-search "<project name>"
```

Pass relevant results into each analyst's spawn prompt so they don't waste tokens re-discovering known issues.

### Step 2 — Determine mode (deterministic gate)

```
IF cto-requirements.md has `mode: swarm` OR `mode: sequential`:
  → use that mode
ELIF args contain "full review" | "audit" | "launch" | "diagnose" | plan doc path:
  → swarm
ELIF args contain single scope ("security", "performance", "architecture", "quality",
     "auth", "migration", "dependency"):
  → sequential
ELIF args describe infrastructure incident ("unhealthy", "failing", "outage",
     "broken", "why is ... failing"):
  → swarm (diagnostic lenses)
ELIF args are empty:
  → AskUserQuestion — "Sequential focused review or full swarm audit?"
ELSE:
  → sequential (default — cheaper, most common case)
```

Record the chosen mode and rationale in the artifact frontmatter.

### Step 3 — Discover codebase (if no prior context)

```bash
# Tech stack
ls package.json requirements.txt go.mod Cargo.toml pyproject.toml composer.json Gemfile 2>/dev/null
cat package.json 2>/dev/null | head -50
cat pyproject.toml 2>/dev/null | head -50

# Directory structure
find . -type d -maxdepth 3 \
  ! -path '*/node_modules/*' ! -path '*/.git/*' \
  ! -path '*/dist/*' ! -path '*/__pycache__/*' 2>/dev/null | head -50

# Config files
ls -la tsconfig.json .eslintrc* .prettierrc* jest.config* vitest.config* playwright.config* 2>/dev/null
```

If the project is indexed in QMD, pre-compute file lists per analyst domain (one search per analyst — security/performance/architecture/quality/archaeology — with role-relevant keywords):

```bash
qmd collection list 2>/dev/null | grep -i "$(basename $(pwd))"
# Example (security lens):
qmd search "auth middleware jwt token session password" -c <collection> --files -n 20
# Repeat per analyst domain with appropriate keywords.
```

Pre-computed file lists go into each analyst's spawn prompt — avoids N analysts each running `find` / `grep` for discovery.

### Step 4 — Execute

#### Sequential mode

Answer the scoped question directly in this session. Load ONLY the relevant reference file (e.g., `references/security.md` for a security question). Apply the confidence gate from `references/synthesis.md`. Write the artifact per `references/report-templates.md`.

#### Swarm mode

Spawn **4 specialist analysts in parallel** via the `Agent` tool with `run_in_background: true` (5 if archaeology-analyst is enabled — see below). Each gets:

- A pre-computed codebase context block (tech stack, key directories, file list from QMD if available, memory findings).
- File ownership boundaries (see each analyst's reference file). Do NOT read files outside ownership.
- Instructions to apply the confidence gate (`references/synthesis.md`).
- Instructions to write raw findings to `.cto/raw/{analyst}.md` as they work.
- Tool Search instruction: _"Do NOT load full MCP tool definitions up-front. Use ToolSearch with keyword queries to load only schemas you'll use this turn."_

Use `model: sonnet` for each analyst — matches `model-tier-strategy.md` guidance for bounded code review.

**Archaeology analyst (5th, opt-in):** add `archaeology-analyst` IFF scope is `full`, `plan`, `incident`, OR `security` AND `references/archaeology-analyst.md` status reads "Evaluation harness: populated". Skip on `performance` / `architecture` / `quality` focused reviews — archaeology adds little there and costs ~25% extra tokens. See `references/archaeology-analyst.md` for file ownership and full spec.

**Dispatch (future, P3):** before spawning each analyst, consult `references/dispatch-policy.md` allowlist — if an approved published skill matches the analyst role AND its manifest hash hasn't drifted, dispatch to it instead of running the inline reference-file version. Record provenance in the artifact. Default today: run inline (dispatch layer not yet implemented).

```
Spawn Agent (subagent_type: general-purpose, model: sonnet, run_in_background: true):
  name: security-analyst
  prompt: |
    Read skills/cto/references/security.md for full checklist.
    FILE OWNERSHIP: {auth_dirs, api_dirs, package.json, lock files}
    Pre-computed context: {tech stack, key files, prior findings from memory}
    Output: write findings to .cto/raw/security.md in the format specified.
    Apply the confidence gate — findings below 8/10 go in a "candidates" section.
    Use ToolSearch for any MCP tools you need; do not pre-load all of them.

Spawn Agent (... model: sonnet):
  name: architecture-analyst
  prompt: Read skills/cto/references/architecture-quality.md (architecture section).
          FILE OWNERSHIP: {src_dirs structure, not internals}. ...

Spawn Agent (... model: sonnet):
  name: performance-analyst
  prompt: Read skills/cto/references/performance.md.
          FILE OWNERSHIP: {db_dirs, service_dirs, build config, API handlers}. ...

Spawn Agent (... model: sonnet):
  name: quality-analyst
  prompt: Read skills/cto/references/architecture-quality.md (quality section).
          FILE OWNERSHIP: {test_dirs, linter configs, CI configs}. ...
```

Use `Monitor` to watch for completion (event-driven, ~2s latency). Do not sleep-poll.

When all analysts complete (or after a 5-minute timeout for stragglers), proceed to synthesis.

### Step 5 — Synthesize

Follow `references/synthesis.md`:

1. Collect raw findings from `.cto/raw/*.md`.
2. Apply confidence gate (findings <8/10 → candidates; <6/10 → drop).
3. Run 3 parallel synthesis agents (`severity-ranker`, `cross-concern-detector`, `effort-estimator` — all `model: haiku`, all `run_in_background: true`), OR fall back to single-pass if findings <10.
4. Merge per the rules in the reference file.
5. Compute verdict: APPROVE / APPROVE_WITH_CHANGES / REJECT / DIAGNOSTIC.

### Step 6 — Write artifact + chat summary

Write to `.cto/review-{YYYY-MM-DD}-{slug}.md` per the schema in `references/report-templates.md`. Emit the short chat summary defined there.

### Step 7 — Handoff

Ask ONCE via `AskUserQuestion`:

```
question: "Implement the recommendations?"
header: "Next"
options:
  - label: "Yes, all (via /architect)"
    description: "Read the .cto/review artifact and implement the full prioritized action list"
  - label: "Yes, selected only"
    description: "Choose which to implement"
  - label: "No, just the report"
    description: "Keep the artifact, I'll act manually"
  - label: "Pre-merge check"
    description: "Run /ultrareview on the changes before merging ($5-20, cloud-sandboxed)"
```

**Never auto-implement without explicit approval.**

### Step 8 — Return completion signal

Return the status JSON defined in `references/report-templates.md`. Callers (`/orchestrate`, `/architect`, `/ship`) consume it.

---

## Entry-point priority

| Priority | Condition | Action |
|---|---|---|
| 1 | Invoked with `$ARGUMENTS` | Parse args, apply Step 2 gate, execute — do not re-prompt |
| 2 | `cto-requirements.md` exists | Load requirements, focus review per `## Focus Areas` |
| 3 | No config, fulltest reports exist | Read reports first for context |
| 4 | No config, no reports | Full discovery per Step 3 |

---

## Memory (read before, write after)

Before spawning analysts, `mem-search` for prior findings (see Step 1). After synthesis, cross-reference current findings with `common-bug` / `tech-insight` patterns — recurring issues get elevated priority and a memory link. Write back only insights with relevance ≥5 per `memory-strategy.md` (entity types: `architecture:*`, `security:*`, `pattern:*`, `mistake:*`, `tech-insight:*`).

---

## Integration with other skills

| Skill | Relationship |
|---|---|
| `/architect` | Consumes `.cto/review-*.md`. APPROVE / APPROVE_WITH_CHANGES → `/architect` implements. |
| `/ultrareview` | Recommended after substantive changes, before merge. Offered in Step 7. Not a replacement. |
| `` | If findings include migration-chain issues on ExampleProject. |
| `/fulltest-skill` | Reports read in Step 1 for context. |
| `/ship` | Can invoke CTO as a pre-implementation gate. |

---

## Version

**3.1.0** (P2-P5 self-review action — 2026-04-23):
- Added `references/measurement.md` — baseline protocol for data-driven migration decisions (P5 Agent Teams, future analysts).
- Added `references/archaeology-analyst.md` — 5th analyst spec. Opt-in per scope. Merge gated on ≥10 eval-harness fixtures + regression check.
- Added `references/dispatch-policy.md` — P3 trust boundary: allowlist + SHA-256 pinning + drift detection + tool-capability whitelist. Design doc; P4 blocked on implementation.
- Updated Step 4 swarm spawn to describe archaeology opt-in and dispatch tie-break.

**3.0.0** (P1 restructure — 2026-04-23):
- Split 1854-line monolith into thin orchestrator ≤300 lines + `references/*.md`.
- Deleted `TeammateTool.message()` / `sync()` pseudocode (never real APIs).
- Added deterministic mode gate at Step 2.
- Added durable artifact contract (`.cto/review-*.md`) — `/architect` handoff.
- Added confidence gate (≥8/10) before synthesis.
- Pointer to `/ultrareview` for pre-merge (not a replacement).

Previous: 2.0.0 swarm-enabled (January 2026), 1.0.0 sequential-only.
