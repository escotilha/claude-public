#!/bin/bash
# Session End Hook - Capture learnings for memory system
# Location: ~/.claude-setup/hooks/session-end.sh

set -euo pipefail

MEMORY_DIR="$HOME/.claude-setup/memory"
SESSIONS_DIR="$MEMORY_DIR/sessions"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M%S)

# Create directories if needed
mkdir -p "$SESSIONS_DIR"

# Parse input from Claude Code (if available)
INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
WORKING_DIR=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null || echo "unknown")

# Detect project from working directory
PROJECT="unknown"
if [[ "$WORKING_DIR" == *"contably"* ]]; then
  PROJECT="Contably"
elif [[ "$WORKING_DIR" == *"agentcreator"* ]] || [[ "$WORKING_DIR" == *"AgentCreator"* ]]; then
  PROJECT="AgentCreator"
elif [[ "$WORKING_DIR" == *"mna"* ]] || [[ "$WORKING_DIR" == *"nuvini"* ]]; then
  PROJECT="M&A Toolkit"
fi

# Create session log
SESSION_FILE="$SESSIONS_DIR/${DATE}-${TIME}-session.json"
cat > "$SESSION_FILE" << EOF
{
  "date": "$DATE",
  "time": "$(date +%H:%M:%S)",
  "sessionId": "$SESSION_ID",
  "project": "$PROJECT",
  "workingDirectory": "$WORKING_DIR",
  "learnings": [],
  "memoriesApplied": [],
  "status": "pending_review"
}
EOF

# Auto-sync claude-setup if there are changes
SETUP_DIR="$HOME/.claude-setup"
if [ -d "$SETUP_DIR/.git" ]; then
  if ! git -C "$SETUP_DIR" diff --quiet 2>/dev/null || \
     ! git -C "$SETUP_DIR" diff --cached --quiet 2>/dev/null || \
     [ -n "$(git -C "$SETUP_DIR" ls-files --others --exclude-standard 2>/dev/null)" ]; then
    git -C "$SETUP_DIR" add -A 2>/dev/null
    git -C "$SETUP_DIR" commit -m "auto: sync claude-setup" --quiet 2>/dev/null
    git -C "$SETUP_DIR" push origin master --quiet 2>/dev/null &
    echo "claude-setup synced to GitHub" >&2
  fi
fi

# Log reminder to stderr (stdout must be valid JSON for Claude Code hooks)
echo "Session logged: $SESSION_FILE" >&2

# Must output valid JSON to stdout for Claude Code hook validation
echo '{}'

exit 0
