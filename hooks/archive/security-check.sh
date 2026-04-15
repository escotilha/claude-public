#!/bin/bash
# Security check hook for Bash commands
# Returns additionalContext with warnings for potentially dangerous commands
# Receives JSON input via stdin from Claude Code hooks

set -euo pipefail

# Extract command from hook input
command=$(jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
    exit 0
fi

# Check for dangerous patterns
WARNINGS=""

# Check for destructive operations without confirmation
if [[ "$command" =~ rm\ +-rf|rm\ +-fr ]]; then
    WARNINGS+="⚠️ DESTRUCTIVE: Command contains 'rm -rf' - ensure you're not deleting critical files\n"
fi

# Check for curl/wget piping to sh/bash
if [[ "$command" =~ curl.*\|.*sh|wget.*\|.*bash ]]; then
    WARNINGS+="⚠️ SECURITY: Piping remote content directly to shell is dangerous\n"
fi

# Check for sudo usage
if [[ "$command" =~ ^sudo\ |\ sudo\  ]]; then
    WARNINGS+="⚠️ PRIVILEGE: Command uses sudo - verify elevated privileges are necessary\n"
fi

# Check for environment variable exposure
if [[ "$command" =~ API_KEY|SECRET|PASSWORD|TOKEN && "$command" =~ echo|cat|curl ]]; then
    WARNINGS+="⚠️ LEAK: Command may expose sensitive environment variables\n"
fi

# Check for git force operations
if [[ "$command" =~ git\ push.*--force|git\ push.*-f ]]; then
    WARNINGS+="⚠️ GIT: Force push can overwrite remote history - ensure this is intentional\n"
fi

# Check for database operations on production
if [[ "$command" =~ DROP\ TABLE|DROP\ DATABASE|TRUNCATE && "$command" =~ prod|production ]]; then
    WARNINGS+="⚠️ DATABASE: Destructive database operation on production detected\n"
fi

# Check for chmod 777
if [[ "$command" =~ chmod\ 777 ]]; then
    WARNINGS+="⚠️ PERMISSIONS: chmod 777 grants full permissions to all users - use more restrictive permissions\n"
fi

# Check for npm install without package-lock
if [[ "$command" =~ npm\ install && ! -f "package-lock.json" ]]; then
    WARNINGS+="💡 TIP: No package-lock.json found - consider using 'npm ci' for reproducible builds\n"
fi

# Return additionalContext to the model if there are warnings
if [[ -n "$WARNINGS" ]]; then
    jq -n --arg warnings "$WARNINGS" --arg cmd "$command" '{
        "additionalContext": "🔒 Security Analysis for command:\n\($cmd)\n\n\($warnings)\nProceed with caution or modify the command to be safer."
    }'
fi

exit 0
