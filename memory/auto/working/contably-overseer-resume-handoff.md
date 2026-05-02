---
name: contably-overseer-resume-handoff
description: 2026-05-02 ~17:30 UTC — STAGING GREEN. Alembic chain repaired, 4754c3d deployed, https://staging-api.contably.ai/health returns 200. Engine still PAUSED. Production NO-GO (per Pierre — "definitely not pushing into production today"). Tomorrow: /qa-conta-gate then prod promote.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---

# RESUME — Contably overseer, 2026-05-02 ~17:30 UTC

## ✅ STAGING IS GREEN

After ~6 hours of staging blackout, all 3 root causes shipped + landed:

| # | Issue | Fix | Commit |
|---|-------|-----|--------|
| 1 | 10 alembic heads from auto-merge cron | `/alembic-chain-repair` collapse + ruff autofix | `58a44f23b` |
| 2 | `closing_periods` had no CREATE TABLE migration; FK from `pending_adjustments` failed | New idempotent migration `7ca9e4ad9ccd` creates closing_* tables AND merges 2 remaining heads | `826c6df02` |
| 3 | Chain order — `pending_adjustments` runs BEFORE `7ca9e4ad9ccd` head, so fresh CI still failed FK | Defensive `if not table_exists("closing_periods"): op.create_table(...)` inside t2_106a | `4754c3d0a` |
| 4 | `REDIS_URL_STAGING` + 8 other `*_STAGING` secrets missing/stale in repo | Pulled from K8s `contably-secrets` via kubectl, set via gh secret set | (Pierre handled) |
| 5 | `deploy-staging.yml` workflow_call permission gap | Added `pull-requests: read` | `085b87363` (earlier in session) |

**Cluster state right now:**
- `contably-api`, `celery-worker`, `celery-beat`, `dashboard`, `portal` → all rolled to `stg-4754c3d`
- 3/3 api pods Running, 0 restarts
- `https://staging-api.contably.ai/health` → 200 `{"status":"healthy"}`
- `https://staging.contably.ai/` (admin) → 200
- `/openapi.json` → 200, openapi schema renders (with pre-existing `export_reconciliations` duplicate-OperationID warning — not a regression)
- A real authenticated user request to `/api/v1/client/messages/conversations` returned 200 mid-rollout — staging is live

## ⛔ Production NO-GO today

Pierre's directive (verbatim 2026-05-02 ~16:50 UTC):
> "I do not want to stop today. We are definitely are not pushing anything into production today. But we do need to fix testing and deploy to staging. Keep plugging away until you fix"

Staging is fixed ✅. **Do not promote to production today.** The 130 PRs merged today have not been browser-smoke-tested.

## Tomorrow's morning order

1. **`/qa-conta-gate`** on staging — full automated browser smoke across 6 dev-switcher users (Master, Pedro, Sevilha, Ana, Carlos, Maria)
2. If green → consider production promotion: `gh workflow run deploy-production.yml --field image_tag=stg-4754c3d --field confirm=yes`
3. Re-arm engine ONLY after staging is QA-validated. 54 tasks still queued.

## Engine state

- **PAUSED** since ~16:30 UTC. Do not restart until /qa-conta-gate passes tomorrow.
- 130 PRs merged today (UTC), some still in CI auto-merge backlog.
- `.oxi/v5/tasks.db` has 54 planned tasks: CODEGEN-P1/P2/P3 + ESOCIAL-P1 + Atlas-50 part 2 + leftover Q3-CLOSE-T2.
- ANTHROPIC_API_KEY in Keychain (`anthropic-api-key`, `psm2`) — fallback for Max-plan quota.

## Engine restart command (only AFTER /qa-conta-gate green)

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

## Lessons baked in this session (Learn → Distill → Encode → Evolve)

- `semantic/mistake_workflow_call_caller_permissions.md` — workflow_call caller cannot grant more perms than itself, only diagnosable in web UI
- `semantic/mistake_tmux_command_substitution_not_expanded.md` — export secrets BEFORE tmux, never inside the command string
- `personal/preference_opus_for_spec_drafting.md` — HARD RULE: opus for briefs
- `personal/reference_anthropic_api_key.md` + `personal/reference_xai_grok_api_key.md` — Keychain pointers

## What NOT to do tomorrow

- ❌ Don't promote to production until /qa-conta-gate passes on staging
- ❌ Don't restart engine before #1 completes — would merge more into a freshly-validated main without re-validating
- ❌ Don't queue more waves until engine is back online and burning down current 54

## Higher-leverage engine improvements to queue NEXT (after current 54)

1. `ENGINE-V3-MIGRATION-VALIDITY` — pre-merge gate that fails PR if merged sequence on `origin/main` would have orphan/multi-head state
2. `ENGINE-V3-RUFF-GATE` — make ruff `continue-on-error: false` OR require auto-merge-clean to wait for ruff green

These are higher-leverage than another wave: they prevent the failure mode that ate 6 hours today.

## Today by the numbers (final)

- **130 PRs merged** (10× normal Pierre-day, 16× top-tier-dev-day)
- **6 waves drafted** by opus (CODEGEN-P0/P1/P2/P3, Atlas-50 part 2, eSocial-P1)
- **54 tasks still queued**
- **3 chain repair commits** (58a44f23b → 826c6df02 → 4754c3d0a)
- **2 GHA workflow bugs found + fixed** (path-filter permissions + workflow_call caller permissions)
- **3 engine bugs shipped** (CANTOPEN retry, orphan sweep, quota breaker)
- **9 GitHub *_STAGING secrets** repopulated from kubectl
- **Staging blackout duration:** ~6h. Resolved.

## API keys (Keychain)

| Key | Service | Account | Purpose |
|---|---|---|---|
| Anthropic | `anthropic-api-key` | `psm2` | oxi engine workers (API billing fallback) |
| xAI Grok | `xai-api-key` | `psm2` | Codegen lane (Phase 0/1 testing) |
