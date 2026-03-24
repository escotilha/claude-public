#!/usr/bin/env bash
# memory-whisper.sh — UserPromptSubmit hook
# Searches auto-memory for context relevant to the user's prompt.
# Returns top matches as additionalContext so Claude sees them before responding.

PROMPT="${PROMPT:-}"
MEM_SEARCH="$HOME/.claude-setup/tools/mem-search"

# Skip if no prompt, very short prompts, or mem-search missing
[ -z "$PROMPT" ] && exit 0
[ ${#PROMPT} -lt 10 ] && exit 0
[ -x "$MEM_SEARCH" ] || exit 0

# Extract search terms: strip stopwords, keep top 3 longest words (most distinctive)
QUERY=$(echo "$PROMPT" | head -c 80 \
  | sed 's/[^a-zA-Z0-9 _-]/ /g' \
  | tr ' ' '\n' \
  | grep -viE '^(the|a|an|is|it|to|in|on|of|for|and|or|but|not|with|this|that|can|do|how|what|why|when|where|my|i|me|we|you|fix|check|run|make|get|set|use|hi|hey|please|help|want|need|should|would|could|issue|issues|problem|error|look|find|show|tell|about)$' \
  | awk '{print length, $0}' \
  | sort -rn \
  | head -3 \
  | awk '{print $2}' \
  | tr '\n' ' ' \
  | xargs)
[ -z "$QUERY" ] && exit 0

# Run mem-search, parse results into concise format
# Uses a temp file to avoid pipefail issues
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

timeout 3 "$MEM_SEARCH" "$QUERY" > "$TMPFILE" 2>/dev/null || true

# Parse: grep data rows, convert multi-space to tab, extract name/type/desc
MEMORIES=$(grep -E '^[a-zA-Z]' "$TMPFILE" \
  | grep -v '^name ' \
  | sed -E 's/  +/\t/g' \
  | awk -F'\t' '{if (NF >= 3) printf "- [%s] %s: %s\n", $2, $1, $3}' \
  | head -5 \
  || true)

[ -z "$MEMORIES" ] && exit 0

# Output as JSON for Claude to consume
printf '{"additionalContext": "Relevant memories:\\n%s"}\n' "$MEMORIES"
