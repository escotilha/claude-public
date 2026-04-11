---
name: pattern_sse_multi_agent_delegation
description: Broadcast SSE events for inter-agent delegation so dashboards can route conversations to the correct agent's channel
type: feedback
originSessionId: eb4e1baa-6aa8-4dfd-b4ee-6658330da543
---

When one agent (COO/orchestrator) delegates a task to a specialist agent, broadcast SSE events so the UI can show the work appearing in the specialist's own chat channel rather than the orchestrator's.

**Pattern:**

1. Orchestrator calls `delegate(agent, task)`
2. Executor fires `broadcastSSE("delegation:task", { fromAgent, toAgent, task })`
3. Specialist processes the task via `handleMessage()`
4. Executor fires `broadcastSSE("delegation:response", { toAgent, response })`
5. Dashboard appends task as "user" message and response as "assistant" in the specialist's channel
6. Orchestrator gets a short preview/confirmation — full response lives in specialist's channel

**Why:** Users see each agent's work independently. The orchestrator's chat stays clean (only high-level summaries). The delegation is transparent and auditable.

**SSE event names:** `delegation:task`, `delegation:response`, `delegation:error`

**Implementation reference:** `/Volumes/AI/Code/agentwave/src/skills/executors/delegate.ts`

Discovered: 2026-04-11
Source: implementation — agentwave delegate skill + dashboard SSE routing
Relevance score: 7
Use count: 1
Applied in: agentwave - 2026-04-11 - HELPFUL
