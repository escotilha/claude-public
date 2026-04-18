---
name: reference:orchestrator-technical-guide
description: Contably Orchestrator technical reference — webhook API, service accounts, job types, circuit breaker, dead letter queue, database models, integration patterns
type: reference
originSessionId: 96fa5c1c-d809-4cfd-a1b4-a73ab6632232
---

Full technical reference for the Contably Orchestrator integration system is saved at:
`/Volumes/AI/Code/contably/docs/orchestrator-complete-guide.md` (source) and `.pdf` (rendered).

Key facts (verify against file before acting):

- Webhook API at `/api/v1/webhooks/orchestrator/` with X-Service-Key auth
- 3 job types: FILE_INGESTION, RECONCILIATION, PENDENCIA_CREATE
- 6 service account scopes: ingestion, reconciliation, pendencias_write, status_read, companies_read, full_access
- Circuit breaker: 5 failures → open, 60s timeout, 3 successes → closed
- Job lifecycle: QUEUED → PROCESSING → COMPLETED/FAILED/RETRYING → DEAD_LETTER
- Exponential backoff: 2^retry_count \* 30s, max 3 retries
- Two-level feature flags: global (system_settings.feature_flags) + per-company (company.settings.orchestrator_enabled)
- Admin UI pages: Orchestrator Rollout, Status Orchestrator
- Current state: infrastructure fully built, file processing/reconciliation/pendencia stubs not wired to real services
- Built by third party — team needs the docs to understand and extend it

**Why:** This was created by a third party and the team had no detailed understanding. The full guide is the definitive reference for extending the Orchestrator.

**How to apply:** Consult this when working on Orchestrator features, wiring stubs to real services, or onboarding new devs to the integration layer.

---

## Timeline

- **2026-04-13** — [implementation] Full technical guide created from codebase analysis (Source: session — /virtual-user-testing + orchestrator investigation)
