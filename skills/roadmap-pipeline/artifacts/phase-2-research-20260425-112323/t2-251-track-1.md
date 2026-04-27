WebSearch isn't permitted in this session. I'll synthesize from the subagent's thorough knowledge-based findings plus my own domain knowledge, clearly marking what wasn't live-fetched.

---

# Track 1: Which tables need column-level audit for Receita Federal/SPED traceability?

## Findings

### Legal Framework

SPED (Sistema Público de Escrituração Digital) was established by **Decreto nº 6.022/2007** and is administered by Receita Federal do Brasil (RFB). Four modules directly govern financial data traceability for Brazilian entities on Lucro Real/Presumido:

| Module | Governing IN | Scope |
|---|---|---|
| **ECD** (Escrituração Contábil Digital) | IN RFB nº 1.774/2017 | Journal entries, trial balance, ledger (Diário + Razão) |
| **EFD-ICMS/IPI** | IN RFB nº 2.005/2021 + AJUSTE SINIEF 02/2009 | Invoices — state (ICMS) + federal excise (IPI) |
| **EFD-Contribuições** | IN RFB nº 1.252/2012 | PIS/COFINS — invoice-level credit tracking |
| **ECF** | IN RFB nº 1.422/2013 | IRPJ/CSLL — reconciliation between ECD and taxable income |

[search failed — WebSearch not permitted in session; findings below are from training knowledge of SPED specifications through August 2025, crosschecked against subagent analysis]

---

### Invoices (`invoices` table)

**EFD-ICMS/IPI Bloco C** and **EFD-Contribuições Bloco C** mandate per-invoice column-level retention. The following NF-e fields become legally immutable once SEFAZ authorizes (status 100):

**Registro C100 (EFD-ICMS/IPI) — mandatory fields with audit significance:**
- `CHAVE_NFE` (44-digit access key) — encodes CNPJ, date, series, number, ICMS model; **non-updatable primary reference**
- `NUM_PROT` (SEFAZ authorization protocol) — immutable
- `DT_DOC` / `DT_ENT_SAI` — invoice date and entry/exit date; immutable post-authorization
- `VL_DOC`, `VL_BC_ICMS`, `ALIQ_ICMS`, `VL_ICMS` — tax values; any discrepancy triggers retification obligation

**Registro C170 (line items):** `COD_ITEM`, `QTD`, `UNID`, `VL_ITEM`, `CFOP`, `CST_ICMS` — must match NF-e XML byte-for-byte.

**Registro C190 (tax summary per CFOP/CST):** `ALIQ_ICMS`, `VL_BC_ICMS`, `VL_ICMS` — aggregated per CFOP combination.

**Critical rule:** NF-e cancellations, inutilizações, and correções are handled exclusively via **separate XML event objects** (each with their own protocol number and timestamp), not by updating the original record. Any ERP that allows silent UPDATE to an authorized NF-e row violates SEFAZ/RFB protocol. Column-level audit log with `old_value` / `new_value` / `changed_at` / `changed_by` is the minimum control needed to detect or prevent such violations.

For **EFD-Contribuições**, per-invoice tracking of `CST_PIS`, `CST_COFINS`, `VL_BC_PIS`, `ALIQ_PIS`, `VL_PIS`, `VL_BC_COFINS`, `ALIQ_COFINS`, `VL_COFINS` must reconcile with the NF-e XML's `<PIS>` and `<COFINS>` tags — another source of mandatory traceability.

---

### Journal Entries (`journal_entries` table)

**ECD Registros I150/I155** (Livro Diário) require:

| Field | Audit requirement |
|---|---|
| `NUM_ORD` (entry number) | Sequential, immutable once ECD transmitted |
| `DT_LCTO` (posting date) | Immutable; ECD is period-locked after transmission deadline |
| `VLR_LCTO` (entry value) | Immutable; amendment requires a *arquivo retificador* with new digital signature |
| `COD_CTA` (account code) | Must reference ECD I050 chart; cannot be changed without retification |
| `HIST` (histórico/narration) | Must be meaningful — SPED Contábil validator flags blank históricos |
| `IND_DC` (debit/credit indicator) | Immutable |

**IN RFB nº 1.774/2017, Arts. 3–5** establish the **hash + digital signature** requirement: the full ECD file is SHA-256 hashed and signed with the accountant's e-CPF and the entity's e-CNPJ certificate before SPED transmission. The *Recibo de Entrega* protocol number from RFB is the legal proof of submission — retained for **5 years** (CTN Art. 195). Any journal entry that has been included in a transmitted ECD is effectively immutable from the RFB's perspective: changing it requires a *retificação* that produces a new signed file referencing the original protocol.

**Registro I250 (Razão — account ledger):** `COD_CTA`, `NUM_LCTO`, `DT_LCTO`, `DESC_LCTO`, `VLR_LCTO`, `IND_DC`, `VLR_SLD` — the running balance per account. Auditors reconcile I250 against I155 to detect gaps or off-period entries.

---

### Reconciliations (`reconciliations` table)

No SPED registro maps directly to bank reconciliation as a first-class object. However, two indirect obligations create audit trail needs:

1. **ECF Bloco M (LALUR/LACS)** — Registros M300 (additions) and M350 (exclusions) reconcile accounting profit (from ECD) to taxable income for IRPJ/CSLL. Any reconciling item must trace back to specific I155 journal entries. An `ecf_reconciliation_items` table tracking `m300_addition`, `m350_exclusion`, `journal_entry_ref`, and `justification` would need column-level audit to support this link.

2. **CTN Art. 195** — Gives Receita Federal auditors the right to inspect *livros, arquivos, documentos, papéis e efeitos comerciais ou fiscais* for up to 5 years (or longer for suspected fraud). Bank reconciliations are among the supporting documents auditors request. Fields requiring traceability: `data_reconciliacao`, `saldo_extrato`, `saldo_contabil`, `diferenca`, `status`.

[SPECULATION: The Contably `tax_prefs_audit` pattern already covers preference changes. Extending it to reconciliations is architecturally straightforward but not explicitly mandated by any single SPED registro — the need is audit-support rather than direct SPED field mapping.]

---

### Priority Columns by Table (SPED-mandated vs. audit-support)

| Table | Column | SPED mandate | Priority |
|---|---|---|---|
| `invoices` | `chave_acesso` | EFD C100 | **Must** — immutable NF-e identifier |
| `invoices` | `num_protocolo` | EFD C100 | **Must** |
| `invoices` | `valor_icms`, `valor_pis`, `valor_cofins` | EFD C100/C190 | **Must** |
| `invoices` | `cfop`, `cst_icms`, `cst_pis_cofins` | EFD C170/C190 | **Must** |
| `invoices` | `situacao` (authorized/cancelled) | NF-e protocol | **Must** — change-tracked with event timestamp |
| `journal_entries` | `numero_lancamento` | ECD I155 | **Must** |
| `journal_entries` | `data_lancamento`, `valor`, `cod_conta` | ECD I155/I250 | **Must** |
| `journal_entries` | `historico` | ECD I155 | **Must** — blank = validator error |
| `reconciliations` | `saldo_extrato`, `saldo_contabil`, `diferenca` | CTN Art. 195 (audit support) | **Should** |
| `reconciliations` | `status`, `data_reconciliacao` | CTN Art. 195 | **Should** |

---

## Sources

[search failed — WebSearch not permitted in this session; no URLs fetched]

The following are the authoritative sources that should be verified:
- `https://www.sped.rfb.gov.br/` — SPED portal (Receita Federal) [not fetched]
- `https://normas.receita.fazenda.gov.br/sijut2consulta/link.action?idAto=85187` — IN RFB nº 1.774/2017 (ECD) [not fetched]
- `https://normas.receita.fazenda.gov.br/sijut2consulta/link.action?idAto=37761` — IN RFB nº 1.252/2012 (EFD-Contribuições) [not fetched]
- `https://www.planalto.gov.br/ccivil_03/_ato2007-2010/2007/decreto/d6022.htm` — Decreto nº 6.022/2007 [not fetched]

**Note:** WebSearch and WebFetch were blocked by session permissions. All findings derive from training knowledge of Brazilian tax law and SPED specifications (through August 2025). Specific IN article numbers should be cross-checked against `normas.receita.fazenda.gov.br` before citing in legal or compliance documentation.

---

## VERDICT: INCREASES priority — SPED mandates byte-exact column-level immutability for invoice fields (`chave_acesso`, CFOP, tax values) and journal entry fields (`numero_lancamento`, `data_lancamento`, `historico`, `valor`) via signed ECD/EFD transmission protocols, making this a legal compliance requirement under IN RFB nº 1.774/2017 and IN RFB nº 1.252/2012, not merely a product feature.
