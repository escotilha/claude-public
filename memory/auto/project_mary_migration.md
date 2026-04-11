---
name: project-mary-openclaw-migration
description: Mary (OpenClaw) replaced Claudia on VPS — 6 plugins, 10 agents, 14 cron jobs, deployment paths, model routing
type: project
originSessionId: 7a5b17fc-fb02-4fe0-8040-d3d479bd1129
---

Claudia fully replaced by Mary (OpenClaw v2026.4.10) on VPS as of 2026-04-11.

**Deployment:**

- OpenClaw installed at `/opt/mary` (git tag v2026.4.10)
- Config: `/root/.openclaw/openclaw.json`
- Env: `/root/.openclaw/.env`
- Agent workspaces: `/root/.openclaw/workspace-{agentId}/`
- Extensions: `/root/.openclaw/extensions/` (mary-memory, mary-dispatch)
- Service: `mary.service` (systemd, enabled on boot)
- Gateway port: 18789 (LAN bind via Tailscale)
- Control UI: `http://100.77.51.51:18789/` (needs HTTPS for full auth)

**Gateway plugins (6):** discord, mary-memory, mary-dispatch, slack, telegram, whatsapp

**Working channels:** Discord (12 channels, 8 agents routed), Slack (nuvini + contably), Telegram
**Not working:** WhatsApp (needs QR pairing), Voice (not configured)

**Custom plugins:**

- `mary-memory` — pgvector KG (4-strategy retrieval + RRF), fact extraction (LLM + heuristic), periodic nudge, session consolidation, daily maintenance cron. At `/root/.openclaw/extensions/mary-memory/`
- `mary-dispatch` — coding task queue → `claude -p`, intent detection, project resolution, 4 agent tools (dispatch, dispatch_intent, dispatch_status, skills_sync), 5min cron processor. At `/root/.openclaw/extensions/mary-dispatch/`

**Plugin security:** Both plugins flagged by OpenClaw security audit (env + network = "credential harvesting"). Bypassed via `plugins.allow: ["mary-memory", "mary-dispatch"]` + `plugins.entries.{id}.enabled: true`.

**Model routing (FINAL — $0/month total):**

- mary (claudia): `claude-cli/claude-sonnet-4-6` — Max plan via CLI backend, FREE
- rex: `claude-cli/claude-opus-4-6` — Max plan via CLI backend, FREE
- marco: `openrouter/qwen/qwen3-coder-480b-a35b:free` — FREE
- swarmy/bella/buzz/north: `openrouter/qwen/qwen3.6-plus:free` — FREE
- julia/arnold/cris: `openrouter/google/gemma-4-26b-a4b-it:free` — FREE

**Token sync:** macOS launchd plist at `~/Library/LaunchAgents/com.mary.token-sync.plist` copies OAuth from Mac keychain to VPS every 6 hours. Script at `/tmp/sync-claude-token.sh`.

**14 cron jobs configured** in `/root/.openclaw/cron/jobs.json`

**Remaining work:**

1. WhatsApp QR pairing (tomorrow morning — run `openclaw channels login --channel whatsapp` on VPS)
2. OpenAI billing fix → switch agents to GPT-4.1-mini for cost savings
3. Email triage as standing order

**Claudia: WIPED** from VPS on 2026-04-11. /opt/claudia deleted, claudia.service removed. No rollback possible.

**Why:** Claudia was 27k LOC solo-maintained with 47% fix commits and 5 features disabled for VPS destabilization. Mary inherits all agent personalities, memories, and 43 skills while dropping 22 dangerous scheduled tasks. OpenClaw provides 35+ channels, native apps, plugin SDK, and community maintenance.

**How to apply:** Any mention of Mary means the OpenClaw install on VPS. SSH to `root@100.77.51.51` or `root@vps`. Claudia is archived at `/opt/claudia` (stopped, disabled).

---

## Timeline

- **2026-04-11** — [implementation] Full migration: Claudia → Mary (OpenClaw). All 4 phases complete. 6 plugins loaded. (Source: session — deep-plan + first-principles + implementation)
- **2026-04-11** — [implementation] Memory plugin (mary-memory) loaded via ~/.openclaw/extensions/ discovery path. (Source: implementation — plugin SDK debugging)
- **2026-04-11** — [implementation] Dispatch plugin (mary-dispatch) deployed with 4 agent tools + cron processor. (Source: implementation — background agent build)
