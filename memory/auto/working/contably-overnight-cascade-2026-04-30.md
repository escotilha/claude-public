---
name: contably-overnight-cascade-2026-04-30
description: Autonomous overnight CI cascade resolution — Pierre approved /loop self-pacing through PR merge cascade, throughput-scaling chain still in flight. Resume here if session drops.
type: project
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
Pierre approved autonomous overnight operation at 2026-04-29 22:32 local. /loop is self-pacing on ScheduleWakeup; will keep cycling until the cascade clears or a blocker requires human review. Talk tomorrow.

**Key constraint:** This is Pierre's Mac Mini terminal session. Stays alive only while the Mini is awake and the terminal isn't closed. Caffeinate not requested — Mini's default sleep settings.

---

## What's in flight (15 open PRs, all in cascade)

**Throughput-scaling chain (priority — these unblock everything else):**
- #775 — ci.yml ubuntu-latest swap. Reopened 22:24 to retrigger Deploy Staging that got concurrency-cancelled. Watch: should land first.
- #744 — auto-merge-clean.yml workflow (10-min cron squash-merger). Land this and overnight merging is automatic.

**Real feature work (alpha-relevant):**
- #757 — Customer/Cliente registry (NF-e Phase 5 prereq)
- #756 — Scheduled report subscriptions (had Frontend CI failure last cycle, may need investigation)
- #753 — NF-e Phase 4 manifestação
- #721 — Nuvini-internal reframe chore
- #713 — T3-5d Journal Mapping Rules + Generator
- #658, #657 — docs (atlas, roadmap)

**Tier-A salvage candidates (rebased 22:30, may or may not pass CI):**
- #556 — OS-1 planner pr-diff (Contably-side library)
- #566 — T2-115 client_processes migration
- #580 — T2-115 frontend test coverage
- #583 — T2-112 WebSocket live updates
- #589 — T2-12 auto-rescue (had stale Deploy + smoke psos-core failure)
- #656 — T2-201 client cert upload

**Out-of-cascade (active competing bot writer):**
- #760 — focus-nfe shim refactor. Will resolve via the bot, not me.

---

## Already-merged this session (do not retouch)

- #774 — production phase attribution
- #777 — workflow-lint allowlist (unblocked the chain)
- #776 — overseer constants 8 → 16 slots

---

## Infrastructure deltas

- **VPS runners doubled**: 8 → 16. Runner names contably-vps-2..16 (plus the unsuffixed contably-vps). All `[self-hosted, Linux, X64, contably-vps]` labeled. Provisioned via `/tmp/scale-runners.sh` on the Contabo VPS as root.
- **CI lint**: ci.yml + auto-merge-clean.yml are now in `UBUNTU_LATEST_APPROVED` in workflow-lint-permissions.sh
- **Overseer constants**: TOTAL_SLOTS=16, MIN_FREE_SLOTS=6, MAX_BACKLOG=12 (live on main as of #776)

---

## Loop behavior

`/loop` is on ScheduleWakeup self-pacing. Each cycle:
1. List open PRs, find CLEAN ones, merge them
2. Investigate any new FAILUREs (only push fixes for trivially recoverable ones — typo fixes, not refactors)
3. If a fix needs judgment beyond simple, snapshot + PushNotification + stop the loop
4. Re-arm wakeup at 1500-1800s (don't burn cache on 5-min ticks)

**Constraints accepted:**
- No production deploys
- No force-pushes to main
- No closing PRs without unambiguous duplicate evidence
- No infra changes (VPS, K8s, overseer)
- No expensive subagent spawns

---

## Stop conditions

- Hit a CI failure that needs human judgment → snapshot, push notification, stop
- All 15 PRs settled (merged or stuck) → snapshot, push notification, stop
- Context > 80% used → run `/handoff` chain, /clear, /primer (per handoff-threshold.md)
- User explicitly says stop in any future turn

---

## Resume hint for tomorrow

Read this memory + run `gh pr list --state open --label auto-merge --json number,mergeStateStatus,headRefName` to see what landed. The auto-merge-clean cron (once #744 lands) will be doing most of the merging — check `gh run list --workflow auto-merge-clean --limit 5` for its activity.

If the loop is still running, just say "status" and I'll snapshot. If it stopped, the last PushNotification has the reason.

---

## Timeline

- **2026-04-29 22:32** — [session] Pierre approved autonomous overnight. 15 PRs in cascade, 153 CI jobs in flight, 16/16 runners pinned, loop wakeup armed for ~22:40. (Source: session — throughput-scaling cascade)
- **2026-04-29 23:24** — [session] Cascade jam diagnosed. Loop has cycled 6+ times. Status snapshot below. (Source: session — cycle 6 of overnight loop)

---

## Current jam state (2026-04-29 23:24)

**Merged this session:** #774, #777, #776, #713 (4 PRs)
**Still open:** 15 PRs

**Why nothing else merges autonomously**:
- Auto-merge-clean cron (#744) hasn't landed → so it can't take over
- All 15 open PRs show `mergeStateStatus: UNSTABLE`
- Operating contract forbids manual merge of UNSTABLE PRs
- The `UNSTABLE` is caused by 3 different things across the 15 PRs:

**Category A — All-CI-green except Deploy Staging (5 PRs):** #757, #756, #753, #721, #658
- Real CI gates all PASS
- Only `Deploy to Staging` fails (every PR runs preview-deploy against shared staging DB; alembic divergence; only one PR can win at a time; this is by design)
- These are the most "ready" — would unblock immediately if Pierre says merge UNSTABLE-mergeable, OR if Deploy Staging is gated to push-events-only

**Category B — Frontend CI pnpm race (4 PRs):** #775, #657, #583, #580
- pnpm shared-cache race on `/home/gh-runner/setup-pnpm/` across all 16 VPS runners
- Two FE jobs running concurrently → ENOTEMPTY rmdir error
- Reruns succeed if non-colliding scheduling
- Fix: per-runner pnpm cache (infra config — forbidden by overnight contract)

**Category C — Real test failures (3 PRs):** #566 (Backend CI MySQL), #556 (Backend CI py3.11+3.13), #589 (psos-core stale)
- These need code investigation; Pierre's call

**Category D — Concurrency-cancel-no-replacement (1 PR):** #744 (auto-merge-clean.yml)
- Bug semantic/mistake_gha_concurrency_cancel_no_replacement.md
- Fixed twice by close+reopen, regenerated each time
- Fix: change `cancel-in-progress: true` to `false` in deploy-staging.yml (workflow config — forbidden)

**Category E — Active bot writer (1 PR):** #760
- Active competing bot rewriter; explicitly out-of-scope

---

## Decision Pierre needs to make (morning)

1. **Merge UNSTABLE-mergeable PRs?** Would unblock 5 alpha-relevant features tonight.
2. **Gate Deploy Staging to push-only?** Workflow config change — split into `validate-deploy-manifest.yml` (pull_request) + `deploy-staging.yml` (push). Removes the systemic UNSTABLE.
3. **Fix pnpm shared-cache race?** Set `PNPM_HOME=$RUNNER_TEMP/...` per-runner in workflow OR clean up `/home/gh-runner/setup-pnpm/` between runs. Fixes 4 more PRs.

If (1) is OK going forward, the overnight loop can resume tomorrow with a relaxed contract: "merge UNSTABLE-mergeable when only failures are Deploy Staging or pnpm race." Otherwise (2) and (3) are needed first.

---

## Already-cleared infra noise

- 7 of 8 new VPS runners had `.tmp-contably-os` orphan dirs that triggered submodule warnings — cleared (some came back per-job since `main` has a broken gitlink at PR #343, mode 160000 with no `.gitmodules` entry; `actions/checkout@v4` recovers via "Bad Submodules found, removing existing files" but it costs ~30s/job)
- The broken gitlink on main is a **separate cleanup task for Pierre**: `git rm --cached .tmp-contably-os` and commit, would prevent future re-creation.
