#!/usr/bin/env bash
# Notify Pierre on WhatsApp via Claudia when Claude Code stops.
# Called by both Stop and StopFailure hooks.
#
# Input: JSON on stdin with fields from Claude Code hook system:
#   Stop:        session_id, cwd, stop_reason, last_assistant_message
#   StopFailure: session_id, cwd, error_type, error_message

set -euo pipefail

CLAUDIA_URL="http://100.77.51.51:3001/api/send"
CLAUDIA_TOKEN="bbc996302a265369d560e889a194d20e"
WHATSAPP_CHAT_ID="130464027279574@lid"

# Read hook input from stdin
INPUT=$(cat)

# Parse common fields
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "Stop"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
PROJECT=$(basename "${CWD:-unknown}" 2>/dev/null || echo "unknown")

if [ "$HOOK_EVENT" = "StopFailure" ]; then
  # ── Failure notification ──
  ERROR_TYPE=$(echo "$INPUT" | jq -r '.error_type // "unknown"')
  ERROR_MSG=$(echo "$INPUT" | jq -r '.error_message // "No details"' | head -c 200)
  MESSAGE="⚠️ *Claude Code failed* in \`${PROJECT}\`
Error: ${ERROR_TYPE}
${ERROR_MSG}"
else
  # ── Success notification ──
  STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // "end_turn"')
  LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // ""')

  # Extract a summary: first 300 chars of the last assistant message
  if [ -n "$LAST_MSG" ] && [ "$LAST_MSG" != "null" ]; then
    SUMMARY=$(echo "$LAST_MSG" | head -c 300 | tr '\n' ' ' | sed 's/  */ /g')
    # Trim trailing incomplete word
    SUMMARY=$(echo "$SUMMARY" | sed 's/ [^ ]*$/…/')
  else
    SUMMARY="(no summary available)"
  fi

  case "$STOP_REASON" in
    end_turn)   REASON_LABEL="completed" ;;
    max_tokens) REASON_LABEL="hit token limit" ;;
    *)          REASON_LABEL="$STOP_REASON" ;;
  esac

  MESSAGE="✅ *Claude Code ${REASON_LABEL}* in \`${PROJECT}\`
${SUMMARY}"
fi

# Escape JSON special chars in message
MESSAGE_JSON=$(echo "$MESSAGE" | jq -Rs .)

# Send via Claudia's outbound API (fire-and-forget, 5s timeout)
curl -s --max-time 5 -X POST "$CLAUDIA_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAUDIA_TOKEN" \
  -d "{\"channel\":\"whatsapp\",\"chatId\":\"$WHATSAPP_CHAT_ID\",\"message\":${MESSAGE_JSON}}" \
  >/dev/null 2>&1 || true
