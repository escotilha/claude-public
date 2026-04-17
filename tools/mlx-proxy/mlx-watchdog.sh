#!/bin/bash
# mlx-watchdog — completion-based health check for MLX
# Runs every 60s via launchd. Two consecutive failures → kickstart MLX.
# "Failure" = /v1/chat/completions does not return 200 within WATCHDOG_TIMEOUT.
# (A plain /health GET is insufficient — the wedged-MLX failure mode keeps
# returning 200 on /health while completions hang indefinitely.)

set -u

LOG=~/Library/Logs/mlx-watchdog.log
STATE_FILE=/tmp/mlx-watchdog.state
PROXY_URL="${MLX_PROXY_URL:-http://127.0.0.1:1240/v1/chat/completions}"
MODEL="${MLX_MODEL:-mlx-community/Qwen3.5-35B-A3B-4bit}"
TIMEOUT="${WATCHDOG_TIMEOUT:-20}"
THRESHOLD="${WATCHDOG_THRESHOLD:-2}"
UID_VAL="$(id -u)"
MLX_LABEL="gui/${UID_VAL}/com.psm2.mlx-server"

ts() { date +"%Y-%m-%d %H:%M:%S"; }
log() { echo "$(ts) $*" >> "$LOG"; }

fails=0
[ -f "$STATE_FILE" ] && fails=$(cat "$STATE_FILE" 2>/dev/null | head -1)
[[ "$fails" =~ ^[0-9]+$ ]] || fails=0

body='{"model":"'"$MODEL"'","messages":[{"role":"user","content":"ping"}],"max_tokens":3,"temperature":0}'

http_code=$(curl -sS --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" \
  -X POST "$PROXY_URL" -H "content-type: application/json" -d "$body" 2>/dev/null || echo "000")

if [ "$http_code" = "200" ]; then
  if [ "$fails" -gt 0 ]; then
    log "RECOVERED after $fails failure(s)"
  fi
  echo 0 > "$STATE_FILE"
  exit 0
fi

fails=$((fails + 1))
echo "$fails" > "$STATE_FILE"
log "FAIL #$fails http=$http_code (threshold=$THRESHOLD)"

if [ "$fails" -ge "$THRESHOLD" ]; then
  log "KICKING $MLX_LABEL after $fails consecutive failures"
  launchctl kickstart -k "$MLX_LABEL" >> "$LOG" 2>&1
  echo 0 > "$STATE_FILE"
fi
