# Enhanced Hooks with additionalContext

## Overview

As of Claude Code v2.1.9, PreToolUse hooks can return `additionalContext` that gets injected into the model's context before tool execution. This enables:

- **Proactive warnings** before dangerous operations
- **Code quality guidance** during edits
- **Security checks** before bash commands
- **File-specific guidelines** for writes

## How It Works

Hooks can return JSON with an `additionalContext` field:

```bash
jq -n --arg context "Your message here" '{
    "additionalContext": $context
}'
```

The context is sent to Claude **before** the tool executes, allowing Claude to:
- Reconsider the action
- Modify the approach
- Ask for user confirmation
- Proceed with awareness of the warnings

## Implemented Hooks

### 1. format-file.sh (Enhanced)

**Location**: `~/.claude/hooks/format-file.sh`

**Purpose**: Formats files after Edit/Write operations AND injects linting warnings

**Features**:
- Auto-formats code using appropriate formatters (Prettier, Black, etc.)
- Runs ESLint for JS/TS files
- Runs pylint for Python files
- Returns linting warnings as additionalContext

**Example additionalContext**:
```
⚠️ Linting warnings for src/api/chat.js:

  15:12  error    'userId' is defined but never used    no-unused-vars
  28:5   warning  Unexpected console.log statement     no-console

Consider addressing these issues to improve code quality.
```

**Claude's behavior**: Will see these warnings and may fix them automatically or ask if you want them addressed.

---

### 2. security-check.sh (New)

**Location**: `~/.claude/hooks/security-check.sh`

**Purpose**: Security analysis for Bash commands

**Checks for**:
- Destructive operations (`rm -rf`)
- Remote script execution (`curl | sh`)
- Sudo usage
- Environment variable leaks
- Git force push
- Production database operations
- Insecure permissions (`chmod 777`)

**Example additionalContext**:
```
🔒 Security Analysis for command:
rm -rf /var/data/*

⚠️ DESTRUCTIVE: Command contains 'rm -rf' - ensure you're not deleting critical files

Proceed with caution or modify the command to be safer.
```

**Claude's behavior**: Will see the warning and may suggest a safer alternative or ask for confirmation.

---

## Configuration

The hooks are configured in `settings.json`:

```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [
      {
        "type": "command",
        "command": "$HOME/.claude/hooks/security-check.sh",
        "timeout": 2000
      }
    ]
  }
],
"PostToolUse": [
  {
    "matcher": "Edit|Write|NotebookEdit",
    "hooks": [
      {
        "type": "command",
        "command": "$HOME/.claude/hooks/format-file.sh",
        "timeout": 10000
      }
    ]
  }
]
```

**Note**: `security-check.sh` is PreToolUse (runs before), `format-file.sh` is PostToolUse (runs after, but can still inject context about what happened).

---

## Creating Your Own Hooks with additionalContext

### Template

```bash
#!/bin/bash
set -euo pipefail

# Extract tool input
INPUT=$(jq -r '.tool_input.FIELD // empty')

# Your analysis logic
WARNINGS=""

if [[ condition ]]; then
    WARNINGS+="Your warning message\n"
fi

# Return additionalContext if needed
if [[ -n "$WARNINGS" ]]; then
    jq -n --arg warnings "$WARNINGS" '{
        "additionalContext": $warnings
    }'
fi

exit 0
```

### Best Practices

1. **Be concise**: Context is added to the model, so keep it relevant
2. **Use emojis**: ⚠️ 🔒 💡 help Claude prioritize warnings
3. **Exit 0 always**: Non-zero exits will block the tool
4. **Timeout appropriately**: Set realistic timeouts (2-10s)
5. **Fail gracefully**: Use `|| true` for non-critical checks

### Ideas for Additional Hooks

**Cost estimation (PreToolUse on Bash)**:
```bash
# Estimate cloud costs before terraform apply
if [[ "$command" =~ terraform\ apply ]]; then
    COST=$(terraform plan -out=plan.tfplan && terraform show -json plan.tfplan | jq '.cost')
    echo "💰 Estimated monthly cost: $${COST}/month"
fi
```

**API rate limiting (PreToolUse on Bash)**:
```bash
# Warn about API rate limits
if [[ "$command" =~ curl.*api.github.com ]]; then
    RATE_LIMIT=$(curl -s https://api.github.com/rate_limit | jq '.rate.remaining')
    if [[ $RATE_LIMIT -lt 100 ]]; then
        echo "⚠️ GitHub API rate limit low: $RATE_LIMIT requests remaining"
    fi
fi
```

**File size checks (PreToolUse on Write)**:
```bash
# Warn about large files
CONTENT=$(jq -r '.tool_input.content')
SIZE=${#CONTENT}
if [[ $SIZE -gt 1000000 ]]; then
    echo "⚠️ Large file: $(($SIZE/1024))KB - consider splitting or using external storage"
fi
```

**Dependency vulnerability checks (PostToolUse on Write)**:
```bash
# Check package.json for known vulnerabilities
if [[ "$file_path" == "package.json" ]]; then
    VULNS=$(npm audit --json | jq '.metadata.vulnerabilities.total')
    if [[ $VULNS -gt 0 ]]; then
        echo "🔓 $VULNS vulnerabilities found - run 'npm audit fix'"
    fi
fi
```

---

## Testing Your Hooks

Test hooks locally:

```bash
# Test format-file.sh
echo '{"tool_input":{"file_path":"test.js"}}' | ~/.claude/hooks/format-file.sh

# Test security-check.sh
echo '{"tool_input":{"command":"rm -rf /"}}' | ~/.claude/hooks/security-check.sh
```

Expected output: JSON with `additionalContext` field or empty output.

---

## Troubleshooting

### Hook not running
- Check file permissions: `chmod +x ~/.claude/hooks/YOUR_HOOK.sh`
- Verify matcher pattern in settings.json
- Check hook timeout (increase if needed)

### Context not appearing
- Ensure you're returning valid JSON
- Use `jq -n` to create JSON (not echo)
- Test hook output manually

### Hook causing errors
- Always `exit 0` even on errors
- Use `|| true` for non-critical operations
- Check stderr: hooks should not output to stderr

---

## Benefits

### Before additionalContext
Claude would execute commands blindly, potentially:
- Running destructive operations
- Creating code with linting errors
- Missing security vulnerabilities

### After additionalContext
Claude receives proactive warnings and can:
- Suggest safer alternatives
- Fix linting issues automatically
- Ask for confirmation on dangerous operations
- Learn from patterns across sessions

---

## Further Reading

- [Claude Code Hooks Documentation](https://github.com/anthropics/claude-code)
- [PreToolUse Hook Specification](https://github.com/anthropics/claude-code/blob/main/docs/hooks.md)
- Claude Code v2.1.9 Changelog
