#!/usr/bin/env bash
# check-careful.sh — PreToolUse hook for /careful skill.
# Gated: no-ops unless ~/.claude-setup/state/careful.on exists (set by /careful skill).
# Reads JSON from stdin, checks Bash command for destructive patterns.
# Returns {"permissionDecision":"ask","message":"..."} to warn, or {} to allow.
set -euo pipefail

STATE_DIR="${HOME}/.claude-setup/state"
FLAG_FILE="${STATE_DIR}/careful.on"

# Gate: if /careful is not active for this user, no-op.
if [ ! -f "$FLAG_FILE" ]; then
  echo '{}'
  exit 0
fi

INPUT=$(cat)

# Extract the "command" field from tool_input.
CMD=$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)

if [ -z "$CMD" ]; then
  CMD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("command",""))' 2>/dev/null || true)
fi

if [ -z "$CMD" ]; then
  echo '{}'
  exit 0
fi

CMD_LOWER=$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')

# Safe exceptions: rm -rf of known build artifacts
if printf '%s' "$CMD" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+|--recursive[[:space:]]+)' 2>/dev/null; then
  SAFE_ONLY=true
  RM_ARGS=$(printf '%s' "$CMD" | sed -E 's/.*rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*//;s/--recursive[[:space:]]*//')
  for target in $RM_ARGS; do
    case "$target" in
      */node_modules|node_modules|*/.next|.next|*/dist|dist|*/__pycache__|__pycache__|*/.cache|.cache|*/build|build|*/.turbo|.turbo|*/coverage|coverage|*/.venv|.venv|*/venv|venv)
        ;;
      -*)
        ;;
      *)
        SAFE_ONLY=false
        break
        ;;
    esac
  done
  if [ "$SAFE_ONLY" = true ]; then
    echo '{}'
    exit 0
  fi
fi

WARN=""

if printf '%s' "$CMD" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*r|--recursive)' 2>/dev/null; then
  WARN="Destructive: recursive delete (rm -r). Permanently removes files."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE 'drop[[:space:]]+(table|database|schema)' 2>/dev/null; then
  WARN="Destructive: SQL DROP detected. Permanently deletes database objects."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE '\btruncate\b' 2>/dev/null; then
  WARN="Destructive: SQL TRUNCATE detected. Deletes all rows from a table."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+.*(-f\b|--force)' 2>/dev/null; then
  WARN="Destructive: git force-push rewrites remote history."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard' 2>/dev/null; then
  WARN="Destructive: git reset --hard discards all uncommitted changes."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+(checkout|restore)[[:space:]]+\.' 2>/dev/null; then
  WARN="Destructive: discards all uncommitted changes in the working tree."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+branch[[:space:]]+-D' 2>/dev/null; then
  WARN="Destructive: git branch -D force-deletes an unmerged branch."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'kubectl[[:space:]]+delete' 2>/dev/null; then
  WARN="Destructive: kubectl delete removes Kubernetes resources. May impact production."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD" | grep -qE 'docker[[:space:]]+(rm[[:space:]]+-f|system[[:space:]]+prune)' 2>/dev/null; then
  WARN="Destructive: Docker force-remove or prune. May delete running containers or cached images."
fi

if [ -z "$WARN" ] && printf '%s' "$CMD_LOWER" | grep -qE 'delete[[:space:]]+from[[:space:]]+' 2>/dev/null; then
  WARN="Destructive: SQL DELETE FROM detected. Verify WHERE clause before running."
fi

if [ -n "$WARN" ]; then
  WARN_ESCAPED=$(printf '%s' "$WARN" | sed 's/"/\\"/g')
  printf '{"permissionDecision":"ask","message":"[careful] %s"}\n' "$WARN_ESCAPED"
else
  echo '{}'
fi
