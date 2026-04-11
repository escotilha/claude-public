---
name: buzz-daily-triage
description: Daily competitive signal triage for NVNI portfolio — scans TechCrunch, Crunchbase, LinkedIn for high-signal moves by OMIE, Brex, Stripe, and NVNI portfolio companies
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Buzz runs a daily competitive intelligence scan at 08:00 UTC. Scans three sources for four target company sets. Outputs 3-5 bullets maximum, urgent-flagged. Pierre reviews same-day. State tracked in `buzz-triage-state.json` to suppress duplicate items.

High-signal filter: funding rounds, executive hires (C-suite/VP), product launches, acquisitions, regulatory actions. Everything else is skipped.

---

## Schedule

- **Cron:** `0 8 * * *` (08:00 UTC daily, ~05:00 BRT)
- **Delivery:** Slack #pierre-briefs or direct DM via Claudia
- **Format:** 3–5 bullets, each prefixed 🔴 Urgent or ⚪ FYI
- **State file:** `~/.claude-setup/memory/auto/buzz-triage-state.json`

## Sources

| Source     | Method                                                                              | Query                     |
| ---------- | ----------------------------------------------------------------------------------- | ------------------------- |
| TechCrunch | Firecrawl `https://techcrunch.com/search/?q={company}`                              | Per company               |
| Crunchbase | Firecrawl `https://www.crunchbase.com/discover/funding_rounds` filtered by org name | Per company               |
| LinkedIn   | Brave Search `site:linkedin.com/company {company} {signal}`                         | Per company × signal type |
| Brave News | `mcp__brave-search__brave_news_search` count=5                                      | Aggregated                |

## Target Companies

```
PRIMARY (always scan):
  - OMIE (Brazilian ERP / fintech)
  - Brex (corporate cards / spend management)
  - Stripe (payments infrastructure)

NVNI PORTFOLIO (scan when known):
  - Contably (accounting SaaS, BR)
  - SourceRank (GEO/SEO AI)
  - AgentWave (AI agent platform)
  - [add new portfolio cos here]
```

## Signal Filter Rules

**Include (🔴 Urgent):**

- Funding round (Seed → Series A+, debt round, PE)
- Acquisition or merger announced
- C-suite or VP-level hire (CEO, CTO, CPO, CFO, CRO)
- Major product launch (not blog post, not changelog)
- Regulatory action (fine, investigation, license)
- IPO filing or rumor

**Include (⚪ FYI) if slot available:**

- Partnership with Fortune 500 / major bank
- Significant layoff (>10% headcount)
- New market entry (geo expansion)

**Exclude always:**

- Blog posts, thought leadership, interviews
- Job postings (except executive search)
- Conference appearances / awards
- Pricing page updates
- Social media activity without news backing

## Output Format

```
📊 Competitive Brief — {YYYY-MM-DD} | Pierre, {N} signals today

🔴 [URGENT] **{Company}** raised ${amount} Series {X} led by {investor} — {1-line context}
   Source: {URL} | {date}

🔴 [URGENT] **{Company}** hired {Name} as {Title} from {Previous Company}
   Source: {URL} | {date}

⚪ [FYI] **{Company}** launched {Feature} targeting {segment}
   Source: {URL} | {date}

— No other signals above threshold today.
Scan window: {start_date} → {end_date} | Next run: {tomorrow 08:00 UTC}
```

## Deduplication Logic

Before flagging any item, check `buzz-triage-state.json`:

1. Hash = SHA256(company + headline_keywords + date_week)
2. If hash exists in `seen_items` → skip
3. If not seen → add to output AND write hash to state file
4. Prune state entries older than 30 days on each run

## Agent Execution Steps

When Claudia executes this triage:

1. Load `buzz-triage-state.json` — get seen hashes + last run timestamp
2. For each PRIMARY company, run Brave news search (count=5, freshness=last24h)
3. For Crunchbase funding signals, fetch `https://www.crunchbase.com/discover/funding_rounds?updated_at[after]={yesterday}` via Firecrawl
4. Deduplicate against state
5. Apply signal filter — keep only qualifying items
6. Rank: funding > acquisition > exec hire > product launch > other
7. Take top 3–5 items
8. Format output per template above
9. Deliver via Slack DM to Pierre
10. Write updated state to `buzz-triage-state.json`

## Escalation

If 🔴 Urgent item involves direct NVNI competitor acquiring a portfolio company or direct competitor raising >$50M: escalate immediately (don't wait for next run) via Claudia's priority dispatch queue.

---

## Timeline

- **2026-04-11** — [session] Created by Buzz (approval task apr-1775840430021). Initial system definition. (Source: session — buzz approval workflow)
