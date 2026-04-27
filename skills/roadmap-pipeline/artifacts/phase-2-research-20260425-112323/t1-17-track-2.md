Both WebSearch and WebFetch are blocked. I'll produce findings based on deep knowledge of the eSocial/EFD-Reinf regulatory framework, clearly flagging what's from model knowledge vs what would require live fetching.

---

# Track 2: eSocial S-1010 rubricas catalog versioning and official sync endpoint

## Findings

**[search failed: WebSearch blocked in this environment] [fetch failed: WebFetch blocked in this environment]** — All findings below are drawn from model knowledge of the eSocial regulatory framework through August 2025. Any claims that would normally require live government source confirmation are marked accordingly.

### S-1010 Structure and Purpose

The S-1010 event ("Tabela de Rubricas") is the employer-maintained catalog that maps every payroll rubric (wage component, deduction, or informational item) to its classification for eSocial transmission. Unlike most eSocial tables (which are *governo-maintained* and downloaded by employers), **S-1010 is employer-submitted**: the employer declares their own rubric taxonomy to eSocial, and the government validates it against codification rules defined in the leiaute manual.

This is the critical architectural distinction: **there is no official government-hosted "rubrica catalog API" to sync against**, because the catalog is employer-defined. What the government publishes are:

1. The **leiaute XSD** (schema) defining what fields each rubric record must contain
2. The **validation rules** (RVs — Regras de Validação) specifying which rubric types (e.g., `codRubr`, `natRubr`, `codIncCP`, `codIncIRRF`, `codIncFGTS`) are valid and their interdependencies
3. **Tabelas de domínio** (domain lookup tables) — e.g., `codIncCP` must be one of a fixed set of values defined by RFB/Previdência

### Versioning Mechanism

The S-1010 record includes a `{iniValid}` / `{fimValid}` validity date-range field (format: `YYYY-MM`). When an employer changes a rubric's classification — for example, updating `codIncCP` (INSS incidence code) or `codIncIRRF` (IRRF incidence code) — they transmit a new S-1010 event closing the old record and opening a new one with the updated validity window.

There is **no system-level version number** on the catalog itself. Versioning is entirely date-range-driven per rubric. The leiaute version (e.g., S-1.3) controls the schema, not the catalog content.

[SPECULATION] Monthly drift of rubric classifications is less common than the candidate description implies. What actually changes monthly is the **leiaute validation rules** (as the government publishes portarias updating incidence codes) — employers then need to re-evaluate whether their existing S-1010 records remain valid under the new rules.

### What Changes Require Re-Sync

Changes that invalidate existing S-1010 records and require employer action:

1. **Portaria MPS/RFB updates** to incidence tables — e.g., changes to which rubric types are exempt from INSS (`codIncCP`) or FGTS (`codIncFGTS`). These are published via Portaria Interministerial and the eSocial Manual do Leiaute is updated to reflect new valid domain values.
2. **New leiaute versions** (e.g., S-1.0 → S-1.1 → S-1.3) that add mandatory fields or deprecate existing ones in the S-1010 XSD.
3. **EFD-Reinf cross-validation**: Starting with EFD-Reinf v2.1.2 (mandatory from July 2026 for large taxpayers), the `codRubr` values in S-1010 must align with the `natRend` codes used in R-4000/R-4010/R-4020 events. This creates a new synchronization constraint between eSocial and EFD-Reinf that did not exist in v2.1.1. [SPECULATION — specific field-level mapping rules require live leiaute confirmation]

### S-1.3 Leiaute and EFD-Reinf v2.1.2 Interaction

The eSocial S-1.3 leiaute (production rollout 2024–2025) introduced new validation rules for S-1010 tied to the EFD-Reinf integration. Specifically, the `codIncIRRF` field alignment with R-4010 event fields tightened, meaning employers who had previously submitted S-1010 records with catch-all IRRF codes now need to disaggregate their rubric catalog.

### No Official "Sync Endpoint" Exists

There is no RESTful or SOAP endpoint from which an application can *pull* an updated government-defined rubric catalog. The data flow is:

- **Employer → eSocial**: employer submits S-1010 via the eSocial webservice (`/WsRecepcaoEvtTabEmpregador` WSDL for non-government employers)
- **Government → Employer**: changes to validation rules are communicated via leiaute manual updates (PDF/XSD downloads from `esocial.gov.br`) and via Portaria publications in the Diário Oficial

What a payroll software like Contably would need to sync is:
1. The updated **XSD schemas** when new leiaute versions are released
2. The updated **domain tables** (tabelas de domínio) embedded in the leiaute manual annexes
3. **RFB portarias** that change incidence code validity

### Practical Sync Frequency

The government publishes leiaute updates irregularly — historically 2–4 major version releases per year, with errata published between versions. There is no official "monthly sync" cadence. The "drifts monthly" characterization in the candidate description likely refers to errata and portaria publications that require manual review, not an automated pull.

[SPECULATION] A production implementation would monitor `esocial.gov.br/portal/conteudo/documentacao-tecnica` for new leiaute versions and the Diário Oficial for portarias affecting incidence codes — neither of which provides a structured API.

## Sources

- [search failed — WebSearch blocked in this environment]
- [fetch failed — WebFetch blocked in this environment: tool permission not granted]
- All findings derived from model knowledge of eSocial regulatory framework (through August 2025 training cutoff). Key official sources that should be fetched to verify: `https://www.gov.br/esocial/pt-br/documentacao-tecnica` (leiaute manual S-1.3), `https://www.esocial.gov.br/portal/servicos/download` (XSD downloads), Diário Oficial portarias from RFB/MPS.

## VERDICT: DECREASES priority — the S-1010 "catalog sync" is employer-submitted (not government-pulled), there is no official sync endpoint, and the actual drift signal is irregular leiaute/portaria updates that require document polling rather than an API integration, making the scheduled-sync framing in the candidate description technically inaccurate and reducing implementation urgency.
