# Opus 4.7 Prompting Patterns

Canonical prompt snippets for Claude Opus 4.7. Source: Boris Cherny + Anthropic blog, 2026-04-16 (https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code).

## Thinking Control (replaces `budget_tokens`)

Opus 4.7 uses adaptive thinking — it decides per-step whether to think. Fixed thinking budgets are no longer supported. Steer via prompt:

**Increase thinking** (hard problems, ambiguous debugging, architecture):
> "Think carefully and step-by-step before responding; this problem is harder than it looks."

**Decrease thinking** (simple lookups, cost-sensitive steps, interactive chat):
> "Prioritize responding quickly rather than thinking deeply. When in doubt, respond directly."

## Subagent Fan-Out (4.7 is more judicious than 4.6)

4.7 won't auto-delegate to subagents the way 4.6 did. If the skill needs parallel execution, say so explicitly:

> "Do not spawn a subagent for work you can complete directly in a single response (e.g., refactoring a function you can already see). Spawn multiple subagents in the same turn when fanning out across items or reading multiple files."

Apply this to: `/cto` swarm mode, `/parallel-dev`, `/qa-cycle`, `/deep-research`, any skill that expects 3+ parallel agents.

## Response Length & Style

4.7 is less verbose by default — shorter on simple queries, longer on open-ended analysis. If you need a specific length or style:

- State it explicitly ("respond in under 150 words", "produce a checklist")
- Prefer positive instructions over negative ones ("be concise" > "don't be verbose")

## Tool Use

4.7 calls tools less often and reasons more before doing so. If aggressive search/file reading is needed during agentic work, describe when and why:

> "Before answering, read all files in `src/auth/` and grep for `authenticate` across the repo."

Do not assume 4.7 will self-discover the need to explore.

## Interactive vs Autonomous Mode

- **Autonomous/async** (single-turn, fire-and-forget): lower reasoning overhead. Best for Routines and scheduled tasks.
- **Interactive/sync** (multi-turn): more reasoning per user turn. Front-load the full task in turn 1 — intent, constraints, acceptance criteria, file locations. Batch follow-up questions rather than asking one at a time; each turn adds reasoning overhead.

## Effort Tiers (when configurable)

| Tier    | When to use                                                     |
| ------- | --------------------------------------------------------------- |
| `low`   | Cost/latency-sensitive, tightly scoped. Still beats 4.6 at same level. |
| `high`  | Concurrent sessions, balanced intelligence/cost                 |
| `xhigh` | **Default.** Most coding and agentic work. Best autonomy-to-cost ratio. |
| `max`   | Evals/ceiling testing only. Diminishing returns, prone to overthinking. |
