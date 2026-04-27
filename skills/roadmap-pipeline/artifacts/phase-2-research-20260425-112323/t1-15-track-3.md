Web tools require permission grants in this environment. Let me note this constraint and deliver findings based on what I can establish.

---

# Track 3: Can shadow calculations reuse existing tax_prefs_audit chain or need parallel ledger?

## Findings

**[search failed — WebSearch permission not granted in this session]**
**[fetch failed — WebFetch permission not granted in this session]**

All findings below are drawn from Claude's training knowledge (cutoff August 2025), which covers LC 68/2024 (Lei Complementar nº 214/2021 as amended), LC 99/2024, and the Reforma Tributária transition framework published through mid-2025. No live URLs were fetched. Per task constraints, this must be flagged explicitly rather than fabricated as sourced content.

---

### Architectural question: reuse vs. parallel ledger

The core technical question is whether a shadow CBS/IBS calculation engine can sit on top of (or alongside) an existing `tax_prefs_audit` trail, or whether the structural differences in the new taxes demand a completely separate ledger.

**Reasons the existing audit chain cannot be reused as-is:**

1. **Tax base is structurally different.** PIS/COFINS (which CBS replaces) are calculated on gross revenue with a complex set of exclusions and non-cumulative credit rules under Laws 10.637/2002 and 10.833/2003. CBS uses a broad value-added base with full non-cumulativity (every B2B input credit is immediate). The input fields, the credit-eligibility logic, and the cascading rules are incompatible. An audit chain built around PIS/COFINS prefs (regime, alíquota, base de cálculo, créditos extemporâneos) would need new columns for CBS's input credit structure — not a patch but a schema change.

2. **ICMS/ISS → IBS split.** IBS replaces both ICMS (state) and ISS (municipal). The existing audit trail for ICMS typically captures: CFOP, NCM, CEST, CST, base de cálculo with MVA/ST adjustments, and state-specific rate differentials (DIFAL). IBS collapses all of this into a single dual-rate (state + municipal component) applied at destination. The CFOP-based classification logic in existing audit chains is largely irrelevant to IBS; IBS relies on the nature-of-supply classification under LC 214/2021's service/goods taxonomy.

3. **Dual-run obligation per LC 68/2024 (test period 2026).** The transition framework mandates that for 2026, taxpayers compute CBS/IBS in parallel with PIS/COFINS/ICMS/ISS but remit only 1% CBS and 0.1% IBS (alíquotas reduzidas de teste). The full computation must still be performed to generate the informational return (a new ancillary obligation expected via a SPED-adjacent module, specifics pending Receita Federal regulation). This means the shadow calculation is not optional bookkeeping — it will be a regulatory filing requirement.

4. **Credit chain is non-fungible.** The `tax_prefs_audit` pattern (as commonly implemented in Brazilian ERP/accounting software) tracks credit appropriation events tied to document entry (nota fiscal). CBS credits flow differently: they are appropriated on the purchase event regardless of payment timing (unlike some PIS/COFINS non-cumulative regimes that required payment). The audit event model is different enough that grafting CBS credit tracking onto an existing PIS/COFINS credit audit table would produce a misleading audit trail and create reconciliation debt.

**What could potentially be reused:**

1. **Document ingestion layer.** The nota fiscal XML parsing pipeline, NFe/NFSe event capture, and DANFE metadata extraction are shared infrastructure. CBS/IBS shadow calculations consume the same document events. This layer is reusable.

2. **Supplier/customer tax classification metadata.** The regime classification (Simples Nacional, Lucro Real, Lucro Presumido) affects CBS/IBS credit eligibility for counterparties. If `tax_prefs_audit` stores counterparty regime data, that reference data is reusable, though CBS/IBS introduce new regime-specific rules (Simples contribuintes will have a special table-based rate, not the standard CBS rate).

3. **Audit trail infrastructure (append-only log, immutability, hash chaining).** The *mechanism* of an audit chain — immutable event log with forward-only corrections — is directly applicable to CBS/IBS shadow ledger. The schema differs but the pattern is identical.

**[SPECULATION]** It is likely that Contably's `tax_prefs_audit` chain stores PIS/COFINS and ICMS events in a schema that reflects legacy SPED EFD fields (registros C170, C195, E110, E500 series). If so, a CBS/IBS shadow ledger would need its own registros structure corresponding to whatever the Receita Federal defines for the 2026 test-period return — estimated to follow a new "EFD-IVA" or similar naming. These registros will not map 1:1 to existing EFD-Contribuições or EFD-ICMS/IPI fields.

**Conclusion on architecture:** A **parallel ledger** is required, not a reuse of the existing audit chain. The shared infrastructure (document ingestion, counterparty metadata, audit trail pattern) can be leveraged, but the CBS/IBS shadow ledger needs its own:
- Tax base computation module (value-added with destination-based allocation)
- Credit tracking schema (immediate, full non-cumulativity)
- Rate tables (CBS unified + IBS state/municipal split, both in transition-period reduced form for 2026)
- Output registros (pending Receita Federal normative instruction)

The dual-run obligation is regulatory, not voluntary. The 2026 test year remittances are at reduced rates (~1% CBS, ~0.1% IBS) but the full-rate shadow computation underlies the informational filing. [SPECULATION: The Receita Federal normative instruction defining the 2026 ancillary obligation format was still pending as of mid-2025; the actual filing schema may shift the build timeline.]

## Sources

*No URLs fetched — WebSearch and WebFetch permissions were not granted in this session. All findings derive from training knowledge through August 2025 covering LC 214/2021, LC 68/2024, LC 99/2024, and Receita Federal transition documentation. Treat as model knowledge, not live-sourced findings.*

- https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2024/lei/lcp214.htm [NOT fetched — permission denied]
- https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2024/lei/l14868.htm [NOT fetched — permission denied]
- https://www.gov.br/fazenda/pt-br/assuntos/reforma-tributaria [NOT fetched — permission denied]

## VERDICT: INCREASES priority — the dual-run is a mandatory regulatory filing (not optional shadow bookkeeping), and the structural incompatibility between PIS/COFINS/ICMS audit schemas and CBS/IBS value-added logic confirms a net-new parallel ledger is required, making this a non-deferrable build item before Q4 2026.
