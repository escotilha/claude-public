---
name: project-mary-openclaw-migration
description: Mary (OpenClaw) on VPS — runs as mary system user under /home/mary, Max plan routing via claude-cli, config paths, model routing
type: project
originSessionId: 7a5b17fc-fb02-4fe0-8040-d3d479bd1129
---

Mary (OpenClaw) is the multi-channel agent runtime on VPS that replaced Claudia on 2026-04-11. Migrated from root to mary system user on 2026-04-18 to unlock Max plan routing via claude-cli.

**Current runtime (as of 2026-04-18):**

- System user: `mary` (uid 1006)
- Home: `/home/mary`
- State dir: `/home/mary/.openclaw/`
- Claude CLI credential: `/home/mary/.claude/.credentials.json` (synced from Mac keychain every 6h)
- Service: `openclaw-gateway.service` (system-wide, `User=mary, Group=mary`)
- Gateway port: 3001 (bind loopback via Tailscale)
- SSH access: `ssh mary@vps` works with Pierre's SSH key

**Why the migration:** Claude CLI refuses `--permission-mode bypassPermissions` (and legacy `--dangerously-skip-permissions`) when running as root. OpenClaw always injects that flag for the `claude-cli` backend — hardcoded, non-configurable. Running as non-root user was the only way to unlock Max plan routing.

**Model routing (2026-04-18):**

- mary/bella/rex/cris: `claude-cli/claude-opus-4-6` — Max plan via Claude CLI, FREE
- buzz/marco/julia/arnold/north/swarmy/agentwave: `mlx/mlx-community/Qwen3.5-35B-A3B-4bit` (local Mac Mini)
- Fallback chain: mlx → openrouter/qwen3.6-plus:free → openrouter/deepseek:free → anthropic/sonnet (paid)

**Gateway plugins (6):** discord, mary-memory, mary-dispatch, slack, telegram, whatsapp

**Working channels:** Discord (12 channels, 8 agents routed, bot @Mary), Slack (nuvini + contably), Telegram, WhatsApp (paired to +5511992241891, allowlist: +5511945661111)

**Custom plugins:**

- `mary-memory` — pgvector KG (4-strategy retrieval + RRF), fact extraction (LLM + heuristic), periodic nudge, session consolidation, daily maintenance cron. At `/home/mary/.openclaw/extensions/mary-memory/`
- `mary-dispatch` — coding task queue → `claude -p`, intent detection, project resolution, 4 agent tools, 5-min cron processor. At `/home/mary/.openclaw/extensions/mary-dispatch/`

**Token sync:** launchd plist `~/Library/LaunchAgents/com.mary.token-sync.plist` runs `/Users/ps/.claude-setup/tools/sync-claude-token.sh` every 6h. Pushes Mac keychain credential to `mary@vps:/home/mary/.claude/.credentials.json`. Log at `/tmp/mary-token-sync.log`.

**Built-in memory disabled:** `memory-core` and `session-memory` hook disabled in openclaw.json (we use mary-memory). Prevents OpenAI embedding errors from inactive account.

**Config file locations (on VPS):**

- State dir: `/home/mary/.openclaw/`
- Config: `/home/mary/.openclaw/openclaw.json`
- Env: `/home/mary/.openclaw/.env` (symlinked from `/opt/openclaw/.env`)
- Secrets env: `/opt/openclaw/.env.secrets` (0 bytes, unused)
- Systemd unit: `/etc/systemd/system/openclaw-gateway.service`
- Drop-in (has ANTHROPIC_API_KEY): `/etc/systemd/system/openclaw-gateway.service.d/resilience.conf`
- Pre-migration snapshot: `/root/mary-snapshot-20260418-0720.tar.gz` (172M, full rollback)

**Claudia: WIPED** from VPS 2026-04-11. /opt/claudia deleted. No rollback.

**How to apply:** Any mention of Mary means OpenClaw running as mary user on VPS. SSH as `mary@vps` for everyday ops, `root@vps` for systemd changes. Never `root@vps` for model testing — credential is at `/home/mary/.claude/`, not `/root/.claude/` (that path no longer exists).

---

## Timeline

- **2026-04-11** — [implementation] Full migration: Claudia → Mary (OpenClaw). All 4 phases complete. 6 plugins loaded. (Source: session — deep-plan + first-principles + implementation)
- **2026-04-13** — [failure] Full-day outage. 6 root causes including memory-core blocker, Discord groupPolicy default, WhatsApp creds auto-restore. (Source: session — debugging)
- **2026-04-18** — [implementation] Migrated gateway from root to mary system user to unlock Max plan via claude-cli. Moved /root/.openclaw → /home/mary/.openclaw (267M), /root/.claude → /home/mary/.claude (335M). Flipped mary/bella/rex/cris to claude-cli/claude-opus-4-6. Fixed stale token-sync script (was at /tmp/, now at ~/.claude-setup/tools/). End-to-end verified: mary agent returns "ONLINE" via claude-cli/opus with zero fallback. (Source: session — user reported Max plan broken, root-cause was Claude CLI refusing bypassPermissions as root)
