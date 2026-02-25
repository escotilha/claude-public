#!/bin/bash
# Health check script for MCP servers
# Runs on SessionStart to verify critical services are available

LOG_FILE="$HOME/.claude/health-check.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_mcp_server() {
    local server_name="$1"
    local check_command="$2"

    if eval "$check_command" >/dev/null 2>&1; then
        log "✓ $server_name: OK"
        return 0
    else
        log "✗ $server_name: UNAVAILABLE"
        return 1
    fi
}

# Start health check
log "--- Session Health Check Started ---"

# Check if npx is available (required for most MCP servers)
if ! command -v npx &>/dev/null; then
    log "✗ CRITICAL: npx not found - MCP servers will fail"
fi

# Check claude-setup git repo
if [ -d "$HOME/.claude-setup/.git" ]; then
    log "✓ claude-setup repo: OK ($HOME/.claude-setup)"
else
    log "✗ claude-setup repo not found at $HOME/.claude-setup"
fi

# Check PostgreSQL (if DATABASE_URL is set)
if [ -n "$DATABASE_URL" ]; then
    if command -v psql &>/dev/null; then
        log "✓ PostgreSQL client: Available"
    else
        log "⚠ PostgreSQL client (psql) not found"
    fi
fi

# Check secrets from Keychain
check_keychain_secret() {
    local key_name="$1"
    local display_name="$2"
    local required="$3"
    local service="claude-code-${key_name}"

    if security find-generic-password -a "$USER" -s "$service" -w &>/dev/null; then
        log "✓ $display_name: Set (Keychain)"
    elif [ "$required" = "required" ]; then
        log "✗ $display_name: NOT SET (required) - run setup-keychain.sh"
    else
        log "○ $display_name: Not set (optional)"
    fi
}

# Check required secrets
check_keychain_secret "github-token" "GITHUB_TOKEN" "required"
check_keychain_secret "anthropic-api-key" "ANTHROPIC_API_KEY" "required"
check_keychain_secret "brave-api-key" "BRAVE_API_KEY" "required"

# Check optional secrets
check_keychain_secret "slack-bot-token" "SLACK_BOT_TOKEN" "optional"
check_keychain_secret "notion-api-key" "NOTION_API_KEY" "optional"
check_keychain_secret "resend-api-key" "RESEND_API_KEY" "optional"
check_keychain_secret "database-url" "DATABASE_URL" "optional"

# Warn if plaintext .env still exists
if [ -f "$HOME/.claude/.env" ]; then
    log "⚠ WARNING: Plaintext .env file still exists - consider deleting after Keychain migration"
fi

# Check Chrome (for chrome-devtools MCP)
if [ -d "/Applications/Google Chrome.app" ]; then
    log "✓ Chrome: Installed"
else
    log "⚠ Chrome: Not found (chrome-devtools MCP may not work)"
fi

# Check disk space
AVAILABLE_SPACE=$(df -h "$HOME" | awk 'NR==2 {print $4}')
log "○ Available disk space: $AVAILABLE_SPACE"

log "--- Health Check Complete ---"

# Keep log file from growing too large (keep last 1000 lines)
if [ -f "$LOG_FILE" ]; then
    tail -1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

# Always exit 0 so session continues even if checks fail
exit 0
