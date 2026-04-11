#!/bin/bash
# Pre-Compact Hook - Preserve state before context compression
# Receives JSON input via stdin from Claude Code hooks

set -euo pipefail

# Check if we're in a directory with progress.md (autonomous mode)
if [[ -f "progress.md" ]]; then
    # Append a marker noting when compaction occurred
    echo "" >> progress.md
    echo "## $(date '+%Y-%m-%d %H:%M:%S') - Context Compacted" >> progress.md
    echo "" >> progress.md
    echo "Context was compressed at this point. Refer to prd.json for current task status." >> progress.md
    echo "" >> progress.md
    echo "---" >> progress.md
fi

# Also save to a global pre-compact log
mkdir -p ~/.claude/compact-logs
COMPACT_LOG=~/.claude/compact-logs/$(date +%Y-%m-%d).log

echo "[$(date '+%H:%M:%S')] Context compacted in: $(pwd)" >> "$COMPACT_LOG"

exit 0
