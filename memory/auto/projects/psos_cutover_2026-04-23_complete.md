---
name: psos-cutover-2026-04-23-complete
description: PSOS engine cutover Contably/contably-os v0.4.9 → escotilha/psos v0.5.0 completed successfully 2026-04-23 06:33Z. Engine running new code. Blocker hit: 7-day rate limit exhausted, dispatched claudes die instantly. Resumes 2026-04-23T19:00Z.
type: project
originSessionId: feef782e-78b3-4a84-8d13-05b8e0fd4168
---
VPS at root@100.77.51.51 completed cutover from `Contably/contably-os` (deprecated) to canonical `escotilha/psos`. All three PRs merged:

- #34 (engine unstick — Fix 1 `last_progress_at`, Fix 2 killswitch guards, Fix 4 auto_merge MERGED noop)
- #37 (ruff cleanup + CI lint step) — successor to closed-by-base #35
- #38 (per-repo scope + clone registry) — successor to closed-by-base #36

**Why:** deployed code swap. Tables + timers already renamed in prior cycles. Only `pip uninstall contably-os / pip install -e psos-core` left.

**How to apply:** Use `docs/psos-cutover-2026-04-23.md` for the procedure. Most of the deviations from the upstream runbook (which targeted a stale state) are captured there.

**Blocker during cutover:** 7-day rate limit exhausted at 06:55Z. Every dispatched claude exits immediately with `rate_limit_event: status=rejected, overageStatus=rejected`. Resets 2026-04-23T19:00Z (16:00 America/Bahia). Killswitch re-set, 20 dispatched→abandoned with reason "rate_limit_7day_burn". Engine state: 204 merged, 20 abandoned, 8 planned, killswitch SET.

## Timeline

- **2026-04-23 06:24** — [session] PR #34 merged (engine unstick)
- **2026-04-23 06:26** — [session] PR #37 merged (ruff cleanup, reopened from closed #35)
- **2026-04-23 06:28** — [session] PR #38 merged (multi-repo scope, reopened from closed #36)
- **2026-04-23 06:33** — [session] VPS cutover complete: psos-core 0.5.0 editable install active, killswitch cleared
- **2026-04-23 06:50** — [failure] Dispatched tasks hit Claude 7-day rate limit, all 20 sessions exit instantly
- **2026-04-23 06:59** — [recovery] Killswitch re-set, 20 dispatched marked abandoned with rate_limit reason
- **2026-04-23 19:00** — [scheduled] 7-day quota resets, can resume dispatch

## Gotchas discovered

1. **`contably_adapter` site-package** was leftover from the old 0.4.9 install and blocked Python import because its `__init__.py` eager-imported `psos_core` before the editable `.pth` loaded. Purged at `/opt/contably-os/venv/lib/python3.12/site-packages/contably_adapter/` + `99-psos-contably-adapter.pth`.

2. **Systemd `psos-v3.timer` has to be enabled separately** from the other `psos-v3-*.timer` units — glob `psos-v3-*.timer` doesn't match the bare `psos-v3.timer`.

3. **Closed PRs can't be reopened once their base branch is deleted.** When merging a stack via squash, GitHub auto-closes PRs targeting the merged branch. Recovery: push-force the branch to itself, open a new PR. Done for #35→#37 and #36→#38.

4. **Rate-limit visibility:** the 7-day limit is NOT visible in `psos v3 status` — only the 5-hour window shows (`rate_limit: N/225 msg`). The 7-day "seven_day" limit blocks in a different category. Watch `/tmp/claude-<task>.log` for `"rateLimitType":"seven_day"` events.

5. **`psos v3 tick --max-iterations` does not exist** — the flag is `--times`. Doc error in `docs/psos-cutover-2026-04-23.md` step 16. Correct flag is `--times 1` for a single iteration.

6. **Stale worktrees must be pruned before dispatch can reuse branch names.** 57 old `/Volumes/AI/Code/t<N>-auto` (no prefix) worktrees plus ~100 stale local branches had to be cleared. Old worktrees held feature branches hostage, causing `git worktree add` to fail on reuse.

7. **Don't race the engine during cutover.** Stop `psos-v3.timer` before doing manual state cleanup. Timers firing every 3 min will race your SQL updates and cause "worktree not found" errors when you delete dirs that the tick concurrently tried to use.

## Related

- [handoff-2026-04-22](../working/resume_2026-04-22_overnight.md) — pre-cutover resume doc
- [psos-engine-root-cause-2026-04-23](../../../../Volumes/AI/Code/contably/docs/psos-engine-root-cause-2026-04-23.md) — CTO diagnosis of the orphan-thrash bug that #34 fixed
- [psos-cutover-2026-04-23](../../../../Volumes/AI/Code/contably/docs/psos-cutover-2026-04-23.md) — the runbook we executed
