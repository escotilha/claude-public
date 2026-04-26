---
name: tech-insight:prompt-cache-invalidation
description: Mid-session tool-list or model changes invalidate the Anthropic prompt cache prefix and drop cache hit rate from ~90% to near 0 for the rest of the session
type: semantic
originSessionId: a7b6874f-5fdb-4bd2-b3e2-d17404f8491b
---
Anthropic's prompt cache keys on the full prefix: system prompt + tool definitions + conversation history. Any change to the tool list (add/remove MCP server, toggle plugin, install plugin) or the model (`/model` switch) invalidates the cached prefix and forces a full re-read at 1.25× write cost on every subsequent turn.

Practical implication: lock tools and model at session start. If a config change is required, finish the turn, `/handoff` if needed, `/clear`, then make the change in a fresh session. One cache-write cost beats paying it on every turn.

Codified in `~/.claude-setup/rules/cache-discipline.md`.

---

## Timeline

- **2026-04-26** — [research] Discovered via Paweł Huryn's article "Claude Code's Limits Are Generous. The Problem Is Your Harness." (Source: research — https://x.com/PawelHuryn/status/2048170309396926577). Author claims this is the single biggest token-waste lever, larger than verbose tool output or 1M context. Codified as global rule `cache-discipline.md`.
