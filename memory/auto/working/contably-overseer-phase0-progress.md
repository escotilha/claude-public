---
name: contably-overseer-phase0-progress
description: Resume pointer for the oxi v5 overseer Phase 0 → Phase 1 work. Phase 0 shipped; Level 1 smoke verified; Level 3 + feeder pending.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
oxi v5 overseer improvement plan — Phase 0 shipped, Phase 1 in progress. Engine is alive (tmux `oxi-overseer`, pid 50597, started 2026-05-01 12:55 PT) but idle: no feeder exists. Auth pre-check verified live.

## What's done

- **Phase 0 fixes pushed** as commit `b9af431f9` on `origin/main` (PR-less push, single-purpose):
  - SKILL.md drift correction (8 files not 5; constants 16/6/12 post-#776; heartbeat post-#788; oxi.db is legacy v3 corpse; current-state section)
  - start.sh auth pre-check (`claude --print --max-turns 0 "ping"`, exits 2 with remediation if `Not logged in`/`invalid_api_key`/`401`); exports REPO_ROOT
- **Plan v2 written** in conversation: Phase 0 (auth+slot fix, done), Phase 1 (feeder), Phase 2 (failure classifier — Paperclip pattern), Phase 3 (Janitor), Phase 4 (LLM planner only-if-needed), Phase 5 (dashboard nice-to-have). Plan v1 was scrapped because PR #776 (TOTAL_SLOTS=16) and PR #788 (heartbeat) had already landed and I missed them — root cause: didn't `git fetch origin` before designing.
- **Level 1 smoke test passed**: tmux session restarted via patched start.sh; auth pre-check fired and returned OK in ~10s (slow because real API round-trip; document this in skill so future operator doesn't think it hung); new loop pid 50597 ticking every 60s; gate.json fresh.

## What's pending

- **Level 3 smoke test** (deferred to next focused window): insert one trivial task into `.oxi/v5/tasks.db` with `files_touched=["docs/oxi-smoke-test-<ts>.md"]`, let running loop pick it up, watch worker open a PR. Skipping Level 2 because separating policy-gate-only-test from worker-spawn-test is awkward with the running loop (would require stopping it, parallel processes would race on locks.db). See "Interference analysis" in conversation for full reasoning.
- **Step 3** of the original sub-plan: read the actual Q3 roadmap (`docs/contably-product-roadmap-2026-Q3.md`, currently modified in working tree) to design the feeder against real format, not generic guess.
- **Step 2 / Phase 1**: build `infra/overseer/feed.py` (~80–110 LOC, no LLM, parses roadmap markdown sections into `task` rows). Source: roadmap docs (existing authoring surface) > manual CLI > stale T17/T18 enrichment.

## Where the content for the feeder comes from

Three candidates, in order of expected pain-to-payoff:
1. **Roadmap markdown** (`docs/*-roadmap-*.md`, `docs/*-plan-*.md`) — natural authoring surface, already maintained, structured headings parseable to (identifier, tier, title, files_touched, done_when). This is the target.
2. **Manual one-shot CLI** (`feed --id T-21 --tier 1 --title …`) — fallback inside the feeder for ad-hoc additions.
3. **Hand-enriching the stale T17/T18 rows** — *not useful* for smoke testing because T17 says "merge stale PRs 711 713 665" and 711/713 are already merged + 665 is closed — task is a no-op, doesn't exercise dispatch.

## Known gotchas to remember

- The auth pre-check takes ~10s in tmux. Document in SKILL.md.
- `claude --print` requires either stdin or a positional prompt arg. Current pre-check passes `"ping"` positionally, so it works.
- Running loop holds open SQLite WAL connection to tasks.db; external `INSERT` from sqlite3 CLI is safe (single fast write, WAL handles it).
- Two simultaneous loop processes against the same `.oxi/v5/locks.db` is **not safe** — they'd both write, semantics break. Always stop one before running another.
- Concurrent-sessions risk: another Claude Code session might be touching files. Smoke-test must use a brand-new file path (e.g. `docs/oxi-smoke-test-<timestamp>.md`) to avoid lock conflicts.
- I made the rebase mistake earlier this session: committed against a tree 36 commits stale because I didn't `git fetch origin` after the initial map. Always fetch before designing changes that touch shared infra. PRs to grep for: `gh pr list --search overseer --state merged`.

## Resume instruction

Pierre will say "do Level 3" or similar. Steps:
1. `git fetch origin && git status` — check no new overseer PRs landed.
2. Pick a unique smoke filename: `docs/oxi-smoke-test-2026-05-01-<HHMM>.md`.
3. `sqlite3 .oxi/v5/tasks.db "INSERT INTO task (identifier, tier, title, files_touched, status, approach, done_when) VALUES ('T-SMOKE-1', 0, 'oxi v5 smoke: create one doc file and PR', '[\"docs/oxi-smoke-test-2026-05-01-<HHMM>.md\"]', 'planned', 'Create the file with text \"oxi v5 smoke test passed at <utc-now>\". Commit. Push. Open PR. Do not modify any other file.', '[\"file exists with the timestamp text\", \"PR open against main\"]');"`
4. Watch `tail -f .oxi/v5/overseer.log` for the next tick (within 60s).
5. Expected sequence: tick → policy `allow=true` → worktree provision → worker_start event → ~5–15min worker runtime → worker_done with rc=0, branch_cleaned=False (PR not merged yet), pr_merged=False, pr_number=null at first; or rc!=0 if something broke.
6. Inspect the PR. If sane: review and decide whether to merge or close. If broken: close PR, delete remote branch (`git push origin --delete feat/oxi-v5-t-smoke-1`), delete worktree, mark task `failed` in DB, debug.
