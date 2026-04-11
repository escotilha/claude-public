#!/usr/bin/env bash
# Notify Pierre on WhatsApp via Claudia when Claude Code finishes a task.
# Called by the Stop hook. Sends a short summary via /api/send.
#
# Environment variables from Claude Code:
#   STOP_HOOK_REASON — why Claude stopped (e.g., "end_turn", "max_turns")
#   CWD — current working directory

set -euo pipefail

CLAUDIA_URL="http://100.77.51.51:3001/api/send"
CLAUDIA_TOKEN="bbc996302a265369d560e889a194d20e"
WHATSAPP_CHAT_ID="130464027279574@lid"

# Derive project name from cwd
PROJECT=$(basename "${CWD:-$(pwd)}" 2>/dev/null || echo "unknown")
REASON="${STOP_HOOK_REASON:-completed}"

# Build notification message
MESSAGE="[Claude Code] Task ${REASON} in ${PROJECT}"

# Send via Claudia's outbound API (fire-and-forget, 5s timeout)
curl -s --max-time 5 -X POST "$CLAUDIA_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAUDIA_TOKEN" \
  -d "{\"channel\":\"whatsapp\",\"chatId\":\"$WHATSAPP_CHAT_ID\",\"message\":\"$MESSAGE\"}" \
  >/dev/null 2>&1 || true
