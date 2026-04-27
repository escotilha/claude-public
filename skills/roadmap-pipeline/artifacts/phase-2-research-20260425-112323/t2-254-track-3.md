# Track 3: Copiloto panel vs new screen for reconciliation deltas

## Findings

**No URLs were fetched** — WebSearch and WebFetch were permission-blocked in the execution environment. All findings are from training knowledge about Brazilian accounting SaaS, competitive intelligence on Omie/Conta Azul/Nibo/Totvs, and UX pattern literature. All non-obvious claims are marked [SPECULATION].

---

### 1. UX pattern: coaching panels can carry alerts — with scope limits

In enterprise accounting SaaS (Xero, QuickBooks Online), the dominant pattern for reconciliation discrepancies is a **contextual alert inside an existing workflow surface**, not a dedicated dashboard — but only when discrepancy count is low and action is clear. Xero's "Reconcile" tab surfaces match failures inline in the bank feed view. QuickBooks uses a persistent "Review" banner when uncategorized transactions exist. Neither builds a new screen for gap detection; they embed it in the closest contextual surface.

For a coaching/guidance panel like Copiloto, the pattern fits when:
- Alerts are **actionable from the panel** (link to offending record, not just "X items differ")
- The panel supports **progressive disclosure** — a collapsed badge that expands to delta detail
- The NF-e/Pluggy/SPED triangle is surfaced as a single consolidated status, not three sub-panels

**Risk:** Coaching panels that carry both guidance ("here's what to do next") and alert content ("something is wrong") create cognitive mode conflict. [SPECULATION] If Copiloto currently serves a prescriptive/advisory role, adding reactive gap alerts may dilute its perceived authority — a real UX tension seen in products like Freshbooks' "Nudges" system, which required refactoring when nudges and alerts competed for the same surface.

---

### 2. Brazilian competitor surface patterns

**Omie:** Has a dedicated "Painel de Pendências" for NF-e failures and boleto discrepancies. Bank reconciliation lives under Financeiro → Conciliação — a dedicated screen, not a coaching panel.

**Conta Azul:** Uses a "Central de Tarefas" (task center) that can surface reconciliation gaps as action items. This is the closest competitive analog to Copiloto-embedding — gaps appear as task items in a unified list, not on a dedicated reconciliation screen. [SPECULATION] Brazilian accounting software reviewers on Capterra BR note this reduces context-switching for small firms.

**Nibo:** Surfaces SPED and fiscal obligations through a compliance calendar/timeline widget in the dashboard. Discrepancies appear as calendar alerts. Nibo targets accountants managing 10+ client portfolios — architecturally different from Copiloto's single-client focus.

**Totvs (Protheus):** Dedicated "Livro Fiscal" reconciliation module — heavy enterprise tooling, not relevant here.

**Key insight:** No major Brazilian competitor embeds NF-e/bank/SPED triangle reconciliation in a coaching panel. Conta Azul's task-center approach is the closest — essentially a "smart inbox" rather than a coaching surface. [SPECULATION] This is both a risk (no validated pattern to copy) and an opportunity (Contably could establish the pattern first).

---

### 3. The functional threshold: signal vs. resolution

The canonical UX decision rule (from Nielsen Norman Group research on notification systems and Intercom's product design blog on in-app guidance):

- **Side/coaching panel:** appropriate when the alert is **transient**, **low-stakes**, and resolves with a single action (e.g., "3 NF-e unmatched — reconcile now →")
- **Dedicated screen:** appropriate when the user needs to **investigate**, compare, drill into individual records, or take multi-step remediation

For NF-e/Pluggy/SPED reconciliation gaps, the workflow is investigative by nature — accountants need to see which invoices don't match, trace them to SPED entries, and potentially amend fiscal bookings. [SPECULATION] A delta summary ("R$12.400 gap across 7 NF-e vs bank") can live in Copiloto, but the reconciliation workflow almost certainly requires a dedicated surface or at minimum a drawer/modal with full record detail.

**Recommended architecture:** Copiloto hosts the **signal** (badge + one-line delta summary per axis), not the **resolution workflow**. The panel links out to either (a) an existing reconciliation flow if one exists, or (b) a lightweight drawer that surfaces specific mismatched records without being a full new top-level screen.

---

### 4. Alert fatigue and refresh cadence

NF-e/SPED/Pluggy data refreshes at different cadences (NF-e near-real-time, Pluggy 1–4× daily, SPED monthly/quarterly). A coaching panel showing stale or high-noise deltas trains accountants to ignore it. [SPECULATION] The reconciliation gap radar should only surface in Copiloto when the delta exceeds a configurable materiality threshold (e.g., >0.5% of faturamento or >R$500), otherwise the panel becomes an alert-fatigue trap that undermines Copiloto's coaching authority.

---

## Sources

No URLs fetched — WebSearch and WebFetch permissions denied in this agent's execution context. Findings are based on training knowledge of Brazilian contabilidade software (Omie, Conta Azul, Nibo, Totvs), UX pattern literature (Nielsen Norman Group notification research, Intercom Product Blog on in-app guidance, Xero/QBO product design precedents), and general fintech coaching-panel UX patterns.

---

## VERDICT: INCREASES priority — the Copiloto panel is the correct surface for the signal layer (delta badge + one-liner), making the reconciliation gap radar a two-part architecture (embed alert in Copiloto now, defer investigation screen), which lowers implementation cost and de-risks the feature against a new-screen build.
