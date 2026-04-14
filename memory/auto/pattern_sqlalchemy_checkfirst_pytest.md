---
name: pattern:sqlalchemy-checkfirst-pytest
description: Use checkfirst=True in Base.metadata.create_all() to prevent duplicate-index errors when SQLAlchemy metadata is shared across a pytest session
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

When using SQLAlchemy with pytest and a shared `Base.metadata`, always pass `checkfirst=True` to `create_all()`. Without it, SQLite raises errors about duplicate indexes on the second test that tries to create the same tables in the same in-memory engine session.

**Trigger:** Any pytest fixture that calls `Base.metadata.create_all(engine)` with a module-scoped or session-scoped engine.

**Fix:**

```python
# WRONG — fails with duplicate index error on shared metadata
Base.metadata.create_all(engine)

# CORRECT — idempotent, safe for shared metadata
Base.metadata.create_all(engine, checkfirst=True)
```

Discovered in Contably when 51 tests failed after parallel-dev added new models that shared the same SQLAlchemy Base. The `checkfirst` flag tells SQLAlchemy to skip table/index creation if it already exists.

Relevance score: 6
Use count: 1

---

## Timeline

- **2026-04-14** — [failure] Discovered: Contably parallel-dev Phase B — 51 tests failing due to duplicate index on shared SQLAlchemy Base.metadata. Fixed by adding checkfirst=True to all test engine fixtures. (Source: implementation — apps/api/tests/unit/test_sync_database.py)
- **2026-04-14** — [session] Applied in: Contably - 2026-04-14 - HELPFUL
