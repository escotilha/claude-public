---
name: pattern:alembic-half-stamped-recovery
description: Recipe for "Table X already exists" alembic errors — when a migration created a table but failed before recording the revision, leaving DB and alembic_version out of sync. Verify schema match, then `alembic stamp` the missing revision.
type: feedback
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
When `alembic upgrade` fails with `OperationalError: (1050, "Table 'X' already exists")` (MySQL) or equivalent on Postgres, the cause is almost always a half-completed prior migration: the `CREATE TABLE` succeeded, but the migration script failed before recording the revision in `alembic_version`. Subsequent runs see the table, try to create it again, and bomb.

## Diagnostic checklist

1. Confirm the target table exists in the DB:
   ```sql
   SHOW TABLES LIKE 'X';   -- MySQL
   \dt X                    -- Postgres
   ```
2. Confirm the revision is NOT in `alembic_version`:
   ```sql
   SELECT version_num FROM alembic_version;
   ```
3. **Confirm the existing table's schema matches what the migration would create.** This is the critical step — never stamp without verifying. Mismatch means the table was created by some other path and stamping would lock in a wrong shape.
   ```sql
   DESCRIBE X;   -- MySQL
   \d X          -- Postgres
   ```
   Compare column-by-column against the migration file's `op.create_table(...)`.
4. Check the table's row count:
   ```sql
   SELECT COUNT(*) FROM X;
   ```
   Zero rows is the safest case — if the table is empty, there's no data risk in any recovery path.

## Recovery: `alembic stamp <revision>`

If schema matches and ideally rows = 0:

```bash
# Inside a pod with the NEW image (must contain the migration file):
kubectl exec -n <ns> deploy/<app> -- alembic stamp <revision_id>
```

Or for a one-shot pod (when the deployment hasn't been updated yet):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alembic-stamp-<rev>
spec:
  restartPolicy: Never
  imagePullSecrets:
    - name: ocir-secret
  containers:
    - name: stamp
      image: <registry>/<image>:<new-tag>
      command: ["alembic", "stamp", "<revision_id>"]
      envFrom:
        - secretRef: { name: <secrets> }
        - configMapRef: { name: <config> }
```

Apply, wait for `Succeeded`, check logs for `Running stamp_revision -> <rev>`, delete pod.

## Re-run the upgrade

After stamping, re-run `alembic upgrade heads`. If the same error appears for a DIFFERENT table, repeat the diagnostic + stamp for that one. Multiple half-stamped tables in a row is rare but happens after a CI cascade where many migrations partially ran.

## When NOT to stamp

- **Schema doesn't match.** The existing table came from a different source (manual SQL, dropped column, different column order). Investigate — don't stamp.
- **Row count is non-zero AND schema is suspect.** Risk of locking in wrong-shape data. Drop+recreate via downgrade-then-upgrade, or migrate the data first.
- **The "missing" revision is actually expected to NOT be in alembic_version.** Some workflows use stamping selectively (e.g., a feature-flagged migration). Read git blame on the migration file before stamping.

## Why this happens

Two common triggers:

1. **Job timeout mid-migration**: kubernetes Job hits `activeDeadlineSeconds`, kills the pod after `CREATE TABLE` ran but before alembic's `INSERT INTO alembic_version`. The DB transaction may have committed (DDL is auto-commit on MySQL).
2. **Test environment leakage**: a test runner that creates schema via `Base.metadata.create_all()` against the real DB, leaving tables behind without alembic awareness.

## Prevention (longer-term)

- **Don't run DDL outside alembic on shared environments.** Test fixtures that need schema should use a separate in-memory DB.
- **Add table-existence guard to migration env.py**: if a `CREATE TABLE` would fail because the table exists with the same shape, log and skip. Risky if implemented broadly — better as opt-in per migration via a custom op.
- **Tighter Job activeDeadlineSeconds**: if migration jobs are getting timeout-killed, that's a symptom — investigate the slow migration rather than just bumping the deadline.

---

## Timeline

- **2026-04-30** — [failure×2] Hit twice in same morning during the deploy cascade. First on `customers` table (#757 migration `35b2eba4da2c`), then on `client_processes` table (#566 migration `t2_115_client_processes`). Both half-stamped from prior cancelled deploy attempts. Stamped both via one-shot pod with new image; subsequent `alembic upgrade heads` ran cleanly. Each diagnostic + stamp cycle took ~5 min once the pattern was recognized; first one took ~30 min figuring out the right kubectl image tag (the IMAGE_TAG var uses 7-char SHA prefix, not 8). (Source: failure — staging deploy cascade 2026-04-30)

Related:
- [pattern:verify-distributed-state](pattern_verify_distributed_state.md) — the schema-match check IS the post-condition verify before stamping
- [tech-insight:contably-db-is-mysql-heatwave](tech-insight_contably_db_is_mysql_heatwave.md) — Contably DB specifics that make this pattern apply
