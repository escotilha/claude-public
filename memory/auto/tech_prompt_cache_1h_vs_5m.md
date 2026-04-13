---
name: tech-insight:prompt-cache-1h-vs-5m
description: Claude Code prompt cache TTL — subagents get 5m (intentional), main agent gets 1h (rolling out), telemetry off = 5m
type: feedback
originSessionId: 79b36636-4198-42c1-b9b2-2193bf7e12b1
---

Subagents in Claude Code run on **5m prompt cache TTL** by default — this is intentional, not a bug. Main orchestrator sessions are getting **1h cache** rolled out selectively for query types where it's validated as net savings.

Key facts:

- 1h cache costs more to write, less to read — only beneficial for sessions that are frequently resumed
- Subagents are rarely resumed, so 1h would be a net overcharge → kept at 5m
- Telemetry off = experiment gates disabled client-side = everything falls back to 5m
- Env vars to force 1h or 5m are coming (not yet available)
- The viral "12x token savings" claim is wrong — real benefit is "a small win"
- Client-side default changing to 1h soon for validated query types

**Why:** Affects token cost modeling for all swarm/parallel patterns. Subagent spawning costs should be estimated at 5m cache TTL, not 1h.

**How to apply:** When designing subagent-heavy workflows (swarm reviewers, parallel testers, worktree agents), don't assume 1h cache benefits for subagents. The ScheduleWakeup 270s "stay in cache" rule remains correct for subagents. Orchestrator sessions may benefit from longer sleep intervals once 1h is confirmed active.

---

## Timeline

- **2026-04-13** — [research] Boris Cherny (@bcherny, Claude Code/Anthropic) clarified on X that subagents intentionally use 5m cache, not 1h. Env vars to override coming. (Source: research — https://x.com/bcherny/status/2043715713551212834)
