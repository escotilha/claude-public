---
name: mary-openclaw-operational-fixes
description: OpenClaw (Mary) on VPS — hard-won operational fixes from 2026-04-13 and 2026-04-18 sessions. Gateway runs as mary system user under /home/mary/.
type: project
originSessionId: e01f4daf-fb00-4f3d-9ef2-152df918fbe8
---

OpenClaw gateway on VPS requires specific configuration to work. These are the hard-won lessons from debugging sessions.

**Root causes of outage (2026-04-13):**

1. **memory-core plugin blocks gateway readiness** — uses OpenAI embeddings (dead billing), fails with 429, blocks Discord from completing initialization. Fix: disable memory-core in plugins.entries + remove from plugins.allow + disable session-memory hook.

2. **Discord groupPolicy defaults to "allowlist"** — without a `channels.discord.guilds` block, ALL guild channel messages are silently dropped. DMs work but channels don't. Fix: set `groupPolicy: "open"` or configure explicit guild allowlist.

3. **Claude CLI refuses bypassPermissions as root** — OpenClaw's claude-cli backend ALWAYS injects `--permission-mode bypassPermissions` (hardcoded in `cli-shared-*.js → normalizeClaudePermissionArgs`). Claude CLI rejects this flag as root. Fix (2026-04-18): migrated gateway to `mary` system user. Running as root also blocks legacy `--dangerously-skip-permissions`.

4. **WhatsApp allowFrom must match the SENDER's number** — not Mary's number. Mary is paired to +5511992241891, Pierre sends from +5511945661111.

5. **WhatsApp creds.json.bak auto-restore** — OpenClaw restores old credentials from backup on startup. Must delete ALL files in `credentials/whatsapp/default/` when re-pairing.

6. **Deprecated free models** — `openrouter/qwen/qwen3.6-plus:free` is dead. Gemini 2.5 Flash hits rate limits. Don't rely on free models for agent responsiveness.

**Current working config (2026-04-18):**

- Gateway runs as `mary` system user under `/home/mary/.openclaw/`
- mary: `claude-cli/claude-opus-4-6` (Max plan, FREE)
- bella: `claude-cli/claude-opus-4-7` (Max plan, FREE — Contably CTO)
- julia: `claude-cli/claude-sonnet-4-6` (Max plan, FREE — Contably PM)
- rex, cris, and the rest: `mlx/mlx-community/Qwen3.5-35B-A3B-4bit` (local Mac Mini)
- Discord: `groupPolicy: "open"`, bot @Mary
- WhatsApp: `dmPolicy: "allowlist"`, `allowFrom: ["+5511945661111"]`, paired to +5511992241891
- memory-core: disabled
- session-memory hook: disabled

**Config file locations (VPS):**

- Config: `/home/mary/.openclaw/openclaw.json`
- Env: `/home/mary/.openclaw/.env` (symlinked from `/opt/openclaw/.env`)
- WhatsApp creds: `/home/mary/.openclaw/credentials/whatsapp/default/`
- Discord allowFrom: `/home/mary/.openclaw/credentials/discord-default-allowFrom.json`
- Claude credential: `/home/mary/.claude/.credentials.json`
- Service: `/etc/systemd/system/openclaw-gateway.service` (system-wide, User=mary)
- Drop-in with ANTHROPIC_API_KEY: `/etc/systemd/system/openclaw-gateway.service.d/resilience.conf`
- Logs: `/tmp/openclaw/` + journald `-u openclaw-gateway.service`
- Rollback snapshot (pre-mary-migration): `/root/mary-snapshot-20260418-0720.tar.gz`

**Critical rules:**

- Gateway MUST run as non-root user for claude-cli backend. Never revert to root.
- Never add unknown config keys — OpenClaw rejects them and crashes.
- Don't restart the gateway more than 2-3x in quick succession — Discord rate-limits (HTTP 428).
- Always check both journald AND file log — they show different things.
- `openclaw channels status` is the quickest way to check if channels are receiving messages (`in:Xm ago`).
- `openclaw doctor` shows Discord connection health.
- Use `ssh mary@vps` for config inspection + `openclaw` CLI commands. Use `ssh root@vps` only for systemd changes.

**Useful commands:**

- Test claude-cli path: `ssh mary@vps "openclaw agent --agent mary -m 'Reply ONLINE'"`
- Verify models: `ssh mary@vps "openclaw models list"`
- Tail logs for claude-cli: `ssh root@vps "journalctl -u openclaw-gateway -f | grep claude-cli"`
- Batch config change: `openclaw config set --batch-file /dev/stdin --strict-json <<< '[{...}]'`

---

## Timeline

- **2026-04-13** — [failure] Full-day outage. Gateway was down since March 31 (missing JS module). Config had been clobbered by onboard wizard. 6 root causes discovered and fixed. (Source: session — debugging)
- **2026-04-18** — [implementation] Migrated gateway from root to mary user. Unlocked Max plan routing via claude-cli/claude-opus-4-6 for 4 Opus agents (mary/bella/rex/cris). End-to-end verified. Root cause of "can't use Max plan" was Claude CLI refusing bypassPermissions as root. (Source: session — root-cause investigation + full migration)
