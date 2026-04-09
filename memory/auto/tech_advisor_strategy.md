---
name: tech_advisor_strategy
description: Claude Platform advisor strategy — Sonnet executor + Opus advisor sharing context, announced April 2026. Applies to Claude Code skills and Claudia agent sessions.
type: reference
originSessionId: 7b579514-325f-4d99-b60f-495da82b5e36
---

## Claude Platform Advisor Strategy

Announced April 9, 2026 by Anthropic. First-party platform pattern for cost-efficient agentic sessions.

**Architecture:** Sonnet (executor, every turn) + Opus (advisor, on-demand via tool call). Shared context window — conversation, tools, history.

**Cost:** Near-Opus intelligence at Sonnet pricing. Opus only activates at judgment points.

**Applied in Claude Code skills:**

- `cto` sequential mode — Sonnet explores, Opus advises on severity/recommendations
- `parallel-dev` CI fix — Sonnet fixes, Opus escalation after 2 failed attempts
- `deep-plan` Phase 2 — Sonnet synthesizes research, Opus advises at decision gates

**Applicable to Claudia:**

- CEO agents (Paperclip): Replace all-Nemotron with Qwen3.5-35B-A3B executor + Nemotron advisor for strategic decisions
- Claude Max sessions: Sonnet 4.6 executor + Opus 4.6 advisor for daily tasks (briefings, health reports, heartbeat)

**Relationship to existing patterns:**

- Supersedes the DIY "Model Delegation Pattern (OpenClaw-Inspired)" in model-tier-strategy.md
- First-party API support means no custom routing logic needed
- For Claudia (non-Claude-Code), the pattern still requires manual adapter logic

Source: https://x.com/claudeai/status/2042308622181339453
Discovered: 2026-04-09
