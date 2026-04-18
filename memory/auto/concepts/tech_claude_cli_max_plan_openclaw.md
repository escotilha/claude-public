---
name: tech-insight:claude-cli-max-plan-openclaw
description: How to route OpenClaw agents through Claude Max plan via claude-cli backend — gateway must run as non-root user, config shape, and token-sync requirements
type: reference
originSessionId: e5c1cdc3-cf0d-482f-96f7-7edd15071071
---
OpenClaw's `claude-cli` backend lets you run agents through your Claude Max plan instead of paying per-token API costs. Setup is finicky and poorly documented.

**Hard requirement:** Gateway must run as a non-root system user. OpenClaw injects `--permission-mode bypassPermissions` on every claude-cli call (hardcoded in `cli-shared-*.js → normalizeClaudePermissionArgs`). Claude CLI refuses this flag as root. See project_mary_migration.md for Mary's migration from root to mary user.

**Config shape** (add to `openclaw.json`):

```json
{
  "auth": {
    "profiles": {
      "anthropic:claude-cli": {
        "provider": "claude-cli",
        "mode": "oauth"
      }
    }
  },
  "agents": {
    "defaults": {
      "models": {
        "claude-cli/claude-opus-4-6": {},
        "claude-cli/claude-sonnet-4-6": {},
        "claude-cli/claude-haiku-4-5": {}
      }
    },
    "list": [
      { "id": "mary", "model": "claude-cli/claude-opus-4-6", ... }
    ]
  }
}
```

**Non-interactive registration:**

```bash
openclaw config set --batch-file /dev/stdin --strict-json <<'EOF'
[
  {"path": "auth.profiles.anthropic:claude-cli", "value": {"provider": "claude-cli", "mode": "oauth"}},
  {"path": "agents.defaults.models.claude-cli/claude-opus-4-6", "value": {}},
  {"path": "agents.list.0.model", "value": "claude-cli/claude-opus-4-6"}
]
EOF
```

(Note: `agents.list.N` uses array index, not agent id. Query first: `python3 -c 'import json; [print(i,a["id"]) for i,a in enumerate(json.load(open("/home/mary/.openclaw/openclaw.json"))["agents"]["list"])]'`.)

**Auth flow:** Provider shells out to `claude` CLI directly. Reads credential from `$HOME/.claude/.credentials.json` (not OpenClaw's auth-profiles.json). Needs to be kept fresh — OAuth tokens expire daily.

**Token sync from Mac:**

- Script: `/Users/ps/.claude-setup/tools/sync-claude-token.sh`
- Launchd: `~/Library/LaunchAgents/com.mary.token-sync.plist` (every 6h)
- Reads `security find-generic-password -s "Claude Code-credentials" -w` from Mac keychain
- Pushes via `scp` to `mary@vps:/home/mary/.claude/.credentials.json`
- Log: `/tmp/mary-token-sync.log`
- Gotcha: script MUST be at a persistent path. `/tmp/` gets wiped on Mac reboot.

**Verification after setup:**

```bash
ssh mary@vps "openclaw models list | grep claude-cli"      # should show "configured"
ssh mary@vps "openclaw agent --agent mary -m 'Reply ONLINE'"  # should return ONLINE
ssh root@vps "journalctl -u openclaw-gateway --since '2min ago' | grep claude-cli"
# Look for: "cli exec: provider=claude-cli model=opus"
# Bad sign: "model-fallback/decision decision=candidate_failed ... --dangerously-skip-permissions cannot be used with root/sudo"
```

**Known failure modes:**

1. `--permission-mode bypassPermissions cannot be used with root/sudo privileges` → gateway running as root. Migrate to non-root user.
2. `401 Invalid authentication credentials` → credential expired on VPS. Run sync script manually: `bash /Users/ps/.claude-setup/tools/sync-claude-token.sh`
3. `claude-cli` not in `openclaw models list` → `agents.defaults.models.claude-cli/...` entries missing. Add them.
4. `Auth store: no` in `models status` → normal. OpenClaw doesn't track OAuth state for claude-cli (it's delegated to Claude CLI itself).

**Cost impact:** 4 Opus agents (mary/bella/rex/cris) moved from paid Anthropic API to Max plan = $0/month for those. Remaining 7 agents still on MLX (local) or OpenRouter free tier.

**How to apply:** When user says "use Max plan on [agent]" or OpenClaw agent is using paid API despite Max subscription — check the claude-cli/ provider is registered, verify non-root user, confirm token is fresh. Don't assume `ANTHROPIC_API_KEY` in env will be preferred — it's the fallback, not the primary.

**Reliability controls (installed 2026-04-18):**

1. **VPS-side token refresh** — mary user crontab: `17 */4 * * * /usr/local/bin/claude -p "ping"`. Keeps OAuth token alive independent of Mac (TTL is ~8h; this refreshes every 4h). Survives Mac sleep/reboot.
2. **Systemd + config integrity guard** — `/usr/local/bin/mary-guard.sh` runs hourly as root cron. Checks: (a) `User=mary` still in unit, (b) mary/bella/rex/cris still on `claude-cli/`, (c) `auth.profiles.anthropic:claude-cli` still registered. On drift, uses `openclaw agent --agent mary -m "GUARD ALERT: ..."` to post Discord message. Log: `/var/log/mary-guard.log`. 1h alert cooldown.
3. **Mac sync failure alerts** — `/Users/ps/.claude-setup/tools/sync-claude-token.sh` alerts via `openclaw agent` when keychain read fails or scp fails. 1h cooldown via `/tmp/mary-sync-last-alert`.

The VPS token refresh is the most important of the three — it removes the Mac as a single point of failure for token freshness.
