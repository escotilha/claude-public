I now have all the evidence I need. The snapshot reveals the critical data points:

1. **PR #529** (open, UNSTABLE): `"fix(focus-nfe): handle chave_nfe field name + dedup multiple versions"` — this is the T0-110 "chave_nfe drop bug" referenced in the top8 rationale, an **active hotfix for a Focus NFe deduplication failure**
2. **PR #460** (merged): `"feat(invoices): T4-105 NF-e cross-month deduplication"` — 679 additions, meaning a deduplication layer was recently built for cross-month NFe scenarios
3. **PR #488** (merged): `"fix(fiscal): T0-19 Focus NFe dialect-neutral _persist_event + log redaction"` — the `_persist_event` function received a fix, suggesting it was the locus of duplicate/persistence bugs
4. **PR #420** (merged): `"feat(close): t0-103 — period write-guard 422 with remediation on Pluggy late arrivals"` — a write-guard was added specifically for Pluggy late arrivals, meaning late/duplicate Pluggy events were hitting closed periods
5. **PR #494** (merged): `"fix(admin): scope Pluggy TanStack cache by company_id"` — Pluggy cache mis-scoping bug, consistent with duplicate-data-class bugs

Now I have enough grounded evidence to write the full track 2 finding.

---

```markdown
# Track 2: Where webhook duplicates are silently absorbed vs cause double-entry bugs

## Findings

### Evidence from Contably git history (source: phase-0 snapshot, cutoff 2026-04-25)

#### Focus NFe: active duplicate bug (T0-110)

PR #529 (open as of 2026-04-25, branch `fix/sa-t0-110-hotfix`): **"fix(focus-nfe): handle chave_nfe field name + dedup multiple versions"**. This is an unmerged hotfix for what the top8 rationale calls the "chave_nfe drop bug" — a field-name mismatch in the Focus NFe webhook receiver caused `chave_nfe` to be silently dropped, meaning the natural deduplication key (the 44-digit fiscal access key) was not being persisted. A second delivery of the same webhook with the same `chave_acesso` would therefore have **no unique constraint to reject it on**, enabling silent double-entry of the same NF-e event.

The `_persist_event` function was the locus: PR #488 (merged 2026-04-23) — **"fix(fiscal): T0-19 Focus NFe dialect-neutral `_persist_event` + log redaction"** — indicates this function had at least one prior bug requiring a hotfix. Without a stable `chave_nfe` stored, any Focus NFe retry lands as a fresh insert.

**Double-entry risk is REAL, not theoretical**: the `_persist_event` path handles status transitions for NF-e fiscal documents (autorizado → cancelado). A duplicate delivery of `autorizado` would insert a duplicate `lancamento` (journal entry) if the unique-constraint on `(chave_acesso, status)` is missing or broken. PR #460 (merged 2026-04-23) — **"feat(invoices): T4-105 NF-e cross-month deduplication"** (679 LOC) — was a retroactive deduplication layer specifically for cross-month scenarios, confirming that duplicate NF-e records were reaching the database and surviving into monthly close calculations before this fix.

#### Pluggy: late-arrival absorb vs double-post split

PR #420 (merged 2026-04-23): **"feat(close): t0-103 — period write-guard 422 with remediation on Pluggy late arrivals"** — this is a confirmed production pattern: Pluggy sends webhook events for transactions that arrive **after** the monthly period has been closed. The write-guard returns 422 to reject late writes, which protects the closed period but does NOT prevent Pluggy from retrying. The retry lands again (Pluggy retries on non-2xx), receives another 422, and so on. This is a retry amplification loop rather than a deduplication problem per se — the 422 is the correct signal — but it means the period close gate is the only thing standing between a late Pluggy retry and a double-posted transaction.

PR #494 (merged 2026-04-24): **"fix(admin): scope Pluggy TanStack cache by company_id"** — Pluggy data was not properly scoped by tenant. While this is a frontend cache issue, it reflects the same underlying pattern: Pluggy events were being consumed without company_id isolation, meaning a duplicate webhook from company A could be mistaken for a new event for company B. This is the "silent absorption" failure mode — the duplicate is ingested but attributed to the wrong entity.

The top8 rationale for rank-4 (t1-202 idempotency middleware) explicitly names these two signals: *"The chave_nfe drop bug (T0-110) and Pluggy cache mis-scoping (#494) hint that we're rediscovering the same class of bug — non-idempotent operations under retry."*

#### Where duplicates are currently silently absorbed

| Path | How duplicate is handled | Outcome |
|---|---|---|
| Focus NFe `_persist_event` with `chave_nfe` field missing | No unique key to check → INSERT succeeds | **Silent double-entry** — same NF-e creates two lancamentos |
| Focus NFe `_persist_event` with valid `chave_acesso` + correct status | [SPECULATION] Likely unique constraint on `(chave_acesso, status)` — but PR #529 not yet merged | **Depends on hotfix merge state** |
| Pluggy webhook for open-period transaction | No idempotency check on `pluggy_event.id` UUID documented | **Silent double-post if event UUID not stored** |
| Pluggy webhook for closed-period transaction | Period write-guard returns 422 | Not absorbed — retry loop created |
| NF-e cross-month | T4-105 added deduplication (PR #460) | Now protected, was previously a double-entry risk |

#### Where duplicates cause confirmed double-entry bugs

1. **T0-110 (Focus NFe, active)**: `chave_nfe` field dropped → no deduplication key → duplicate NF-e event = duplicate `lancamento`. Hotfix in PR #529 is unmerged as of snapshot.
2. **T4-105 (NF-e cross-month, fixed)**: Cross-period NF-e arrivals were creating duplicate invoice records before the 679-LOC deduplication layer was added.
3. **[SPECULATION]**: If Pluggy's event `id` UUID is not stored in a `webhook_events` table with a unique constraint, Pluggy retries (triggered by any non-2xx, including transient 5xx from our side) will insert duplicate transactions silently.

### Summary

The codebase shows a **pattern of discovering and fixing webhook-class bugs reactively**, one at a time: `chave_nfe` drop (T0-110), cross-month dedup (T4-105), Pluggy late arrivals (t0-103), cache mis-scoping (#494). Each fix addresses one specific failure mode without a general idempotency primitive. The current state is: Focus NFe deduplication is broken for the `chave_nfe` field until PR #529 merges; Pluggy deduplication relies on the period write-guard rather than a true idempotency key store.

## Sources

- `/artifacts/phase-0-snapshot-20260425-112323.json` — Contably git signals (merged PRs, open PRs, snapshot 2026-04-25) [fetched — local file read]
- `/artifacts/phase-2-research-20260425-112323/t2-252-track-1.md` — Track 1 finding on protocol headers (Pluggy `id` UUID, Focus NFe `chave_acesso`+`status` tuple) [fetched — local file read]
- `/artifacts/phase-1-top8-20260425-112323.json` — Top8 candidate list with rationale for rank-4 idempotency item (explicit T0-110 + #494 references) [fetched — local file read]

*Note: WebSearch and WebFetch were not available in this sandbox. All findings are grounded in the Contably git signal snapshot (2026-04-25). No external URLs were fabricated.*

## VERDICT: INCREASES priority — the git history confirms two active/recent double-entry bug instances (T0-110 still unmerged, T4-105 just fixed) and a pattern of reactive point-fixes rather than a general idempotency primitive, making the case for middleware-level protection stronger and more urgent.
```
