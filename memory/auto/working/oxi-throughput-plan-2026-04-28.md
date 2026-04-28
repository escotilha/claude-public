---
name: oxi-throughput-plan-2026-04-28
description: Strategic plan to take oxi from 26 PRs/day (today) to 60-100 PRs/day. Synthesizes 4 parallel CTO Opus reviews; orders fixes by impact and prerequisites.
type: working
originSessionId: 1325e91e-d8f4-4d28-8812-5fa0a6ec6a55
---
# OXi → 60-100 PRs/day — strategic plan

**Today's result:** 26 PRs merged at $58.99 spend ($2.27/merge). Target: 60-100/day at <$0.70/merge. Gap is **3-4× throughput, ~3× cost efficiency**.

**Bottom line from 4 parallel Opus analyses (throughput, reliability, roadmap-quality, cost):** the dispatch state machine is sound. The orchestrator can ship 80-150 PRs/hr at concurrency=20. We are running at ~5/hr because of **5 systemic issues**, all fixable, none requiring a state-machine rewrite.

Reports live in `/Volumes/AI/Code/oxi/.cto-review/{throughput,reliability,roadmap,cost}.md`.

---

## Five root causes (ranked by ship-rate impact)

### 1. `oauth_mode=True` is the single largest cost AND reliability tax (P0)

**File:** `oxi-core/src/oxi_core/v3/dispatch_invoke.py:236-237`, `adapters/contably/adapter.py:179`.

Setting `oauth_mode=True` drops the `--bare` flag from the worker spawn. Without `--bare`, every worker subprocess loads:
- The full `~/.claude/` plugin set
- Hooks (memory, warp, hookify, etc.)
- Auto-memory tier (the `~/.claude-setup/memory/auto/` corpus)
- Skill loaders + MCP servers

That's ~95K cache-creation tokens **per worker**, every cold start. At Opus 4.7 cache-create rates (~$18.75/M-tok 1h cache), that's **$1.80 spent before turn 1**. With `--max-budget-usd $2`, the worker has $0.20 of real headroom and busts the budget mid-stream → exit 1.

**Today's evidence:** 39 of 51 worker failures are exit-code 1 with avg cost $2.15 and 127s runtime. That cohort matches "loaded plugins, started coding, hit budget cap" almost exactly. The reliability analyst confirmed independently that workers consistently exit at the budget boundary because of this.

**Fix:** flip `oauth_mode=False` for workers, provision an `ANTHROPIC_API_KEY` from a Max-plan service account or use the API-key path that's already plumbed at `dispatch_invoke.py:128, 216-217`. Bonus: API-key billing decouples from the user's personal 5-hour Max-plan rate limit.

**Expected impact:** +30-40 PRs/day, saves ~$150/day at 100 PRs/day target.

---

### 2. Routing is hardcoded to Opus for every tier (P0, cost)

**File:** `oxi-core/src/oxi_core/v3/routing.py:391-392`, `routing.yaml:59-96`.

The `route_for("worker", task=task_dict)` call accepts a `task` parameter, but the implementation has a comment that literally says **"task parameter is intentionally unused until T2-40"**. So every T0 (one-line fix), T1 (small feature), T2 (medium feature), and T3 (full feature) gets routed to **claude-opus-4-7**.

T0 stub work doesn't need Opus. Sonnet-4.6 is 5× cheaper and adequate. Most T1/T2 work is also fine on Sonnet.

There's a wrinkle: the **critic-tier gate** at `routing.py:304-340` raises `CriticUnderpoweredError` at startup if `worker_tier > critic_tier`. So if you downgrade the critic without downgrading the worker, the engine refuses to start. The right move is per-tier worker roles (`worker_t0`, `worker_t1`, ...) with critic gate computed per-tier.

**Fix:** Add per-tier worker roles to `routing.yaml`. Plumb `task.tier` into `_pick_model`. T0 → Haiku/Sonnet; T1/T2 → Sonnet; T3 → Opus.

**Expected impact:** -$140/day at 100 PRs/day. No throughput change directly, but enables cheaper failed-dispatch retries.

---

### 3. No shipped-detection in roadmap pipeline (P0, throughput + cost)

**Files:** `ingest_roadmap.py:69-118`, `seed_from_roadmap.py:67-100,140-208`.

`seed_from_roadmap` filters new tasks ONLY by "is this identifier already in the `task` table?" It never consults git log. So an item that shipped via a direct human commit, a branch reset, or a PR whose `task_id` link was lost stays in `planned` forever — and gets re-dispatched every tick.

**Today's evidence:** T0-2/4/7/13/15/18/19/25 etc. all have shipped commits in `Contably/contably` git log. They are still sitting in the `task` table as `failed` or `planned`. 37 "ghost failures" are this exact pattern — items the engine thinks need work, but git already has the work.

There's also a sibling bug: `ingest_roadmap` can't accept a `merged_prs` list — `ranking.build_corpus` supports it (`ranking.py:626`) but the wiring isn't there.

**Fix:** In `ingest_roadmap.ingest()`, before the upsert loop, run `git log --grep '^T[0-9]+-[0-9]+:' --since='180 days ago'` to extract identifiers that shipped outside the engine. `INSERT OR IGNORE` task rows with `status='merged'` for them. One regex, idempotent, no schema change.

Also: reap the 37 ghost rows via a one-shot `oxi v3 doctor` migration.

**Expected impact:** +15-25 PRs/day worth of dispatcher capacity reclaimed (no longer dispatching workers to redo merged work). Avoids wasting ~$80/day on already-shipped work.

---

### 4. Worker stderr is structurally empty — no observability into 39 silent failures (P0, reliability)

**File:** `dispatch.py:575-608`, `dispatch_invoke.py:381-414`.

`claude -p --output-format stream-json` writes its **termination diagnostics** (`is_error`, `subtype=error_max_turns | error_max_budget | error_during_execution`, `stop_reason`) into the stdout event stream as JSON, **not stderr**. `dispatch_invoke.invoke()` already captures all events into `result.events`, but `_record_outcome` only persists `exit_code`, `cost_usd`, `wall_clock_seconds`, `classification`, and `stderr_tail` — the richest diagnostic (the `result` event) is **dropped on the floor**.

Today we paid $2.15 per failure × 39 failures = ~$84 of failure spend, captured zero "why."

**Fix:** Emit a `dispatch_failure_diag` event payload containing:
- The final `result` event JSON (cap 4KB)
- `last_assistant_text` (last `type=assistant` event's text)
- `last_tool_use` (final tool name + ID)

Add a new `Classification.BUDGET_EXHAUSTED` to disambiguate "ran out of budget cleanly" from "exit-1 crash." Currently both classify as FAILED.

**Expected impact:** 1 morning of debugging beats 1 month of guessing. Doesn't directly add PRs/day but unblocks every other diagnosis.

---

### 5. Concurrency illusion + serialized I/O wall (P0, throughput)

**Files:** `saturate.py:420`, `dispatch.py:1041`, `dispatch.py:773-794` (overlap gate), `seed_from_roadmap.py:23-25`.

Three independent issues that compound:

a. **`dispatch_loop(max_iterations=20, concurrency=20)` is a 20-then-drain-then-resleep pattern.** Saturate spawns 20, waits for them all, sleeps 5s, re-enters. Steady-state is not 20 in flight; it's 20 every ~150-200s.

b. **The overlap gate runs `gh pr list` + per-PR file fetches on EVERY dispatch_one** (~6 calls × 300-1000ms each). At 20-way concurrency, that serializes into an I/O wall. Logs show only 1-2 workers actually in flight despite concurrency=20 — this is the cause.

c. **`seed_from_roadmap` default batch size is 1**, so after a successful dispatch burst, queue drains and saturate seeds 1, dispatches 1, sleeps 60s. Throughput cap of ~60/hr theoretical, much less in practice.

**Fix:**
- Hoist `gh pr list` once per `dispatch_loop` invocation; pass an `OverlapSnapshot` into each `dispatch_one`. The injectable knobs (`_open_pr_numbers`, `_overlap_checker`) already exist.
- Raise seed batch size to `2 × concurrency` (= 40).
- Drop `idle_sleep_s` from 60 to 15.

**Expected impact:** +15-25 PRs/day on top of the other fixes. Unlocks real concurrency utilization.

---

## Secondary fixes (P1) — do these in week 2

| # | Issue | File | Impact |
|---|---|---|---|
| 6 | `auto_recover` retries `critic_rejected` (semantic failure, no new info) — wastes $7+ per item | `auto_recover.py:90-96` | -$30-50/day |
| 7 | Engine_health threshold treats SSH-fail (exit 255) and budget-bust (exit 1) the same | `engine_health.py:76`, `dispatch.py:976-979` | Stops nuisance UNHEALTHY trips |
| 8 | Saturate auto_merge SQLite-thread bug from PR #235 | `saturate.py:472-474` | Doubles merge cadence (5-10s vs 30s tick) — refactor critic to use `await review_async()` |
| 9 | Per-tier slot quotas in `_pick_next_planned` (don't let T3 saturate the pool) | `dispatch.py:467-471` | +5-10 PRs/day |
| 10 | `target_repo` regex only checks subtitle, contably items put `(Repo: x/y)` in title — silent mis-route | `dispatch.py:188-220` | Eliminates wrong-repo dispatches |

## Tertiary (P2) — week 3+

11. **Cache pre-warm anchor session per (repo, hour)**: today each cold worker pays $1.80 warmup. Shared 1h-TTL cache means only the first worker pays. Saves ~$120/day at 100 PRs.
12. **Per-tier per-task budget caps**: T0=$0.30, T1=$0.80, T2=$2.00, T3=$8.00 — caps tail risk visibly.
13. **Failed-dispatch sub-cap**: separate $40/day cap on FAILED spend with `dispatch_quality_alarm` event when breached.
14. **Worktree provisioner writes stub `.claude/settings.json`** to short-circuit hook walk-up — belt-and-braces against the committed-hook-breaks-worktrees pattern.

---

## Concrete week-1 sequence (in dependency order)

The fixes have ordering constraints — some unblock others:

1. **Day 1 morning: emit observability diagnostics** (#4). Without this we're flying blind. Adds `dispatch_failure_diag` event + `BUDGET_EXHAUSTED` classification. ~3 hours, no risk.

2. **Day 1 afternoon: ship oauth_mode=False for workers** (#1). The single biggest impact. Verify with one task, then enable for the contably adapter. Watch the next 50 dispatches in real time. Expected: exit-1 cohort cuts from 75% → <10%. ~2 hours.

3. **Day 2 morning: ship git-log shipped-detection** (#3). Stops the engine from re-dispatching merged work. Adds `git log --grep` regex to `ingest_roadmap`. Run `oxi v3 doctor` migration to reap 37 ghost rows. ~4 hours.

4. **Day 2 afternoon: hoist overlap gate + raise seed batch + lower idle_sleep** (#5). Unlocks real concurrency. Adapter knob changes only — no schema. ~2 hours.

5. **Day 3: per-tier worker routing** (#2). Routing.yaml expansion + `_pick_model` plumbing + critic-tier gate update. Trickiest of the five because the gate logic is interlocked. ~6 hours including tests.

6. **Day 4: validate at scale.** Run saturate for 8 hours, measure: PRs/hr, $/PR, exit-code histogram, queue depth. Target: 60+ PRs/day, <$1/PR. If we hit 80, we're done; if not, do P1 items #6-10.

---

## Throughput math (confirmed by all 4 analysts)

- **Per-task latency:** ~150-200s happy path (worker + critic + merge)
- **Theoretical at concurrency=20:** 240 PRs/hr raw, ~80-150 PRs/hr realistic (SQLite + GH API as soft ceiling)
- **Today's actual: 5/hr** — 16× below realistic, **gap is 90% failure rate, not capacity**
- **Drive success 32% → 70% with the P0 fixes:** same code ships 60-80/day immediately
- **Cost target after fixes:** $0.50-0.70/merge × 100/day = $50-70/day = $1.5-2.1K/month (vs $58.99 today for 26)

---

## What we are NOT going to do

These came up but are wrong calls:

1. **Add Agent Teams to dispatch.** The state machine is sound; coordination is fine. Don't add complexity to a working orchestrator.
2. **Refactor saturate to be more "real-time".** The 5-10s loop is fine — the problem is what happens DURING those 5-10s, not the cadence.
3. **Migrate off SQLite.** SQLite is fine at this scale with WAL + per-thread connections. The thread-bug is a code issue, not a database choice.
4. **Add ML-based task scheduling.** Per-tier slot quotas + FIFO is sufficient; no learning system needed.
5. **Re-implement critic in Python (no claude subprocess).** The critic working pattern is correct — it's the model tier and OAuth posture that's wrong, not the architecture.

---

## Memory & monitoring (post-implementation)

After the P0 sequence ships, save these as semantic memory:

- **Pattern:** "oxi worker oauth_mode=True drops --bare → 95K-token cache warmup → budget bust" (concrete numbers, with the classifier signature)
- **Tech-insight:** "claude-code stream-json puts termination diagnostics in stdout result event, NOT stderr"
- **Mistake:** "Routing.yaml accepts task param but ignored without per-tier roles — silent Opus-everywhere"
- **Pattern:** "Roadmap shipped-detection requires git-log ingest, not just task-table presence check"

Set up a daily auto-trigger at 09:00 BRT to run `oxi v3 doctor` and email a brief: PRs merged last 24h, $ spent, failure histogram, queue depth, top 5 stale tasks. The brief becomes the operator's morning standup.

---

## Open question for you to decide tomorrow

The cleanest fix to #1 (oauth_mode) is to provision a service-account API key. Two options:

1. **Max-plan service key** — cheaper (Max plan price), but gates against personal-account 5h rate limit if shared
2. **Pay-as-you-go API key on a separate org** — no rate-limit interaction with personal usage, full control, slightly higher per-token cost

The reliability analyst recommends option 1 if your org allows service accounts on Max-plan; option 2 otherwise. Either works. Pick before starting day-1 afternoon work.

---

## Timeline

- Day 1: P0 #4, #1 → expected immediate jump to ~50 PRs/day
- Day 2: P0 #3, #5 → expected ~70-80 PRs/day
- Day 3: P0 #2 → cost drops 3-4× without throughput regression
- Day 4: Validate. If <60 PRs/day, work P1.
- Week 2: P1 cleanup
- Week 3+: P2 polish + cache anchoring

If everything goes well: you're at 80-100 PRs/day at $50-70/day spend by end of week.

---

## Progress log

### 2026-04-28 08:30 BRT — All 5 P0 fixes shipped + engine running

**Plan:** All 5 P0 items complete. Engine running in production (Mini, tmux).

**Code:** `xurman/main` at `381d320` (fix/saturate: fresh DB connection in auto_merge thread). PRs #241-#243 merged to Xurman/oxi. Contably PRs #4-#9 merged to Contably/oxi (separate fork, also applied — note: deployed engine reads from xurman/main, NOT Contably/oxi).

**Execution:**
- P0 #4 (observability): DONE — DISPATCH_FAILURE_DIAG events, BUDGET_EXHAUSTED classification
- P0 #1 (scrub_home): DONE — scrub_home field + wrap_with_ssh. Note: local-spawn (Mini ssh_alias="") is not affected, HOME scrub only fires over SSH. Separate follow-up needed.
- P0 #3 (shipped-detection): DONE — `shipped_detect.py`, 60 ghost rows reaped on first run
- P0 #5 (concurrency): DONE — overlap gate hoisted, seed batch 2*concurrency, idle_sleep 15s
- P0 #2 (per-tier routing): DONE — worker_t0..t4, critic_t0..t3, critic-tier gate, route_for honors task tier
- PR #242 (per-tier max_turns): T0=30, T1=60, T2=100, T3=180, T4=200, escalation=240
- PR #243 (auto_merge SQLite-thread fix): fresh db.connect() inside to_thread — auto_merge now working

**Staging/prod status:**
- Production: HEALTHY. master@contably.com password rotated (both envs). Login confirmed HTTP 200.
- Staging: HEALTHY. Failed migration jobs from today's engine runs cleaned up. Portal responding.
- Enum data bug fixed: fiscal_deadlines + deadline_instances — lowercase enum values uppercased to match SQLAlchemy enum names (FEDERAL_TAX, MONTHLY, PENDING). Same fix applied staging + prod.
- PR #706 (T3-7 Billing): MERGED to contably/contably
- PR #707 (T3-5 Journal Entry): CLOSED — broken migration (6 tables in model, only 1 created). Split into T3-5a..d.
- T3-5 roadmap split: T3-5a/b/c/d added to roadmap. Engine dispatched all 4 (~11:16 UTC). T3-5a, T3-5c already merged; T3-5b, T3-5d dispatched (workers in flight).

**Blockers:** none. Engine running autonomously.

**Priorities established (Pierre's directives 2026-04-28):**
1. Daily reconciliation — go-live-gap-analysis-2026-04-24.md §1
2. Monthly closing — monthly-closing-inventory-2026-04-23.md
3. Agent onboarding + gamification — copiloto-gamificacao-apresentacao.md

**Next actions (for resume):**
1. Check engine status: `tail -20 /Volumes/AI/Code/oxi-runtime/saturate.log`
2. Check DB state: `sqlite3 /Volumes/AI/Code/contably/.oxi/oxi.db "SELECT status, COUNT(*) FROM task GROUP BY status"`
3. Wait for T3-5b + T3-5d to land (or fail) — if fail, inspect DIAG events
4. Remaining open work (P1 week-2, per plan): auto_recover skips critic_rejected, engine_health excludes budget_exhausted, per-tier slot quotas in _pick_next_planned, target_repo regex fix
5. Code follow-up: fix `Column(Enum(X))` → `Column(Enum(X, values_callable=...))` in deadlines.py to prevent re-introduction of the lowercase enum bug
6. Roadmap expansion: discuss with Pierre which new items to add aligned with 3 directives above

---

## Timeline (the page itself)

- **2026-04-27 22:00 BRT** — [research] Four parallel Opus CTO analyses spawned in single message per parallel-first.md rule. (Source: session — oxi cutover Phase 4 night-2)
- **2026-04-27 22:35 BRT** — [synthesis] All four reports landed at `/Volumes/AI/Code/oxi/.cto-review/{throughput,reliability,roadmap,cost}.md`. Strong convergence on root causes. Plan written. (Source: consolidation — merged from 4 specialist reviews)
