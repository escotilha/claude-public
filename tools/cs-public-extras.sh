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
  qa-conta qa-conta-gate qa-sourcerank qa-stonegeo virtual-user-testing oci-health
  proposal-source chief-geo health-report cs cpr sc slack agentmail tweet
  gws claude-setup-optimizer memory-consolidation meditate test-memory
  deploy-conta-staging deploy-conta-production deploy-conta-full
  deploy-sourcerank deploy-claudia contably-guardian sourcerank-guardian
  pr-impact rex mini-remote nanoclaw computer-use office-hours primer
  vibc discord loop schedule verify-conta contably-ci-rescue contably-eod
  contably-snapshot alembic-chain-repair qa-verify conta-cpo _archive
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
  local blocks_json="${3:-}"

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
  if [[ -n "$blocks_json" ]]; then
    payload="$(jq -n --arg ch "$channel" --arg txt "$message" --argjson bl "$blocks_json" \
      '{channel: $ch, text: $txt, blocks: $bl}')"
  else
    payload="$(jq -n --arg ch "$channel" --arg txt "$message" '{channel: $ch, text: $txt}')"
  fi

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

# Extract the Portuguese "O que faz" summary from a skill's README.pt.md.
# Returns the first paragraph after "## O que faz", trimmed.
# Falls back to the SKILL.md description field if README.pt.md is missing.
extract_pt_summary() {
  local skill="$1"
  local pt_md="skills/$skill/README.pt.md"
  local skill_md="skills/$skill/SKILL.md"

  if [[ -f "$pt_md" ]]; then
    # Grab the content between "## O que faz" and the next "## " heading,
    # then join lines and squeeze whitespace.
    local summary
    summary="$(awk '
      /^## O que faz/ { in_section=1; next }
      /^## / && in_section { exit }
      in_section { print }
    ' "$pt_md" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ +//; s/ +$//')"
    if [[ -n "$summary" ]]; then
      echo "$summary"
      return 0
    fi
  fi

  # Fallback: SKILL.md description
  if [[ -f "$skill_md" ]]; then
    awk '/^description:/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^["\x27]|["\x27]$/, "")
      print
      exit
    }' "$skill_md"
  fi
}

# Build a dynamic Block Kit message listing new/changed skills since last push.
# Baseline: local tag `cs-last-push` (updated at end of each successful run).
# Outputs: "<plain-text-fallback>|||<json-blocks>" — caller splits on |||.
build_slack_message() {
  local base_ref
  if git rev-parse --verify --quiet refs/tags/cs-last-push > /dev/null; then
    base_ref="cs-last-push"
  else
    base_ref="HEAD~5"
    git rev-parse --verify --quiet "$base_ref" > /dev/null || base_ref="$(git rev-list --max-parents=0 HEAD | head -1)"
  fi

  local changed_skills
  changed_skills="$(git diff --name-only "$base_ref"...HEAD -- 'skills/' 2>/dev/null \
    | awk -F/ 'NF>=2 {print $2}' | sort -u)"

  local new_list=() updated_list=()
  while IFS= read -r s; do
    [[ -z "$s" ]] && continue
    is_excluded "$s" && continue
    [[ -f "skills/$s/SKILL.md" ]] || continue
    if git cat-file -e "$base_ref":"skills/$s/SKILL.md" 2>/dev/null; then
      updated_list+=("$s")
    else
      new_list+=("$s")
    fi
  done <<< "$changed_skills"

  # If nothing changed, emit a minimal message
  if [[ ${#new_list[@]} -eq 0 && ${#updated_list[@]} -eq 0 ]]; then
    local fallback="📦 Sync do repo claude-public — sem skills novos ou atualizados nesta rodada. https://github.com/escotilha/claude-public"
    local blocks
    blocks="$(jq -n --arg t "$fallback" '[{type:"section",text:{type:"mrkdwn",text:$t}}]')"
    printf '%s|||%s' "$fallback" "$blocks"
    return 0
  fi

  # Build plain-text fallback (for notifications + clients without block support)
  local fallback="📦 Nova atualização em claude-public"
  [[ ${#new_list[@]} -gt 0 ]] && fallback+=" — 🆕 ${new_list[*]}"
  [[ ${#updated_list[@]} -gt 0 ]] && fallback+=" — 🔧 ${updated_list[*]}"

  # Start with a header block
  local blocks_json
  blocks_json='[{"type":"section","text":{"type":"mrkdwn","text":"📦 Nova atualização em *claude-public*"}}]'

  # New skills: one section per skill with name + PT summary.
  if [[ ${#new_list[@]} -gt 0 ]]; then
    blocks_json="$(printf '%s' "$blocks_json" | jq -c '. += [{type:"divider"},{type:"section",text:{type:"mrkdwn",text:"*🆕 Novos skills*"}}]')"
    for s in "${new_list[@]}"; do
      local summary
      summary="$(extract_pt_summary "$s")"
      # Defense-in-depth: scrub any leaked project-private tokens before Slack sees them.
      summary="$(printf '%s' "$summary" | sed -E \
        -e 's/Contably/ExampleProject/g' \
        -e 's/contably\.ai/example\.com/g' \
        -e 's/p@contably\.ai/hello@example\.com/g' \
        -e 's/contably/example-project/g' \
        -e 's/SourceRank AI/ProjectB/g' \
        -e 's/SourceRank/ProjectB/g' \
        -e 's/sourcerank/projectb/g' \
        -e 's/StoneGEO/ProjectC/g' \
        -e 's/stonegeo/projectc/g' \
        -e 's/AgentWave/ProjectD/g' \
        -e 's/OpenClaw/ProjectE/g' \
        -e 's/Nuvini/Example/g' \
        -e 's/nuvini/example/g' \
        -e 's/Contabo/external VPS/g' \
        -e 's/100\.77\.51\.51/<VPS_HOST>/g' \
        -e 's/pluggy/bank-integration/g' \
        -e 's/escotilha@gmail\.com/user@example\.com/g' \
        -e 's/p@nuvini\.ai/hello@example\.com/g')"
      if (( ${#summary} > 400 )); then
        summary="${summary:0:397}..."
      fi
      # Use jq -c to emit compact JSON with properly escaped newlines.
      blocks_json="$(printf '%s' "$blocks_json" | jq -c --arg name "$s" --arg sum "$summary" \
        '. += [{type:"section",text:{type:"mrkdwn",text:("• */" + $name + "*  —  _" + $sum + "_")}}]')"
    done
  fi

  # Updated skills: single section listing names only, comma-separated.
  if [[ ${#updated_list[@]} -gt 0 ]]; then
    local updated_joined=""
    for u in "${updated_list[@]}"; do
      [[ -n "$updated_joined" ]] && updated_joined+=", "
      updated_joined+="$u"
    done
    local updated_line="*Skills atualizados:* $updated_joined"
    blocks_json="$(printf '%s' "$blocks_json" | jq -c --arg line "$updated_line" \
      '. += [{type:"divider"},{type:"section",text:{type:"mrkdwn",text:$line}}]')"
  fi

  # Footer with repo link
  blocks_json="$(printf '%s' "$blocks_json" | jq -c \
    '. += [{type:"context",elements:[{type:"mrkdwn",text:"<https://github.com/escotilha/claude-public|Ver no GitHub →>"}]}]')"

  printf '%s|||%s' "$fallback" "$blocks_json"
}

# -------- Entry points --------

cmd="${1:-all}"

case "$cmd" in
  list-missing-pt)
    # Print public skills (one per line) that have SKILL.md but no README.pt.md.
    # Used by the /cs skill so Claude can write the READMEs directly.
    for skill in $(public_skills); do
      [[ -f "skills/$skill/README.pt.md" ]] && continue
      echo "$skill"
    done
    ;;
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
    raw="$(build_slack_message)"
    # Split on "|||" delimiter: first half is plain-text fallback, second is JSON blocks.
    fallback="${raw%%|||*}"
    blocks="${raw#*|||}"
    # Final safety gate: abort if any private token survived scrubbing.
    leak_pattern='contably|sourcerank|stonegeo|agentwave|openclaw|contabo|vmi3065960|pluggy|nuvini|escotilha@|p@contably|p@nuvini|100\.77\.51\.51'
    if printf '%s\n%s' "$fallback" "$blocks" | grep -iEq "$leak_pattern"; then
      echo "  ABORT: private token survived scrub in Slack payload — refusing to post" >&2
      printf '%s\n%s\n' "$fallback" "$blocks" | grep -iE "$leak_pattern" >&2
      exit 1
    fi
    if post_slack "$channel" "$fallback" "$blocks"; then
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
  push-public)
    # Orphan-push to escotilha/claude-public: always single-commit, no history carried.
    # Prevents Contably references from ever leaking via git log — every run is a clean slate.
    prev_branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo master)"

    git branch -D nuvini-public-fresh 2>/dev/null || true

    # Stash the public README to a temp location BEFORE we git rm tools/.
    public_readme_tmp="$(mktemp)"
    if [[ -f "$SETUP_DIR/tools/cs-public-readme.md" ]]; then
      cp "$SETUP_DIR/tools/cs-public-readme.md" "$public_readme_tmp"
    fi

    git checkout --orphan nuvini-public-fresh > /dev/null 2>&1
    git reset --hard > /dev/null 2>&1
    git checkout master -- .

    git rm -rf --quiet --ignore-unmatch \
      secrets/ memory/ tools/ hooks/ rules/ backups/ config/ launchd/ plans/ guides/ \
      bin/ commands/ mcp-servers/ settings.json .deep-plan-state.json .gstack/ \
      settings.json.backup* settings.json.bak* settings.local.json \
      plan.md research.md .github/ SETUP-BASELINE.md

    # Purge any remaining backup/secret/env files anywhere in the tree (defense-in-depth).
    for pat in '*.bak' '*.backup' '*.bak-*' '*.env' '.env.*' '*.credentials' \
               '*secret*.json' '*credentials*.json' '*.key' '*.pem' '*.p12'; do
      while IFS= read -r f; do
        [[ -n "$f" ]] && git rm -rf --quiet --ignore-unmatch "$f"
      done < <(git ls-files "$pat" 2>/dev/null)
    done

    for skill in "${EXCLUDED_SKILLS[@]}"; do
      [[ "$skill" == "_archive" ]] && continue
      git rm -rf --quiet --ignore-unmatch "skills/$skill"
    done

    # Swap in the public-facing README (friendlier showcase) + append changelog.
    if [[ -s "$public_readme_tmp" ]]; then
      cp "$public_readme_tmp" README.md
      rm -f "$public_readme_tmp"
      recent="$(git log master -3 --pretty=format:'- **%ad** — %s' --date=short 2>/dev/null || echo '')"
      if [[ -n "$recent" ]]; then
        {
          echo ""
          echo "---"
          echo ""
          echo "## Últimas 3 atualizações"
          echo ""
          echo "$recent"
          echo ""
        } >> README.md
      fi
    fi

    # Scrub project-private mentions across all remaining text files.
    for f in $(git ls-files); do
      [[ -f "$f" ]] || continue
      file -b --mime "$f" 2>/dev/null | grep -q "charset=binary" && continue
      sed -i '' -E \
        -e 's/Contably/ExampleProject/g' \
        -e 's/contably\.ai/example\.com/g' \
        -e 's/p@contably\.ai/hello@example\.com/g' \
        -e 's/contably_test/example_test/g' \
        -e 's/\/contably-ci-rescue/\/ci-rescue/g' \
        -e 's/\/contably-guardian/\/guardian/g' \
        -e 's/\/verify-conta/\/verify/g' \
        -e 's/\/qa-conta/\/qa-cycle/g' \
        -e 's/\/deploy-conta-staging/\/deploy-staging/g' \
        -e 's/\/deploy-conta-production/\/deploy-production/g' \
        -e 's/\/deploy-conta-full/\/deploy-full/g' \
        -e 's/platform-sweep-contably/platform-sweep-example/g' \
        -e 's/contably-auth-strategy/example-auth-strategy/g' \
        -e 's/contably-stack/example-stack/g' \
        -e 's/contably-colors/example-colors/g' \
        -e 's/\/alembic-chain-repair//g' \
        -e 's/\/qa-verify//g' \
        -e 's/alembic-chain-repair//g' \
        -e 's/qa-verify//g' \
        -e 's/contably[- ]?ai/example-project/g' \
        -e 's/contably/example-project/g' \
        -e 's/SourceRank AI/ProjectB/g' \
        -e 's/SourceRank/ProjectB/g' \
        -e 's/sourcerankai/projectb/g' \
        -e 's/sourcerank/projectb/g' \
        -e 's/StoneGEO/ProjectC/g' \
        -e 's/stonegeo/projectc/g' \
        -e 's/AgentWave/ProjectD/g' \
        -e 's/agentwave/projectd/g' \
        -e 's/OpenClaw/ProjectE/g' \
        -e 's/openclaw/projecte/g' \
        -e 's/Nuvini Group/Example Group/g' \
        -e 's/nuvini-brand/example-brand/g' \
        -e 's/nuvini-claude/example-claude/g' \
        -e 's/share-to-nuvini/share-to-example/g' \
        -e 's/nuvini\.ai/example\.com/g' \
        -e 's/Nuvini/Example/g' \
        -e 's/nuvini/example/g' \
        -e 's/NVNI, Nasdaq/PUBCO, Nasdaq/g' \
        -e 's/\(NVNI\)/(PUBCO)/g' \
        -e 's/Contabo \(`vmi[0-9]+`\)/an external VPS/g' \
        -e 's/vmi3065960/vps-host/g' \
        -e 's/Contabo/external VPS/g' \
        -e 's/contabo/external-vps/g' \
        -e 's/100\.77\.51\.51/<VPS_HOST>/g' \
        -e 's/root@<VPS_HOST>/user@<VPS_HOST>/g' \
        -e 's/pluggy/bank-integration/g' \
        -e 's/Pluggy/BankIntegration/g' \
        -e 's/escotilha@gmail\.com/user@example\.com/g' \
        -e 's/p@nuvini\.ai/hello@example\.com/g' \
        -e 's/São Paulo/(city)/g' \
        "$f" 2>/dev/null || true
    done

    git add -A
    git commit -m "public claude-code skills library" --allow-empty > /dev/null

    # Secret-pattern gate: abort if anything looks like a live API key or token.
    # Every pattern requires at least one DIGIT in the key body, which filters English
    # identifiers like re_returns_specific_error while keeping real keys (Resend,
    # Brave, Anthropic, etc. all have digits).
    # Real Resend keys: re_{28}chars with digits, e.g. re_SBHeSKNj_AM1wzDrF5eJZ2LKmuyDyNvE2
    # Real Brave keys: BSA{26}chars with digits, e.g. BSAYdiKG6QoqYPSm9rCGdPlwM_fnzNu
    secret_pattern='(\bre_[A-Za-z0-9_]*[0-9][A-Za-z0-9_]{18,}|\bsk-ant-[A-Za-z0-9_-]*[0-9][A-Za-z0-9_-]{40,}|\bsk-proj-[A-Za-z0-9_-]*[0-9][A-Za-z0-9_-]{40,}|\bsk-[A-Za-z0-9]*[0-9][A-Za-z0-9]{48,}|\bgh[pousr]_[A-Za-z0-9]{36}|\bxox[baprs]-[0-9]+-[0-9]+-[A-Za-z0-9]+|\bAKIA[0-9A-Z]{16}\b|\beyJhbGciOi[A-Za-z0-9._-]{100,}|\bBSA[A-Za-z0-9_]*[0-9][A-Za-z0-9_]{20,})'
    if git grep -E -l "$secret_pattern" > /dev/null 2>&1; then
      echo "  ABORT: likely live secret/API key detected in public tree:" >&2
      git grep -E -n "$secret_pattern" >&2 || true
      git checkout "$prev_branch" > /dev/null 2>&1
      git branch -D nuvini-public-fresh > /dev/null 2>&1
      exit 1
    fi

    # Extended safety gate: fail on any private token surviving the scrub.
    leak_pattern='contably|sourcerank|stonegeo|agentwave|openclaw|contabo|vmi3065960|pluggy|nuvini|escotilha@|p@contably|p@nuvini|100\.77\.51\.51'
    if git grep -iE -l "$leak_pattern" > /dev/null 2>&1; then
      echo "  ABORT: private token still present in public tree after scrub:" >&2
      git grep -iE -n "$leak_pattern" >&2
      git checkout "$prev_branch" > /dev/null 2>&1
      git branch -D nuvini-public-fresh > /dev/null 2>&1
      exit 1
    fi

    unset GITHUB_TOKEN
    git remote set-url public https://github.com/escotilha/claude-public.git 2>/dev/null \
      || git remote add public https://github.com/escotilha/claude-public.git
    git push public nuvini-public-fresh:main --force

    git checkout "$prev_branch" > /dev/null 2>&1
    git branch -D nuvini-public-fresh > /dev/null 2>&1

    echo "  public: orphan-pushed (single commit, no history)"
    ;;
  *)
    echo "usage: $0 {backfill-readmes|refresh-root|notify-slack [channel]|push-public|all}" >&2
    exit 1
    ;;
esac
