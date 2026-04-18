---
name: feedback_use_swarms_for_big_tasks
description: Always use parallel swarm agents for large tasks — never single agent for 100+ item workloads
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

For any task with 50+ items to fix/build/review, use swarm pattern (3-5 parallel agents split by file/category) instead of a single agent. Use the cheapest model that handles the work.

**Why:** Single agent on 164 test failures was too slow. Swarm of 3 agents (split by test file, lint, and remaining) finished 3x faster. User explicitly requested swarms for big tasks.

**How to apply:**

- CI cleanup (tests, lint, mypy): split by test file groups, use Sonnet
- Code review: split by domain (security, perf, architecture), use Sonnet
- Multi-file refactors: split by directory, use Sonnet
- Mechanical fixes (rename, format): use Haiku
- Investigation/architecture decisions: use Opus (only for orchestrator)
- Always 3-5 agents max (token cost vs coordination)

**Model selection for swarm agents:**

- Haiku: file discovery, grep, test running, format changes, scaffolding
- Sonnet: code fixes, test fixes, lint fixes, feature implementation, investigation
- Opus: orchestration only, architecture decisions, security audits

---

## Timeline

- **2026-04-14** — [user-feedback] "use swarms for big tasks, cheapest model needed" (Source: user-feedback — overnight sprint)
