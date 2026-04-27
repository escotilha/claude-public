# Track 3: Focus NFe cron pattern reuse for catalog sync

## Findings

**Note:** WebSearch/WebFetch permissions were not available to the subagent. All findings below are from training knowledge (cutoff August 2025). URLs listed were not fetched; marked accordingly. No hallucinated content — speculation is explicitly labeled.

---

### Focus NFe reconciliation architecture

Focus NFe exposes a REST API at `api.focusnfe.com.br`. The daily-reconciliation pattern is:

- Nightly cron (`0 3 * * *`) fetches NFes updated in a rolling 48h window via `GET /v2/nfes?created_at[gte]=YYYY-MM-DD`
- Diffs returned `status` field against local DB state
- State machine: `processando` → `autorizada` / `cancelada` / `denegada` / `erro_sefaz`
- Idempotent by design: re-polling already-reconciled documents is a no-op
- External API is the **authoritative source**; local DB is the mirror

Core structural properties: document-level objects with stable identity keys (`referencia`), scalar status fields, bounded daily volume (hundreds to low thousands), time-triggered cadence.

---

### eSocial S-1010 rubricas — structure and change frequency

S-1010 (`evtTabRubrica`) is the employer's **own** rubrica (payroll item) catalog submitted to eSocial — it is not a government-published feed. Key distinction:

- The employer declares their payroll item classifications mapped to eSocial's taxonomy (`codRubr`, `natRubr`, `tpRubr`, incidência codes)
- **No official query API exists** — eSocial webservices are submission-oriented (`enviarLoteEventos`), not query-oriented; there is no `GET /rubricas?updated_since=...` equivalent
- Change frequency: episodic, not daily — triggered by HR system changes, new payroll item types, collective bargaining updates, or eSocial layout version upgrades
- Layout version changes (e.g., S-1.0 → S-1.1 → S-1.2) accompany major eSocial releases, typically annual with 90–180 day transition windows
- Record structure is complex: each rubrica has `iniValid`/`fimValid` validity ranges, multiple incidência flags (CP, IR, FGTS, SCP), and `dscRubr` descriptions — not a scalar status field

**EFD-Reinf v2.1.2 relationship:** EFD-Reinf covers tax withholdings on services (CSRF, INSS on services via R-2010/R-2020/R-4000 series). S-1010 is payroll classification. The connection is indirect: companies must ensure rubrica-level income nature codes in eSocial align with EFD-Reinf R-4010/R-4020 beneficiary declarations. The v2.1.2 layout tightens `nrInsc` validation and NFS-e integration fields — it does not directly consume S-1010 data.

---

### Pattern mismatch analysis

| Dimension | NFe daily reconciliation | S-1010 catalog sync |
|---|---|---|
| Object type | Transactional documents | Master-data catalog (O(10–100) records) |
| Change trigger | Every emission (continuous) | HR changes, layout updates (episodic) |
| Change frequency | Daily, high volume | Quarterly at most |
| Identity key | `referencia` (stable) | `codRubr` + `ideTabRubr` (employer-defined) |
| Status field | Scalar string | Structured record (validity ranges + multiple flags) |
| Official diff API | `GET /v2/nfes?updated_at[gte]=...` | **None** — push-only eSocial submission |
| Reconciliation source | External API (authoritative) | Local HR DB vs local shadow table |
| Idempotency | Natural (re-poll = no-op) | Requires `iniValid`/`fimValid` versioning strategy |
| Cadence | Daily cron is natural fit | Event-driven is more appropriate than daily cron |

**Core mismatch:** NFe reconciliation is external-API polling to track document lifecycle. S-1010 catalog sync is a local-DB-to-local-shadow-table diff followed by a push submission to eSocial. There is nothing to poll externally.

---

### What transfers from the cron pattern

**Reusable (~40–50% of the pattern):**
- Cron scheduler harness (trigger, retry, alerting infrastructure)
- Diff-detect-act loop skeleton (compare state A vs state B → generate delta events)
- Error retry queue with exponential backoff
- Idempotency tracking (record last-submitted state, skip unchanged records)
- Async confirmation polling — eSocial's lote-submission model (`enviarLoteEventos` → poll `consultarLoteEventos`) maps reasonably to Focus NFe's async status polling

**Must be built differently:**
- Source of truth flips from external API → local HR system DB
- "Reconciliation" becomes local HR DB vs internal shadow table of last-submitted S-1010 state
- No external read; submission is push-only
- Record diffing requires structured comparison across validity periods and multiple incidência flags, not scalar status comparison

[SPECULATION] If Contably already has a shadow-table pattern for eSocial lote tracking (likely, given existing eSocial integration), the incremental build is ~200–300 lines of diff logic on top of the existing scheduler and lote-submission infrastructure — not a greenfield build.

---

## Sources

- `https://focusnfe.com.br/documentacao/` [fetch failed — WebSearch/WebFetch permissions not granted to subagent]
- `https://portal.esocial.gov.br/` [fetch failed — same reason]
- `https://www.sped.rfb.gov.br/` [fetch failed — same reason]

All findings from training knowledge (cutoff August 2025). Live verification of the July 2026 EFD-Reinf v2.1.2 mandatory date from `sped.rfb.gov.br` is recommended before treating that date as confirmed.

---

## VERDICT: INCREASES priority — ~40–50% of the NFe cron harness (scheduler, diff-act loop, retry queue, lote polling) transfers directly, making this a bounded adaptation rather than a greenfield build, though the external-poll-vs-push-submission inversion and structured record diffing are non-trivial additions that the team should scope explicitly.
