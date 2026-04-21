---
name: Dogfood the autonomous dispatcher before trusting it — sandbox EPERMs never show in unit tests
description: v4 Phase 5/6 dogfood surfaced 3 sandbox bugs unit tests couldn't catch. Pattern is to trigger a real task before declaring an orchestrator "ready."
type: semantic
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
Autonomous orchestrators that SSH into a sandboxed executor and run shell commands have a class of bugs that unit tests CANNOT catch: filesystem permission denials at the OS sandbox layer. These fire only when a REAL claude on a REAL mini writes to a REAL path that the profile doesn't allow.

**Pattern:**
1. Build the orchestrator + profile to spec.
2. Unit-test the orchestrator with mock subprocess runners (as done — 224 passing tests).
3. **Before marking "ready," dogfood at least one real dispatch** of a task the orchestrator itself will eventually do. Watch it fail. Fix. Re-dispatch.
4. Each class of FS access the real claude wants triggers a profile patch:
   - `~/.claude/projects/<uuid>` (session state)
   - `~/.claude/session-env/<uuid>` (sub-shell env)
   - `~/.claude-setup/memory/sessions/*.json` (SessionEnd hook output)
   - `/Volumes/AI/Code/contably/.git/worktrees/<name>/index.lock` (git bookkeeping)
5. 3-5 iterations is normal. Budget 30-60 min per iteration (rsync, restart, re-dispatch, wait for a real trace).

**Why:** Apple's sandbox docs are minimal. The EPERM message tells you the path but not why. You learn the profile by watching real programs break against it.

**Counter-example:** Trying to enumerate every path claude needs before running it. Guaranteed to miss something — claude's working-dir layout isn't documented and changes across versions.

**How to apply to a new orchestrator:**
- Budget a "dogfood hour" after the unit-test-green milestone, before merging to main.
- Pick the simplest possible task that exercises the full loop (dispatch → claude → commit → push → PR).
- Expect 2-5 sandbox/env fixes. Commit each individually so the profile's evolution is auditable.

---

## Related

- [pattern_learn-distill-encode-evolve.md](pattern_learn-distill-encode-evolve.md) — dogfooding is the "evolve" step of that meta-pattern; this memory is a concrete application (2026-04-21)
- [pattern_sandbox-exec-allow-default-deny-dangerous.md](pattern_sandbox-exec-allow-default-deny-dangerous.md) — the sandbox EPERMs specifically discovered via dogfood; iterated 4-5 times via real dispatches (2026-04-21)
- [tech-insight_non-interactive-ssh-path-trap.md](tech-insight_non-interactive-ssh-path-trap.md) — SSH PATH trap (exit 127) also found only during real dispatch, never in unit tests (2026-04-21)
- [tech-insight_pytest-unborn-head-breaks-branch-tests.md](tech-insight_pytest-unborn-head-breaks-branch-tests.md) — unborn HEAD bug: unit tests themselves had this class of issue that only surfaced during real dogfood (2026-04-21)

## Timeline

- **2026-04-21** — [success] v4 Phase 5/6 dogfood caught: slack `window_seconds=0` dedup bug, test PYTHONUSERBASE, git-init unborn HEAD, 3 sandbox EPERMs. None of these would have failed a CI test suite. (Source: session — Contably OS v4 Phase 5/6 dogfood logs)
- **2026-04-21** — [applied] Became the template for v4.2 ship_recovery + queue_replenisher: build, unit-test, then dogfood before declaring production-ready.
