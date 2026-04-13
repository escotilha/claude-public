---
name: mary-openclaw-operational-fixes
description: OpenClaw (Mary) on VPS — critical operational knowledge from 2026-04-13 debugging session
type: project
originSessionId: e01f4daf-fb00-4f3d-9ef2-152df918fbe8
---

OpenClaw gateway on VPS requires specific configuration to work. These are the hard-won lessons from a full-day debugging session.

**Root causes of outage (2026-04-13):**

1. **memory-core plugin blocks gateway readiness** — uses OpenAI embeddings (dead billing), fails with 429, blocks Discord from completing initialization. Fix: disable memory-core in plugins.entries + remove from plugins.allow + disable session-memory hook.

2. **Discord groupPolicy defaults to "allowlist"** — without a `channels.discord.guilds` block, ALL guild channel messages are silently dropped. DMs work but channels don't. Fix: set `groupPolicy: "open"` or configure explicit guild allowlist.

3. **claude-cli/ models don't work as root** — `--dangerously-skip-permissions` is blocked when running as root. The gateway runs as root via systemd. Fix: use `anthropic/` API models instead of `claude-cli/`.

4. **WhatsApp allowFrom must match the SENDER's number** — not Mary's number. Mary is paired to +5511992241891, Pierre sends from +5511945661111.

5. **WhatsApp creds.json.bak auto-restore** — OpenClaw restores old credentials from backup on startup. Must delete ALL files in credentials/whatsapp/default/ when re-pairing.

6. **Deprecated free models** — `openrouter/qwen/qwen3.6-plus:free` is dead. Gemini 2.5 Flash hits rate limits. Don't rely on free models for agent responsiveness.

**Current working config (2026-04-13):**

- Mary/Rex/Bella: `anthropic/claude-opus-4-6` (API)
- All others: `anthropic/claude-sonnet-4-6` (API)
- Discord: `groupPolicy: "open"`
- WhatsApp: `dmPolicy: "allowlist"`, `allowFrom: ["+5511945661111"]`
- WhatsApp paired to: `+5511992241891`
- memory-core: disabled
- session-memory hook: disabled

**Config file locations:**

- Config: `/root/.openclaw/openclaw.json`
- Env: `/root/.openclaw/.env`
- WhatsApp creds: `/root/.openclaw/credentials/whatsapp/default/`
- Discord allowFrom: `/root/.openclaw/credentials/discord-default-allowFrom.json`
- Service: `~/.config/systemd/user/openclaw-gateway.service`
- Logs: `/tmp/openclaw/openclaw-2026-04-13.log`

**Critical rules:**

- Never add unknown config keys — OpenClaw rejects them and crashes
- Don't restart the gateway more than 2-3x in quick succession — Discord rate-limits (HTTP 428)
- Always check both journald AND file log — they show different things
- `openclaw channels status` is the quickest way to check if channels are receiving messages (`in:Xm ago`)
- `openclaw doctor` shows Discord connection health

---

## Timeline

- **2026-04-13** — [failure] Full-day outage. Gateway was down since March 31 (missing JS module). Config had been clobbered by onboard wizard. Multiple root causes discovered and fixed. (Source: session — debugging)
