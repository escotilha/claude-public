---
name: julia-searxng-fallback
description: SearXNG fallback chain — health checks, error patterns, tool fallback order for web search
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

SearXNG runs on the Mac Mini at 100.66.244.112:8888 (Tailscale). It is the free/high-volume search tier — use it for bulk queries where API token cost matters. It is unreachable when the Mac Mini is off, asleep, or Tailscale is disconnected. Always health-check before routing traffic to it.

Health check:

```
curl -s -o /dev/null -w '%{http_code}' http://100.66.244.112:8888/healthz
```

200 = ok. Any other result = skip SearXNG and use the next tier.

Error patterns:

- `connection refused` — SearXNG service is down (Mac Mini off or service crashed)
- `timeout` — network issue (Tailscale disconnected or Mac Mini asleep)
- `503 Service Unavailable` — SearXNG overloaded (too many concurrent queries)

Fallback chain (in order):

| Tier | Tool                                                          | When                                       | Token budget        |
| ---- | ------------------------------------------------------------- | ------------------------------------------ | ------------------- |
| 1    | SearXNG (100.66.244.112:8888)                                 | High-volume, free, non-urgent              | ~300-800 tokens     |
| 2    | Brave Search (`mcp__brave-search__*`, count=5)                | Quick factual lookup                       | ~1,500-2,000 tokens |
| 3    | Exa (`mcp__exa__search`, highlights=true, maxCharacters=1500) | Content research, semantic                 | ~500-1,500 tokens   |
| 4    | WebSearch (built-in)                                          | Discovery, URL gathering, always available | ~150-400 tokens     |

When to use each:

- **SearXNG** — bulk/repeated searches, cost-sensitive workflows (Buzz daily triage, Marco research sweeps), when Mac Mini is confirmed up
- **Brave** — fast factual queries, structured results, most reliable paid tier
- **Exa** — semantic/neural search where result quality matters over cost; highlights mode preferred
- **WebSearch** — fallback of last resort; always available, lowest token cost for pure URL discovery

Full content extraction chain (after finding URLs):

```
Exa highlights → Firecrawl (onlyMainContent=true) → WebFetch → Scrapling (anti-bot)
```

---

## Timeline

- **2026-04-11** — [session] Documented SearXNG fallback chain from web-search-efficiency.md rules and reference_vps_connection.md (Source: session — memory entity creation)
