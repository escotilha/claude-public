#!/bin/bash
# Subagent Activity Hook - Log agent spawning and completion
# Used for both SubagentStart and SubagentStop hooks
# Receives JSON input via stdin from Claude Code hooks

set -euo pipefail

# Create activity log directory
mkdir -p ~/.claude/logs

ACTIVITY_LOG=~/.claude/logs/agent-activity.log

# Parse input
INPUT=$(cat)

# Extract agent info
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // .subagent_type // "unknown"' 2>/dev/null || echo "unknown")
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // "unknown"' 2>/dev/null || echo "unknown")
EVENT_TYPE=$(echo "$INPUT" | jq -r '.event // "activity"' 2>/dev/null || echo "activity")
TASK=$(echo "$INPUT" | jq -r '.task // .prompt // ""' 2>/dev/null | head -c 100 || echo "")

# Determine if this is start or stop based on hook context
# The hook type will be passed in the environment or we detect from input
if [[ "${HOOK_TYPE:-}" == "SubagentStop" ]] || echo "$INPUT" | jq -e '.completed' &>/dev/null; then
    STATUS="STOPPED"
else
    STATUS="STARTED"
fi

# Log the activity
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $STATUS: [$AGENT_ID] $AGENT_TYPE - ${TASK:0:100}..." >> "$ACTIVITY_LOG"

exit 0
