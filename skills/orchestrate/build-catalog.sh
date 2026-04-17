#!/usr/bin/env bash
# build-catalog.sh — regenerate skill-catalog.json from ~/.claude-setup/skills/*/SKILL.md
# Called by /orchestrate Pre-Flight step. Fast (<200ms target).
set -euo pipefail

SKILLS_DIR="${HOME}/.claude-setup/skills"
OUT="${HOME}/.claude-setup/skills/orchestrate/skill-catalog.json"
TMP="$(mktemp)"

echo '{"generated_at":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","skills":[' > "$TMP"

first=1
for skill_dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$skill_dir")"
  skill_md="$skill_dir/SKILL.md"
  [[ -f "$skill_md" ]] || continue
  [[ "$name" == "orchestrate" ]] && continue  # don't list self

  # Extract frontmatter between --- ... ---
  fm="$(awk '/^---$/{c++; next} c==1' "$skill_md" 2>/dev/null | head -200)"
  [[ -z "$fm" ]] && continue

  # Grab key fields (best-effort; malformed YAML is skipped)
  desc="$(echo "$fm" | grep -E '^description:' | head -1 | sed -E 's/^description:[[:space:]]*//; s/^"//; s/"$//' | tr -d '\n' | sed 's/"/\\"/g')"
  user_invocable="$(echo "$fm" | grep -E '^user-invocable:' | head -1 | sed -E 's/^user-invocable:[[:space:]]*//')"
  model="$(echo "$fm" | grep -E '^model:' | head -1 | sed -E 's/^model:[[:space:]]*//')"
  effort="$(echo "$fm" | grep -E '^effort:' | head -1 | sed -E 's/^effort:[[:space:]]*//')"
  arg_hint="$(echo "$fm" | grep -E '^argument-hint:' | head -1 | sed -E 's/^argument-hint:[[:space:]]*//; s/^"//; s/"$//' | tr -d '\n' | sed 's/"/\\"/g')"

  # Skip non-user-invocable skills
  [[ "$user_invocable" == "false" ]] && continue

  # Emit JSON record
  if [[ $first -eq 0 ]]; then echo "," >> "$TMP"; fi
  first=0
  cat >> "$TMP" <<EOF
  {"name":"$name","description":"${desc:-}","model":"${model:-unknown}","effort":"${effort:-unknown}","argument_hint":"${arg_hint:-}"}
EOF
done

echo ']}' >> "$TMP"

# Pretty-print if jq is available
if command -v jq >/dev/null 2>&1; then
  jq . "$TMP" > "$OUT"
else
  mv "$TMP" "$OUT"
fi
rm -f "$TMP"

count=$(command -v jq >/dev/null 2>&1 && jq '.skills | length' "$OUT" || grep -c '"name"' "$OUT")
echo "Catalog rebuilt: $OUT ($count skills)"
