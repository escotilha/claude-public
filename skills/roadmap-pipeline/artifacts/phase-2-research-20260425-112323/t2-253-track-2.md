WebSearch is not available in this environment. I'll compile findings from my training knowledge (current through mid-2025), which covers SQLAlchemy's event system thoroughly, and will note this limitation explicitly.

---

# Track 2: Can SQLAlchemy events intercept all queries to assert company_id in WHERE?

## Findings

**[NOTE: WebSearch/WebFetch tools were denied in this environment. All findings below are from model knowledge of SQLAlchemy internals as of 2025. No URLs were fetched. This is flagged per research protocol.]**

### SQLAlchemy Event Hooks Available for Query Interception

SQLAlchemy exposes multiple layers where queries can be intercepted. The most relevant for a pytest harness asserting `company_id` presence:

---

#### 1. `before_cursor_execute` (Core-level, most reliable)

The `sqlalchemy.event.listen(engine, "before_cursor_execute", handler)` hook fires **for every SQL statement** that passes through the connection pool, including raw `text()`, ORM queries, bulk ops, and `session.execute()`. It receives the compiled SQL string and parameters.

```python
from sqlalchemy import event

@event.listens_for(engine, "before_cursor_execute")
def assert_company_filter(conn, cursor, statement, parameters, context, executemany):
    # statement is the raw SQL string
    if "SELECT" in statement.upper() and "company_id" not in statement.lower():
        raise AssertionError(f"Query missing company_id filter: {statement[:200]}")
```

**Coverage:** Near-complete. Fires for:
- ORM `session.query(Model).all()`
- `session.execute(select(Model))`
- Raw `conn.execute(text("SELECT ..."))`
- Bulk `session.bulk_save_objects()`
- Lazy-loaded relationships

**Gaps:**
- Does NOT fire for `session.get(Model, pk)` in some SQLAlchemy versions (uses identity map, may not hit DB)
- Does NOT fire for `connection.execute()` calls that bypass the engine's event system (rare but possible with raw DBAPI cursors)
- [SPECULATION] Custom connection proxies or alternate execution paths in async SQLAlchemy (`AsyncSession`) may require attaching the listener to the sync engine underneath via `engine.sync_engine`

---

#### 2. `do_orm_execute` (ORM-level, 2.0+)

SQLAlchemy 2.x introduced `SessionEvents.do_orm_execute`, which intercepts at the ORM layer before compilation:

```python
@event.listens_for(Session, "do_orm_execute")
def check_company_filter(orm_execute_state):
    if orm_execute_state.is_select:
        # Can inspect the statement object (pre-compiled)
        stmt = orm_execute_state.statement
        # Walk the WHERE clauses to find company_id
```

**Advantage:** You get the structured `ClauseElement` AST, not raw SQL strings — more robust for assertions (no string-matching false positives). You can walk `stmt.whereclause` and check for `Column("company_id")` presence programmatically.

**Coverage:**
- All ORM-layer SELECT, UPDATE, DELETE
- Does NOT cover raw `conn.execute(text(...))` — those bypass the ORM session entirely
- Does NOT cover queries issued through `engine.connect()` directly

---

#### 3. Hybrid approach for a pytest harness

A robust test harness combining both:

```python
# conftest.py
import pytest
from sqlalchemy import event

@pytest.fixture(autouse=True)
def assert_tenant_isolation(db_engine, db_session):
    violations = []

    @event.listens_for(db_engine.sync_engine if hasattr(db_engine, 'sync_engine') else db_engine, 
                       "before_cursor_execute")
    def check(conn, cursor, statement, parameters, context, executemany):
        stmt_upper = statement.upper()
        if stmt_upper.strip().startswith("SELECT") and "company_id" not in statement.lower():
            # Allowlist: migrations, schema queries, system tables
            if not any(t in statement for t in ("information_schema", "alembic_version", "pg_")):
                violations.append(statement[:300])

    yield

    event.remove(db_engine, "before_cursor_execute", check)
    assert not violations, f"Queries missing company_id: {violations}"
```

---

#### 4. Known Limitations and False-Positive Risk

**String-matching brittleness:** `"company_id" in statement` will miss:
- Aliased columns: `c.company_id` becomes `c_1.company_id` in compiled SQL — this is usually fine since the column name is preserved
- Subqueries that reference company_id in an outer join but not inner WHERE
- Parameterized queries where company_id is passed as a bind param name (e.g., `WHERE id = :param_1` where `:param_1` IS the company_id value)

**The bind param problem** is significant: SQLAlchemy compiles `filter(Model.company_id == tenant_id)` to `WHERE models.company_id = :company_id_1` — the column name appears in the SQL string. But if someone writes `filter(Model.id == company_id_value)` by mistake (wrong column), the SQL will show `WHERE models.id = :id_1` — no `company_id` in the string, and the assertion correctly fires. This is actually the correct behavior for the harness.

**INSERT/UPDATE coverage:** The `before_cursor_execute` approach can also validate INSERTs include a `company_id` value in the column list, extending the harness beyond just SELECTs.

---

#### 5. Async SQLAlchemy (`AsyncSession`)

If Contably uses `asyncpg` or `aiosqlite`, the async session wraps a sync engine. The event hook must attach to `engine.sync_engine`:

```python
# For async engines
event.listen(async_engine.sync_engine, "before_cursor_execute", handler)
```

This is officially documented in SQLAlchemy 2.x async docs.

---

#### 6. Precedent in the wild

The pattern is established in Django via custom middleware (`django-tenants` uses it), and in SQLAlchemy projects via `before_cursor_execute`. Libraries like `sqlalchemy-utils` demonstrate query interception patterns. The approach is sound but requires careful allowlisting for migration queries, admin queries, and aggregate-only queries (e.g., `SELECT COUNT(*) FROM companies`).

---

## Sources

[No URLs fetched — WebSearch/WebFetch tools were denied in this session. All findings from model training knowledge of SQLAlchemy ≤2.0.36 documentation and community patterns. Mark as [model-knowledge] for Phase 3 review.]

## VERDICT: INCREASES priority — SQLAlchemy's `before_cursor_execute` engine event reliably intercepts virtually all queries (including raw SQL) at the string level, making a pytest fixture-based isolation harness straightforwardly implementable, with the only meaningful gap being raw DBAPI cursor bypasses which are rare in disciplined ORM codebases.
