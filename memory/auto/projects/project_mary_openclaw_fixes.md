---
name: mary-openclaw-operational-fixes
description: OpenClaw (Mary) on VPS — hard-won operational fixes from 2026-04-13 and 2026-04-18 sessions. Gateway runs as mary system user under /home/mary/.
type: project
originSessionId: e01f4daf-fb00-4f3d-9ef2-152df918fbe8
---

OpenClaw gateway on VPS requires specific configuration to work. These are the hard-won lessons from debugging sessions.

## Root cause of outage (2026-04-23) — "Agent couldn't generate a response" on Discord

**Symptom:** Discord channel #mary returns "⚠️ Agent couldn't generate a response. Please try again." for every message. Direct `openclaw agent --agent mary -m '...'` works fine. Logs show `[agent/embedded] incomplete turn detected: stopReason=stop payloads=0`. Parallel cron failures across 7+ jobs with same signature.

**Root cause:** The per-agent session registry at `/home/mary/.openclaw/agents/<agentId>/sessions/sessions.json` (NOT the top-level `agents/main/sessions/sessions.json`) had the Discord channel pinned to `"model": "qwen/qwen3.6-plus-preview:free"`. That OpenRouter free model returns empty content. Every Discord turn for mary dispatched to the dead model → empty payload → surfaced as "couldn't generate a response".

This is the guide's "Passo 9" failure mode — but at a path most people miss. There are TWO sessions.json registries in OpenClaw:

- `/home/mary/.openclaw/agents/main/sessions/sessions.json` — top-level, usually small/empty
- `/home/mary/.openclaw/agents/<agentId>/sessions/sessions.json` — PER-AGENT, this is where the channel→model pin actually lives (~2 MB for active agents)

When sticky fallbacks strike, you MUST wipe the per-agent file, not just the top-level one.

**Diagnostic one-liner** to find pinned-to-bad-model sessions:
```bash
ssh mary@vps 'for a in mary bella julia cris rex buzz marco arnold north swarmy; do \
  f=/home/mary/.openclaw/agents/$a/sessions/sessions.json; \
  [ -f "$f" ] && grep -c "qwen3.6-plus-preview\|:free\|openrouter/auto" "$f" | xargs -I{} echo "$a: {} bad-model refs"; \
done'
```

**Fix sequence (10 steps, ~5 min, 2026-04-23 verified):**

1. Confirm auth profile is clean (no `apiKey`/`key` fields — per updated guide):
   ```bash
   ssh mary@vps 'jq ".profiles[\"anthropic:claude-cli\"]" ~/.openclaw/agents/main/agent/auth-profiles.json'
   # expected: {"type":"oauth","provider":"claude-cli"} — no apiKey, no key
   ```

2. Verify `providersWithOAuth` includes `claude-cli`:
   ```bash
   ssh mary@vps 'openclaw models status --json 2>/dev/null | jq ".auth.providersWithOAuth"'
   # expected: ["claude-cli (1)"]
   ```

3. Strip dead fallbacks from defaults + remove from allowlist:
   ```bash
   ssh mary@vps 'jq ".agents.defaults.model.fallbacks = [] | del(.agents.defaults.models[\"openrouter/qwen/qwen3.6-plus-preview:free\"])" \
     ~/.openclaw/openclaw.json > /tmp/oc.new && mv /tmp/oc.new ~/.openclaw/openclaw.json'
   ```

4. Disable ALL paid + free API keys in `/opt/openclaw/.env` (guide Step 8):
   ```bash
   ssh root@vps 'sed -i "s/^ANTHROPIC_API_KEY=/#DISABLED_ANTHROPIC_API_KEY=/; \
     s/^ANTHROPIC_BASE_URL=/#DISABLED_ANTHROPIC_BASE_URL=/; \
     s/^OPENROUTER_API_KEY=/#DISABLED_OPENROUTER_API_KEY=/" /opt/openclaw/.env'
   ```

5. Also disable ANTHROPIC_API_KEY in any systemd drop-in (don't just trust `.env`):
   ```bash
   ssh root@vps 'ls /etc/systemd/system/openclaw-gateway.service.d/'
   # rename any drop-in injecting ANTHROPIC_API_KEY → *.conf.DISABLED-<date>
   ssh root@vps 'systemctl daemon-reload'
   ```

6. Remove `openrouter:default` profile from auth-profiles.json so router has no way to fall through:
   ```bash
   ssh mary@vps 'jq "del(.profiles[\"openrouter:default\"])" \
     ~/.openclaw/agents/main/agent/auth-profiles.json > /tmp/ap.new && \
     mv /tmp/ap.new ~/.openclaw/agents/main/agent/auth-profiles.json'
   ```

7. **THE KEY STEP** — wipe the PER-AGENT sessions.json for every agent with bad-model refs:
   ```bash
   for a in mary julia; do  # expand based on diagnostic output above
     ssh mary@vps "cp /home/mary/.openclaw/agents/$a/sessions/sessions.json \
       /home/mary/.openclaw/agents/$a/sessions/sessions.json.bak-\$(date +%Y%m%d-%H%M%S) && \
       echo '{}' > /home/mary/.openclaw/agents/$a/sessions/sessions.json && \
       chmod 600 /home/mary/.openclaw/agents/$a/sessions/sessions.json"
   done
   ```

8. Also move any per-channel .jsonl files that were created with bad models (Discord channel session files in `agents/<agentId>/sessions/<uuid>.jsonl`).

9. Restart gateway:
   ```bash
   ssh root@vps 'systemctl restart openclaw-gateway && sleep 15 && systemctl show openclaw-gateway -p ActiveState -p NRestarts'
   ```

10. Validate via Discord (not just `openclaw agent -m`) — those use different paths. Check the log:
    ```bash
    ssh root@vps 'journalctl -u openclaw-gateway --since "2min ago" | grep -E "cli exec|cleared=ANTHROPIC"'
    # expected:
    #   [agent/cli-backend] cli exec: provider=claude-cli model=opus ...
    #   cli env auth: ... cleared=ANTHROPIC_API_KEY
    ```
    Response should show `"model":"claude-opus-4-7"` in the assistant payload and `rate_limit_event` with `five_hour` window (= Max plan routing).

**Why `openclaw agent -m` works but Discord fails:** Different invocation paths. The CLI command routes directly through cli-backend with the agent's declared model. Discord goes through the channel→session→agent lookup, which consults the per-agent `sessions.json` registry for a pinned model BEFORE falling back to the agent's declared model. If that registry has a stale pin, Discord turns get dispatched to whatever model was last used successfully (even if that model is now dead).

**Cost signal (proof Max plan is active):** the assistant response includes `rate_limit_event.rateLimitType=five_hour`. That's the Max plan rate window. The paid API uses different rate limit types. Zero-cost routing confirmed when the log shows `cleared=ANTHROPIC_API_KEY` on the subprocess env.

---

## Root causes of outage (2026-04-13):

1. **memory-core plugin blocks gateway readiness** — uses OpenAI embeddings (dead billing), fails with 429, blocks Discord from completing initialization. Fix: disable memory-core in plugins.entries + remove from plugins.allow + disable session-memory hook.

2. **Discord groupPolicy defaults to "allowlist"** — without a `channels.discord.guilds` block, ALL guild channel messages are silently dropped. DMs work but channels don't. Fix: set `groupPolicy: "open"` or configure explicit guild allowlist.

3. **Claude CLI refuses bypassPermissions as root** — OpenClaw's claude-cli backend ALWAYS injects `--permission-mode bypassPermissions` (hardcoded in `cli-shared-*.js → normalizeClaudePermissionArgs`). Claude CLI rejects this flag as root. Fix (2026-04-18): migrated gateway to `mary` system user. Running as root also blocks legacy `--dangerously-skip-permissions`.

4. **WhatsApp allowFrom must match the SENDER's number** — not Mary's number. Mary is paired to +5511992241891, Pierre sends from +5511945661111.

5. **WhatsApp creds.json.bak auto-restore** — OpenClaw restores old credentials from backup on startup. Must delete ALL files in `credentials/whatsapp/default/` when re-pairing.

6. **Deprecated free models** — `openrouter/qwen/qwen3.6-plus:free` is dead. Gemini 2.5 Flash hits rate limits. Don't rely on free models for agent responsiveness.

**Current working config (2026-04-23, end-to-end Discord verified):**

- Gateway runs as `mary` system user under `/home/mary/.openclaw/`
- OpenClaw version: 2026.4.16 (4 versions behind latest 2026.4.20 — upgrade pending)
- mary: `claude-cli/claude-opus-4-6` (Max plan, FREE — flipped 2026-04-23 from opus-4-7 because of "configured,missing" cosmetic tag on 4-7; opus-4-7 actually works, just `openclaw models list` probe mislabels it)
- bella: `claude-cli/claude-opus-4-6` (Max plan, FREE — Contably CTO)
- julia: `claude-cli/claude-sonnet-4-6` (Max plan, FREE — Contably PM)
- rex, cris, and the rest: `mlx/mlx-community/Qwen3.5-35B-A3B-4bit` (local Mac Mini)
- `agents.defaults.model.primary`: `claude-cli/claude-sonnet-4-6`
- `agents.defaults.model.fallbacks`: `[]` (deliberately empty — no silent fallback to dead/paid providers)
- Discord: `groupPolicy: "allowlist"`, bot @Mary, guild 1470588045450412179 allowed
- WhatsApp: `dmPolicy: "allowlist"`, `allowFrom: ["+5511945661111"]`, paired to +5511992241891
- memory-core: disabled
- session-memory hook: disabled
- ANTHROPIC_API_KEY: DISABLED in `/opt/openclaw/.env` AND in systemd drop-in `resilience.conf.DISABLED-20260423-*`
- OPENROUTER_API_KEY: DISABLED in `/opt/openclaw/.env`
- `openrouter:default` profile: REMOVED from auth-profiles.json
- `anthropic:claude-cli` profile: `{type:"oauth", provider:"claude-cli"}` (NO apiKey, NO key — per updated guide)
- Debug env (temporary, enabled 2026-04-23 03:20): `OPENCLAW_CLI_BACKEND_LOG_OUTPUT=1`, `OPENCLAW_CLAUDE_CLI_LOG_OUTPUT=1` in `/etc/systemd/system/openclaw-gateway.service.d/debug.conf`. Verbose; remove when steady.

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
- **2026-04-23** — [failure→fix] Full Discord outage on mary channel ("Agent couldn't generate a response"). After ~2h debug: per-agent `sessions.json` had Discord channel pinned to dead `openrouter/qwen/qwen3.6-plus-preview:free`. Fixed via 10-step sequence above: clean auth profile, kill all paid+free API keys in env AND systemd drop-ins, remove openrouter profile, wipe per-agent sessions.json for mary+julia, restart. End-to-end verified via Discord: response arrived in 3.8s from `claude-opus-4-7` via claude-cli, log confirms `cleared=ANTHROPIC_API_KEY` + `rate_limit_event.five_hour` (Max plan). Documented key lesson: there are TWO sessions.json paths in OpenClaw and the per-agent one is the load-bearing registry. (Source: failure — Discord screenshots + full log capture + session file inspection)

## Open items after 2026-04-23

- OpenClaw version 2026.4.16 is 4 versions behind latest `v2026.4.20` (git remote `origin/main` on github.com/openclaw/openclaw). Upstream has `fix: clear embedded runs before lifecycle end (#70187)` and `fix: harden external auth fallback loading` which look directly relevant. Upgrade path: branch the 2 local commits ("Add learning-loop and x-reader skills" + merge), `git reset --hard v2026.4.20`, rebuild, cherry-pick skills commit back. ~15 min with rollback via `/root/mary-snapshot-20260418-0720.tar.gz` + fresh snapshot before upgrade.
- `claude-cli/claude-opus-4-7` shows `configured,missing` in `openclaw models list` even though routing works (see 2026-04-23 00:40 Discord turn: assistant payload was opus-4-7). The `missing` tag is a metadata probe bug, not functional. Only matters cosmetically — investigate after upgrade.
- Debug env flags (`OPENCLAW_CLI_BACKEND_LOG_OUTPUT`, `OPENCLAW_CLAUDE_CLI_LOG_OUTPUT`) still enabled — verbose, remove when stable. Drop-in at `/etc/systemd/system/openclaw-gateway.service.d/debug.conf`.
- `/etc/systemd/system/openclaw-gateway.service.d/resilience.conf.DISABLED-*` left for rollback; safe to delete after 1 week of stable Max-plan operation.
- Mary's own notes (`/home/mary/.openclaw/workspace-mary/tasks.md`, `reviews/failures-2026-04-23.md`) document this exact failure from cron-side — her investigation converged with mine.
