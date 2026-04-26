# Cache Discipline (Lock Tools & Model at Session Start)

## The rule

**Once a session starts, do not change the tool list or the model.** Both invalidate the prompt cache prefix and force a full re-read at 1.25× write cost for the rest of the session.

Specifically, never do these mid-session:

1. **Add or remove an MCP server** — any change to the MCP config triggers a tool-list change on the next turn.
2. **Toggle a plugin on/off** that contributes tools.
3. **Run `/model`** to switch between Opus / Sonnet / Haiku in the same session.
4. **Edit `~/.claude/settings.json` `permissions` or `enabledMcpjsonServers`** while the session is live.
5. **Install/uninstall a Claude Code plugin** mid-session.

If you need any of the above, **finish the current turn, run `/handoff` (if context is non-trivial), `/clear`, then make the change, then start a fresh session.** That fresh session pays one cache-write cost; the alternative pays it on every subsequent turn.

## Why this matters

The Anthropic prompt cache keys on the full prefix: system prompt + tool definitions + conversation history. Changing the tool list rewrites the prefix from the top, so every cached block downstream is invalidated. Cache hit rate drops from ~90% to near 0 for the rest of the session. On a long agentic session this is the single most expensive failure mode — more than verbose tool output, more than 1M context, more than wrong model choice.

Source: Paweł Huryn, "Claude Code's Limits Are Generous. The Problem Is Your Harness." (2026-04-25). Confirmed by Anthropic prompt-cache docs — tool definitions are part of the cached prefix.

## What's safe to change mid-session

- **Skills** (loading via the Skill tool doesn't change the tool list — skill content loads inside the existing tool envelope)
- **CLAUDE.md / project rules** (these are conversation context, not the cached system prefix)
- **Memory files** in `~/.claude-setup/memory/` (read-only context, not cached as tools)
- **Working files / code edits** (obviously)
- **Spawning subagents** (subagents are isolated sessions with their own caches)

## When to break this rule

Only when the cost of restarting the session exceeds the cost of the cache miss. Examples:

- A multi-hour debug session where you've built up irreplaceable context and need one specific MCP server for the next 5 minutes — pay the cache miss, finish, accept the cost.
- A user explicitly asks for a model switch and is aware of the tradeoff.

In both cases, **announce the cache impact** before doing it: "Switching to Sonnet — this invalidates the prompt cache for the rest of this session." Then proceed.

## Pre-flight check (start of session)

Before starting a long agentic session (`/ship`, `/parallel-dev`, `/qa-cycle`, `/cto` swarm), verify:

- The right model is already selected (check the statusline)
- All MCP servers needed for the task are enabled
- All plugins needed are loaded
- `/model` will not be needed mid-flight

If any of these are wrong, fix them now, then start the agentic session. Switching them after kickoff costs more than the 30 seconds it takes to verify upfront.

## Relationship to other rules

- **Subagent spawn caches are separate** (5m TTL, see model-tier-strategy.md). The orchestrator session's cache is what this rule protects.
- **`/handoff` chain** preserves work across sessions when the only way to fix a configuration is to restart. Use it freely — restarting is cheap relative to a broken cache.
- **1M context + late autocompact** (see settings.json env vars `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` and `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80`) is a complementary lever — it controls *when* the cache prefix grows, this rule controls *whether* it gets invalidated.
