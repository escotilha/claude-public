---
name: contably-overseer-resume-handoff
description: Resume from 2026-05-02 ~16:35 UTC. Engine PAUSED. 130 PRs merged today but staging is BROKEN — alembic chain has 4 unconnected heads + 1 ruff failure. STAGING NO-GO until chain repaired. PRODUCTION NO-GO. Read on /primer.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---

# RESUME — Contably overseer, 2026-05-02 ~16:35 UTC

## ⚠️ CRITICAL — staging is uninstallable

**130 PRs merged into main today, but the latest Deploy Staging FAILED.** Two real regressions:

### 1. Alembic migration chain broken — 4 unconnected heads
```
HEADS (uncalled by anything):
  046  20260413_180000_046_rename_company_user_roles.py
  031  20260315_100001_031_add_sefaz_webhook_events.py
  055  20260414_130000_055_sync_bank_model_columns.py
  025  20260127_130100_025_extend_uploads_ocr.py

ORPHANS (down_revision points to nothing):
  20260414_130000_055_sync_bank_model_columns.py     down=054 (missing)
  20260127_130100_025_extend_uploads_ocr.py          down=024 (missing)
  20260315_120000_030_add_lineage_tickets_notifications.py  down=030 (missing)
  20260413_180000_046_rename_company_user_roles.py   down=045 (missing)
```

CI symptom: `ProgrammingError: (1146, "Table 'contably_ci.fiscal_certificates' doesn't exist")` when running `ALTER TABLE fiscal_certificates ADD COLUMN manager_saas_cert_id`. Migration ordering broken.

### 2. Ruff lint failure in apps/api/src/
"1 fixable with the --fix option" — single auto-fixable rule violation slipping past CI somehow. Run `ruff check apps/api/src/ --fix` locally to see + fix.

## Why this happened

- Engine merged 130 PRs in one day with auto-merge-clean
- Some PRs added new alembic migrations with stale `down_revision` (pointing to a parent that was deleted/renamed in another concurrent PR)
- CI's `Backend CI` was passing per-PR (each PR's migration was valid against its base sha) but the MERGED sequence on main has broken links
- Pre-existing issue or new — both are possible. Either way, **staging cannot install**, so production cannot promote

## Engine state RIGHT NOW

- **PAUSED** by Pierre at ~13:40 UTC, restarted ~14:23 UTC, paused again at ~16:30 UTC
- 130 PRs merged today (UTC), 38 still open in CI (some auto-merge cron will land overnight)
- 54 planned tasks queued (CODEGEN-P1/P2/P3 + ESOCIAL-P1 + Atlas-50 part 2 + leftover Q3-CLOSE-T2)
- ANTHROPIC_API_KEY in Keychain (`anthropic-api-key`, account `psm2`) — fallback for when Max-plan quota hits

## DO NOT restart engine until alembic chain is fixed

**This is not a stop-and-think pause — it's a real blocker.** Restarting the engine right now means more PRs get merged into a main that already cannot deploy. Fix-first.

## Tomorrow's morning priorities (in order)

1. **`/alembic-chain-repair`** skill — exists exactly for this. Will analyze the chain, propose a repair script, walk you through it. ~30-60 min.
2. **Fix the ruff failure**: `cd apps/api && ruff check src/ --fix` — should be 1 line
3. **Push the fix as a single commit**: `chore(ci): repair alembic chain + ruff fix`
4. **Watch Deploy Staging** — should pass with the fixed chain
5. **`/qa-conta-gate`** — automated browser smoke test on staging before promoting to production
6. **THEN** consider production promotion via `gh workflow run deploy-production.yml --field image_tag=stg-<sha> --field confirm=yes`

## Engine restart command (only AFTER step 4 above succeeds)

```bash
cd /Volumes/AI/Code/contably
export ANTHROPIC_API_KEY="$(security find-generic-password -s anthropic-api-key -a psm2 -w)"
tmux new-session -d -s oxi-overseer "exec python3 -m infra.overseer.loop \
  --repo Contably/contably \
  --oxi-db /Volumes/AI/Code/contably/.oxi/oxi.db \
  --max-workers 5 \
  --worker-cmd claude --dangerously-skip-permissions -p"
```

⚠️ NEVER use `\$(...)` inside the tmux string — passes literal text. See `semantic/mistake_tmux_command_substitution_not_expanded.md`.

## Key fixes shipped this session

- **PR #900** lock_db CANTOPEN retry — MERGED
- **PR #901** orphan-lock startup sweep — MERGED
- **PR #890** path-filter ci.yml for doc/dashboard PRs — MERGED
- **PR #942** codex-grok integration design plan — MERGED
- **commit 085b873** workflow_call permissions fix (Deploy Staging permissions: pull-requests: read) — pushed direct to main

## What NOT to do tomorrow

- ❌ Don't queue more waves until chain is repaired
- ❌ Don't restart engine — it'll merge more into a broken main
- ❌ Don't promote to production until /qa-conta-gate passes on staging
- ❌ Don't run `alembic upgrade head` against staging until repair is committed

## Active background polls (may have died with session)

- 120-merged milestone (already fired — count is 130)
- CODEGEN-P0 completion (likely fired, was waiting for CODEGEN-P0 to leave planned/dispatched — those are merged now)
- queue watchdog (already fired multiple times)
- engine health monitor

These are dead with session. Re-arm only after steps 1-4.

## Memory entries added this session

- `personal/reference_anthropic_api_key.md` — Keychain reference
- `personal/reference_xai_grok_api_key.md` — Grok Keychain reference
- `personal/preference_opus_for_spec_drafting.md` — HARD RULE: opus for briefs
- `semantic/mistake_tmux_command_substitution_not_expanded.md` — `$(cmd)` in tmux strings
- `semantic/mistake_workflow_call_caller_permissions.md` — workflow_call caller cannot grant more perms than itself

## Today by the numbers

- **130 PRs merged** (10× normal Pierre-day, 16× top-tier-dev-day)
- **6 waves drafted by opus** (CODEGEN-P0/P1/P2/P3, Atlas-50 part 2, eSocial-P1)
- **54 tasks still queued** for next session
- **2 GHA workflow bugs found + fixed** (path-filter permissions + workflow_call caller permissions)
- **3 engine bugs shipped** (CANTOPEN retry, orphan sweep, quota breaker)
- **1 alembic chain break introduced** — the cost of merging without smoke-testing
- **1 ruff regression slipped through** — same root cause

## API keys (Keychain)

| Key | Service | Account | Purpose |
|---|---|---|---|
| Anthropic | `anthropic-api-key` | `psm2` | oxi engine workers (API billing fallback) |
| xAI Grok | `xai-api-key` | `psm2` | Codegen lane (Phase 0/1 testing) |

## Recommendation for engine going forward

The autonomous engine is shipping 130 PRs/day faster than CI can validate them. Two fixes to consider:

1. **Add migration-chain-validity check to `Detect code changes`** — fail PR if the merged sequence on `origin/main` would have orphan/multi-head state after this PR lands. Caught BEFORE merge, not after.
2. **Add ruff to the `continue-on-error: false` set** OR fix the auto-merge-clean cron to require ruff green. Currently a single ruff regression breaks ALL deploys.

These are higher-leverage than another wave. Could queue as `ENGINE-V3-MIGRATION-VALIDITY` + `ENGINE-V3-RUFF-GATE`.
