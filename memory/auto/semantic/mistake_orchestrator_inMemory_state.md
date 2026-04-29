---
name: mistake:orchestrator-in-memory-state
description: Orchestrator tracking in-flight work only in RAM causes re-dispatch loops on restart — always persist status before launching
type: feedback
originSessionId: 18d12c41-147b-4b47-8389-c8ff7092c361
---
Any orchestrator that tracks "what's running" in-memory only (e.g. WorkerHandle list) will re-dispatch the same task on every restart. The symptom is a task looping at 60s intervals with rc=0 but never advancing.

Fix pattern: write `status=dispatched` to the DB *before* considering the launch successful. If the write fails, don't launch. Write `status=merged` when the PR is detected as merged.

Diagnostic reflex when seeing "no planned tasks" with a non-empty DB: check what the DB actually contains (`SELECT status, COUNT(*) FROM task GROUP BY status`), then check what the query filters. It is always a path mismatch or a status mismatch — never a real empty queue.

**Why:** Learned from V5 overseer dogfood session 2026-04-28. T3 looped 3+ times because WorkerHandle was lost on restart and status stayed `planned`. Fixed by adding `_update_task_status()` called immediately after `launch_worker()`.

---

## Timeline

- **2026-04-29** — [failure] V5 overseer re-dispatched T3 in a 60s loop; root cause was missing DB write after launch. Fixed with `_update_task_status()` in loop.py. (Source: failure — contably-overseer-v5 dogfood session)
