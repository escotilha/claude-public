---
name: tech-insight-opus-4-7-best-practices
description: Official Opus 4.7 best practices from Boris Cherny + Anthropic blog — effort tiers, adaptive thinking, subagent delegation changes
type: reference
originSessionId: 11982d0f-fea0-4714-a37b-81e549c5874b
---
Official guidance for Claude Opus 4.7 (shipped 2026-04-16 in Claude Code). Three behavioral changes from 4.6:

1. **Default effort is `xhigh`** (was `high` in 4.6). Tiers: low / high / xhigh (recommended) / max (evals only — overthinks). Use `xhigh` for most coding/agentic work; `max` gives diminishing returns.
2. **Adaptive thinking replaces fixed `budget_tokens`** — 4.7 decides per-step whether to think. Control via prompts, not API parameter. More thinking: *"Think carefully and step-by-step before responding; this problem is harder than it looks."* Less thinking: *"Prioritize responding quickly rather than thinking deeply. When in doubt, respond directly."*
3. **More judicious subagent delegation** — 4.7 won't auto-fan-out like 4.6 did. Skills expecting parallel subagents must include explicit instruction: *"Do not spawn a subagent for work you can complete directly in a single response. Spawn multiple subagents in the same turn when fanning out across items or reading multiple files."*

Other notes:

- Interactive mode reasons more per user turn than autonomous mode — front-load full intent/constraints/acceptance criteria in turn 1
- 4.7 is less verbose by default — state length/style explicitly if needed, prefer positive over negative instructions
- 4.7 calls tools less often — describe explicitly when/why tools should fire for agentic work
- Sweet spot: long-running tasks, complex multi-file changes, ambiguous debugging, code review across services

Canonical references in this setup:

- Prompting patterns: `~/.claude-setup/rules/opus-4-7-prompting.md`
- Tier R definition: `~/.claude-setup/rules/model-tier-strategy.md` ("Opus 4.7 Behavior" section)

Related: [advisor-strategy](concepts/tech_advisor_strategy.md) — Sonnet executor + Opus 4.7 advisor pattern still applies; [claude-code-routines](concepts/tech_claude_code_routines.md) — Routines default to 4.7 per Anthropic PM; [opus-for-investigation](feedback/feedback_opus_for_investigation.md) — now means 4.7 with xhigh default; [pattern-reasoning-sandwich](../semantic/pattern_reasoning_sandwich.md) — per-phase effort allocation applying this guidance to multi-phase skills (2026-04-23).

---

## Timeline

- **2026-04-16** — [research] Boris Cherny (@bcherny) posted tips thread linking to official Anthropic blog post "Best practices for using Claude Opus 4.7 with Claude Code". Captured three behavioral deltas from 4.6. (Source: research — https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code)
- **2026-04-16** — [implementation] Added "Opus 4.7 Behavior" subsection to model-tier-strategy.md and created opus-4-7-prompting.md rules file. (Source: implementation — ~/.claude-setup/rules/)
