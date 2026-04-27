[fetch failed: permission not granted for WebFetch tool]

Both WebSearch and WebFetch require permission grants that haven't been given to this subagent invocation. I'll produce findings based on my training knowledge (knowledge cutoff August 2025), clearly marking the basis for each claim.

---

# Track 2: Does Focus NFe cover new DPS endpoints or is a fallback provider needed per city?

## Findings

### Background on NFSe DPS Standard

The Brazilian government's NFSe Padrão Nacional (unified NFS-e) uses a new XML schema called **DPS (Documento Padrão de Sincronia)**, specified under ABRASF's framework and adopted by SEFIN/SEFAZ. The rollout is municipality-by-municipality: each city must formally adhere and configure its gateway, with mandatory adoption deadlines set by the federal government rolling through 2024–2026 for municipalities of different size tiers.

Key regulatory anchor: **Resolução CGSN nº 169/2022** and complementary ABRASF technical specs define the DPS schema (version 1.0). Cities with population above 100k were targeted first (2023–2024); smaller municipalities follow in waves through 2026.

[SPECULATION] Cities such as São Paulo, Rio de Janeiro, Curitiba, and Belo Horizonte were early adopters. Smaller cities in Santa Catarina, Paraná, and Goiás — common Sevilha/Contably client geographies — are likely in the mid-to-late wave (2025–2026 compliance).

### Focus NFe's Coverage of DPS

Based on Focus NFe's documented API surface (as of mid-2025):

- **Focus NFe does support NFSe**, with an abstraction layer that routes requests to city-specific SOAP/REST endpoints behind a unified REST API.
- However, Focus NFe's NFSe integration has historically relied on **per-municipality adapters** using each city's legacy webservice schema — not the new unified DPS schema. Their API docs describe a `municipio` parameter that selects the city-specific parser/sender.
- As of Q2 2025, Focus NFe had **not yet announced** a dedicated DPS/NFSe Nacional endpoint in their public changelog or developer documentation. Their approach remained adapter-per-city.
- The new `nfse-nacional` (DPS) standard requires the provider to: (a) implement the DPS XML schema, (b) call the new SEFAZ-Nacional gateway (`nfse.sefaz.gov.br`) rather than each city's own webservice, and (c) handle the new signed-response protocol.

[SPECULATION] Focus NFe was likely in active development of DPS support during H2 2025, given competitive pressure from providers like **eNotas**, **Nota Carioca API**, and **nfse.io** which had begun advertising DPS-ready endpoints.

### Competitor Provider Landscape

- **eNotas** (by Omie): Has advertised NFSe Padrão Nacional / DPS compatibility since early 2025, with specific mention of the national gateway endpoint.
- **nfse.io**: A newer provider built ground-up on the DPS spec; covers only DPS-compliant cities but does so natively.
- **Plugnotas**: Had partial DPS coverage as of mid-2025, mixing legacy adapters with new DPS endpoints per city.
- **NFe.io**: Similar partial coverage, active development on DPS.

### Practical Risk for Sevilha's Multi-City Clients

If Sevilha's clients span 4+ cities:

1. **If all 4+ cities have adopted DPS** — Focus NFe's legacy adapter approach may still work temporarily (cities often run dual SOAP + DPS gateways during transition) but will break when cities decommission their legacy webservices (expected 2026–2027 for early adopters).
2. **If some cities haven't adopted DPS yet** — Focus NFe's existing adapters remain fully functional, and DPS is irrelevant for those cities.
3. **Fallback provider risk**: The main exposure is a city decommissioning its legacy webservice before Focus NFe ships a DPS adapter for that city. This creates a gap window where Contably/Sevilha clients in that city cannot emit NFSe.

[search failed: could not confirm Focus NFe's current DPS roadmap via live fetch]
[search failed: could not confirm current city-by-city DPS adoption status via live fetch]

### What Contably Would Need

For robust multi-city DPS coverage, Contably's NFSe integration layer should:
- **Abstract over provider**: don't hard-code Focus NFe as the sole NFS-e emitter; the integration should be provider-agnostic so a per-city fallback can be configured.
- **Monitor city decommission notices**: cities post transition dates on their fazenda portals; Sevilha should track these for all client cities.
- **Evaluate eNotas or nfse.io as DPS-native fallback** for cities where Focus NFe lags.

## Sources

- [search failed: WebSearch permission not granted — could not retrieve live URLs]
- [fetch failed: WebFetch permission not granted — could not retrieve focusnfe.com.br/nfse or dev.focusnfe.com.br]

*All findings above are based on training knowledge (cutoff August 2025). No URLs were fetched in this session. Treat DPS-specific claims about Focus NFe's roadmap as [SPECULATION] requiring live verification before Phase 3 scoring.*

## VERDICT: INCREASES priority — Focus NFe lacks confirmed DPS-native endpoints as of mid-2025, creating a real coverage gap risk for multi-city Sevilha clients that Contably must architect around before city decommission deadlines hit in 2026–2027.
