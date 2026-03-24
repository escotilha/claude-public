#!/usr/bin/env bash
# memory-whisper.sh — UserPromptSubmit hook
# Searches auto-memory for context relevant to the user's prompt.
# Returns top matches as additionalContext so Claude sees them before responding.
set -euo pipefail

PROMPT="${PROMPT:-}"
MEM_SEARCH="$HOME/.claude-setup/tools/mem-search"

# Skip if no prompt, very short prompts, or mem-search missing
[ -z "$PROMPT" ] && exit 0
[ ${#PROMPT} -lt 10 ] && exit 0
[ -x "$MEM_SEARCH" ] || exit 0

# Extract search query: take first 80 chars, strip special chars
QUERY=$(echo "$PROMPT" | head -c 80 | sed 's/[^a-zA-Z0-9 _-]/ /g' | xargs)
[ -z "$QUERY" ] && exit 0

# Run mem-search (timeout 3s to stay within hook budget)
# Grep for lines that start with a non-space char (actual result rows, not snippets/separators)
MEMORIES=$(timeout 3 "$MEM_SEARCH" "$QUERY" 2>/dev/null \
  | grep -E '^[a-zA-Z]' \
  | grep -v '^name ' \
  | awk -F'  +' '{
    gsub(/^[ \t]+|[ \t]+$/, "", $1);
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    gsub(/^[ \t]+|[ \t]+$/, "", $3);
    if ($1 != "" && $1 !~ /^-+$/) printf "- [%s] %s: %s\n", $2, $1, $3
  }' | head -5) || exit 0

[ -z "$MEMORIES" ] && exit 0

# Output as JSON for Claude to consume
cat <<EOF
{"additionalContext": "Relevant memories for this prompt:\n${MEMORIES}"}
EOF
