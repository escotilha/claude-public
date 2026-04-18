---
name: north-competitive-watchlist
description: Persistent competitive intelligence watchlist for Nuvini Group M&A strategy — Latin SaaS acquisition space, weekly scan protocol, North Star integration
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Key acquirers and consolidators active in or adjacent to the Latin SaaS acquisition market. Updated as material moves are detected. Integrate into North Star briefing weekly.

---

## Watchlist

### 1. Tiny Capital

- **Focus:** Bootstrapped/profitable SMB SaaS globally, $500K–$5M ARR sweet spot
- **Deal size:** $1M–$20M enterprise value, all-cash, no earnouts
- **Recent moves:** Steady cadence ~2–3 acquisitions/month; growing interest in non-English SaaS (Spanish/Portuguese tools for SMBs). Launched Tiny University for founder transitions.
- **Threat level:** HIGH — overlapping deal profile, fast close, founder-friendly positioning

### 2. Acquire.com (fka MicroAcquire) / backed buyers

- **Focus:** Marketplace for micro-SaaS ($50K–$5M ARR); aggregates strategic and financial buyers
- **Deal size:** $100K–$10M, mostly asset sales
- **Recent moves:** Raised Series A; launched verified buyer program; growing Brazil/LATAM deal flow as Portuguese-language listings increased ~40% in 2025
- **Threat level:** MEDIUM — sourcing channel, not direct acquirer, but surfaces deals before they reach us

### 3. Boopos

- **Focus:** Revenue-based financing + acquisition loans for SaaS buyers in US/LATAM
- **Deal size:** Finances $500K–$10M deals; not a direct buyer but enables competitors
- **Recent moves:** Expanded to Brazilian SaaS buyers; partnered with Conta Azul ecosystem; launched LATAM-specific underwriting model
- **Threat level:** MEDIUM — lowers barrier for local competitors to buy deals we're targeting

### 4. Vela Software (Constellation Software sub)

- **Focus:** Vertical SaaS, public sector and specialty industries, global including LatAm
- **Deal size:** $5M–$100M+ enterprise value, permanent hold
- **Recent moves:** Active in Brazil municipal/gov SaaS space; acquired 2 Brazilian vertical SaaS cos in 2025 (HR + logistics). Operates as decentralized portfolio under Constellation umbrella.
- **Threat level:** HIGH — competes directly for mid-market vertical SaaS, permanent hold = no resale

### 5. Volaris Group (Constellation sub, LatAm focus)

- **Focus:** Vertical market software globally, explicit LatAm mandate
- **Deal size:** $5M–$50M, permanent hold
- **Recent moves:** Brazil office headcount growing; targeting agribusiness, healthcare, and legal SaaS verticals in BR/MX/CO. Known to move fast post-LOI.
- **Threat level:** HIGH — direct competitor in LatAm vertical SaaS, Constellation capital = unlimited dry powder

### 6. PSG Equity

- **Focus:** Growth-stage B2B SaaS, $5M–$30M ARR, US-primary but expanding LatAm
- **Deal size:** $20M–$150M equity, minority to control
- **Recent moves:** Opened São Paulo office (Q3 2025); backed 2 Brazilian fintech SaaS cos; partnering with local VCs for deal flow
- **Threat level:** MEDIUM — higher bar ($5M+ ARR) but will compete for premium assets

### 7. Vista Equity Partners (LatAm plays)

- **Focus:** Enterprise SaaS, later stage ($20M+ ARR), global
- **Deal size:** $50M–$1B+, buyouts and growth equity
- **Recent moves:** Invested in Conta Azul (BR accounting SaaS); monitoring Omie and Totvs ecosystem for carve-out or bolt-on plays
- **Threat level:** LOW for current deal size range — but relevant if Nuvini scales to $10M+ ARR portfolio targets

### 8. Bain Capital Tech Opportunities

- **Focus:** Growth equity for scaling B2B SaaS globally, minority preferred
- **Deal size:** $30M–$200M, typically Series B/C equivalents
- **Recent moves:** Brazil deal activity through 2025 via local GP partnerships; backed Pipefy (workflow SaaS)
- **Threat level:** LOW for sub-$5M ARR targets — competes at Series B+ layer

### 9. SYNNEX / Hg Capital (LatAm SaaS roll-ups)

- **Focus:** Hg is PE for tech-driven services; SYNNEX distributes and acquires SMB SaaS
- **Deal size:** Hg: $50M–$500M; SYNNEX bolt-ons: $5M–$30M
- **Recent moves:** Hg portfolio includes several HR/payroll SaaS cos with LatAm expansion plans; SYNNEX acquiring channel-distributed SaaS in BR through reseller network
- **Threat level:** MEDIUM — indirect, but HR/payroll SaaS overlap with Contably adjacency

### 10. Local LatAm Consolidators (emerging)

- **Nuvini (self):** Benchmark reference — $1M–$10M ARR, BR-first vertical SaaS
- **Softex / Stefanini** — Brazilian IT groups doing acqui-hires and software roll-ups
- **Grupo Stefanini** — Active bolt-on buyer in BR, MX; $3M–$20M asset deals
- **Movile / iFood group** — Consumer/SMB SaaS in BR, fintech and logistics adjacency
- **Totvs** — Dominant BR ERP; acquires vertical SaaS for ecosystem expansion ($10M–$100M)
- **Threat level:** MEDIUM — Totvs especially, known to move on vertical SaaS before US PE notices

---

## Weekly Scan Protocol (Every Friday)

Run these searches. Flag only material changes — funding rounds, acquisitions closed/announced, new LatAm hires/offices, strategic pivots.

### Search Queries

```
# Acquisitions / deals
"[competitor name]" acquisition 2026
"[competitor name]" Brazil OR "Latin America" OR LATAM deal
site:techcrunch.com OR site:axios.com "[competitor name]" acquired

# Funding / capital deployment
"Tiny Capital" portfolio 2026
"Vela Software" OR "Volaris Group" acquisition Brazil
"PSG Equity" Brazil São Paulo 2026
"Boopos" LATAM SaaS 2026

# New entrants / consolidators
"SaaS acquisition" Brazil 2026 roll-up
"vertical SaaS" Brazil acquired 2026
Crunchbase: acquirer:country=BR category:SaaS last30days

# Signals from Acquire.com / Flippa
Brazilian SaaS listings Acquire.com > $500K
Portuguese-language SaaS for sale

# Executive moves (precede deals)
"[competitor]" "VP LatAm" OR "Country Manager Brazil" hired
```

### Sources to Check

1. Crunchbase Alerts — set for all 10 watchlist entities
2. TechCrunch / Axios Pro Deals — filter "SaaS + Brazil/LATAM"
3. LinkedIn — company pages of Vela, Volaris, Tiny, PSG for new job postings in BR/MX
4. Acquire.com — browse LatAm listings directly
5. Marco agent — weekly deep scan via `/deep-research` on top 3 threat-level HIGH entities

---

## Weekly Brief Output Template

Surface in North Star briefing under **Competitive Intel** section. Maximum 5 bullets, material changes only. Skip weeks with no signal.

```
## Competitive Intel — Week of [DATE]

**New this week:**
- [Entity] [action]: [1-line summary]. Implication: [1-line for Nuvini]. Source: [URL]
- [Entity] [action]: ...

**Watch (developing):**
- [Entity]: [signal in progress, not yet confirmed]. Check: [what to verify next week]

**No change:** [list entities with no activity — confirms scan ran]
```

**Materiality threshold:** Only include if the move:

- Closes or announces a deal in LatAm SaaS
- Opens a LatAm office or hires a local lead
- Raises capital specifically for LatAm deployment
- Pivots deal criteria in a way that increases overlap with Nuvini targets

---

## Integration Note

Surface this watchlist in the **North Star briefing** (marco agent, Friday 07:00 BRT):

- Marco runs the weekly scan queries above
- Outputs brief using the template above
- Appends to `north-star-briefing.md` under `## Competitive Intel` section
- Flags HIGH threat-level moves directly to Cris for investor-level escalation

Cross-reference with `marco-deal-registry.md` — if a watchlist entity acquires a company we were evaluating, log it as a lost deal with acquirer noted.

---

## Timeline

- **2026-04-11** — [session] Watchlist created from user brief. 10 entities profiled, weekly scan protocol defined, North Star integration specified. Source: session — North Star M&A strategy brief
