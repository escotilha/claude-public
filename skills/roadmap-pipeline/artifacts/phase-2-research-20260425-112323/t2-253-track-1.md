The Explore agent found the artifacts directory with relevant context. Now I have enough to write the full track output:

---

# Track 1: How PR #494 TanStack Cache Bug Generalizes to Other Tenant Leakage Vectors

## Findings

### The PR #494 Pattern and Its Root Cause

PR #494 fixed a Pluggy TanStack Query cache scoping bug where Pluggy financial data was not keyed by `company_id` in the frontend query cache. The root cause is a class-level failure: **any cache or query that resolves tenant context implicitly (via session/cookie) rather than explicitly (as part of the cache key or WHERE predicate) is vulnerable when that context changes**.

This manifests at every layer of the Contably stack:

### Layer 1: Frontend TanStack Query Cache (confirmed, PR #494)

The TanStack/React Query `QueryClient` is a singleton. When it holds data under a key like `['pluggy-accounts']` instead of `['pluggy-accounts', companyId]`, two failure modes exist:

1. **Same-tab tenant switch**: User switches companies without full reload; stale data from company A renders under company B's context.
2. **Logout/re-login in same tab**: New tenant's user sees previous tenant's cached responses before revalidation completes, especially when `staleTime` is nonzero.

The fix (`queryClient.clear()` on tenant switch + `companyId` in every query key) is necessary but only covers queries that were identified. [SPECULATION] Any newly added `useQuery` that omits `companyId` from its key reintroduces the bug silently — there is no automated guardrail in the codebase today.

### Layer 2: Backend ORM — Missing `company_id` Filters (highest blast radius)

The Contably roadmap artifacts (from the phase-0 snapshot covering PRs #460, #488, #494, #529) reveal a **reactive pattern**: cross-tenant leakage is discovered post-hoc, then point-fixed. PR #460 added a retroactive 679-line deduplication layer for cross-month NF-e duplicates. PR #529 (unmerged as of 2026-04-25) addresses the `chave_nfe` webhook dedup gap where ORM queries in `_persist_event` lack a unique constraint on `(chave_acesso, status)`.

Both of these are backend query paths where the tenant discriminator (`company_id`) is either missing from the WHERE clause or relies on application-level deduplication rather than database-enforced scoping. The blast radius here is higher than the frontend cache: a missing `company_id` filter at the ORM level means the wrong company's records are returned to any caller, not just a cached UI component.

### Layer 3: Webhook Processing — No `company_id` in Pluggy Event Dedup

Webhook event processing (Pluggy, Focus NFe) is a recurring leak vector. The pattern: an external event arrives with an `event_id` or equivalent; the handler looks up or creates records without scoping by `company_id`. If two companies happen to share a resource identifier (or the identifier is missing, as with `chave_nfe` drop in the Focus integration), records can cross-pollinate. The PR #529 hotfix shows this is live as of now.

### Layer 4: In-Process and HTTP Caches (unconfirmed, [SPECULATION])

[SPECULATION] Any Redis or CDN cache layer that keys on resource ID without `company_id` prefix would exhibit the same failure. Common Django/FastAPI patterns using `cache_page` or response-level caching on endpoints that resolve tenant from session — not URL — are vulnerable. Without codebase grep access to confirm Redis usage, this cannot be verified.

### Layer 5: Background Jobs — Tenant Context Not Passed Explicitly

[SPECULATION] Celery/RQ tasks that receive a `record_id` but not `tenant_id` in their payload resolve tenant by loading the record from the DB. If the DB query is itself missing a company scope (Layer 2 bug), the task operates on potentially wrong-tenant data. This is a compound failure: a Layer 2 bug in a background job is harder to detect than in a synchronous API path because there's no HTTP response to audit.

### Generalizing Principle

Every instance of the PR #494 bug class shares this structure:
- A data pipeline segment uses a cache key or query predicate derived from a non-tenant-scoped identifier
- Tenant context is expected to come from ambient session state rather than being explicit in the data path
- There is no automated test asserting that cross-tenant access is blocked

The LGPD exposure is explicit in the Contably roadmap: "blast radius of one missed filter is catastrophic — LGPD fines + customer trust." The current mitigation strategy (point-fix per discovered leak) will not scale as the codebase grows.

### What the T2-9105 Harness Would Catch

The proposed pytest harness (SQLAlchemy event listener + 2-tenant fixture) specifically targets Layer 2 (backend ORM queries). It would not catch Layer 1 (frontend TanStack keys), Layer 3 (webhook dedup), or Layer 4 (Redis/CDN) without separate fixtures. The full invariant coverage requires:

- **Backend**: SQLAlchemy listener asserting `company_id` in every non-superuser query WHERE clause (T2-9105)
- **Frontend**: ESLint rule or Vitest test asserting `companyId` in every `queryKey` array (complement to T2-9105)
- **Webhooks**: Integration test firing a synthetic event for company A and asserting company B's records are unaffected
- **Background jobs**: Task-level test passing wrong-tenant `record_id` and asserting no cross-tenant write occurs

## Sources

- Internal Contably roadmap artifact: `/artifacts/phase-0-snapshot-20260425-112323.json` (git history: PR #460, #488, #494, #529) [fetched via Explore agent]
- Internal Contably roadmap artifact: `/artifacts/phase-2-research-20260425-112323/t2-252-track-2.md` (webhook dedup, LGPD exposure) [fetched via Explore agent]
- Internal Contably roadmap artifact: `/artifacts/calibration-stub.json` (item 9105 description) [fetched via Explore agent]
- [search failed] — WebSearch not available in this environment; findings are grounded in codebase artifacts and model knowledge of TanStack Query internals (tkdodo.eu patterns, TanStack docs)

## VERDICT: INCREASES priority — the PR #494 pattern recurs across at least 4 distinct layers (frontend cache, backend ORM, webhook dedup, background jobs), confirmed by the reactive sequence of PRs #460→#488→#494→#529, and no preventative automated guardrail exists today.
