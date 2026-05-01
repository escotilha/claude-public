---
name: contably-overseer-phase0-progress
description: oxi v5 overseer — Phase 0/1/2 shipped, Phase 6 wave 1 dispatching, target 600 PRs/wk by 2026-05-08. Autonomous mode active.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
oxi v5 overseer is live, verified, autonomous. Pierre target: 600 PRs/wk by week ending 2026-05-08. Current engine producing autonomous PRs (#793 + #794 merged). Phase 6 wave 1 (5 cross-cutting tasks) seeded and dispatching as of 2026-05-01 ~17:05 PT.

## Today's commits (2026-05-01, all on origin/main)

- **b9af431f9** — Phase 0: SKILL.md drift + start.sh auth pre-check
- **a0c1a2635** — Phase 0 follow-up: drop --bare from worker_cmd (Max plan keychain compat)
- **c08fc3a3c** — Phase 1: roadmap → tasks.db feeder
- **b685078d4** — Phase 2: failure classifier + cascade-prevention breaker
- **feccb104a** — feed.py staleness check (closes the Tier 0 hole)
- **7d63028ea** — runtime-tunable max-workers via --max-workers / MAX_WORKERS env var
- **3e5ced992** — Phase 6 wave 1 seed (5 tasks: P6-OBS-1, P6-SEC-1, P6-INF-1, P6-INF-2, P6-INF-3)

## Two PRs already merged (autonomously)

- **PR #793** — smoke test (engine first-light, May 1)
- **PR #794** — T0-104 WeasyPrint (worker built and PR auto-merged)

## Engine state

- tmux `oxi-overseer`, pid 77562 (started 15:05 PT)
- Phase 2 code, cascade-prevention breaker active
- Worker cmd: `claude --dangerously-skip-permissions -p` (no --bare; Max plan keychain auth)
- MAX_ACTIVE_WORKERS=3 (default; bump via MAX_WORKERS env var on next restart)
- Test suite: 170/170 pass

## Phase 6 wave 1 — what's queued

5 tasks, hand-curated, staleness-verified, file-paths-confirmed:

| ID | Track | Files | Risk |
|---|---|---|---|
| P6-OBS-1 | Observability | infrastructure/monitoring/alerts/ | low (alert YAML only) |
| P6-SEC-1 | Security | .gitleaks.toml + ci.yml | low (CI config) |
| P6-INF-1 | Infra | kustomize overlays + 2 workflows | medium (infra refactor) |
| P6-INF-2 | Infra | scripts/ | low (script + docs) |
| P6-INF-3 | Infra | scripts/ | low (script + docs) |

Stale items audited and explicitly NOT queued:
- NF-e get_async_session_context bug (module deleted by PR #790)
- Celery Beat persistence (PR #738 + celery_app.py already done)
- HIGH #3 / HIGH #4 cert-upload redaction (already on remote-agent calendar 2026-05-08)

## The 600 PR/wk plan

Per Pierre's POWER LEVEL screenshot 2026-04-23 to 2026-04-30: 472 PR/wk at R$146/wk. Target 600 = +27%. Plan v1 split into 3 tracks:

- **Track A** — Phase 6 cross-cutting via overseer. ~30 PRs/wk capacity at MAX_WORKERS=3, ~50-60 at MAX_WORKERS=5-6.
- **Track B** — Pierre + manual flows continue at 472/wk pace.
- **Track C** — Phase 7 atlas-tier0 slicing (deferred until Track A proven).

Pierre asked to test the upper limit of MAX_ACTIVE_WORKERS — runtime-tunable via env var now (`MAX_WORKERS=4 bash .claude/skills/contably-overseer/scripts/start.sh`). Strategy: ramp 3→4→5→6 with halt criteria (breaker trip / file conflict / RAM pressure / rate limit). Stop at 6 max for tonight; document ceiling.

## Halt conditions for autonomous mode

- Any PR touches `apps/api/src/api/routes/` (Phase 1 freeze)
- Any PR touches auth/scope code (`/full-review` required)
- Breaker trips (cascade detected — by definition needs operator)
- More than 1 worker rc!=0 in a row from same Phase-6 batch (suggests batch is mis-curated)
- Wants to push to main work I didn't author through engine
- A roadmap-implied scope decision (NF-e flip, holerite, Tier 0/1 audit)

## Resume context

- Wave 1 dispatches around 20:05-20:30 UTC; first wakeup checks 20:09 UTC
- If wave clears clean → queue wave 2 (5 more Phase 6 items I haven't drafted yet — observability dashboards, more P6-TST items)
- If breaker trips or quality bad → halt, report, debug
- Next morning: optional ramp to MAX_WORKERS=4 via tmux restart with env var

## Known landmines

- `find_next_planned` has no priority col in v5 schema → defaults to rowid order. T17/T18 (no files) rank ahead of P6 in scan but fail policy gate, fallthrough is correct
- Workers run with --dangerously-skip-permissions: real autonomy, real blast radius. Trust the breaker but don't crank concurrency without monitoring
- Roadmap-implied scope decisions (NF-e flip, holerite scope, Tier 0/1 audits) STAY operator-decision
