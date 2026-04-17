#!/usr/bin/env bash
# cs-public-extras.sh — run AFTER step 1 (commit) and BEFORE step 2 (push).
# Produces:
#   1. README.pt.md inside any public skill that lacks one (Haiku-generated)
#   2. README.md refresh at repo root with "Últimas 3 atualizações" section
# Exits 0 on success, non-zero on fatal error (caller should decide to proceed).

set -euo pipefail

SETUP_DIR="${SETUP_DIR:-$HOME/.claude-setup}"
cd "$SETUP_DIR"

# Skills excluded from the public repo (kept in sync with /cs step 3).
EXCLUDED_SKILLS=(
  qa-conta qa-sourcerank qa-stonegeo virtual-user-testing oci-health
  proposal-source chief-geo health-report cs cpr sc slack agentmail tweet
  gws claude-setup-optimizer memory-consolidation meditate test-memory
  deploy-conta-staging deploy-conta-production deploy-conta-full
  deploy-sourcerank deploy-claudia contably-guardian sourcerank-guardian
  pr-impact rex mini-remote nanoclaw computer-use office-hours primer
  vibc discord loop schedule verify-conta _archive
)

is_excluded() {
  local name="$1"
  for x in "${EXCLUDED_SKILLS[@]}"; do
    [[ "$name" == "$x" ]] && return 0
  done
  return 1
}

# List public skill dirs (excludes private ones + _archive).
public_skills() {
  for d in skills/*/; do
    local name
    name="$(basename "$d")"
    is_excluded "$name" && continue
    [[ -f "$d/SKILL.md" ]] || continue
    echo "$name"
  done
}

# Generate a Portuguese README for a single skill using Claude Haiku.
# Takes skill name, reads SKILL.md, writes README.pt.md in the skill folder.
generate_pt_readme() {
  local skill="$1"
  local skill_md="skills/$skill/SKILL.md"
  local out_md="skills/$skill/README.pt.md"

  [[ -f "$skill_md" ]] || { echo "  skip $skill (no SKILL.md)"; return 0; }
  [[ -f "$out_md" ]] && { echo "  skip $skill (README.pt.md exists)"; return 0; }

  echo "  generating README.pt.md for $skill"

  local api_key
  api_key="$(security find-generic-password -s claude-code-anthropic-api-key -w 2>/dev/null || true)"
  if [[ -z "$api_key" ]]; then
    api_key="$(security find-generic-password -s ANTHROPIC_API_KEY -w 2>/dev/null || true)"
  fi
  if [[ -z "$api_key" ]]; then
    api_key="${ANTHROPIC_API_KEY:-}"
  fi
  if [[ -z "$api_key" ]]; then
    echo "  WARN: ANTHROPIC_API_KEY not found — skipping $skill" >&2
    return 0
  fi

  local skill_content
  skill_content="$(cat "$skill_md")"

  local prompt="Você está documentando um Claude Code skill para desenvolvedores brasileiros. Leia o SKILL.md abaixo e produza um README.pt.md conciso em português brasileiro com:

1. Título: # {nome do skill}
2. Seção '## O que faz' (1-2 parágrafos, direto ao ponto)
3. Seção '## Como invocar' (comando de slash + exemplos curtos)
4. Seção '## Quando usar' (lista com 2-4 bullets)

Tom: técnico, direto, sem marketing. Máximo 250 palavras. Retorne APENAS o markdown, sem cercas de código ao redor do arquivo inteiro.

SKILL.md:
---
$skill_content
---"

  local response
  response="$(curl -sS https://api.anthropic.com/v1/messages \
    -H "x-api-key: $api_key" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    --data @<(jq -n --arg p "$prompt" '{
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      messages: [{role: "user", content: $p}]
    }'))"

  local text
  text="$(echo "$response" | jq -r '.content[0].text // empty')"
  if [[ -z "$text" ]]; then
    echo "  WARN: empty response for $skill" >&2
    echo "$response" | head -c 500 >&2
    return 0
  fi

  echo "$text" > "$out_md"
}

# Refresh root README.md with "Últimas 3 atualizações" based on git log.
refresh_root_readme() {
  echo "refreshing root README.md"

  local readme="README.md"
  [[ -f "$readme" ]] || { echo "  skip: README.md missing"; return 0; }

  local recent
  recent="$(git log -3 --pretty=format:'- **%ad** — %s' --date=short -- . 2>/dev/null || echo '')"
  [[ -z "$recent" ]] && { echo "  skip: no git history"; return 0; }

  local tmp="$(mktemp)"
  # Strip any existing "## Últimas 3 atualizações" section (from previous runs)
  awk '
    /^## Últimas 3 atualizações$/ { skip=1; next }
    skip && /^## / { skip=0 }
    !skip { print }
  ' "$readme" > "$tmp"

  # Append the fresh section at the end
  {
    cat "$tmp"
    echo ""
    echo "## Últimas 3 atualizações"
    echo ""
    echo "$recent"
    echo ""
  } > "$readme"
  rm -f "$tmp"
}

# Post Slack notification. Reads token from Keychain.
# Args: channel_id message
post_slack() {
  local channel="$1"
  local message="$2"

  local token
  token="$(security find-generic-password -s claude-code-slack-bot-token -w 2>/dev/null || true)"
  if [[ -z "$token" ]]; then
    token="$(security find-generic-password -s SLACK_BOT_TOKEN -w 2>/dev/null || true)"
  fi
  if [[ -z "$token" ]]; then
    echo "  WARN: Slack bot token not in Keychain — skipping Slack post" >&2
    return 0
  fi

  local payload
  payload="$(jq -n --arg ch "$channel" --arg txt "$message" '{channel: $ch, text: $txt}')"

  local response
  response="$(curl -sS -X POST https://slack.com/api/chat.postMessage \
    -H "Authorization: Bearer $token" \
    -H "Content-type: application/json; charset=utf-8" \
    --data "$payload")"

  if [[ "$(echo "$response" | jq -r '.ok // false')" != "true" ]]; then
    echo "  WARN: Slack post failed: $(echo "$response" | jq -r '.error // "unknown"')" >&2
    return 0
  fi
  echo "  Slack: posted to $channel"
}

# Build a dynamic message listing new/changed skills since last push to public.
# Baseline: local tag `cs-last-push` (updated at end of each successful run).
# If the tag doesn't exist yet, falls back to HEAD~5 — good enough for first few runs.
build_slack_message() {
  local base_ref
  if git rev-parse --verify --quiet refs/tags/cs-last-push > /dev/null; then
    base_ref="cs-last-push"
  else
    # First run — diff last 5 commits to capture recent activity
    base_ref="HEAD~5"
    git rev-parse --verify --quiet "$base_ref" > /dev/null || base_ref="$(git rev-list --max-parents=0 HEAD | head -1)"
  fi

  local changed_skills
  changed_skills="$(git diff --name-only "$base_ref"...HEAD -- 'skills/' 2>/dev/null \
    | awk -F/ 'NF>=2 {print $2}' | sort -u)"

  local new_skills=""
  local updated_skills=""
  while IFS= read -r s; do
    [[ -z "$s" ]] && continue
    is_excluded "$s" && continue
    # "new" means the skill dir didn't exist at the baseline commit
    if git cat-file -e "$base_ref":"skills/$s/SKILL.md" 2>/dev/null; then
      updated_skills+=" $s"
    else
      new_skills+=" $s"
    fi
  done <<< "$changed_skills"

  local msg="📦 Nova atualização no repo: https://github.com/escotilha/claude-public"
  if [[ -n "$new_skills" ]]; then
    msg+=$'\n'"🆕 Novos skills:$new_skills"
  fi
  if [[ -n "$updated_skills" ]]; then
    msg+=$'\n'"🔧 Atualizados:$updated_skills"
  fi
  echo "$msg"
}

# -------- Entry points --------

cmd="${1:-all}"

case "$cmd" in
  backfill-readmes)
    echo "Backfilling README.pt.md for all public skills…"
    for skill in $(public_skills); do
      generate_pt_readme "$skill"
    done
    ;;
  refresh-root)
    refresh_root_readme
    ;;
  notify-slack)
    channel="${2:-C0AS64REV4J}"
    msg="$(build_slack_message)"
    if post_slack "$channel" "$msg"; then
      # Advance the baseline tag so next run diffs from here
      git tag -f cs-last-push HEAD > /dev/null 2>&1
    fi
    ;;
  all)
    # Run after step 1 (commit) so new skills already on disk get READMEs.
    for skill in $(public_skills); do
      generate_pt_readme "$skill"
    done
    refresh_root_readme
    # Stage any READMEs we generated.
    git add -A
    git diff --cached --quiet || git commit -m "docs: update Portuguese READMEs + root summary"
    ;;
  *)
    echo "usage: $0 {backfill-readmes|refresh-root|notify-slack [channel]|all}" >&2
    exit 1
    ;;
esac
