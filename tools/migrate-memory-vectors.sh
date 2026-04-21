#!/usr/bin/env bash
# migrate-memory-vectors.sh — one-shot vector embedding for existing corpus.
#
# Runs a full FTS5 reindex + full vector embed over every memory file,
# prints timing, and reports the final vec-status. Idempotent — safe to
# re-run. Use after installing sqlite-vec + sentence-transformers, or
# after switching embedding models.
set -euo pipefail

MEM_SEARCH="$HOME/.claude-setup/tools/mem-search"
MEM_EMBED="$HOME/.claude-setup/tools/mem-embed"

if [[ ! -x "$MEM_SEARCH" ]]; then
  echo "migrate-memory-vectors: mem-search not found at $MEM_SEARCH" >&2
  exit 2
fi

if [[ ! -x "$MEM_EMBED" ]]; then
  echo "migrate-memory-vectors: mem-embed not found at $MEM_EMBED" >&2
  echo "  Install deps first: /opt/homebrew/bin/python3.11 -m pip install --user -r $HOME/.claude-setup/tools/requirements.txt" >&2
  exit 2
fi

echo "[migrate] Starting full memory vector migration"
echo "[migrate] Model: sentence-transformers/all-MiniLM-L6-v2 (384-dim, local)"
echo "[migrate] Expected duration: ~15-30s for 140 files (first run may download ~80MB model)"
echo ""

start=$(date +%s)
"$MEM_SEARCH" --reindex --vectors-full
end=$(date +%s)
dur=$((end - start))

echo ""
echo "[migrate] Done in ${dur}s"
echo ""
echo "[migrate] Vector layer status:"
"$MEM_SEARCH" --vec-status
