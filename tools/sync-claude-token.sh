#!/bin/bash
# Sync Claude Code OAuth credential from Mac keychain to VPS (Mary).
# Invoked by ~/Library/LaunchAgents/com.mary.token-sync.plist every 6h.
#
# Prereqs:
#   - Keychain item: "Claude Code-credentials" (created by `claude login`)
#   - SSH alias "vps" resolves to the Mary host
#
# Failure modes (logged to /tmp/mary-token-sync.log):
#   - Keychain locked (reboot + no login) → security errors
#   - VPS unreachable → ssh timeout
#   - Disk full on VPS → scp errors

set -eo pipefail

LOG_PREFIX="[$(date -u +%Y-%m-%dT%H:%M:%SZ)]"
echo "${LOG_PREFIX} sync start"

CRED_TMP="$(mktemp -t claude-cred)"
trap 'rm -f "${CRED_TMP}"' EXIT

if ! security find-generic-password -s "Claude Code-credentials" -w > "${CRED_TMP}" 2>/dev/null; then
    echo "${LOG_PREFIX} FAIL: could not read keychain (locked or missing)"
    exit 1
fi

if ! python3 -c "import json,sys,time; d=json.load(open(sys.argv[1])); exp=d['claudeAiOauth']['expiresAt']; assert exp > int(time.time()*1000), f'expired {exp}'" "${CRED_TMP}" 2>/dev/null; then
    echo "${LOG_PREFIX} WARN: keychain credential is expired or malformed — pushing anyway so VPS has the refreshToken"
fi

if ! scp -o ConnectTimeout=10 -o BatchMode=yes "${CRED_TMP}" root@vps:/root/.claude/.credentials.json 2>&1; then
    echo "${LOG_PREFIX} FAIL: scp to root@vps failed"
    exit 1
fi

ssh -o ConnectTimeout=10 -o BatchMode=yes root@vps "chmod 600 /root/.claude/.credentials.json" 2>&1 || {
    echo "${LOG_PREFIX} WARN: chmod on VPS failed"
}

echo "${LOG_PREFIX} sync OK"
