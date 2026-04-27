---
name: mistake-nested-asyncio-run-in-async-loop
description: Calling a sync function from an async coroutine, where the sync function does asyncio.run() internally, raises 'cannot be called from a running event loop' — fix with asyncio.to_thread
type: feedback
originSessionId: 1325e91e-d8f4-4d28-8812-5fa0a6ec6a55
---
When an async coroutine calls a sync function that *internally* does `asyncio.run(...)`, Python raises `RuntimeError: asyncio.run() cannot be called from a running event loop`. This is a sneaky bug because the async caller's static analysis says "I'm calling a sync function, no await needed" — the failure only manifests at runtime when the sync function tries to spin up its own event loop on top of the running one.

**Fix:** wrap the sync call with `await asyncio.to_thread(sync_fn, ...)`. The thread has no running loop, so the inner `asyncio.run()` succeeds. Same pattern works for any sync→async bridge that needs to call `asyncio.run` underneath.

**Why:** Python's `asyncio.run()` creates a new event loop and runs until completion. It cannot nest — you either reuse the running loop with `await`, or you offload to a thread that has no loop.

**How to apply:**
- When migrating a function from sync to async, audit every callee. If a callee does `asyncio.run(...)` (or wraps a sync API around `await some_coro()`), either:
  1. Make the callee async too, and `await` it directly (cleanest)
  2. Wrap the call in `await asyncio.to_thread(...)` (least invasive — works without modifying the callee)
- Watch for "sync wrapper around async" classes — they're often `def review(self): return asyncio.run(self.review_async(...))`. Those break under any async caller.
- Tests that stub the sync function won't catch this — the bug only fires when the *real* implementation runs. Write a regression test where the stub itself does `asyncio.run(coro())` to simulate the production failure.
- The `except Exception` swallowing pattern is dangerous here: if the only signal that the call failed is a generic warning log, the engine keeps running but makes no progress. Consider letting the RuntimeError propagate, or counting consecutive failures and halting (oxi's `engine_health.UNHEALTHY` flag pattern).

---

## Timeline

- **2026-04-27 22:18 UTC** — [failure] oxi saturate engine flipped UNHEALTHY in production after 5 consecutive `auto_merge.run failed: asyncio.run() cannot be called from a running event loop` failures. saturate.run was async, auto_merge.run was sync, critic.review() did asyncio.run(review_async) internally. The except block swallowed the error so dispatch kept happening but auto_merge never advanced. (Source: failure — oxi-core/src/oxi_core/v3/saturate.py:468 calling auto_merge.run from async context)
- **2026-04-27 23:36 UTC** — [implementation] Fixed in PR Xurman/oxi#235 by wrapping the call with `merge_report = await asyncio.to_thread(auto_merge.run, conn, state, critic)`. Pattern matched the existing fix in heartbeat.py:425-452 for the sync triage call. Regression test test_auto_merge_offloaded_to_thread reproduces the exact production failure (29/29 saturate tests pass; test FAILS without the fix). (Source: implementation — Xurman/oxi PR #235, commit 155ee8e)
- **2026-04-27 23:45 UTC** — [implementation] Engine healed and saturate restarted; 0 asyncio errors in the new run, dispatches succeeding. (Source: session — OXi cutover Phase 4)
- **Discovered:** 2026-04-27
- **Use count:** 1
- **Applied in:** oxi - 2026-04-27 - HELPFUL
