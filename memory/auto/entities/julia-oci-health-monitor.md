---
name: julia-oci-health-monitor
description: Design spec for persistent OCI health monitoring — hourly checks stored in SQLite, status page at /oci-status
type: project
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Contably's OCI health is currently checked on-demand via /oci-health (Discord command). This spec adds persistence, a status page, and change-driven alerting — replacing manual checks with a URL Pierre can bookmark.

**Status:** Design approved, not yet implemented.

---

## Current State

- `/oci-health` skill runs on-demand when invoked in Discord
- Checks: OCI API reachability, Kubernetes pod health, Woodpecker CI pipeline status
- Output: Discord message with current status snapshot
- No history, no trend visibility, no passive alerting

## Proposed Architecture

### 1. Hourly Scheduled Task (`default-tasks.ts`)

Add a new scheduled task to Claudia's scheduler:

```typescript
{
  id: "oci-health-monitor",
  name: "OCI Health Monitor",
  schedule: "0 * * * *",          // top of every hour
  agent: "julia",                  // infra-monitoring agent
  prompt: "Run /oci-health and store the result. Only alert Discord if status changed.",
  silent: true,                    // suppress Discord output unless status changes
}
```

### 2. SQLite Table

New table in Claudia's existing SQLite DB (same db as sessions):

```sql
CREATE TABLE IF NOT EXISTS oci_health_checks (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp   TEXT NOT NULL,           -- ISO 8601 UTC
  status      TEXT NOT NULL,           -- 'ok' | 'degraded' | 'down'
  api_ok      INTEGER NOT NULL,        -- 0 or 1
  pods_ok     INTEGER NOT NULL,        -- 0 or 1
  pipeline_ok INTEGER NOT NULL,        -- 0 or 1
  details_json TEXT NOT NULL           -- full /oci-health JSON output
);
CREATE INDEX IF NOT EXISTS idx_oci_checks_ts ON oci_health_checks(timestamp DESC);
```

Retention: auto-prune rows older than 30 days on each insert.

### 3. Dashboard Endpoint (`GET /oci-status`)

Add to Claudia's Express server (alongside existing `/health`, `/dashboard` routes):

- Returns simple HTML status page — no JS framework, inline CSS
- Shows: current status badge (green/amber/red), last check timestamp, 24h sparkline
- Table: last 24 checks (timestamp, status, api, pods, pipeline, details toggle)
- Auto-refreshes every 5 minutes via `<meta http-equiv="refresh" content="300">`
- Auth: same token-based auth as existing dashboard (or IP allowlist for VPS-internal)

### 4. Change Detection for Alerts

Before storing each result, query the previous row:

```typescript
const prev = db
  .prepare(
    "SELECT status FROM oci_health_checks ORDER BY timestamp DESC LIMIT 1",
  )
  .get();

if (!prev || prev.status !== current.status) {
  // Status changed — send Discord alert
  await notifyDiscord(`#tech-ops`, buildStatusChangeMessage(prev, current));
}
// Always store, never always-alert
```

Alert format:

- ok → degraded: "OCI degraded: {failed_checks}. Last ok: {prev_timestamp}"
- degraded → ok: "OCI recovered. All checks passing as of {timestamp}"
- ok → down / degraded → down: "OCI DOWN: {details}"

## Implementation Path

| Phase | Task                                                        | File(s)                                                 |
| ----- | ----------------------------------------------------------- | ------------------------------------------------------- |
| 1     | Add hourly cron task                                        | `src/default-tasks.ts`                                  |
| 2     | Create SQLite migration for `oci_health_checks`             | `src/db/migrations/`                                    |
| 3     | Add storage + change-detection logic to /oci-health handler | `src/skills/oci-health.ts` or new `src/monitors/oci.ts` |
| 4     | Add `GET /oci-status` Express route + HTML template         | `src/server/routes/oci-status.ts`                       |

Each phase is independently deployable and testable.

## Key Design Decisions

- **SQLite, not Postgres** — health check history is local/operational data, not business data. Keeps it simple, no pgvector overhead.
- **Julia as agent** — she handles infra monitoring; consistent with her role. Arnold handles task execution but Julia owns the observation loop.
- **Silent by default** — scheduler suppresses Discord output unless status changes. Avoids hourly noise.
- **HTML, not API** — /oci-status is a human-readable page, not a JSON API. Pierre wants a URL to visit, not a dashboard to build.

---

## Timeline

- **2026-04-11** — [session] Design spec written, approved for implementation (Source: session — pierre request via claudia)
