---
name: psos-failure-patterns-to-detect
description: Engine failure modes that today required operator cleanup — these are the ones T2-13 (ledger pattern detection) should auto-file when it ships. Tracking here so we can verify T2-13's first detections match reality.
type: project
originSessionId: 94d135c3-3bc2-408d-a0b6-51089b31ad95
---
T2-13 (Ledger Pattern Detection → Self-Filing) hasn't shipped yet (PSOS issue #12). Once it does, it should auto-file the failure modes below — operator-curated to validate T2-13's detection accuracy on first run.

**Why:** today (2026-04-22) the engine exhibited several distinct repeating failure modes that all required manual operator intervention. The whole point of T2-13 is to notice these and file them; this memory is the ground-truth list to compare against T2-13's first output.

**How to apply:** when T2-13's first nightly run lands, diff its `self_improvement_filed` events against this list. Anything T2-13 missed = T2-13 itself is incomplete. Anything T2-13 found beyond this list = bonus signal.

## Patterns observed 2026-04-22

### Pattern 1: Externally-closed PR → task stuck dispatched forever

**Signature:** ≥3 `auto_merge_rejected` events for the same `task_key` where the underlying PR state has changed to `CLOSED` (operator clicked close, or the PR was superseded). The engine has no "PR was killed externally" handler — `auto_merge` keeps rejecting, `pr_watcher_v3` doesn't surface the state change, and the front never frees up for re-seeding.

**Right autonomous response:** `pr_watcher_v3` should emit `pr_closed_externally` when it observes a state transition open→closed without a corresponding merge. `ship_recovery` should treat that event as terminal — abandon the task, free the front.

**Today's instances:** t2-12-auto (PR #339), t2-13-auto (PR #340). Required operator-manual abandonment after closing the wrong-codebase PRs.

### Pattern 2: Wrong-codebase dispatch (the cause of pattern 1)

**Signature:** dispatched task whose roadmap-item attribute table declares `Repo: <X>` but whose worktree is provisioned off `Contably/contably`. Resulting PR either commits to the wrong repo (creating garbage like `apps/api/src/scripts/pattern_detector.py` for what should be a `psos_core/...` change) or commits temp files only.

**Right autonomous response:** T2-17 — `worktree_provision.py` reads `fronts.target_repo` and clones the right repo. Until T2-17 ships, the dispatched session has to be smart enough to route itself (works ~70% of the time per today's evidence).

**Today's instances:** PR #339 (.tmp files), PR #340 (wrong-codebase pattern_detector.py). 4 PSOS PRs (#8/#9/#10/#11) succeeded by agent self-routing.

### Pattern 3: ship_recovery reaping orphans-with-PRs

**Signature:** `dispatch_dead` event followed by `task_transition → abandoned reason=orphan_detected` for a task whose `pr_number IS NOT NULL`. Engine confused "Mini-side PID dead" with "work lost."

**Right autonomous response:** Already shipped (psos PR #1). The PR-guard in `heartbeat.sweep_dead_dispatches` now correctly emits `dispatch_dead` with `skip_reason=pr_open_keep_dispatched` instead of abandoning. **T2-13 should NOT re-flag this — already fixed.**

**Today's instances:** 10 false-abandonments at 18:41Z + 10 again at 19:02Z (before fix deployed); 0 since fix landed.

### Pattern 4: Stale local clone for deploy

**Signature:** an scp deploy from a local checkout where `git rev-parse main != git rev-parse origin/main`. Engine has no visibility into this — it's an operator-side bug.

**Right autonomous response:** N/A for the engine. Solved by `~/.claude-setup/tools/psos-deploy` (clones from origin on the VPS) and `~/.claude-setup/tools/ppr` (worktree always off `origin/main`).

**Today's instances:** 3× during the heartbeat hotfix and dashboard port. **Out of scope for T2-13 — operator tooling, not engine.**

### Pattern 5: Cooldown was load-bearing for dedup

**Signature:** seeder logs `IntegrityError: UNIQUE constraint failed: psos_task.task_key` after the cooldown window goes to 0. Stable task_keys + previously-merged fronts = collision.

**Right autonomous response:** Already shipped (psos PR #7). `_front_has_alive_task` now includes `merged` in the alive-set; the cooldown is structurally redundant. **T2-13 should NOT re-flag this — already fixed.**

**Today's instances:** 2× during the cooldown experiment.

## Timeline

- **2026-04-22** — [failure] Patterns 1, 2 observed during the autonomous-loop recovery work; manually cleaned up. (Source: failure — Contably engine recovery session)
- **2026-04-22** — [failure] Patterns 3, 5 observed and fixed inline. (Source: failure — same session)
- **2026-04-22** — [user-feedback] Pierre asked "this should be part of learning, right?" when filing pattern 1 — confirmed T2-13's design intent. (Source: user-feedback — same session)
