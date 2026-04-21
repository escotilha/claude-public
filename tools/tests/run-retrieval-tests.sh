#!/usr/bin/env bash
# run-retrieval-tests.sh — golden-file tests for mem-search hybrid retrieval.
#
# Creates a throwaway DB, indexes a fixture corpus of 5 pages, runs three query
# modes (fts / vec / hybrid), and asserts expected files appear in top-3.
#
# Usage:
#   ~/.claude-setup/tools/tests/run-retrieval-tests.sh
#
# Exit code 0 on all-pass, 1 on any fail.
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
CORPUS="$TESTS_DIR/fixture-corpus"
TEST_DB="$TESTS_DIR/test-mem-search.db"

export MEM_CORPUS_PATH="$CORPUS"
export MEM_DB_PATH="$TEST_DB"
export MEM_HYBRID=1

MEM_SEARCH="$HOME/.claude-setup/tools/mem-search"

PASS=0
FAIL=0

assert_has() {
  local mode="$1" query="$2" expected="$3"
  local cmd_args=()
  [[ "$mode" != "hybrid" ]] && cmd_args+=("--$mode")
  cmd_args+=("$query")

  local out
  out=$("$MEM_SEARCH" "${cmd_args[@]}" 2>/dev/null || true)
  if echo "$out" | grep -q "$expected"; then
    echo "  PASS  [$mode] '$query' contains '$expected'"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  [$mode] '$query' missing '$expected'"
    echo "    --- output ---"
    echo "$out" | sed 's/^/    /' | head -15
    echo "    --------------"
    FAIL=$((FAIL + 1))
  fi
}

# Clean slate
rm -f "$TEST_DB"

echo "=== Building fixture index ==="
"$MEM_SEARCH" --reindex --vectors-full >/dev/null 2>&1
echo ""

echo "=== FTS5 tests (exact keyword match) ==="
assert_has "fts" "pumpernickel"          "exact-match-page"
assert_has "fts" "rainbow marmalade"      "description-only-page"
assert_has "fts" "elephant zebras"        "timeline-only-page"
echo ""

echo "=== Vector tests (semantic match) ==="
assert_has "vec" "CUDA tensor acceleration"  "semantic_only.md"
assert_has "vec" "pumpernickel"              "exact_match.md"
echo ""

echo "=== Hybrid tests (RRF fusion) ==="
assert_has "hybrid" "pumpernickel"        "exact-match-page"
assert_has "hybrid" "rainbow marmalade"   "description-only-page"
echo ""

echo "=== Summary ==="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"

# Cleanup
rm -f "$TEST_DB"

[[ $FAIL -eq 0 ]]
