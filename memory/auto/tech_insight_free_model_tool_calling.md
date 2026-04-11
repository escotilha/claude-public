---
name: tech_insight_free_model_tool_calling
description: Free/smaller LLMs describe tool calls in natural language instead of calling them — fix via imperative persona instructions
type: feedback
originSessionId: eb4e1baa-6aa8-4dfd-b4ee-6658330da543
---

Free and smaller open-weight models (Qwen, Nemotron, local models via Ollama) tend to narrate tool use ("I'll now call the delegate function to route this task...") instead of actually invoking the function. This breaks agentic workflows where the orchestrator must actually execute tools.

**Fix:** In the agent's system prompt / persona, add explicit imperative instructions:

- "IMMEDIATELY call the function. Do NOT describe what you would do — actually DO it."
- "When the user asks for X, IMMEDIATELY call `tool_name(...)`. Do not ask for permission or describe the process."
- List each tool with its exact trigger condition so the model has no ambiguity.

**Why it happens:** These models are trained more on chat/instruction-following than tool-use patterns. They learn to describe actions rather than invoke them. The fix is to remove all hedging language ("I would", "I can", "I'll prepare") from the persona and replace with imperatives.

**Applies to:** Any multi-agent platform using open/free models as the primary orchestrator (Claudia, AgentWave, any self-hosted LLM router).

Discovered: 2026-04-11
Source: failure — AgentWave COO (Qwen-based) describing delegate calls instead of executing them
Relevance score: 7
Use count: 1
Applied in: agentwave - 2026-04-11 - HELPFUL
