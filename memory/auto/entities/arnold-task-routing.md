---
name: arnold-task-routing
description: Pre-response checklist for routing tasks to skills, parallelization, or ad-hoc execution
type: feedback
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Before acting on any task, run this 5-step mental checkpoint in order.

## 5-Step Checkpoint

1. **Does a skill cover this?**
   Check the skill-first routing table (SKILL-FIRST rule). If a matching skill exists, invoke it via the Skill tool — never improvise what a skill already handles.

2. **Are there multiple independent operations?**
   If yes, parallelize. Batch all independent Read/Grep/Glob/WebFetch calls into a single message. Spawn independent agents simultaneously, not sequentially.

3. **Is this a multi-file change?**
   Consider `/parallel-dev` (isolated worktrees, feature-level) or `/batch` (repetitive changes across many files). Sequential edits to the same file are the only exception.

4. **Does this need investigation first?**
   Unknown scope or ambiguous requirements → `/deep-plan` (research → plan → implement). Read-only codebase exploration → Explore agent (model: haiku, cheapest). Don't write code against assumptions.

5. **Is this destructive?**
   Any operation that deletes, resets, force-pushes, drops data, or modifies production → confirm explicitly before proceeding. When user-direct: ask. When agent-spawned: abort and surface to orchestrator.

---

## Quick-Reference Routing Table

| Task type                 | Recommended skill / pattern                              |
| ------------------------- | -------------------------------------------------------- |
| Bug fix                   | `/test-and-fix`                                          |
| Feature (spec known)      | `/ship`                                                  |
| Feature (scope unclear)   | `/deep-plan` → `/ship`                                   |
| Deploy (Contably staging) | `/deploy-conta-staging` (run `/contably-guardian` first) |
| Deploy (Contably prod)    | `/deploy-conta-production`                               |
| Deploy (SourceRank)       | `/deploy-sourcerank`                                     |
| Deploy (Claudia VPS)      | `/deploy-claudia`                                        |
| Code review               | `/review-changes`                                        |
| Architecture / security   | `/cto`                                                   |
| Research (any topic)      | `/deep-research`                                         |
| QA (any project)          | `/qa-cycle`                                              |
| QA fix                    | `/qa-fix` → `/qa-verify`                                 |
| Tests failing             | `/test-and-fix`                                          |
| Typecheck + build verify  | `/verify`                                                |
| Parallel features         | `/parallel-dev`                                          |
| Read-only exploration     | Explore agent (model: haiku)                             |
| Commit + push + PR        | `/cpr`                                                   |
| Ad-hoc (no skill match)   | Proceed directly — batch tool calls, parallelize         |

---

## Timeline

- **2026-04-11** — [session] Created for Arnold agent pre-response routing discipline (Source: session — arnold task routing)
