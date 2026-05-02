---
name: contably-overseer-resume-handoff
description: Resume block from session ending 2026-05-02 ~13:40 UTC. Engine PAUSED by Pierre. 98 merged today, 46 open, 19 planned tasks. API key in Keychain. Read on /primer.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---

# RESUME — Contably overseer, 2026-05-02 ~13:40 UTC

**Pierre's directive: consistency over acceleration. Pause → evaluate → adapt → keep going.**

## Engine state RIGHT NOW

- **PAUSED** intentionally by Pierre at 13:40 UTC.
- Tmux server dead. No `infra.overseer.loop` process.
- **19 tasks planned** in `.oxi/v5/tasks.db`.
- **46 oxi-v5 PRs open** in GitHub (all in CI or waiting for auto-merge).
- **98 PRs merged today** (UTC day).
- **ANTHROPIC_API_KEY** saved in Keychain (`anthropic-api-key`, account `psm2`). Confirmed working (HTTP 200). Use API billing going forward — Max-plan hit org monthly quota at 13:08 UTC.

## How to restart engine

```bash
cd /Volumes/AI/Code/contably
export ANTHROPIC_API_KEY="$(security find-generic-password -s anthropic-api-key -a psm2 -w)"
tmux new-session -d -s oxi-overseer "exec python3 -m infra.overseer.loop \
  --repo Contably/contably \
  --oxi-db /Volumes/AI/Code/contably/.oxi/oxi.db \
  --max-workers 5 \
  --worker-cmd claude --dangerously-skip-permissions -p"
```

⚠️ **CRITICAL**: Export the API key in the PARENT shell BEFORE `tmux new-session`. Never use `\$(...)` inside the tmux string — it passes literal text, not the resolved value.

Verify:
```bash
ps -ef | grep "infra.overseer.loop" | grep -v grep
tail -3 .oxi/v5/overseer.log
```

## Queue state

- **Dispatched**: 202 (already worked on this session)
- **Planned**: 19 (CODEGEN-P0-* + Q3-CLOSE-T2-* + ENGINE-V2-* + A-* Atlas)
- **Failed**: 3 (quota-kills + scope-drift — requeue before restart)
- **Merged in DB**: 6 (note: actual GitHub merges = 98, `pr_number: null` parsing bug understates)

### Requeue failed tasks before restart

```bash
sqlite3 /Volumes/AI/Code/contably/.oxi/v5/tasks.db \
  "SELECT identifier, failure_reason FROM task WHERE status='failed' AND identifier NOT LIKE 'T%';"
# For each quota-kill (failure_reason='worker rc=1'):
sqlite3 /Volumes/AI/Code/contably/.oxi/v5/tasks.db \
  "UPDATE task SET status='planned', branch=NULL, dispatch_count=0, dispatched_at=NULL,
   failed_at=NULL, failure_class='', failure_reason='', failure_signature=''
   WHERE status='failed' AND failure_reason='worker rc=1' AND identifier NOT LIKE 'T%';"
```

## Active background polls (may still be running)

- **120-merged milestone** (`b6u757gy6`) — fires when merged ≥ 120
- **CODEGEN-P0 completion** (`b60oz8zxx`) — fires when all 4 CODEGEN-P0-* tasks leave planned/dispatched; spawns Phase 1 spec-drafting with **opus** (Pierre's hard rule)

## Today's major waves (what shipped)

| Wave | Tasks | Status |
|---|---|---|
| Phase 6 (P6-*) | 34 | ✅ Fully shipped + merged |
| P9 hooks | 9 | ✅ Fully shipped |
| Throughput (TP-*) | 35 | ✅ Fully shipped |
| Engine self-improvement v1 | 12 | ✅ Fully shipped |
| Sevilha Copiloto base (CSV-P*) | 24 | ✅ Mostly shipped |
| Gamification (CSV-G*) | 17 | 🔄 ~10 shipped, ~7 in queue |
| Go-Live wiring (GL-*) | 17 | ✅ Fully shipped |
| Q3-CLOSE-T2-* | 22 | 🔄 ~8 shipped, ~14 in queue |
| ENGINE-V2-* | 11 | 🔄 ~8 shipped, ~3 in queue |
| CODEGEN-P0-* | 4 | ⏳ Queued, not yet dispatched |
| A-* Atlas-50 | 14 | ⏳ Queued, not yet dispatched |

## PRs to merge when you're back

46 open PRs. Run this to trigger auto-merge-clean:

```bash
gh workflow run auto-merge-clean.yml --repo Contably/contably
```

Or check CLEAN PRs:
```bash
gh pr list --repo Contably/contably --state open --search "head:feat/oxi-v5" --limit 50 \
  --json number,mergeStateStatus --jq '[.[] | select(.mergeStateStatus == "CLEAN")] | length'
```

## Morning priorities

1. Restart engine (command above)
2. Requeue failed tasks
3. Trigger auto-merge-clean (46 open, many CLEAN)
4. Wait for CODEGEN-P0 PRs to merge → Phase 1 spec drafting (opus agent)
5. Consider MAX_WORKERS 5 → 6 if CI free_slots > 8 consistently

## Key fixes shipped this session

- **PR #900** `fix(overseer): retry lock_db._connect on SQLITE_CANTOPEN race` — MERGED
- **PR #901** `fix(overseer): sweep orphan locks on engine startup` — MERGED
- **PR #890** `P6-INF-6: path-filter ci.yml — doc/dashboard PRs skip Backend CI` — MERGED
- **PR #942** `docs(codegen): design plan for Codex + Grok integration` — MERGED

## API keys (Keychain)

| Key | Service | Account | Purpose |
|---|---|---|---|
| Anthropic | `anthropic-api-key` | `psm2` | oxi engine workers (API billing, not Max subscription) |
| xAI Grok | `xai-api-key` | `psm2` | Codegen lane (Phase 0/1 testing) |

## Bugs documented / tasks queued

- `ENGINE-V2-QUOTA-BREAKER` — auto-pause on quota wall (tier 5, queued)
- `ENGINE-V2-POLICY-SKIP-FILELESS` — policy.py skips tasks with no files_touched (tier 5, queued)
- T17/T18 bumped to tier 9 (manual judgment tasks, no files_touched — won't dispatch autonomously)

## Memory entries added this session

- `personal/reference_anthropic_api_key.md` — Keychain reference
- `personal/reference_xai_grok_api_key.md` — Grok Keychain reference
- `personal/preference_opus_for_spec_drafting.md` — HARD RULE: opus for all briefs
- `semantic/mistake_tmux_command_substitution_not_expanded.md` — $(cmd) in tmux string
