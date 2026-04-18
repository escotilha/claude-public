---
name: claudia-heartbeat-tracker
description: Spec for heartbeat issue dedup — tracks active issues, prevents re-reporting, escalates persistent ones
type: project
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Heartbeat runs on a schedule and reports service health to #tech-ops. Without dedup, transient failures (a single failed HTTP check, a brief Redis timeout) trigger repeated alerts every run until resolved — alert fatigue sets in and real issues get ignored. This spec extends the existing heartbeat-state.json tracking (added 2026-04-09) with a dedicated issue registry that deduplicates reports, escalates persistent issues, and auto-resolves stale ones.

**VPS file location:** `/root/.claude/state/active-issues.json`

---

## Schema

```json
{
  "issues": [
    {
      "id": "string", // deterministic key: "{service}:{error-type}" e.g. "redis:connection-refused"
      "service": "string", // e.g. "redis", "postgres", "claudia-api", "discord", "telegram"
      "message": "string", // human-readable error description (latest seen)
      "firstSeen": "ISO8601", // timestamp of first occurrence
      "lastSeen": "ISO8601", // timestamp of most recent occurrence
      "count": "number", // total times seen since firstSeen (cumulative)
      "severity": "low | medium | high | critical",
      "status": "active | resolved"
    }
  ]
}
```

**ID generation rule:** `{service}:{error-class}` where error-class is a normalized slug (lowercase, no special chars). Example: `postgres:connection-timeout`, `claudia-api:500`, `discord:gateway-disconnect`. Do NOT include dynamic values (timestamps, request IDs) in the ID — IDs must be stable across runs for dedup to work.

---

## Dedup Logic

On each heartbeat run, for every detected issue:

1. Compute the issue ID (`{service}:{error-class}`)
2. Look up the ID in `active-issues.json`
3. **If found and `status = "active"`:** increment `count`, update `lastSeen`, update `message` (latest wording), **skip re-reporting to Slack**
4. **If found and `status = "resolved"`:** treat as a new occurrence — reset `firstSeen` to now, set `count = 1`, set `status = "active"`, **report as new issue**
5. **If not found:** create new entry with `count = 1`, `firstSeen = now`, `lastSeen = now`, `status = "active"`, **report to Slack**

**Report on first occurrence only** (count = 1). Subsequent occurrences update the registry silently.

---

## Escalation Logic

After updating the registry (post-dedup), check escalation conditions for each active issue:

| Condition                                   | Action                                                    |
| ------------------------------------------- | --------------------------------------------------------- |
| `count > 5`                                 | Escalate severity by one level (low→medium→high→critical) |
| `duration > 2 hours` (lastSeen - firstSeen) | Escalate severity by one level                            |
| Both conditions met simultaneously          | Escalate by two levels (cap at critical)                  |
| Severity reaches `critical`                 | Re-report to Slack with `[ESCALATED]` prefix              |

Escalation re-reports happen **once per severity level crossed**, not on every run. Track escalated severity in the registry to avoid repeat escalation messages.

Add `escalatedAt` and `escalatedSeverity` fields when escalation fires:

```json
{
  "escalatedAt": "ISO8601",
  "escalatedSeverity": "high"
}
```

---

## Resolution Logic

On each heartbeat run, after processing new issues:

1. For each issue with `status = "active"` in the registry:
   - If the issue was **not detected in this run** AND `lastSeen` is more than **30 minutes ago**: mark `status = "resolved"`, set `resolvedAt = now`
   - Report to Slack once: "[RESOLVED] {service}: {message} — was active for {duration}, seen {count} times"
2. Resolved issues remain in the file (do not delete) for audit trail
3. Prune resolved issues older than **7 days** to keep the file small

---

## Integration with Heartbeat

The heartbeat scheduled task should follow this flow each run:

```
1. Run health checks (all services)
2. Read active-issues.json (or create empty if missing)
3. For each detected failure:
   a. Run dedup logic → update registry
   b. Run escalation check → update registry + maybe re-report
4. For each active issue in registry:
   a. Run resolution check → update registry + maybe report resolved
5. Write updated active-issues.json back to disk
6. Update heartbeat-state.json (existing, tracks last-run timestamp)
```

**Atomic writes:** write to `active-issues.json.tmp` then rename to `active-issues.json` to avoid corruption if the heartbeat is killed mid-write.

---

## Relationship to Existing State

- `heartbeat-state.json` — tracks last-run timestamps, quiet hours, run counts. **Keep as-is.** This file does not change.
- `active-issues.json` — new file, tracks issue lifecycle. Heartbeat reads and writes both files each run.

Both live at `/root/.claude/state/` on the VPS.

---

## Slack Message Templates

**New issue (count = 1):**

```
[HEARTBEAT] {severity.upper()}: {service} — {message}
First seen: {firstSeen}. Issue ID: {id}
```

**Escalated issue:**

```
[ESCALATED to {severity.upper()}] {service} — {message}
Active for {duration}, seen {count} times since {firstSeen}. Issue ID: {id}
```

**Resolved issue:**

```
[RESOLVED] {service} — {message}
Was active for {duration}, seen {count} times. Resolved at {resolvedAt}.
```

---

## Timeline

- **2026-04-11** — [session] Spec created — extends heartbeat-state.json (added 2026-04-09) with issue dedup, escalation, and auto-resolution (Source: session — heartbeat issue tracker design)
- **2026-04-09** — [session] Heartbeat state tracking added (heartbeat-state.json) — quiet hours, #tech-ops routing (Source: session — project_heartbeat_followup)
