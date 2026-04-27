---
name: mary-openclaw-operational-fixes
description: OpenClaw on VPS — gateway runs as `openclaw` user, routes through OpenRouter (post-2026-04-27). Hard-won operational fixes from multiple debug sessions.
type: project
originSessionId: e01f4daf-fb00-4f3d-9ef2-152df918fbe8
---

OpenClaw gateway on VPS Contabo (`vps-root`, `100.77.51.51`).

## Current operational state (as of 2026-04-27)

- Runs as `openclaw` system user (NOT `mary` — that user no longer exists; only stale path refs remain)
- State dir: `/home/openclaw/.openclaw/`
- systemd unit: `openclaw-gateway.service` — User=openclaw, port 3001 loopback, sandbox flag set
- EnvironmentFile (authoritative): `/opt/openclaw/.env`
- Inference path: **OpenRouter** (NOT Max-plan claude-cli — that auth is dead and `hasAvailableSubscription=null`)
- Embedded harness: `pi` (NOT `claude-cli`)
- Primary model: `openrouter/anthropic/claude-sonnet-4.6`
- Fallback chain: `claude-opus-4.6` → `qwen/qwen3-coder-plus` → `openai/gpt-oss-20b:free`
- Agents on OpenRouter: mary, julia, bella + default (4 agents migrated 2026-04-27)
- Agents on MLX (Mac Mini Qwen3.5-35B): buzz, marco, arnold, rex, north, swarmy, cris, agentwave
- Channels active: Discord (@Mary), WhatsApp (+5511992241891), Telegram, Slack (Nuvini + Contably), ElevenLabs voice
- Memory backend: local Postgres (KG_PG_*)

## Stale references to clean up (non-blocking)

- `/home/openclaw/.openclaw/.env` lines 5–6 still point `OPENCLAW_STATE_DIR` and `OPENCLAW_CONFIG_PATH` at `/home/mary/.openclaw/...` — runtime ignores them and falls back to `$HOME/.openclaw`, but `openclaw status` CLI crashes with EACCES on `/home/mary/.openclaw/plugin-runtime-deps/...`
- mary-dispatch plugin uses `/home/mary/.openclaw/dispatch-queue.json` — loads but the queue file never appears
- All "ssh mary@vps" guidance below is historical — the user is `openclaw`, accessed via `ssh vps-root` or sudo

## Known dead paths

- Claude CLI `--print` returns 401 Invalid auth as both root and openclaw users — OAuth identity exists but no active subscription token
- `qwen/qwen3.6-plus-preview:free`, `qwen/qwen3-235b-a22b:free`, `deepseek/deepseek-r1:free`, `deepseek/deepseek-chat-v3-0324:free`, `qwen/qwen-2.5-72b-instruct:free` — all return HTTP 404 "No endpoints found" on OpenRouter as of 2026-04-27 (preview pricing ended)
- Free models that still 200 but rate-limit hard: `google/gemma-4-31b-it:free`, `meta-llama/llama-3.3-70b-instruct:free`

## Diagnostic snippets (still useful)

**Per-agent session pin check** (for "Agent couldn't generate a response" on Discord):

```bash
ssh vps-root 'sudo -u openclaw bash -c "
  for a in mary bella julia cris rex buzz marco arnold north swarmy agentwave; do
    f=/home/openclaw/.openclaw/agents/\$a/sessions/sessions.json
    [ -f \"\$f\" ] && grep -c \"qwen3.6-plus-preview\\|:free\\|openrouter/auto\" \"\$f\" | xargs -I{} echo \"\$a: {} bad-model refs\"
  done"'
```

**Wipe per-agent sessions when a stale model pin is causing empty responses:**

```bash
for a in mary julia; do
  ssh vps-root "sudo -u openclaw bash -c \"
    cp /home/openclaw/.openclaw/agents/$a/sessions/sessions.json \\
       /home/openclaw/.openclaw/agents/$a/sessions/sessions.json.bak-\\\$(date +%Y%m%d-%H%M%S) && \\
    echo '{}' > /home/openclaw/.openclaw/agents/$a/sessions/sessions.json && \\
    chmod 600 /home/openclaw/.openclaw/agents/$a/sessions/sessions.json\""
done
```

**Live inference logs:**

```bash
ssh vps-root 'journalctl -u openclaw-gateway -f | grep -E "agent model|provider=|FailoverError|cli exec|model-fallback"'
```

**Validate OpenRouter key:**

```bash
ssh vps-root 'KEY=$(grep "^OPENROUTER_API_KEY=" /opt/openclaw/.env | cut -d= -f2-); \
  curl -s -H "Authorization: Bearer $KEY" https://openrouter.ai/api/v1/auth/key | jq .data.usage'
```

## Critical rules (still apply)

- Gateway must run as non-root (was migrated off root 2026-04-18 — that lesson stands)
- Never add unknown config keys — OpenClaw rejects them and crashes
- Don't restart >2-3x in quick succession — Discord rate-limits (HTTP 428)
- Check BOTH journald AND `/tmp/openclaw-993/openclaw-*.log`
- TWO sessions.json registries exist: top-level `agents/main/sessions/sessions.json` AND per-agent `agents/<id>/sessions/sessions.json`. The per-agent one is load-bearing for channel→model pins.

## Config file locations (current)

- Config: `/home/openclaw/.openclaw/openclaw.json` (697 lines)
- Provider models: `models.providers.openrouter` (correct baseUrl is `https://openrouter.ai/api/v1` — NOT `/v1`)
- Auth profiles: `/home/openclaw/.openclaw/agents/main/agent/auth-profiles.json` (now stripped of openrouter:default after 2026-04-23)
- Models registry: `/home/openclaw/.openclaw/agents/main/agent/models.json`
- Service: `/etc/systemd/system/openclaw-gateway.service` (User=openclaw, Group=openclaw)
- Drop-in: `/etc/systemd/system/openclaw-gateway.service.d/override.conf` (`IS_SANDBOX=1`)
- EnvironmentFile: `/opt/openclaw/.env` (root:openclaw 0640)
- Backups: `/home/openclaw/.openclaw/openclaw.json.bak-*`, `/opt/openclaw/.env.bak-*`

## Open items

- Fix `/home/mary/...` references in `/home/openclaw/.openclaw/.env` lines 5-6 and mary-dispatch plugin path — non-blocking but breaks `openclaw status`
- Confirm end-to-end inference: send a Discord/WhatsApp message and verify a turn lands via OpenRouter (config validated 2026-04-27, but no real channel message has been observed routing through the new path yet)
- OpenClaw still on 2026.4.24; check for newer versions
- Memory entry `reference_openrouter_api.md` updated 2026-04-27 with current key locations and validated model list

---

## Timeline

- **2026-04-27** — [implementation] Migrated entire inference path from dead claude-cli (Max plan auth expired) to OpenRouter. Patched `openclaw.json`: fixed broken `https://openrouter.ai/v1` → `/api/v1`, replaced 5 dead "free preview" model IDs with 4 working ones, switched embedded harness `claude-cli` → `pi`, remapped 4 agents (mary/julia/bella + default) from `claude-cli/*` to `openrouter/anthropic/*`. Uncommented `OPENROUTER_API_KEY` in `/opt/openclaw/.env`. Service ready in 11.4s, log confirmed `[gateway] agent model: openrouter/anthropic/claude-sonnet-4.6`. (Source: implementation — /opt/openclaw/.env, /home/openclaw/.openclaw/openclaw.json)
- **2026-04-27** — [failure] Discovered `mary` user no longer exists on VPS (migrated to `openclaw` system user at some point); stale `/home/mary/...` paths in env still point at the old home. Most cause warnings, not crashes — runtime falls back to `$HOME` which now resolves to `/home/openclaw`. `openclaw status` CLI does crash with EACCES because it honors the literal env var. (Source: failure — `id mary: no such user`; `openclaw status` permission error)
- **2026-04-27** — [failure] OpenRouter "free preview" strategy from April 2026 has fully expired — `qwen/qwen3.6-plus-preview:free` and 4 other dead model IDs return 404. Free-tier reliability for production is broken; paid models or BYOK only. (Source: failure — direct curl validation against OpenRouter API)
- **2026-04-23** — [failure→fix] Full Discord outage on mary channel ("Agent couldn't generate a response"). Root cause: per-agent `sessions.json` had Discord channel pinned to dead `openrouter/qwen/qwen3.6-plus-preview:free`. Fixed via 10-step sequence: clean auth profile, kill paid+free API keys in env AND systemd drop-ins, remove openrouter profile, wipe per-agent sessions.json for mary+julia, restart. End-to-end verified via Discord — response in 3.8s from `claude-opus-4-7` via claude-cli; `cleared=ANTHROPIC_API_KEY` + `rate_limit_event.five_hour` confirmed Max-plan routing. **Key lesson:** TWO sessions.json paths exist; per-agent is the load-bearing registry. (Source: failure — Discord screenshots + log capture + session file inspection)
- **2026-04-18** — [implementation] Migrated gateway from root to non-root user. Unlocked Max-plan routing via claude-cli/claude-opus-4-6 for 4 Opus agents. Root cause of "can't use Max plan as root" was Claude CLI refusing `bypassPermissions` flag for root. (Source: session — root-cause investigation + full migration)
- **2026-04-13** — [failure] Full-day outage. Gateway down since March 31 (missing JS module). Config clobbered by onboard wizard. Six root causes: memory-core blocking readiness (OpenAI 429), Discord groupPolicy=allowlist silently dropping channel messages, claude-cli refusing bypassPermissions as root, WhatsApp allowFrom needing sender's number not Mary's, WhatsApp creds.json.bak auto-restoring, deprecated free models. (Source: session — debugging)

Use count: 4
