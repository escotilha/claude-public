---
name: mistake-committed-hook-breaks-worktrees
description: A committed .claude/settings.json SessionEnd hook pointing at a decommissioned CLI binary silently breaks every oxi worker dispatch — worktrees inherit the committed settings file, so the missing binary causes non-zero exit on every fresh dispatch.
type: mistake
originSessionId: b8cba660-2b56-4f56-85b9-ec3bd65ab012
---
When a Claude Code repo has `.claude/settings.json` committed with a `SessionEnd` (or any lifecycle) hook pointing at a CLI binary that no longer exists, **every git worktree created from that repo inherits the broken hook**. The session exits non-zero after every dispatch — no actual work runs. In oxi/parallel-dev scenarios, the repeat-failure circuit-breaker trips after N failures and the engine flips UNHEALTHY / saturate halts.

**Root cause surfaced 2026-04-27:**
- `contably-os hook session-stop` was registered as a SessionEnd hook in `.claude/settings.json`
- The `contably-os` v2 binary was decommissioned during the oxi cutover on 2026-04-27
- Every `git worktree add` for an oxi worker dispatch inherited the committed settings file
- Each worker session emitted: `SessionEnd hook [contably-os hook session-stop] failed: /bin/sh: contably-os: command not found`
- Workers exited at ~4s with a non-zero code; oxi's circuit-breaker kept tripping

**Fix:** Remove the hook entry from `.claude/settings.json`. Reverify with `cat .claude/settings.json | jq .hooks`.

**Prevention:**
1. After any CLI binary is decommissioned / renamed, immediately audit ALL repos that have `settings.json` committed and grep for the old binary name: `grep -r "old-binary-name" **/.claude/settings.json`
2. Treat committed lifecycle hooks in `settings.json` as a **distributed dependency** — they run in every worktree, not just the main checkout.
3. When switching harnesses (v2 → oxi, contably-os → psos, etc.), add a PR checklist item: "Audit and clean settings.json hooks."
4. Smoke-test after harness cutover by creating a fresh worktree and checking `echo $?` after session exit.

---

## Timeline

- **2026-04-27** — [failure] oxi worker dispatches exiting at ~4s with SessionEnd hook error. `contably-os` CLI decommissioned during the same-day oxi cutover but hook remained in committed settings.json. Fix: removed the hook entry in PR #682. (Source: session — contably oxi Phase 4 first-task seeding)

## Related

- [mistake-hardcoded-legacy-fallback-in-code](mistake_hardcoded_legacy_fallback_in_code.md) — analogous pattern: decommissioned binary path referenced in committed config, not just source code
