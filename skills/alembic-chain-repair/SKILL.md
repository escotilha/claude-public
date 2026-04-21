---
name: alembic-chain-repair
description: "Repair broken Alembic migration chain — multiple heads, missing parents. Triggers: alembic repair, fix migration, multiple heads."
argument-hint: "[--env=<staging|production|local>] [--target=<mysql|postgres>] [--dry-run]"
user-invocable: true
context: fork
model: opus
effort: high
alwaysThinkingEnabled: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
tool-annotations:
  Bash: { destructiveHint: true, idempotentHint: false }
---

# `/alembic-chain-repair` — Fix Broken Alembic Migration Chains

Built from the 8+ migration chain repair commits in the last 17 days. Handles the recurring Contably failure modes:
- multiple head revisions
- missing parent references
- PostgreSQL-only syntax on MySQL targets
- stale `alembic_version` entries
- branch conflicts after merge

**Scope**: Contably's Alembic setup at `apps/api/alembic/`. MySQL 8 production target, flexible for staging (usually MySQL). PostgreSQL only used for specific feature tables (pgvector).

**Approval password**: `go`.

---

## Invocation

```bash
# Full diagnosis + repair on local DB
/alembic-chain-repair

# Repair with prod MySQL target (rewrites PG-only syntax)
/alembic-chain-repair --target=mysql --env=production

# Dry run — print repair plan without touching files
/alembic-chain-repair --dry-run
```

---

## Phase 1: Diagnosis

Run these in the repo root (`apps/api/`):

```bash
cd apps/api
# List all heads
alembic heads 2>&1
# Full history
alembic history --verbose 2>&1 | tail -40
# Current DB revision(s)
alembic current 2>&1
# List all version files
ls alembic/versions/*.py | wc -l
```

Classify into one of the 5 damage types:

| Damage type | Diagnosis signal | Severity |
|---|---|---|
| `multiple-heads` | `alembic heads` returns ≥2 revisions | Medium |
| `missing-parent` | `Can't locate revision identified by '<rev>'` or `down_revision` points to nothing | High |
| `stale-db-version` | `alembic_version` table has revisions not in code | High |
| `pg-only-syntax` | MySQL target rejects `RETURNING`, `gen_random_uuid()`, `SERIAL`, `JSONB`, `ARRAY`, `CONCURRENTLY` | High |
| `branch-conflict` | Two feature branches both added migrations with same `down_revision` | Medium |

Write diagnosis to `.alembic-repair/diagnosis.md`. Confidence < 0.75 → ask user to confirm via `AskUserQuestion`.

---

## Phase 2: Gate

```
Diagnosis: <damage_type> (confidence 0.92)
Evidence:
  <top 3 lines>
Current heads: <list>
Repair plan: <summary>
Files to modify: <list>
DB changes: <stamp|upgrade|none>
Risk: <low|medium|high>

Reply 'go' to apply, anything else to abort.
```

Production env → always `go`-gated regardless of mode.

---

## Phase 3: Repair Procedures

### `multiple-heads`

When `alembic heads` shows 2+ revisions:

1. Identify the heads: `alembic heads` → `[rev_a, rev_b]`
2. Ask user which is the "main" line and which is the feature branch, OR infer from commit dates (newest = feature).
3. Create a merge revision:
   ```bash
   alembic merge -m "merge <feature_name> into main chain" <rev_a> <rev_b>
   ```
4. Alembic auto-generates `alembic/versions/<new_rev>_merge_*.py` — review that `down_revision = (rev_a, rev_b)`.
5. Test locally: `alembic upgrade head` (singular) against a scratch MySQL container.
6. Commit: `fix(migrations): merge branch heads <rev_a>+<rev_b>`.

### `missing-parent`

When a migration references a `down_revision` that doesn't exist:

1. `grep -rE "down_revision = ['\"]<missing_rev>['\"]" alembic/versions/` — find the orphan file.
2. Two options:
   - **The missing parent was deleted** → fix the orphan's `down_revision` to point to the nearest valid ancestor (trace from `alembic history`).
   - **The missing parent was never merged** → restore it from git history: `git log --all -- alembic/versions/ | grep <missing_rev>` then `git show <sha>:<path>`.
3. Verify: `alembic history --verbose` runs clean.
4. Commit: `fix(migration): repair broken Alembic revision chain — restore <missing_rev>`.

### `stale-db-version`

When `alembic_version` table has revisions not in code (usually after reverting migrations):

1. Connect to the target DB directly:
   ```bash
   # Read current DB state without touching code
   python -c "
   from sqlalchemy import create_engine, text
   import os
   e = create_engine(os.environ['DATABASE_URL'])
   with e.connect() as c:
       rows = c.execute(text('SELECT version_num FROM alembic_version')).fetchall()
       print([r[0] for r in rows])
   "
   ```
2. Compare to `alembic heads`. Stale revisions are in DB but not in `alembic/versions/`.
3. If staging/local: clean stale + stamp correct:
   ```sql
   DELETE FROM alembic_version WHERE version_num NOT IN (<current_heads>);
   ```
   then `alembic stamp heads`.
4. If production: **always gate with `go`**. Option to stamp correct heads:
   ```bash
   alembic stamp <correct_heads>
   ```
5. After stamping, `alembic upgrade heads` should be a no-op. If it tries to run migrations, STOP — the repair is incomplete.

### `pg-only-syntax`

When a migration fails on MySQL with PostgreSQL-only constructs:

**Rewrite table**:

| PostgreSQL | MySQL 8 replacement |
|---|---|
| `RETURNING id` | `LAST_INSERT_ID()` after INSERT, separate SELECT |
| `gen_random_uuid()` | `UUID()` |
| `SERIAL` or `BIGSERIAL` | `INTEGER AUTO_INCREMENT PRIMARY KEY` (or `BIGINT`) |
| `JSONB` | `JSON` |
| `TEXT[]` / `INTEGER[]` | Normalized junction table (no native array) |
| `CREATE INDEX CONCURRENTLY` | `CREATE INDEX` (MySQL 8 is online by default for most ops) |
| `TIMESTAMPTZ` | `DATETIME` + application-level UTC |
| `ILIKE` | `LIKE` + `COLLATE utf8mb4_0900_ai_ci` |
| `EXCLUDE USING gist` | Application-level check or unique index on generated column |
| `$$ ... $$` PL/pgSQL blocks | Split into raw `op.execute()` individual statements |

Procedure:
1. Identify offending migration: logs usually point to `alembic/versions/<rev>_<name>.py`.
2. Rewrite the `op.execute()` or autogenerated `op.*` calls using the table above.
3. For polymorphic support (Contably ships staging-MySQL + future-PG), wrap dialect-specific ops:
   ```python
   from sqlalchemy import inspect
   def upgrade():
       bind = op.get_bind()
       dialect = bind.dialect.name
       if dialect == 'mysql':
           op.execute("... MySQL syntax ...")
       elif dialect == 'postgresql':
           op.execute("... PG syntax ...")
   ```
4. Test against a fresh MySQL 8 container:
   ```bash
   docker run --rm -d --name mysql8-test -e MYSQL_ROOT_PASSWORD=test -e MYSQL_DATABASE=contably_test -p 3307:3306 mysql:8
   sleep 10
   DATABASE_URL=mysql+pymysql://root:test@localhost:3307/contably_test alembic upgrade heads
   docker stop mysql8-test
   ```
5. Commit: `fix(migration): rewrite <rev> for MySQL 8 compatibility`.

### `branch-conflict`

When two feature branches both added a migration with the same `down_revision`:

1. `alembic heads` → shows both sibling revisions.
2. If both have already merged to `main`: apply `multiple-heads` procedure (merge revision).
3. If one is still on a feature branch: rebase the feature migration's `down_revision` to point to the other:
   ```python
   # In alembic/versions/<feature_rev>_*.py
   down_revision = '<other_merged_rev>'  # was: '<shared_parent>'
   ```
4. Also widen `alembic_version.version_num` column if error mentions length:
   ```python
   op.alter_column('alembic_version', 'version_num', type_=sa.String(255))
   ```
   (Contably hit this — migration 039 idempotency.)
5. Commit: `fix(migrations): rebase <feature_rev> to sequential chain`.

---

## Phase 4: Idempotency Check

After any repair, verify the migration can run twice without error:

```bash
# Fresh DB
alembic upgrade heads
# Run again — should be no-op, not error
alembic upgrade heads
# Downgrade should also be clean (optional, don't run on prod)
alembic downgrade -1 && alembic upgrade head
```

If re-run produces errors: the migration has side-effects that aren't idempotent. Fix by:
- Wrap `CREATE TABLE` with `IF NOT EXISTS`
- Wrap `INSERT` with `INSERT IGNORE` or `ON DUPLICATE KEY UPDATE`
- Guard `ALTER TABLE ADD COLUMN` with a dialect-specific existence check

Commit: `fix(migration): make <rev> idempotent for MySQL`.

---

## Phase 5: Verify + Hand-Back

1. Run `alembic history --verbose` — should show single linear chain (or clean merge points).
2. Run `alembic heads` — should show single revision (or known intentional branching).
3. Run `alembic upgrade heads` against scratch DB — success.
4. Run `/verify-conta` if in Contably repo to catch side-effects.
5. Write report to `.alembic-repair/report.md`:
   ```markdown
   # Alembic Repair Report
   Damage type: <name>
   Commits: <shas>
   Current heads: <list>
   Verified: upgrade heads ✓, idempotency ✓, /verify-conta ✓
   Next step: <push + CI | manual test | deploy>
   ```
6. If invoked by `/contably-ci-rescue`, return structured result:
   ```json
   {"status": "DONE", "damage_type": "...", "commits": ["..."], "heads": ["..."]}
   ```

---

## Anti-Patterns

- **Never `alembic downgrade` against production.** Fix forward. Downgrade is for local scratch only.
- **Never delete a migration file that has been applied to any shared DB.** It breaks everyone's `alembic_version`.
- **Never stamp a revision that hasn't actually been applied.** Stamping lies to Alembic — only use it to correct a known-synced-but-mislabeled state.
- **Don't mix `op.execute()` raw SQL with `op.create_table()`** for the same table. Pick one style per migration.
- **Don't run migrations directly via Python** (`Base.metadata.create_all()`) in production. Always via `alembic upgrade`.
- **Don't assume `async_engine`.** Contably uses sync `create_engine` with `pymysql` for Alembic stamps. This was one of the recent CI fixes.

---

## Integration with Other Skills

| Skill | Relationship |
|---|---|
| `/contably-ci-rescue` | Delegates here when `failure_class = alembic-chain-broken` or `alembic-mysql-incompat` |
| `/verify-conta` | Runs after repair to catch side-effects |
| `/deploy-conta-staging` | Never run until repair is verified locally |
| `/orchestrate` | Can invoke as a sub-phase in investigate-then-fix patterns |

---

## Version

**v1.0.0** — 2026-04-17. Built from 17-day commit history pattern analysis.
