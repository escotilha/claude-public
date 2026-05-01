---
name: contably-overseer-phase0-progress
description: oxi v5 overseer Phase 0 + Phase 1 shipped May 1 2026. Engine works end-to-end, feeder ready, awaiting first --apply against real Tier 0.
type: project
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
oxi v5 overseer is live, verified, and now has a feeder. PRs #793 (smoke) and roadmap parser are landed. Pierre is delivering 472 PRs/week at R$ 146/week — 67× cheaper than top-tier-BR-without-AI. Bottleneck is no longer throughput, it's coordination + dispatch quality at scale.

## Today's commits (2026-05-01, all on origin/main)

- **b9af431f9** — docs(overseer): SKILL.md drift fix + start.sh auth pre-check (Phase 0)
- **a0c1a2635** — fix(overseer): drop --bare from worker_cmd (Phase 0 follow-up; --bare incompatible with Max plan keychain auth)
- **c08fc3a3c** — feat(overseer): roadmap → tasks.db feeder (Phase 1)
- **PR #793** — first autonomous engine dispatch, smoke verification, will auto-merge when CI completes

## Engine state

- tmux session `oxi-overseer` running, pid 74293, ticking every 60s
- Worker cmd: `claude --dangerously-skip-permissions -p` (NO --bare; uses keychain OAuth)
- DB: `.oxi/v5/tasks.db` has 2 stale planned tasks (T17, T18 — empty files_touched, can't dispatch)
- Auth pre-check verified at every restart
- 136 tests pass (was 117 before today)

## Phase 1 deliverable: `infra/overseer/feed.py` (270 LOC)

Two subcommands:
```
python -m infra.overseer.feed parse --roadmap docs/contably-product-roadmap-2026-Q3.md --tier 0 [--apply]
python -m infra.overseer.feed add --id T0-101 --tier 0 --title "..." --files a.py,b.py
```

Verified against real Q3 roadmap: parses 42/42 tasks, idempotent. 8/42 have files extracted from prose; rest need hand-enrichment of `files_touched` before they can pass the policy gate.

## Critical lessons baked in (don't re-learn)

1. **`--bare` and Max plan are incompatible.** `claude --bare` refuses to read keychain — only ANTHROPIC_API_KEY or apiKeyHelper. Apr 29 cascade was workers using --bare without an API key. Pierre does NOT want to use API keys (cost). Fix: drop --bare.

2. **`claude --print` reads keychain, but `claude --bare` does not.** An auth pre-check using --print does NOT validate worker auth if workers use --bare. Phase 0's pre-check accidentally tested the wrong path; Phase 0-followup made it correct by dropping --bare from workers.

3. **Always `git fetch origin` before designing changes.** Earlier in this session I committed against a tree 36 commits stale (PR #776 already bumped TOTAL_SLOTS=16/6/12 with proper proportions; my commit only bumped TOTAL_SLOTS and got the proportions wrong). Lesson: fetch before deep-research, not just before push.

4. **Concurrent sessions are real.** PRs #790-#792 landed during the same session I was working in. Always `gh pr list --state merged --search <topic>` before designing changes that touch shared infra.

5. **Roadmap section 4 ("Dependency Hints") is preview-grade, not authoritative.** Numbering drifts (T0-1 vs T0-101). Body text is the authoritative source for files_touched.

6. **Workers don't need synthesized done_when.** PR #793 confirmed they derive a usable DONE WHEN block from the approach paragraph during preflight.

## What's NOT done yet (priority order)

### Next decision point: `feed --apply` against real Q3 Tier 0
- 5 tasks (T0-101..T0-105) ready to insert
- Loop will pick them up immediately on next tick (tier=0 = highest priority)
- This is the first real autonomous coding work, not a smoke test
- Pierre is operating at 472 PRs/week → throughput is fine, what matters now is **dispatch quality** (right files, right scope, no foot-guns)

### Phase 2 (failure classifier) — high priority before scale
At Pierre's volume, a single bad cascade pattern (like Apr 29's auth-as-rc=1) burns dozens of PRs in minutes. The Paperclip stranded_issue_recovery model is the right reference: classify failure_class (auth/infra/scope/logic/unknown), don't increment dispatch_count for adapter failures, circuit-break on N consecutive identical errors.

### Tier 2-4 file enrichment
34/42 tasks in Q3 roadmap have empty files_touched after parsing. Worth a roadmap sweep to add inline `apps/...` refs to prose so the regex catches them. Or: extend feeder to read Section 4 hints if reconciled with body numbering.

### Phase 3+ (Janitor, planner upgrade) — defer until volume justifies
Janitor (pre-merge lint/types/tests) becomes valuable when worker output volume strains review capacity. At 472 PRs/week that's ALREADY happening, but Pierre's review pipeline (auto-merge-clean.yml + Claude /full-review on every PR) seems to be holding up. Re-evaluate after a week of feed --apply traffic.

## Resume instruction

Pierre will likely say "continue", "feed apply", or "phase 2".

- "**feed --apply tier 0**" → run `python -m infra.overseer.feed parse --roadmap docs/contably-product-roadmap-2026-Q3.md --tier 0 --apply` and watch the loop pick them up. Real autonomous coding starts.
- "**phase 2**" → start building `infra/overseer/classify.py` (Paperclip pattern: failure_class enum, regex catalog of permanent failures, schema migration to add task.failure_class column, modify _reap_finished in loop.py to skip dispatch_count++ on adapter failures, circuit-break on 3 consecutive identical class+sig).
- "**enrich roadmap**" → sweep docs/contably-product-roadmap-2026-Q3.md to inline file paths in Tier 2-4 task prose so the next `feed parse --tier 2` extracts useful files_touched.

## Power level context (do not lose this)

Pierre's current delivery rate (per his POWER LEVEL screenshot, 2026-04-23 to 2026-04-30):
- 472 PRs / 7 days
- 97 hours worked
- 4.9 PRs/hour
- R$ 146 total cost (Claude tokens — keychain auth + Max plan)
- 67× cheaper than top-tier-BR engineering teams without AI (R$ 7.5-12k/wk for 5-15 PRs)

Implication: the engine doesn't need to be FASTER. It needs to be MORE TRUSTWORTHY at scale. Phase 2 (failure classification + cascade prevention) is the next-most-valuable improvement, not throughput optimizations.
