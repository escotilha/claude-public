The research subagent couldn't fetch live URLs due to permissions — I'll compile the findings from its training knowledge (current through August 2025) into the required output format.

```markdown
# Track 1: Brazilian Fiscal Deadlines Sevilha Tracks Manually

## Findings

> **Note:** WebSearch/WebFetch were unavailable in this execution environment. All findings below draw from training knowledge through August 2025, grounded in official Brazilian tax legislation (IN RFB, Lei Complementar, Convênios ICMS). Items requiring live 2026 verification are flagged `[VERIFY LIVE]`.

### DCTF — Declaração de Débitos e Créditos Tributários Federais

**Legal basis:** IN RFB nº 2.005/2021; transitioning to DCTFWeb (DCTFWeb integration with eSocial/EFD-Reinf).

**Deadline:** 15th of the **second** month following the reference period. If 15th is a weekend/holiday → next business day. Example: DCTF for January → due March 15.

**Who files:** All Lucro Real, Lucro Presumido, and Lucro Arbitrado entities. Simples Nacional optants file only for taxes outside DAS (IRRF on contracted services, IOF, etc.). Even months with zero movement require a "sem movimento" filing.

**Penalties (Lei nº 10.426/2002, Art. 7):**
- Late filing: 2% per month on declared value, capped at 20%
- Minimum: R$ 500/month (profit-regime); R$ 200/month (Simples/MEI/inactive)
- Non-filing omission: R$ 500/month (profit-regime); R$ 200/month (others)

**DCTFWeb migration:** RFB has been migrating DCTF into DCTFWeb (unified portal with eSocial + EFD-Reinf). Grupo 1 (faturamento > R$ 78M/year): payroll taxes migrated since 2019. Remaining tributes (IRPJ, CSLL, IPI, IOF) still on classic DCTF for most companies as of mid-2025. `[VERIFY LIVE: check IN RFB 2026 migration schedule]`

---

### EFD-Reinf — Escrituração Fiscal Digital de Retenções e Outras Informações Fiscais

**Legal basis:** IN RFB nº 1.701/2017; amended through IN RFB nº 2.043/2021, nº 2.096/2022.

**What it covers:** CSRF (PIS/COFINS/CSLL retidos na fonte), INSS retido sobre serviços tomados, IRRF on certain non-payroll income, revenue-based contributions.

**Deadline:** **15th of the month following** the reference period. Events R-2010 through R-2099 (including the mandatory closing event R-2099) must all land by this date. If 15th falls on weekend/holiday → next business day.

**Group rollout:**
- Grupo 1 (faturamento > R$ 78M/ano): mandatory since May 2018
- Grupo 2 (nonprofits + others not in G1): mandatory since January 2019
- Grupo 3 (remaining private entities, Lucro Presumido mid-size): since August 2021
- Grupo 4 (MEI, Simples Nacional): since January 2022 (staggered)

**Special sub-rule:** Companies filing only R-4000 series events (retained income, dividends) may follow a quarterly or annual sub-schedule. `[VERIFY LIVE — evolving in 2024–2025]`

**Who must file:** All entities that retain INSS on contracted services (IN RFB nº 971/2009 scope), retain PIS/COFINS/CSLL (Lei nº 9.430/1996 Art. 30), or make IRRF payments outside eSocial scope. Simples Nacional companies must file as tomadores (service takers) when retaining INSS or other tributes.

**Penalties:** R$ 500/group of 10 incorrect/omitted items (Lei nº 12.873/2013); late filing: 2% per month on covered tax value, capped at 20%, minimum R$ 500 (or R$ 200 for MEI/Simples).

---

### SPED Sub-Obligations

#### ECD — Escrituração Contábil Digital

**Legal basis:** IN RFB nº 1.774/2017; Decreto nº 8.683/2016.

**Deadline:** **Last business day of June** of the following year (e.g., ECD for calendar year 2024 → due last business day of June 2025).

**Who files:** All Lucro Real companies (mandatory). Lucro Presumido companies that distributed profits above the presumed base. Simples Nacional: generally exempt unless SCP or above certain nonoperating income thresholds. MEI: exempt.

**Penalty:** 0,5% per month on net revenue in the period (Art. 12, Lei nº 8.218/1991); minimum R$ 500. `[VERIFY LIVE: RFB has proposed increasing minima]`

#### ECF — Escrituração Contábil Fiscal

**Legal basis:** IN RFB nº 1.422/2013; IN RFB nº 2.004/2021 (consolidated).

**Deadline:** **Last business day of July** of the following year. ECF contains LALUR and LACS (the Lucro Real computation).

**Who files:** All Lucro Real, Lucro Presumido, and Lucro Arbitrado companies. Immune/exempt entities with gross revenue > R$ 4,8M/year. Simples Nacional: exempt (IRPJ/CSLL within DAS). MEI: exempt.

**Penalty:** Same 0.5%/month structure, minimum R$ 500.

#### EFD-Contribuições (SPED PIS/COFINS)

**Legal basis:** IN RFB nº 1.052/2010; IN RFB nº 1.911/2019 (consolidated).

**Deadline:** **10th business day of the second month** following the reference period. Example: EFD-Contribuições for February 2025 → due 10th business day of April 2025.

**Who files:** All Lucro Real companies (non-cumulative PIS/COFINS). Lucro Presumido companies (cumulative, but still must file). Companies with CPRB (substituição previdenciária). Simples Nacional: exempt. MEI: exempt.

**Penalty:** 0.5%/month on net revenue, minimum R$ 500.

#### EFD-ICMS/IPI (SPED Fiscal)

**Legal basis:** Convênio ICMS nº 143/2006; Ajuste SINIEF nº 02/2009 + state-specific Portarias SEFAZ.

**Deadline: Varies significantly by state (UF)** — the primary source of inter-state variability:
- São Paulo, Minas Gerais: day 15 of the **second** month following (e.g., January EFD → due March 15)
- Rio de Janeiro, Bahia: day 20 of the **following** month
- Rio Grande do Sul: last business day of the following month
- Paraná: day 25 of the following month
- Each state publishes an annual Portaria SEFAZ with exact calendar `[VERIFY LIVE per state for 2026]`

**Who files:** All companies with IE (Inscrição Estadual) that collect ICMS — Lucro Real, Lucro Presumido, and Simples Nacional companies with IE conducting interstate operations (DIFAL, ICMS ST). Pure service companies (ISS-only) generally exempt.

**Penalty:** 1%–5% of tax value per month of delay, absolute minimums R$ 300–R$ 1.500 depending on UF and company size (set per state legislation).

---

### NFSe — Nota Fiscal de Serviços Eletrônica

**Legal basis:** Lei Complementar nº 116/2003 (ISS framework); each municipality enacts its own lei municipal. The federal Padrão Nacional NFSe (coordinated by ENCAT/ABRASF/CGSN from 2020 onward) standardizes XML schema and transmission — **but does NOT unify deadlines**.

**Key structural asymmetry:** NFSe is entirely municipal. Each of Brazil's 5,570 municipalities that has implemented NFSe has its own portal, issuance rules, and monthly DMS (Declaração Mensal de Serviços) deadline. By 2024–2025, over 3,000 municipalities had adopted the national standard schema `[VERIFY LIVE]`.

**Sample deadlines by major city:**

| Municipality | NFSe System | DMS Deadline |
|---|---|---|
| São Paulo (SP) | NFS-e próprio | Day 10 of following month |
| Rio de Janeiro (RJ) | RIO NFS-e | Day 10 of following month |
| Belo Horizonte (MG) | BHISS Digital | Day 5 of following month |
| Curitiba (PR) | ISSQN Digital | Day 10 of following month |
| Porto Alegre (RS) | NFS-e Nacional | Day 15 of following month |
| Fortaleza (CE) | NFS-e Fortaleza | Day 5 of following month |
| Salvador (BA) | NFS-e Salvador | Day 10 of following month |
| Manaus (AM) | SEMEF | Day 10 of following month |

**Who must file:** All service providers (prestadores de serviço) in municipalities that have implemented NFSe, regardless of tax regime (Lucro Real, Presumido, Simples, MEI where local law requires).

**Penalties (per municipality):**
- Failure to issue NFSe: 50%–100% of the ISS value of the transaction, minimums of R$ 100–R$ 500 per infraction
- Failure to submit monthly DMS: R$ 200–R$ 1.000 per month, per municipality

---

### Cross-Regime Applicability Matrix

| Obligation | Lucro Real | Lucro Presumido | Simples Nacional | MEI |
|---|---|---|---|---|
| DCTF (monthly) | Mandatory | Mandatory | Partial (outside DAS) | Generally exempt |
| DCTFWeb (payroll) | Mandatory | Mandatory | Mandatory (if employees) | Mandatory (if employee) |
| EFD-Reinf | Mandatory | Mandatory | Mandatory as tomador | Limited |
| ECD (annual, June) | Mandatory | Conditional | Exempt generally | Exempt |
| ECF (annual, July) | Mandatory | Mandatory | Exempt | Exempt |
| EFD-Contribuições | Mandatory | Mandatory | Exempt | Exempt |
| EFD-ICMS/IPI | Mandatory (if IE) | Mandatory (if IE) | Mandatory (if IE + interstate) | Exempt |
| NFSe/DMS | Mandatory (if service) | Mandatory (if service) | Mandatory (if service, per city) | Mandatory (per city) |
| DEFIS/DASN-SIMEI | N/A | N/A | DEFIS annual; DASN-SIMEI (MEI) | Mandatory (annual) |

---

### Compliance Complexity for Sevilha

The two highest-complexity tracking areas are:
1. **EFD-ICMS/IPI** — 27 different state deadlines, each with an annually updated Portaria SEFAZ
2. **NFSe/DMS** — up to 3,000+ municipalities each with independent deadlines and portals

Federal obligations (DCTF, EFD-Reinf, EFD-Contribuições, ECD, ECF) have predictable, uniform national deadlines that can be computed algorithmically from business-day rules. The regime of each client company (Lucro Real / Presumido / Simples / MEI) is the primary filter for which obligations apply — a per-company obligation matrix is the correct data model.

---

## Sources

WebSearch and WebFetch were not available in this execution environment (tool permission not granted). The following are the authoritative URLs that a live re-run should fetch:

- https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/declaracoes-e-demonstrativos/dctf `[not fetched — permission denied]`
- https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/declaracoes-e-demonstrativos/efd-reinf `[not fetched — permission denied]`
- https://portalsped.fazenda.gov.br `[not fetched — permission denied]`
- https://abrasf.org.br (NFSe Padrão Nacional coordination) `[not fetched — permission denied]`
- https://www.conjur.com.br (tax practitioner analysis) `[not fetched — permission denied]`

## VERDICT: INCREASES priority — Brazil's fiscal obligation landscape is structurally complex (27-state ICMS calendars + 3,000+ municipal NFSe deadlines + 5 distinct federal obligations with per-regime applicability rules), confirming that a machine-readable compliance registry is a high-value primitive for any Contably/Sevilha client company.
```
