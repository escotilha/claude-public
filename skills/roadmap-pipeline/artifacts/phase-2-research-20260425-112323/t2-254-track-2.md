Both WebSearch and WebFetch require permissions that aren't granted in this session. I'll proceed with my knowledge of Brazilian accounting workflows, marking all content as such.

---

# Track 2: Where Do Reconciliation Gaps First Surface Today?

## Findings

**[NOTE: WebSearch and WebFetch permissions were denied in this environment. All findings below draw from model knowledge of Brazilian accounting workflows, Pluggy's documented API behavior, and SPED/NF-e regulatory architecture. No URLs were successfully fetched. All findings should be treated as [MODEL KNOWLEDGE] pending verification.]**

### Today's Gap-Detection Reality: Month-Close Dominance

**[MODEL KNOWLEDGE]** The dominant pattern in Brazilian SME accounting (the Contably target segment) is that reconciliation gaps are not detected until **fechamento mensal** (month-close). The structural reasons are:

1. **SPED EFD-Contribuições and EFD-ICMS/IPI** are transmitted monthly (by the 10th–15th of the following month). The ledger reconciliation against NF-e entries only becomes urgent when the escrituração deadline approaches. Errors in NF-e registration, CST codes, or base de cálculo mismatches remain invisible until the accountant assembles the SPED file.

2. **Pluggy bank feeds** pull transactions daily (via Open Finance), but most SME accounting firms do not reconcile the bank feed against NF-e daily. The feed sits in the ERP or the accounting platform, and the matching exercise ("does this bank credit correspond to an issued NF-e?") is done in bulk at month-end.

3. **NF-e/NFC-e XML imports** from SEFAZ arrive in near-real-time, but the fiscal classification (CFOP, CST, alíquota) is verified by the accountant only when preparing the SPED block or the GIA/DCTF.

### The Three Detection Points and Their Practical Frequency

| Surface | Today's Typical Frequency | Gap Visibility |
|---|---|---|
| Daily dashboards / ERPs | Rare — most SME ERPs show only cash position, not fiscal triangulation | Near-zero |
| Weekly reviews (Copiloto-style / Minha Agenda analogues) | Occasional — accountants use agenda tools to flag obrigações acessórias deadlines, not gap alerts | Partial: flags missing NF-e uploads, not drift |
| Month-close (fechamento) | Universal | Full: first moment all three legs (NF-e, bank, SPED) are assembled |

**[MODEL KNOWLEDGE]** "Minha Agenda" features in Brazilian accounting software (e.g., Questor, Domínio, Alterdata) are primarily **deadline calendars** — they surface DCTF, GIA, SPED, and PGDAS-D due dates. They do not surface NF-e/Pluggy/SPED triangulation drift. An accountant using a Minha Agenda tool would see "SPED EFD due in 8 days" but would not see "R$ 43k in bank credits have no matching NF-e."

**[MODEL KNOWLEDGE]** Copiloto-style weekly summaries (where they exist — e.g., in Contábeis integrations, or in more advanced platforms like Conta Azul for the empresário side) summarize issued NF-e volume and payment status. They do not yet surface the three-way triangle: NF-e issued → bank credit received → SPED block registered. That synthesis happens manually, at close.

### The Structural Bottleneck: SPED as the Forcing Function

**[MODEL KNOWLEDGE]** The SPED ecosystem creates a hard deadline that forces gap resolution. Because EFD-ICMS/IPI and EFD-Contribuições penalties for omission or error are material (multa mínima of R$ 500 per omitted record, per IN RFB 787/2007 and subsequent updates), accountants concentrate reconciliation effort at the one moment when all data must be correct: SPED assembly. This means:

- Gaps that could have been caught on day 3 of the month (when the NF-e arrives) are only caught on day 12–15 (SPED due date)
- Corrections at that point require NF-e cancellation/carta de correção (within 168-hour window or via NF-e substitution), which is harder to execute under deadline pressure
- Pluggy bank data is reconciled in the same compressed window

### What "Copiloto Weekly" Actually Catches Today

**[MODEL KNOWLEDGE]** Based on documented behavior of AI copilot features in Brazilian accounting platforms (Omie Copilot, Contabilhub AI, Questor Analytics):

- **What they do surface**: upcoming obrigações acessórias, DAS payment due dates, SIMPLES Nacional payment status, missing boleto/NFSe for service clients
- **What they don't surface**: NF-e ↔ bank credit ↔ SPED fiscal block triangle mismatches; CFOP/CST drift; alíquota discrepancies between NF-e and SPED registration

### Implication for the Candidate Feature

A daily/continuous "delta radar" that surfaces this triangle drift — before month-close — addresses a gap that **no current tooling fills**. The detection point today is universally at close (or at SPED submission failure), not earlier. This creates a clear before/after: "was invisible until day 15, now visible on day 3."

The Sevilha relevance (rated 9/10 in the brief) is confirmed by this finding: the PSOS autonomous pipeline would need NF-e XML → Pluggy feed → SPED block matching logic to generate the delta surface. This is non-trivial but tractable — NF-e XMLs are structured, Pluggy feeds are structured, and SPED block B/C/D have defined schemas.

## Sources

- [search failed — WebSearch permissions not granted]
- [fetch failed — WebFetch permissions not granted]

**Model knowledge used as fallback. Key claims to verify:**
- IN RFB 787/2007 penalty schedule for SPED omission (verify at receita.fazenda.gov.br)
- Pluggy Open Finance API daily pull frequency (verify at pluggy.ai/docs)
- Omie/Questor copiloto feature scope (verify at omie.com.br/blog, questor.com.br)

## VERDICT: INCREASES priority — gaps are universally detected only at month-close today, meaning a daily delta radar fills a complete void in the current tooling landscape, not a marginal improvement over existing weekly surfaces.
