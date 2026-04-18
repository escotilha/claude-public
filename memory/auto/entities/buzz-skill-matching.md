---
name: buzz-skill-matching
description: Living index of skill trigger patterns — when to invoke which skill, missed routing, parallelism opportunities
type: feedback
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Buzz frequently performs URL analysis, market research, scraping, and growth auditing. This file tracks which skill to invoke vs when to go ad-hoc, common miss patterns, and a log of routing decisions made in practice.

Default rule: prefer skills over improvisation. Skills encode token-efficient pipelines (parallel agents, token-capped search, structured output). Ad-hoc costs more and produces less consistent output.

---

## Skill Routing Patterns

### /research — URL / Tool / Article Analysis

**Invoke when:**

- User or message contains a URL to analyze ("check this", "what is this", "summarize this")
- Evaluating a competitor product, tool, or news article
- Buzz receives a link in Slack/Telegram with no other context
- Trigger phrases: "analyze", "what do you think of", "check out", "review this link", "tell me about {URL}"

**Do NOT invoke when:**

- URL is a data source to scrape (use /firecrawl instead)
- URL is an API doc to fetch (use /get-api-docs instead)
- It's a quick redirect check or availability ping (Bash/WebFetch directly)

**Common miss:** Using WebFetch ad-hoc when /research would run richer multi-signal analysis (screenshot + structured summary + evaluation rubric).

---

### /growth — CRO, SEO, Pricing, Onboarding, Churn

**Invoke when:**

- Auditing a landing page or pricing page for conversion
- Analyzing a signup or onboarding flow for friction points
- Competitive comparison page needed
- SEO/GEO visibility audit for any NVNI portfolio property
- Email lifecycle sequence design (activation, retention, win-back)
- Trigger phrases: "improve conversion", "CRO audit", "optimize pricing", "reduce churn", "SEO audit", "landing page review", "growth analysis"

**Do NOT invoke when:**

- It's a one-line factual question about a product ("what's Brex's pricing?") — use Brave search directly
- The goal is market sizing, not optimization (use /deep-research instead)

**Common miss:** Running ad-hoc Firecrawl + manual analysis when /growth would orchestrate a structured CRO audit with parallel persona testing and actionable recommendations.

---

### /firecrawl — Structured Data Extraction / Crawling

**Invoke when:**

- Extracting structured data from one or more pages (pricing tables, job boards, funding lists)
- Crawling a site hierarchy (e.g., all blog posts, all product pages)
- Exporting clean markdown from a content-heavy page for downstream analysis
- Trigger phrases: "scrape", "extract", "crawl", "get all pages from", "pull the data from"

**Do NOT invoke when:**

- Anti-bot / Cloudflare-protected site — use /scrapling instead
- Single URL summary (use /research)
- Headless browser interaction needed (forms, auth, JS-heavy SPAs) — use /browserless or /pinchtab

**Common miss:** Using WebFetch directly on a multi-page site when /firecrawl would crawl the full structure in one call with clean output.

---

### /deep-research — Market Analysis / Multi-Track Investigation

**Invoke when:**

- Research question has 3+ independent angles (market sizing, competitor landscape, technology trends, regulatory context)
- Answer requires synthesizing across sources (not a single lookup)
- Output is investment-memo-grade or briefing-quality
- Trigger phrases: "research", "deep dive", "analyze the market", "compare competitors", "what's the landscape for", "build a brief on", "investigate"
- Used by Buzz for: M&A context on targets, market positioning for NVNI portfolio, trend analysis for Pierre briefs

**Do NOT invoke when:**

- Single factual lookup (use Brave search)
- URL-specific analysis (use /research)
- Question can be answered from a single source in <5 minutes

**Common miss:** Running sequential Brave searches manually when /deep-research would spawn 3-5 parallel tracks and synthesize a structured output at 3-4x lower token cost per finding.

---

### /last30days — Social / Trend Research

**Invoke when:**

- Looking for Reddit, X, YouTube, HN, or TikTok signals on a topic in the last 30 days
- Buzz needs social proof or sentiment for a market (e.g., "what's Twitter saying about OMIE?")
- Trigger phrases: "trending", "what's being said about", "recent buzz on", "social signals", "last month's discussion"

**Do NOT invoke when:**

- Query is news-based (use Brave news search with freshness filter)
- Structured competitive intelligence (use /deep-research)

---

## Missed Routing Log

Template for logging when sequential was used but parallel was available, or a skill was skipped:

```
### {YYYY-MM-DD} — {Session/Context}

**What happened:** {describe the ad-hoc action taken}
**Skill that should have been used:** /{skill-name}
**Why it was missed:** {trigger phrase not recognized | skill not known | seemed too simple}
**Cost delta:** {estimated token difference, if known}
**Fix:** {update trigger phrases above | add to routing table | n/a}
```

---

## Improvisation Log

Template for when ad-hoc work was done but a skill existed:

```
### {YYYY-MM-DD} — {Task}

**Task:** {what was being done}
**Approach used:** {ad-hoc: WebFetch / manual Brave / custom loop / etc.}
**Skill available:** /{skill-name}
**Quality gap:** {what was missed vs skill output}
**Action:** {add to routing table above | already captured | no action needed}
```

---

## Parallelism Opportunities

Buzz-specific patterns where parallel execution is routinely available but sometimes missed:

| Scenario                                | Sequential (miss)            | Parallel (correct)                                       |
| --------------------------------------- | ---------------------------- | -------------------------------------------------------- |
| Scanning 4 companies for news           | Brave search × 4 in sequence | 4 parallel Brave calls in one message                    |
| Research + scrape a competitor          | /research then /firecrawl    | Both in parallel (independent)                           |
| CRO audit + SEO audit                   | /growth sequentially         | Single /growth invocation handles both tracks internally |
| 3-track market research                 | Sequential Brave searches    | /deep-research spawns 3-5 parallel investigator agents   |
| TechCrunch + Crunchbase + LinkedIn scan | Sequential Firecrawl calls   | Parallel Firecrawl calls per source per company          |

---

## Timeline

- **2026-04-11** — [session] Created. Initial routing patterns for /research, /growth, /firecrawl, /deep-research, /last30days. Templates for missed routing and improvisation logs. (Source: session — buzz-skill-matching creation)
