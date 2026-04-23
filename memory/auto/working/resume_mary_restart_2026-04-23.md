---
name: resume-mary-restart-2026-04-23
description: Mary restart COMPLETED 2026-04-23 03:40 — Discord verified end-to-end on Max plan via claude-cli
type: project
originSessionId: 8b063cf6-6ed4-43d3-937a-d793abba6893
---
**Status:** ✅ RESOLVED. Mary responds on Discord via Max plan (claude-opus-4-7) at zero paid-API cost. Verified 2026-04-23 03:40 local.

**For the full operational-fixes writeup (10-step recipe + diagnostic one-liner + signals to confirm Max plan routing):** see `projects/project_mary_openclaw_fixes.md` — the 2026-04-23 section.

**Plan doc:** `/Volumes/AI/Code/mary-restart-plan-2026-04-23.md` (superseded by operational-fixes update; retain for timeline).

## What the morning session actually did (2026-04-23 02:00 → 03:40 local)

Root cause turned out NOT to be any of the anticipated gaps. Was Passo 9 of the guide at a path I missed: per-agent `sessions.json` (not top-level) had Discord channel pinned to dead `openrouter/qwen/qwen3.6-plus-preview:free`.

Sequence that worked:

1. Confirmed auth profile clean (no apiKey/key) → `providersWithOAuth = ["claude-cli (1)"]`
2. Stripped dead qwen from `defaults.fallbacks` + allowlist
3. Disabled ANTHROPIC_API_KEY + OPENROUTER_API_KEY + ANTHROPIC_BASE_URL in `/opt/openclaw/.env`
4. Disabled systemd drop-in `resilience.conf` (was re-injecting ANTHROPIC_API_KEY)
5. Removed `openrouter:default` from auth-profiles.json
6. **Wiped per-agent sessions.json for mary (1.9 MB) and julia (had 2 qwen refs)** ← THE FIX
7. Restart → Discord `hi` got response in 3.8s from `claude-opus-4-7`, log confirmed `cli exec: provider=claude-cli` + `cleared=ANTHROPIC_API_KEY` + `rate_limit_event.five_hour`

## Open items (not blockers, do after sleeping)

- Upgrade OpenClaw 2026.4.16 → 2026.4.20 (4 versions behind; upstream has directly relevant fixes including `#70187 fix: clear embedded runs before lifecycle end`)
- Opus-4-7 shows `configured,missing` cosmetically in `openclaw models list` — investigate after upgrade
- Remove debug env flags (`OPENCLAW_CLI_BACKEND_LOG_OUTPUT`, `OPENCLAW_CLAUDE_CLI_LOG_OUTPUT`) once stable for 1-2 days
- Delete `resilience.conf.DISABLED-20260423-*` after 1 week of stable operation
- MLX stack audit (Phase 2 of original plan) — never executed, still pending
- Memory reconciliation (stale `project_claudia_migration_complete.md` + `project:claudia-router`) — still pending

## Key learning for future

**There are TWO sessions.json registries in OpenClaw.** The guide mentions "sessions.json" generically. In practice:

- `/home/mary/.openclaw/agents/main/sessions/sessions.json` — top-level, often small/empty
- `/home/mary/.openclaw/agents/<agentId>/sessions/sessions.json` — PER-AGENT, ~2 MB, this is where channel→model pins live

When sticky fallbacks strike (Discord works on cli path but not on channel path, for example), you MUST wipe the per-agent file. Wiping only the top-level one does nothing.

## Timeline

- **2026-04-23 03:00** — [implementation] SSH config + token sync + functional test from Mac Mini. VPS credential refreshed. (Source: session — overnight prep)
- **2026-04-23 03:05** — [failure] User reported Discord still returning "Agent couldn't generate a response" after prep. Gateway active, direct CLI path working, but Discord-triggered turns failing with `[agent/embedded] incomplete turn detected: stopReason=stop payloads=0`.
- **2026-04-23 03:05-03:40** — [investigation→fix] ~35 min debug. Inspected session jsonl files, found `"provider":"openrouter","model":"qwen/qwen3.6-plus-preview:free"` was being used despite config saying `claude-cli/claude-opus-4-6`. Located per-agent sessions.json with pinned dead model. Full 10-step fix applied. Verified end-to-end via Discord: `"model":"claude-opus-4-7"`, `rate_limit_event.five_hour`, `cleared=ANTHROPIC_API_KEY`. Mary responded "Hey Pierre. What's up?" in 3.8s. (Source: failure — Discord screenshots + log capture + session file grep)
