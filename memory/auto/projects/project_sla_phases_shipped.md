---
name: project_sla_phases_shipped
description: SLA Phases 1–4a shipped to production 2026-04-15, Phase 4b trigger-gated — unified agenda, scope toggle, aggregation endpoints
type: project
originSessionId: 7b2437ec-9cc1-4b2d-813c-43c23f2528e6
---
SLA Unification Phases 1–4a fully deployed to production on 2026-04-15. Phase 4b specified and gated on triggers.

**Phase 1:** Fixed metadata→extra_data data loss, wired Celery 5-min sweeps, per-priority at-risk thresholds (urgent=1h, high=2h, medium=6h, low=12h).

**Phase 2+3:** AgendaService merges tickets + workflow SLAs + fiscal obligations via read-only query-join. Endpoints: `/agenda/deadlines` + `/agenda/metrics`.

**Phase 4a:** ORDER BY before LIMIT, per-source allow-list scrub, fiscal templates visible, 5 partial indexes (migration 058), SQL GROUP BY (p95 <80ms), Prometheus histograms, event-driven `before_update` + `pg_notify`.

**Phase 4a.8 (Minha Agenda):** Role-aware scope toggle (Minha/Empresa/Firma/Grupo/Plataforma), `GET /agenda/metrics` accepts company_id/analyst_id/firm_id/group_id, new endpoints `/agenda/metrics/by-analyst` and `/agenda/metrics/by-company`, PT-BR translations, default list tab = Todos (unified), breakdown tables with coming-soon banner for unstubbed views.

**Phase 4b (trigger-gated, not started):** Polymorphic `sla_tracking(source_type, source_id)`, extract `src/sla/` bounded context, feature flag `SLA_UNIFIED_READER`. Triggers: p95 > 300ms sustained 24h, 4th SLA source, or cross-source escalation rules. Spec in `plan.md` lines 493–650.

**Why:** Transforms SLA from a superuser-only dashboard into a role-aware compliance tool for all user levels (junior through group admin).

**How to apply:** Phase 4b is ready to fire when any trigger hits. SLA strategic expansion plan (`docs/sla-strategic-expansion-plan.md`) adds tiers, complexity sizing, client reliability score, heatmap prediction, root-cause analysis — 3-wave roadmap (Q2/Q3/Q4 2026).

**Key files:** `apps/api/src/workflows/agenda_service.py`, `apps/api/src/api/routes/system/agenda.py`, `apps/admin/src/pages/tickets/TicketsPage.tsx`, `apps/admin/src/hooks/useAgendaScope.ts`

---

## Timeline

- **2026-04-15** — [implementation] Phases 1, 2+3, 4a, 4a.8 shipped to production in single day (9 commits + 3 hotfixes). (Source: session — SLA unification sprint)
- **2026-04-15** — [implementation] SLA strategic expansion plan written from partner feedback — 5 ideas, 3-wave roadmap, tier definitions (Essencial/Profissional/Premium). (Source: session — partner feedback analysis)
