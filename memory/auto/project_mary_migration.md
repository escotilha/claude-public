---
name: project-mary-openclaw-migration
description: Mary (OpenClaw) replaced Claudia on VPS — deployment state, config paths, deferred work, model routing
type: project
originSessionId: 7a5b17fc-fb02-4fe0-8040-d3d479bd1129
---

Claudia fully replaced by Mary (OpenClaw v2026.4.10) on VPS as of 2026-04-11.

**Deployment:**

- OpenClaw installed at `/opt/mary` (git tag v2026.4.10)
- Config: `/root/.openclaw/openclaw.json`
- Env: `/root/.openclaw/.env`
- Agent workspaces: `/root/.openclaw/workspace-{agentId}/`
- Service: `mary.service` (systemd, enabled on boot)
- Gateway port: 18789 (LAN bind via Tailscale)
- Dashboard: `http://100.77.51.51:18789/` (needs HTTPS for full Control UI)

**Working channels:** Discord (12 channels resolved), Slack (nuvini + contably), Telegram
**Not working:** WhatsApp (needs QR pairing), Voice (not configured yet)

**Model routing (temporary — OpenAI billing inactive):**
All agents on `anthropic/claude-sonnet-4-6` except:

- rex: `anthropic/claude-opus-4-6` (security audits)
- buzz/bella/north: `openrouter/qwen/qwen3.6-plus:free`

**When OpenAI billing is fixed, switch claudia/julia/arnold/cris to `openai/gpt-4.1-mini`.**

**14 cron jobs configured** (daily briefing, north star, eod summary, competitive pulse, etc.)

**Deferred work (next session):**

1. Memory Context Engine plugin — files at `/opt/mary/plugins/mary-memory/` (10 files, ~62KB). SDK integration needs debugging (plugin discovery path).
2. Dispatch queue plugin — not started.
3. OpenAI billing fix → switch agents back to GPT-4.1-mini for cost savings.
4. WhatsApp QR pairing.
5. Dashboard port (or use OpenClaw's built-in Control UI).

**Why:** Claudia was 27k LOC solo-maintained with 47% fix commits and 5 features disabled for VPS destabilization. Mary inherits all agent personalities, memories, and 43 skills while dropping 22 dangerous scheduled tasks. OpenClaw provides 35+ channels, native apps, plugin SDK, and community maintenance.

**How to apply:** Any mention of Mary means the OpenClaw install on VPS. SSH to `root@100.77.51.51` or `root@vps`. Claudia is archived at `/opt/claudia` (stopped, disabled).

---

## Timeline

- **2026-04-11** — [implementation] Full migration: Claudia → Mary (OpenClaw). Phase 1 complete. (Source: session — deep-plan + first-principles analysis + implementation)
