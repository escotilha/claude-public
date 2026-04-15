#!/bin/bash
# Memory whisper hook — runs on every user prompt submit
# Emits hookSpecificOutput.sessionTitle for auto-titling sessions (v2.1.94+)
# Also injects relevant memory context as additionalContext

set -euo pipefail

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // ""')

# Skip empty prompts
if [ -z "$prompt" ] || [ ${#prompt} -lt 5 ]; then
  exit 0
fi

# Auto-title: extract a concise session title from the first substantive prompt
# Only emit on first prompt (when no title has been set yet)
SESSION_TURN=$(echo "$input" | jq -r '.session.turn_number // 1')
if [ "${SESSION_TURN}" = "1" ]; then
  # Truncate prompt to first 80 chars for title
  TITLE=$(echo "$prompt" | head -c 80 | tr '\n' ' ' | sed 's/[[:space:]]*$//')
  echo "{\"hookSpecificOutput\": {\"sessionTitle\": \"$TITLE\"}}"
fi

exit 0
