---
name: eSocial Activation Plan
description: Contably eSocial module activation via TecnoSpeed middleware — decisions, phases, and partner strategy
type: project
---

eSocial module activation decided 2026-03-18. Using TecnoSpeed (tecnospeed.com.br) as middleware partner for all 48 event types. Cloud certificate model — TecnoSpeed handles A1 signing.

**Why:** Existing code is 70% complete (3,187 lines backend + 504 lines UI) but has critical gaps: in-memory storage, placeholder routes, outdated schema (S-1.2 vs current S-1.3). TecnoSpeed eliminates SOAP/XML/signing complexity — Contably sends TX2 (plain text field-value format) via REST, TecnoSpeed handles everything else.

**How to apply:**

- Plan saved at `/Volumes/AI/Code/contably/docs/esocial-activation-plan.md`
- Phase 1 (infra): DB migration, TecnoSpeed REST client, certificate upload flow, employer registration — 3-5 days
- Phase 2 (pipeline): TX2 builders, wire routes, Celery Beat polling task (every 2 min), all 48 events — 3-5 days
- Phase 3 (UI + prod): Dashboard upgrade, cert management UI, deadline integration, bulk ops — 3-5 days
- Phase 4 (go live): TecnoSpeed contract, homologation testing, production switch — 1-2 days
- Celery infrastructure already exists (5 queues, Redis, Beat, Flower, K8s workers)
- Key env vars needed: TECNOSPEED_CNPJ_SH, TECNOSPEED_TOKEN_SH, TECNOSPEED_ENV
- TecnoSpeed API: POST .../enviar/tx2 (submit), GET .../consultar (poll), auth via cnpj_sh + token_sh headers
- Next action: Contact TecnoSpeed (0800 006 9500) + register free Conta TecnoSpeed for Data Dictionary access
