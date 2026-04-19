#!/bin/bash
# watch-models.sh — check HuggingFace for new MLX quants of tracked models.
# Emits MEDIUM-priority findings for /claude-setup-optimizer when a quant drops.
#
# Usage: watch-models.sh [--json]
# Exits 0 on success. Emits to stdout.
#
# Tracked models live in models.txt (one HF repo id per line, # for comments).
# Watches for MLX variants under mlx-community/* and the original author.

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
MODELS_FILE="$DIR/models.txt"
CACHE_DIR="$HOME/.cache/claude-setup-optimizer"
CACHE_FILE="$CACHE_DIR/mlx-watch.state"
mkdir -p "$CACHE_DIR"

JSON=false
[ "${1:-}" = "--json" ] && JSON=true

if [ ! -f "$MODELS_FILE" ]; then
  echo "# tracked models (one HF repo id per line, # = comment)" > "$MODELS_FILE"
  echo "hesamation/Qwen3.6-35B-A3B-Claude-4.6-Opus-Reasoning-Distilled" >> "$MODELS_FILE"
  echo "Jackrong/Qwen3.5-35B-A3B-Claude-4.6-Opus-Reasoning-Distilled" >> "$MODELS_FILE"
fi

touch "$CACHE_FILE"
findings=()

search_mlx() {
  local orig="$1"
  local name
  name="$(echo "$orig" | cut -d/ -f2)"
  # HF API search — public, no auth needed
  curl -sS --max-time 10 \
    "https://huggingface.co/api/models?search=${name}&filter=mlx&limit=20" \
    2>/dev/null \
    | grep -oE '"id":"[^"]+"' \
    | cut -d'"' -f4 \
    | grep -iE "mlx|MLX" || true
}

while IFS= read -r model; do
  [ -z "$model" ] && continue
  [[ "$model" =~ ^# ]] && continue

  matches="$(search_mlx "$model")"
  [ -z "$matches" ] && continue

  while IFS= read -r match; do
    [ -z "$match" ] && continue
    key="${model}|${match}"
    if ! grep -qxF "$key" "$CACHE_FILE" 2>/dev/null; then
      findings+=("$model -> $match")
      echo "$key" >> "$CACHE_FILE"
    fi
  done <<< "$matches"
done < "$MODELS_FILE"

if [ ${#findings[@]} -eq 0 ]; then
  if $JSON; then
    echo '{"findings":[],"status":"no new quants"}'
  else
    echo "No new MLX quants since last run."
  fi
  exit 0
fi

if $JSON; then
  printf '{"findings":['
  sep=""
  for f in "${findings[@]}"; do
    orig="${f%% -> *}"
    new="${f##* -> }"
    printf '%s{"tracked":"%s","new_variant":"%s","url":"https://huggingface.co/%s"}' \
      "$sep" "$orig" "$new" "$new"
    sep=","
  done
  printf '],"status":"new quants found"}\n'
else
  echo "NEW MLX quants detected:"
  for f in "${findings[@]}"; do
    echo "  - $f"
    new="${f##* -> }"
    echo "    https://huggingface.co/$new"
  done
fi
