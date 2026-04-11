---
name: marco-agent-teams-routing
description: Consolidated Agent Teams vs subagents decision matrix — 3-5 rule, token multipliers, independence criteria, quickstart checklist
type: feedback
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Default to subagents. Agent Teams is the exception. Use it only when workers genuinely need to discuss findings with each other AND can operate on isolated files AND the task is complex enough to justify N separate context windows.

Token multiplier: Agent Teams costs approximately 1.5-2x vs subagents for comparable tasks. Accept this overhead only when cross-agent communication produces qualitatively better output (e.g., cross-concern detection in security+architecture reviews, cross-feature API coordination in worktree-isolated parallel dev).

Key operational rules:

- Shut down finished teammates immediately — idle teammates still consume tokens on every broadcast
- Never broadcast when a direct message works — broadcasts touch all N context windows
- Pre-compute shared codebase context in orchestrator, pass in spawn prompts — avoid each teammate re-exploring independently
- 3-5 tasks per teammate (not 1 coarse task) — enables checkpointing and reassignment
- Always define a subagent fallback — Agent Teams is experimental, every skill must work without it

---

## Decision Flowchart

```
Does the skill spawn multiple workers?
  NO  → Single session. Done.
  YES ↓

Do workers need to DISCUSS findings with each other?
(React to each other's output, not just report back)
  NO  → Subagents (Task tool). Done.
  YES ↓

Can workers operate on SEPARATE files/directories?
  NO  → Subagents with sequential hand-off.
        (Agent Teams + shared files = merge failures + wasted tokens)
  YES ↓

Is the task COMPLEX enough to justify N full context windows?
(Each teammate ≈ $0.50–2.00 in tokens)
  NO  → Subagents. Discussion benefit doesn't justify cost.
  YES ↓

USE AGENT TEAMS.
```

## The 3-5 Rule

Sweet spot: **3-5 teammates**.

- Below 3: coordination overhead exceeds the benefit
- Above 5: token costs scale linearly, coordination quality degrades (broadcasts flood everyone, lead struggles to synthesize)

## Quick Signal Table

| Signal                         | Use This                    |
| ------------------------------ | --------------------------- |
| Workers report results only    | Subagents                   |
| Workers react to each other    | Agent Teams                 |
| Same files being edited        | Subagents (sequential)      |
| Isolated directories/worktrees | Agent Teams candidate       |
| < 3 workers                    | Subagents (overhead > gain) |
| > 5 workers                    | Subagents (tokens explode)  |
| 3-5 workers with cross-talk    | Agent Teams sweet spot      |

## Token Multiplier Reference

| Scenario                                   | Estimated multiplier vs subagents |
| ------------------------------------------ | --------------------------------- |
| Agent Teams (3-4 teammates, focused tasks) | ~1.5x                             |
| Agent Teams (4-5 teammates, broad scope)   | ~2x                               |
| Agent Teams > 5 teammates                  | 2-3x+ (not recommended)           |
| Accept if: quality delta justifies it      | threshold: ≤ 2x, revert if > 3x   |

## Skill Evaluation Quickstart Checklist

Before migrating any skill to Agent Teams:

- [ ] Count workers needed (if < 3, stop — use subagents)
- [ ] Do they need cross-talk? (if report-back only, stop — use subagents)
- [ ] File isolation possible? (if shared files, stop — use sequential subagents)
- [ ] Token budget acceptable? (estimate N × avg subagent cost × 1.5-2x)
- [ ] Fallback to subagents defined in the SKILL.md?
- [ ] Measured actual token cost on a real run before committing?

## Current Migration Status (as of 2026-04-10)

| Skill            | Status         | Rationale                                                                                                                                                                                |
| ---------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| parallel-dev     | Candidate      | Worktree isolation + cross-feature API coordination is the unique AT value; Monitor tool now handles polling elimination so AT only justified when features have real cross-dependencies |
| cto (swarm mode) | Hybrid         | Swarm mode → Agent Teams (4 specialists); sequential mode stays single session                                                                                                           |
| fulltest-skill   | Stay subagents | 15 page testers — report-back only, no inter-agent reasoning, AT would be 15 full context windows                                                                                        |
| cpo-ai-skill     | Stay subagents | Sequential phases, specialists report back to lead, no cross-talk needed                                                                                                                 |
| review-changes   | Stay single    | Single-purpose, sequential, no parallelism needed                                                                                                                                        |
| cpr              | Stay single    | Single-purpose, sequential                                                                                                                                                               |
| test-and-fix     | Stay single    | Single-purpose, sequential                                                                                                                                                               |
| website-design   | Stay single    | Single-purpose, sequential                                                                                                                                                               |

## Messaging Discipline

| Pattern         | When                                      | Token cost                   |
| --------------- | ----------------------------------------- | ---------------------------- |
| Direct message  | One teammate needs info from one other    | Low (2 context windows)      |
| Message to lead | Reporting findings or completion          | Low (1 + lead)               |
| Broadcast       | Genuinely affects ALL teammates' approach | High (all N context windows) |

Never broadcast for: progress updates, individual findings, acknowledgments.
Only broadcast for: blocking discoveries that change everyone's approach, shared resource conflicts.

---

## Timeline

- **2026-04-11** — [session] Synthesized from AGENT-TEAMS-STRATEGY.md rules file into consolidated routing memory (Source: session — /synthesize rules to memory)
