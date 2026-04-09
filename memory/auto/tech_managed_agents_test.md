---
name: tech-insight:managed-agents-live-test
description: Live test of Anthropic Managed Agents API with Claudia — results, cost, and recommendation to wait before enabling
type: project
originSessionId: 1ec6f264-2981-42b8-89f8-236436c7af8a
---

## Managed Agents Live Test Results (2026-04-09)

Ran first live simulation against Anthropic's Managed Agents API using Claudia's existing adapter (`src/inference/managed-agents.ts`).

**Setup:** Opus orchestrator + 2 Sonnet specialists via `callable_agents`, cloud environment, web search tools enabled. Test script at `scripts/test-managed-agents.ts`.

**Results:**

| Metric      | Value                                   |
| ----------- | --------------------------------------- |
| Wall time   | 393s (6.5 min)                          |
| Active time | 89.8s                                   |
| Tokens      | 5 input + 32,807 cached + 3,312 output  |
| Tool calls  | 5 (web searches + agent calls)          |
| Cost        | $0.25 ($0.2485 tokens + $0.002 session) |
| Response    | 7,048 chars — high quality synthesis    |

**Why:** Tested whether Managed Agents could replace or complement Claudia's Agent SDK inference for multi-agent orchestration (swarmy use case).

**How to apply:**

**Decision: Don't enable yet.** Revisit in 2-3 months. Reasons:

1. **No performance win** — 393s wall (77% idle on cloud scheduling) vs ~60-90s for equivalent Agent SDK swarm
2. **Custom tool bridging adds latency** — memory_query, channel_send, wiki_query must round-trip to VPS
3. **Kills local model fallback** — Managed Agents locks to Anthropic models only; Claudia's 4-tier cascade (Opus → Sonnet → Mac Mini MLX → Ollama) is a cost/resilience advantage
4. **Multi-agent API still research preview** — `sessions.threads.list` not exposed in SDK yet
5. **Prompt caching worked well** — 32K cached tokens automatically, built into harness

**Revisit triggers:**

- Thread introspection goes GA
- Native MCP server support in Agent config (would eliminate custom tool bridging — mcp-memory-pg connects directly)
- Session resume proven stable for production use

**What's ready:** Code is complete. Flip `MANAGED_AGENTS_ENABLED=true` in VPS .env and add `"swarmy"` to `managedAgents` array in `data/inference.json`. Zero code changes needed.

Discovered: 2026-04-09
Source: implementation — scripts/test-managed-agents.ts live test
Use count: 1
Applied in: claudia - 2026-04-09 - HELPFUL (informed decision to wait)
