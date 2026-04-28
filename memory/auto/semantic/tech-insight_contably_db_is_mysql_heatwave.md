---
name: tech-insight:contably-db-is-mysql-heatwave
description: Contably production DB is MySQL HeatWave on OCI — not Postgres, not local Docker. Migrated 2026-03-28.
type: feedback
originSessionId: 6e9cc58c-9bce-4391-8095-41baaccc6508
---
Contably's production (and staging) database is **MySQL HeatWave on OCI** — accessed via `mysql+asyncmy://` in `DATABASE_URL`. There is no local Postgres, no Docker Compose DB, no Supabase.

Migration from Postgres to MySQL HeatWave completed ~2026-03-28. Any code, scripts, or docs referencing `postgresql://`, `localhost:5432`, `contably_password@localhost`, or `docker compose up -d` for the DB are stale and should be removed.

Key implications:
- No `RETURNING` clause in UPDATE statements (MySQL doesn't support it — SELECT first, then UPDATE)
- Password hashing uses `bcrypt` (not argon2) on the pod scripts, because the ORM hash context picks bcrypt for MySQL
- DB updates must run via `kubectl exec` on the `contably` namespace pods — there is no local connection path
- The Postgres MCP tool (`mcp__postgres__query`) is read-only and irrelevant for Contably writes
- `update_master_password.py` on the pod is the canonical script pattern for password ops

---

## Timeline

- **2026-03-28** — [session] Pierre confirmed migration from Postgres to MySQL HeatWave completed ~month ago
- **2026-04-28** — [session] Discovered during dev-user password rotation — RETURNING clause failed, asyncmy driver confirmed, bcrypt used on pod. All 5 test users updated via kubectl exec.
