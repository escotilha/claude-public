---
name: project_certcontrol_integration
description: Contably CertControl digital certificate integration — plan location, architecture decisions, API spec, review status
type: project
originSessionId: 4dbae309-cc60-45e3-aac5-28237cd9345b
---

CertControl integration plan for Contably's eSocial module. Adds seamless digital certificate acquisition via CertControl API, with webhook-driven auto-download and auto-upload to TecnoSpeed.

**Plan location:** `docs/certcontrol-integration-plan.md` in the Contably repo (`/Volumes/AI/Code/contably/docs/certcontrol-integration-plan.md`)

**Architecture:** Option A — integrated into existing `apps/api/src/integrations/esocial/` module. Webhook-driven (no Celery poller). Auto-pipeline: CertControl webhook "certificate_ready" → download .pfx → upload to TecnoSpeed → store in `esocial_certificates` → link to employer.

**Key decisions:**

- Contably defines the certificate password at sale creation (enables full automation)
- Contably absorbs cost (no payment link passthrough to clients)
- CertControl will expose webhooks (confirmed by user, not yet in their docs)
- Product catalog lookup needed (fetch tabela_id/produto_id from CertControl)
- Manual refresh button as fallback for missed webhooks

**Review status (2026-04-14):** DRAFT — CTO review passed (no critical security issues in codebase). Plan has 6 issues to fix before implementation:

1. API client uses speculative endpoints — must align to real spec (POST /api/integracao/vendas, etc.)
2. Base URL wrong (plan says api.certcontrol.com.br, real is service.certcontrol.com.br)
3. Missing product catalog lookup
4. Password flow needs alignment with real download endpoint
5. No scheduling integration (appointment booking from Contably UI)
6. Webhook spec is speculative — needs flexibility for actual payload format

**How to apply:** When user asks to "implement digital certificates" or "implement CertControl" or "implement cert integration", read `docs/certcontrol-integration-plan.md` first, fix the 6 issues above, then implement via `/deep-plan` or `/ship`.

---

## Timeline

- **2026-04-14** — [session] Deep-plan research + planning complete, CTO review done, plan saved to docs/certcontrol-integration-plan.md (Source: session — /deep-plan + /cto for CertControl integration)
