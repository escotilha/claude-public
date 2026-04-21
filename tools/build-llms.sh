#!/usr/bin/env bash
# build-llms.sh — generate llms.txt + llms-full.txt for the Claude setup repo.
#
# Spec: https://llmstxt.org
#
# llms.txt        Index file: H1 title, blockquote summary, H2 sections with
#                 markdown links to the full docs. Small (~5-10 KB).
# llms-full.txt   Single-file context: all rules inlined + skill frontmatter +
#                 description + first paragraph. Fits under a 150k-token window.
#
# Usage:
#   build-llms.sh            Generate both files, print stats
#   build-llms.sh --stats    Just print current state without regenerating
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./llms-config.sh
source "$SCRIPT_DIR/llms-config.sh"

# --- Helpers ---

today() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
bytes() { wc -c < "$1" | tr -d ' '; }
lines() { wc -l < "$1" | tr -d ' '; }

# Extract a frontmatter field from a markdown file.
# Returns empty string if not found. Strips surrounding quotes.
fm_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    BEGIN { in_fm = 0 }
    /^---$/ { if (in_fm) exit; in_fm = 1; next }
    in_fm && $0 ~ "^" f ":" {
      sub("^" f ":[[:space:]]*", "")
      # Strip trailing YAML comment (# ...) — safe because values are one-line
      sub(/[[:space:]]+#.*$/, "")
      gsub(/^"|"$/, "")
      gsub(/^'"'"'|'"'"'$/, "")
      print
      exit
    }
  ' "$file" 2>/dev/null || true
}

# Extract the first paragraph after the frontmatter (up to SKILL_PREVIEW_CHARS).
fm_preview() {
  local file="$1" maxchars="${2:-$SKILL_PREVIEW_CHARS}"
  awk -v maxchars="$maxchars" '
    BEGIN { fm_done = 0; in_fm = 0; buf = "" }
    /^---$/ {
      if (in_fm) { fm_done = 1; in_fm = 0; next }
      if (!fm_done) { in_fm = 1; next }
    }
    fm_done {
      # Skip blank lines at start
      if (buf == "" && /^[[:space:]]*$/) next
      # Stop on a new H2 or higher (first paragraph only)
      if (buf != "" && /^#{1,2}[[:space:]]/) exit
      buf = buf $0 "\n"
      if (length(buf) >= maxchars) exit
    }
    END { print substr(buf, 1, maxchars) }
  ' "$file" 2>/dev/null || true
}

# True if a rule file is excluded by config.
rule_excluded() {
  local basename="$1"
  for excl in "${RULE_EXCLUDES[@]}"; do
    [[ "$basename" == "$excl" ]] && return 0
  done
  return 1
}

# --- llms.txt (index only) ---

build_llms_txt() {
  local out="$LLMS_TXT_PATH"
  {
    echo "# $LLMS_TITLE"
    echo ""
    echo "> $LLMS_SUMMARY"
    echo ""
    echo "Last generated: $(today)"
    echo ""

    echo "## Rules"
    echo ""
    echo "Global behavioral rules loaded into every Claude session via CLAUDE.md."
    echo ""
    for f in "$RULES_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      local base desc
      base="$(basename "$f")"
      rule_excluded "$base" && continue
      # First heading or filename as label
      desc="$(head -5 "$f" | grep -m1 '^#' | sed 's/^#*[[:space:]]*//' | head -c 120)"
      [[ -z "$desc" ]] && desc="(no description)"
      echo "- [$base](rules/$base): $desc"
    done
    echo ""

    echo "## Skills"
    echo ""
    echo "User-invocable skills. Trigger via \`/<skill-name>\` or natural-language match."
    echo ""
    for d in "$SKILLS_DIR"/*/; do
      [[ -d "$d" ]] || continue
      local name="$(basename "$d")"
      [[ "$name" == ${SKILL_EXCLUDE_PREFIX}* ]] && continue
      local skill_md="$d/SKILL.md"
      [[ -f "$skill_md" ]] || continue
      local desc
      desc="$(fm_field "$skill_md" "description")"
      [[ -z "$desc" ]] && desc="(no description)"
      # Truncate to one line, 200 chars
      desc="$(printf '%s' "$desc" | tr '\n' ' ' | head -c 200)"
      echo "- [$name](skills/$name/SKILL.md): $desc"
    done
    echo ""

    # Agents section (optional — only if agents/ has content)
    if [[ -d "$AGENTS_DIR" ]] && [[ -n "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]]; then
      echo "## Agents"
      echo ""
      echo "Specialist subagent definitions spawned by skills or user."
      echo ""
      for f in "$AGENTS_DIR"/*.md; do
        [[ -f "$f" ]] || continue
        local base="$(basename "$f")"
        local desc="$(fm_field "$f" "description")"
        [[ -z "$desc" ]] && desc="$(head -5 "$f" | grep -m1 '^#' | sed 's/^#*[[:space:]]*//' | head -c 120)"
        [[ -z "$desc" ]] && desc="(no description)"
        desc="$(printf '%s' "$desc" | tr '\n' ' ' | head -c 200)"
        echo "- [$base](agents/$base): $desc"
      done
      echo ""
    fi

    echo "## Optional"
    echo ""
    echo "- [llms-full.txt](llms-full.txt): Single-file context with rules + skill descriptions inlined. Fetch this for offline / one-shot agent context."
  } > "$out"
}

# --- llms-full.txt (inlined content) ---

build_llms_full_txt() {
  local out="$LLMS_FULL_TXT_PATH"
  {
    echo "# $LLMS_TITLE"
    echo ""
    echo "> $LLMS_SUMMARY"
    echo ""
    echo "Generated: $(today)"
    echo ""
    echo "---"
    echo ""
    echo "This file inlines the content of every rule + the frontmatter/description/preview of every skill so that an agent can load the entire setup context in a single fetch."
    echo ""

    # Rules (inlined full content — they're short and always relevant)
    echo "# Rules"
    echo ""
    for f in "$RULES_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      local base="$(basename "$f")"
      rule_excluded "$base" && continue
      echo "## rules/$base"
      echo ""
      cat "$f"
      echo ""
      echo "---"
      echo ""
    done

    # Skills (frontmatter + description + first paragraph only — full content would bust budget)
    echo "# Skills"
    echo ""
    echo "Each entry shows frontmatter + description + first paragraph. For full content, read skills/<name>/SKILL.md directly."
    echo ""
    for d in "$SKILLS_DIR"/*/; do
      [[ -d "$d" ]] || continue
      local name="$(basename "$d")"
      [[ "$name" == ${SKILL_EXCLUDE_PREFIX}* ]] && continue
      local skill_md="$d/SKILL.md"
      [[ -f "$skill_md" ]] || continue

      local fm_name fm_desc fm_invocable fm_model fm_effort preview
      fm_name="$(fm_field "$skill_md" "name")"
      fm_desc="$(fm_field "$skill_md" "description")"
      fm_invocable="$(fm_field "$skill_md" "user-invocable")"
      fm_model="$(fm_field "$skill_md" "model")"
      fm_effort="$(fm_field "$skill_md" "effort")"
      preview="$(fm_preview "$skill_md" "$SKILL_PREVIEW_CHARS")"

      echo "## skills/$name"
      echo ""
      echo "- **name:** ${fm_name:-$name}"
      echo "- **description:** ${fm_desc:-(no description)}"
      [[ -n "$fm_invocable" ]] && echo "- **user-invocable:** $fm_invocable"
      [[ -n "$fm_model" ]] && echo "- **model:** $fm_model"
      [[ -n "$fm_effort" ]] && echo "- **effort:** $fm_effort"
      echo ""
      if [[ -n "$preview" ]]; then
        printf '%s\n' "$preview"
        echo ""
      fi
      echo "---"
      echo ""
    done

    echo "# End of context"
    echo ""
    echo "For full skill content, read \`skills/<name>/SKILL.md\` directly. For memory state, see \`memory/auto/MEMORY.md\`. For graph digest, see \`memory/auto/reports/GRAPH_REPORT.md\`."
  } > "$out"
}

# --- Main ---

if [[ "${1:-}" == "--stats" ]]; then
  [[ -f "$LLMS_TXT_PATH" ]] && echo "llms.txt:      $(bytes "$LLMS_TXT_PATH") bytes, $(lines "$LLMS_TXT_PATH") lines"
  [[ -f "$LLMS_FULL_TXT_PATH" ]] && echo "llms-full.txt: $(bytes "$LLMS_FULL_TXT_PATH") bytes, $(lines "$LLMS_FULL_TXT_PATH") lines"
  exit 0
fi

echo "[build-llms] generating llms.txt..."
build_llms_txt
echo "[build-llms] generating llms-full.txt..."
build_llms_full_txt

llms_bytes="$(bytes "$LLMS_TXT_PATH")"
full_bytes="$(bytes "$LLMS_FULL_TXT_PATH")"

echo ""
echo "  llms.txt:      $llms_bytes bytes, $(lines "$LLMS_TXT_PATH") lines"
echo "  llms-full.txt: $full_bytes bytes, $(lines "$LLMS_FULL_TXT_PATH") lines"

# Budget warning
if (( full_bytes > LLMS_FULL_MAX_BYTES )); then
  echo ""
  echo "  WARNING: llms-full.txt exceeds budget ($full_bytes > $LLMS_FULL_MAX_BYTES bytes)" >&2
  echo "  Consider: trimming SKILL_PREVIEW_CHARS in llms-config.sh, excluding more rules, or splitting." >&2
fi

echo ""
echo "[build-llms] Done. Written to $LLMS_TXT_PATH and $LLMS_FULL_TXT_PATH"
