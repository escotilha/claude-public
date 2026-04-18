#!/bin/bash
# Sync Claude Code OAuth credential from Mac keychain to VPS (Mary).
# Invoked by ~/Library/LaunchAgents/com.mary.token-sync.plist every 6h.
#
# Prereqs:
#   - Keychain item: "Claude Code-credentials" (created by `claude login`)
#   - SSH alias "vps" resolves to the Mary host
#   - Pushes to mary@vps (gateway runs as mary system user since 2026-04-18)
#
# Backup refresh: a VPS cron (mary user) pings `claude -p "ping"` every 4h.
# If the keychain sync dies, Mary can still refresh her own token for ~24h
# off the refreshToken before needing a fresh OAuth flow on the Mac.
#
# Alerts: on failure, asks Mary to post a warning to Discord via openclaw agent.
# Rate-limited by /tmp/mary-sync-last-alert (1h cooldown) to prevent spam.

set -eo pipefail

LOG_PREFIX="[$(date -u +%Y-%m-%dT%H:%M:%SZ)]"
ALERT_COOLDOWN=/tmp/mary-sync-last-alert
COOLDOWN_SECS=3600

echo "${LOG_PREFIX} sync start"

alert_mary() {
    local msg="$1"
    if [ -f "$ALERT_COOLDOWN" ]; then
        local age=$(( $(date +%s) - $(stat -f %m "$ALERT_COOLDOWN" 2>/dev/null || stat -c %Y "$ALERT_COOLDOWN") ))
        if [ "$age" -lt "$COOLDOWN_SECS" ]; then
            echo "${LOG_PREFIX} suppressed (cooldown): $msg"
            return
        fi
    fi
    touch "$ALERT_COOLDOWN"
    ssh -o ConnectTimeout=5 -o BatchMode=yes mary@vps \
        "openclaw agent --agent mary -m 'SYNC ALERT from Mac: ${msg}. Max plan will expire in <8h if not fixed.' --timeout 45" \
        >/dev/null 2>&1 || echo "${LOG_PREFIX} ALERT SEND FAILED: $msg"
}

CRED_TMP="$(mktemp -t claude-cred)"
trap 'rm -f "${CRED_TMP}"' EXIT

if ! security find-generic-password -s "Claude Code-credentials" -w > "${CRED_TMP}" 2>/dev/null; then
    echo "${LOG_PREFIX} FAIL: could not read keychain (locked or missing)"
    alert_mary "could not read Claude keychain on Mac (locked after reboot?)"
    exit 1
fi

if ! python3 -c "import json,sys,time; d=json.load(open(sys.argv[1])); exp=d['claudeAiOauth']['expiresAt']; assert exp > int(time.time()*1000), f'expired {exp}'" "${CRED_TMP}" 2>/dev/null; then
    echo "${LOG_PREFIX} WARN: keychain credential is expired or malformed — pushing anyway so VPS has the refreshToken"
fi

if ! scp -o ConnectTimeout=10 -o BatchMode=yes "${CRED_TMP}" mary@vps:/home/mary/.claude/.credentials.json 2>&1; then
    echo "${LOG_PREFIX} FAIL: scp to mary@vps failed"
    alert_mary "scp to mary@vps failed (VPS unreachable?)"
    exit 1
fi

ssh -o ConnectTimeout=10 -o BatchMode=yes mary@vps "chmod 600 /home/mary/.claude/.credentials.json" 2>&1 || {
    echo "${LOG_PREFIX} WARN: chmod on VPS failed"
}

echo "${LOG_PREFIX} sync OK"
