# /cto — Performance Lens Reference

Full checklist + patterns for the `performance-analyst` role. The orchestrator injects the relevant section based on the review scope.

---

## File ownership

The performance-analyst owns: `{db_dirs}`, `{service_dirs}`, build/bundle config, API route handlers. Do NOT read files outside this ownership — other analysts cover them.

---

## Checklist

### Database

- **N+1 queries**: ORM loops calling DB inside `array.map` / `forEach` — must use batch fetch (`findMany` with `in`, DataLoader, or joined query).
- **Index coverage**: WHERE / ORDER BY / JOIN columns without indexes on high-cardinality tables.
- **Missing pagination**: unbounded queries returning potentially large result sets.
- **Connection pooling**: verify pool is configured (PgBouncer, Prisma `connection_limit`, Supabase `?connection_limit=`). Serverless deployments creating a new connection per request will exhaust the DB.

### Next.js / RSC Caching (if Next.js App Router is in use)

- **`"use cache"` coverage**: identify Server Components or data-fetching functions that are not-user-specific and tolerate staleness — they should use `"use cache"` + `cacheLife()`. Missing cache on product catalogs, blog posts, and config data is a HIGH opportunity.
- **Caching anti-pattern — `connection()` overuse**: grep for `await connection()` at page level. Using `connection()` makes the entire route dynamic. Replace with Suspense boundaries isolating only the truly dynamic parts.
- **`cacheTag` invalidation gaps**: Server Actions that mutate data without calling `revalidateTag()` cause stale reads. Cross-reference mutation paths against `cacheTag` usage.
- **Dynamic API leakage into cached scope**: `cookies()`, `headers()`, `searchParams` called inside a `"use cache"` function throws at runtime. Must be extracted outside and passed as arguments.
- **Route vs data cache confusion**: `fetch()` calls without explicit `cache` or `next.revalidate` options — verify intentional caching behavior (Next.js 15 defaults fetch to `no-store`).
- **Full Route Cache vs Data Cache invalidation**: confirm `revalidateTag()` is used after mutations (granular) rather than `revalidatePath('/')` (nukes entire route cache).
- **PPR (Partial Prerendering)**: if `experimental.ppr` is enabled, check Suspense boundary placement — static shell should be outermost, dynamic content innermost.
- **`"use cache: private"` + client navigation**: known bug in 16.1.x — prefer user-scoped tags.

### Frontend / Bundle

- **Bundle size**: identify heavy dependencies imported without tree-shaking (lodash, moment, full icon libraries). Flag `import * as X from` patterns.
- **Memory leaks**: event listeners or intervals not cleared in `useEffect` cleanup.
- **Async handling**: blocking await chains that could run in parallel — prefer `Promise.all([...])` for independent async operations.

### API / Network

- **Rate limiting**: confirm external API calls are guarded (retries with backoff, not unbounded retry loops).
- **Streaming**: large data responses that could be streamed (SSE, RSC streaming) but are blocking.

---

## Output format

```
severity | file:line | issue | recommendation
```

Write findings to `.cto/review-{date}-{slug}.md` under the `## Performance` heading. Message the lead with critical findings immediately. Message architecture-analyst if you find patterns requiring structural changes.

---

## Inline commands

```bash
# N+1 query patterns (multiple similar queries in tight scope)
grep -rn "\.find\|\.findOne\|\.query\|\.select" \
  --include="*.ts" --include="*.js" | head -30

# Missing indexes hints (SQL files)
grep -rn "ORDER BY\|GROUP BY\|WHERE" --include="*.sql" | head -20

# Large bundle concerns
cat package.json 2>/dev/null | jq '.dependencies' 2>/dev/null | head -30

# Uncached Server Components that fetch data
grep -rn "async function\|export async" \
  --include="*.tsx" --include="*.ts" | grep -v "use cache" | head -20

# connection() overuse (makes entire route dynamic)
grep -rn "await connection()" --include="*.tsx" --include="*.ts" | head -10

# Server Actions that revalidate
grep -rn "revalidateTag\|revalidatePath" \
  --include="*.ts" --include="*.tsx" | head -20

# Dynamic API leakage into cached scope
grep -rn "cookies()\|headers()\|searchParams" \
  --include="*.ts" --include="*.tsx" | head -20
```

---

## Scaling Tiers Guide (for the final report)

```
Tier 1: 0-1K users
├── Single server sufficient
├── Managed database (Supabase/Neon)
├── Basic caching
└── Estimated cost: $0-50/month

Tier 2: 1K-10K users
├── Horizontal scaling ready
├── Read replicas if needed
├── Redis caching layer
├── CDN for static assets
└── Estimated cost: $50-500/month

Tier 3: 10K-100K users
├── Auto-scaling groups
├── Database sharding consideration
├── Queue-based async processing
├── Full observability stack
└── Estimated cost: $500-5K/month

Tier 4: 100K+ users
├── Microservices consideration
├── Multi-region deployment
├── Advanced caching strategies
├── Dedicated database clusters
└── Estimated cost: $5K+/month
```
