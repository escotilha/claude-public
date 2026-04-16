---
name: project_esocial_phase2_shipped
description: eSocial Phase 2 shipped 2026-04-15 — routes wired to real ESocialService, S-1000/S-1010 builders, schema S-1.3
type: project
originSessionId: 7b2437ec-9cc1-4b2d-813c-43c23f2528e6
---
eSocial Phase 2 deployed to production on 2026-04-15 (commit `fcfa6cff0`). The submission pipeline is now end-to-end functional via TecnoSpeed middleware.

**What shipped:**
- Routes `/esocial/events/submit`, `/events/{id}/status`, `/certificates`, `/certificates/upload` now use real `ESocialService` (DB-backed, tenant-isolated) instead of the 503 placeholder.
- S-1000 (Informações do Empregador) + S-1010 (Tabela de Rubricas) TX2 builders + Pydantic schemas added — mandatory prerequisites for any eSocial submission.
- Schema version bumped from S-1.2 to S.01.03.00 (2026 Receita spec).
- `.env.example` now documents all TECNOSPEED_* vars.
- 7 event types total: S-1000, S-1010, S-1200, S-1210, S-1299, S-2200, S-2299.

**What's NOT shipped (Phase 3/4):**
- Remaining 45 event types (of 52 total).
- Status webhook receiver (still Celery Beat polling every 2 min).
- Dead SOAP client cleanup (`client.py`, `submission.py`, `events.py`, `certificate_manager.py` still in repo — identified in codebase audit).
- Admin UI upgrade for submission history/certificate management.
- TecnoSpeed commercial contract (needed for `TECNOSPEED_TOKEN_SH`).

**Why:** Unblocks eSocial submission for any accounting firm with a TecnoSpeed token. Routes return 503 only when env vars are unset (legit — no token yet).

**How to apply:** Once TecnoSpeed contract is signed and token obtained, set `TECNOSPEED_CNPJ_SH` and `TECNOSPEED_TOKEN_SH` in K8s secrets → eSocial goes live immediately.

---

## Timeline

- **2026-04-15** — [implementation] Phase 2 shipped to staging then production. Routes wired, S-1000/S-1010 added, schema bumped. (Source: session — eSocial Phase 2 sprint)
