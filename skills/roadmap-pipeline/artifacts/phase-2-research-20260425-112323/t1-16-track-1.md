Both WebSearch and WebFetch require permission approval that hasn't been granted in this session. I'll report what I can from authoritative knowledge within my training data, clearly marked.

---

# Track 1: Which municipalities have migrated to NFSe nacional DPS vs legacy ABRASF?

## Findings

**[search failed — WebSearch permission not granted in this session]**
**[fetch failed — WebFetch permission not granted in this session]**

All findings below are from model knowledge (cutoff August 2025). Per research track instructions, I am flagging this explicitly rather than fabricating fetched URLs.

---

### NFSe Nacional DPS: Background

The NFSe Nacional (Nota Fiscal de Serviços eletrônica Nacional) with the **DPS (Documento de Prestação de Serviços)** layout was established by the **Comitê Gestor do Simples Nacional (CGSN)** and the **Receita Federal do Brasil (RFB)** under **Resolução CGSN nº 220/2023** and complementary IN RFB regulations. The system is operated via the **Emissor Nacional de NFS-e** portal (nfse.gov.br), launched in 2023.

The DPS standard aims to unify the fragmented municipal NFS-e landscape, where each of Brazil's ~5,570 municipalities historically ran their own system — many on **ABRASF NFS-e** (Associação Brasileira das Secretarias de Finanças das Capitais) schemas, which vary considerably per city.

### Migration Status as of Mid-2025 [MODEL KNOWLEDGE — not fetched]

The migration is **voluntary for municipalities** with their own NFS-e system and **mandatory for municipalities without any NFS-e system** (roughly ~2,000+ cities that lacked local infrastructure). The phased rollout proceeded as follows:

- **Phase 1 (2023)**: Emissor Nacional goes live; MEIs and Simples Nacional optantes in municipalities without local NFS-e start issuing via DPS/Emissor Nacional.
- **Phase 2 (2024)**: Larger municipalities with existing ABRASF systems begin integration via API convênio — meaning their local systems can forward data to RFB, but citizens may still interact with local portals.
- **Phase 3 (2025)**: Municipalities that have signed "Convênio de Integração" with RFB are considered "migrated" — their local NFS-e data feeds into the national SPED environment.

**Key distinction**: "Migrated" can mean either (a) the municipality dismantled its local system and uses nfse.gov.br exclusively (full DPS adoption), or (b) the municipality retained its local portal but implemented API integration to share data nationally (partial / convênio model). These are treated very differently in Contably's integration architecture.

### Known Migration Status by Major Cities [MODEL KNOWLEDGE]

| Municipality | Population | Status (as of ~mid-2025) | Notes |
|---|---|---|---|
| **São Paulo** | 12M | Legacy ABRASF (local portal NF-e SP) | Strong local system, integration convênio underway but not full migration |
| **Rio de Janeiro** | 7M | Legacy ABRASF (RIO NFS-e) | Own portal maintained |
| **Belo Horizonte** | 2.5M | Legacy ABRASF | BH Nota Fácil, integration discussions |
| **Curitiba** | 1.9M | Legacy ABRASF | Local portal active |
| **Porto Alegre** | 1.4M | Legacy ABRASF | Local portal, POST-flood infrastructure stress |
| **Campinas** | 1.2M | Legacy ABRASF | |
| **Manaus** | 2.2M | DPS/Emissor Nacional (partial) | Fewer local system resources; heavier federal reliance |
| **Fortaleza** | 2.7M | Legacy ABRASF | |
| **Salvador** | 2.9M | Legacy ABRASF | |
| **Recife** | 1.6M | Legacy ABRASF | |
| Smaller municipalities (<50k pop.) | — | DPS via Emissor Nacional | Most lack independent NFS-e infrastructure |

**[SPECULATION]**: The majority of Sevilha's client municipalities — if spanning São Paulo state (Campinas, Sorocaba, Santos, Ribeirão Preto, São José dos Campos) — are almost certainly still on legacy ABRASF systems, because São Paulo state municipalities have historically been the strongest holdouts against the national standard, given their mature local tax infrastructure and political resistance to ceding municipal fiscal sovereignty.

### Convênio de Integração as the Practical Bridge

Rather than a hard cutover, RFB's strategy is "Convênio de Integração" — municipalities sign a protocol that makes their ABRASF data flow to the national environment. This means:

1. **Contably must handle both schemas simultaneously** — a client in SP city issues via local portal (ABRASF), a client in a small interior municipality issues via nfse.gov.br (DPS). Both end up in Receita Federal's environment, but via different paths.
2. **No announced national mandatory cutover date** as of mid-2025 — each municipality sets its own timeline once it signs the convênio.
3. **The DPS XML schema** differs significantly from ABRASF XML (different field names, different validation rules, different signing/transmission protocols).

### What This Means for Sevilha Coverage Gaps

If Sevilha's clients span 4+ cities (as stated in the brief), the high-probability scenario is:
- **1-2 cities on DPS** (smaller municipalities, or municipalities that already signed full convênio)
- **2-3 cities still on legacy ABRASF** (larger or São Paulo-state municipalities)

This creates a **dual-schema maintenance burden**: Contably must parse, validate, and display both DPS and ABRASF NFS-e formats. A migration tracking feature (knowing which of a client's operating cities is on which schema) would be necessary infrastructure for any serious NFSe coverage feature.

## Sources

- [search failed — no WebSearch permission granted; no URLs fetched]
- [fetch failed — WebFetch permission not granted; nfse.gov.br and receita federal pages not retrieved]

**Note to Phase 3 reviewer**: All findings above are from model knowledge (training cutoff August 2025), not live fetched sources. The research track method required WebSearch + WebFetch, both of which were blocked by permission gate. This finding should be weighted accordingly — the structural analysis is likely sound, but specific city-level migration statuses should be verified against live nfse.gov.br and RFB portal data before use in product decisions.

## VERDICT: INCREASES priority — dual-schema reality (DPS + legacy ABRASF coexisting across municipalities) means coverage gaps are structural and immediate, not hypothetical, making this a near-certain pain point for any Sevilha client operating across 2+ cities today.
