---
name: skill-audit
description: "Audit and improve the skills library. Inventories every SKILL.md, scores usage from transcripts + routing-table references, reviews top-ranked skills against a fixed rubric, flags low-usage skills for deprecate-or-fix. Triggers on: skill audit, audit skills, improve skills, review skills, skill health, /skill-audit."
argument-hint: "[scope — e.g. 'top 20', 'all', 'bottom quartile', 'single <skill-name>']"
user-invocable: true
context: fork
model: opus
effort: high
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
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: true, readOnlyHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
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

# skill-audit

Systematic audit of the skills library. Produces a prioritized improvement plan — not auto-fixes — because SKILL.md changes are consequential and deserve human sign-off.

## When to run

- Quarterly maintenance, or when skill count grows by >10
- After a big refactor of skills infrastructure (new frontmatter fields, new tool annotations)
- When you notice skills you don't remember writing, or skills you never invoke despite matching tasks

## What it does

Five phases. Each phase writes a durable artifact under `~/.claude-setup/skills/_audit/<YYYY-MM-DD>/`.

### Phase 0 — Routing eval

Run the routing evaluation harness to detect drift between the seed corpus (`~/.claude-setup/skills/_audit/routing-eval/cases.yaml`) and the actual routing table + SKILL.md files. This catches:

- **Misrouted skills** — a phrase the user would type doesn't overlap any trigger in the expected skill
- **Shadow skills** — multiple skills' triggers match the same phrase, creating ambiguous routing
- **Broken routing-table entries** — `/foo` appears in `skill-first.md` but no `foo/SKILL.md` exists (and it's not in the built-in allowlist)
- **Missing routing-table entries** — a skill exists but is not referenced in `skill-first.md`

```bash
~/.claude-setup/tools/routing-eval --json > ~/.claude-setup/skills/_audit/<date>/routing.json
~/.claude-setup/tools/routing-eval    # also print pretty report to session
```

Feed the `routed_but_missing_skill`, `skills_not_in_routing_table`, and shadow-heavy phrases into Phase 4's report. If `--strict` and failures exist, flag as P0 in the final report.

To add a new case after shipping a skill: append to `cases.yaml` with a 3-5 word phrase that represents the user's intent, the expected skill name, and a one-line rationale. Run `routing-eval` to verify.

### Phase 1 — Inventory

Walks `~/.claude-setup/skills/*/SKILL.md`. For each skill, extract:

- `name`, `description`, `model`, `effort`, `user-invocable`, `context`
- Presence of: `argument-hint`, `tool-annotations`, `invocation-contexts`, `allowed-tools`
- File size (tokens, approximate via `wc -c / 4`)
- Last-modified date (via `git log -1 --format=%ci`)
- Whether it appears in `~/.claude-setup/rules/skill-first.md` routing table
- Whether it's listed in `~/.claude-setup/rules/nuvini-sync-rules.md` EXCLUDE list (project-specific) or INCLUDE list (public)

Output: `inventory.json` — one record per skill.

### Phase 2 — Usage scoring

For each skill, compute a usage count from three sources:

1. **Direct slash-command invocations** — grep `~/.claude/projects/**/*.jsonl` for `/<skill-name>` at start of user message content
2. **Skill tool invocations** — grep same corpus for `"skill":"<name>"` in Skill tool calls
3. **Indirect references** — grep other SKILL.md files + rule files for the skill name (e.g. `/cto` composes `/get-api-docs`)

Weighting: direct = 3, skill-tool = 3, indirect = 1. Sum into `usage_score`. Compute percentile within the library.

Skips transcripts older than 90 days (stale usage ≠ current relevance).

Output: `usage.json` — `{name, direct, skill_tool, indirect, usage_score, percentile, last_invoked_at}`.

### Phase 3 — Rubric review (parallel subagents)

Pick the review set:

- Default: top 50% by `usage_score` + bottom 10% (the "fix or deprecate" tail)
- `top N`: review only the top N
- `single <name>`: review one skill
- `all`: review everything (expensive — confirm first)

Spawn **Sonnet** subagents, one batch of 5 skills per agent, fanned out in parallel. Each subagent receives:

- The skill's full SKILL.md content
- Its usage scores
- Three neighbor skills' descriptions (for dedup-overlap detection)
- The rubric below

**Rubric (fixed — do not improvise):**

1. **Frontmatter compliance** — all required fields per `~/.claude-setup/rules/skill-authoring-conventions.md`
2. **Trigger specificity** — description lists concrete trigger phrases; no ambiguous "maybe use for X" language
3. **Tool annotations** — `destructiveHint`, `readOnlyHint`, `idempotentHint` declared for non-obvious tools
4. **Invocation contexts** — split declared if skill is callable by both users and agents
5. **Token budget** — SKILL.md <8K chars for fork context, <4K for inline
6. **Model tier fit** — matches `model-tier-strategy.md` (read-only → haiku, judgment → sonnet, architecture → opus)
7. **Dedup risk** — description overlaps with ≤1 neighbor skill's description
8. **Deprecation candidate** — usage_score in bottom 10% AND last_invoked >60 days AND a clearer successor exists
9. **Composition hygiene** — if skill references other skills, they actually exist
10. **Karpathy check** — skill is minimum-viable, not speculative; doesn't solve problems that haven't happened

Each subagent returns a structured memo per skill:

```
{
  "name": "...",
  "rubric_pass": ["1", "3", "4", "6"],
  "rubric_fail": [{"rule": "2", "finding": "...", "fix": "..."}, ...],
  "verdict": "keep | revise | deprecate | merge-into:<name>",
  "priority": "P0 | P1 | P2",
  "estimated_fix_effort": "5min | 30min | 2h"
}
```

Output: `reviews.json` — flat array of all memos.

### Phase 4 — Consolidated report

Synthesize into `REPORT.md` with sections:

- **Executive summary** — total skills, % covered by routing table, % with full frontmatter, dedup-risk count, deprecation-candidate count
- **Top 10 priorities** — P0/P1 fixes ranked by (priority × usage_score)
- **Deprecation slate** — skills proposed to remove, with successor suggestion
- **Merge candidates** — pairs of skills with overlapping triggers
- **Frontmatter drift** — skills missing `tool-annotations`, `invocation-contexts`, `argument-hint`
- **Raw data appendix** — full `reviews.json` contents

Print the report path. Do **not** auto-apply fixes — the report is the artifact. Next step is the user choosing which P0s to run.

## Constraints

- Never edits SKILL.md files. This is a diagnostic skill.
- Never deprecates/archives anything. Only recommends.
- Usage data has survivorship bias (a skill can be broken → nobody invokes it → low usage → "deprecate" — watch for this in the bottom-decile review). The rubric item 8 explicitly requires a *successor* before deprecating.
- Max 20 subagents fanned out in parallel, batched 5 skills per agent.

## Composition

- Inventory and usage phases use `Bash` only — cheap, deterministic
- Review phase uses parallel `Agent` subagents (Sonnet, per model-tier-strategy)
- Report phase is orchestrator (Opus) synthesis

## Artifacts

All under `~/.claude-setup/skills/_audit/<YYYY-MM-DD>/`:

- `routing.json` — Phase 0 routing-eval output
- `inventory.json`
- `usage.json`
- `reviews.json`
- `REPORT.md`
- `raw/` — raw grep counts, transcript hits (for debugging)

The routing-eval seed corpus lives at `~/.claude-setup/skills/_audit/routing-eval/cases.yaml` — edit it whenever a skill is added, renamed, or deprecated.

## Follow-up skills (not part of this skill)

After the report, the user chooses what to do. Likely follow-ups:

- `/deep-plan` — plan the fix-queue rollout
- Direct edits to individual SKILL.md files for P0 fixes
- `/meditate` — extract patterns found during review into memory
