---
name: tech_insight_safari_api_caching
description: Safari aggressively caches API responses, causing stale data — fix with Cache-Control: no-store on all API routes
type: feedback
originSessionId: eb4e1baa-6aa8-4dfd-b4ee-6658330da543
---

Safari caches API GET responses more aggressively than Chrome/Firefox, causing stale agent lists, outdated UI state, and other data freshness bugs. This manifests as "the page works in Chrome but not Safari".

**Fix:** Add `Cache-Control: no-store` (and optionally `Pragma: no-cache`) to all `/api/` and `/auth/` routes at the router middleware level — not per-handler.

```typescript
// Apply once at the router level
router.use((req, res, next) => {
  res.set("Cache-Control", "no-store");
  next();
});
```

**Why `no-store` not `no-cache`:** `no-cache` still allows Safari to store the response and revalidate; `no-store` prevents storage entirely, which is what you want for dynamic API data.

**Applies to:** Any web app with an API served via Express/Fastify/Hono that has Safari users.

Discovered: 2026-04-11
Source: failure — Safari caching /api/agents causing stale agent list in AgentWave dashboard
Relevance score: 6
Use count: 1
Applied in: agentwave - 2026-04-11 - HELPFUL
Related: [pattern_nginx_vite_spa_cache.md](concepts/pattern_nginx_vite_spa_cache.md) — complementary browser cache fix for SPAs (nginx + meta no-cache for index.html) (2026-04-16)
