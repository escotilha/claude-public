---
name: contably-roadmap-priorities-2026Q2
description: Pierre's 3 priority directives for oxi engine roadmap execution as of 2026-04-28. Daily reconciliation, monthly closing, agent onboarding (incl. gamification) drive task selection. The master tracker is split across three Apr 23-24 docs.
type: personal
originSessionId: db8b7a66-ea55-4429-8965-c5a75b7635a3
---
# Contably roadmap priorities — Pierre's directives 2026-04-28

The oxi engine's roadmap execution should prioritize work that advances these three product capabilities, in this order:

1. **Daily reconciliation** — analyst's morning loop
2. **Monthly closing** — period-end workflow
3. **Agent onboarding** — Sevilha analyst rollout, **including gamification**

## Master tracker (the canonical "what's done vs missing" docs)

There is no single tracker file. The truth is split across three living docs in `/Volumes/AI/Code/contably/docs/`. When choosing what oxi should ship next, read these first and cross-reference with the roadmap:

| Directive | Tracker doc | Status as of 2026-04-24 |
| --- | --- | --- |
| Daily reconciliation | `go-live-gap-analysis-2026-04-24.md` §1 + `daily-reconciliation-cron-audit-2026-04-23.md` | Engine ready. Gaps are data seeding (no invoices on NUVINI), 694 historical BTs uncanonicalized, reconciliation engine never run for the tenant. Code complete. |
| Monthly closing | `monthly-closing-inventory-2026-04-23.md` | 7-step close workflow shipped + Stage 4 NUVINI 2026-03 closed 2026-04-20. Open: T2-20 financial-reports CSV/XLSX export, T2-30 lock-indicator extension to non-closing pages. |
| Agent onboarding (incl. gamification) | `copiloto-gamificacao-apresentacao.md` + `ux-research-accountant-workflow.md` + `ux-restructure-plan.md` | 5-level Copiloto journey designed. Gamification opt-in spec exists. Tier-1 roadmap items T1-1 (Copiloto Sevilha), T1-2 (progressive onboarding) cover this. |

**Q2 roadmap source:** `docs/contably-product-roadmap-2026-Q2.md` (master plan from Feb 28 at `tasks/prd-contably-mvp-master-plan.md` is **stale** — Q2 roadmap supersedes it).

## How to apply

When a new task identifier comes up for dispatch / when seeding new fronts:

1. Map it to one of the three directives above (or none).
2. Tasks aligned with directive #1 (daily reconciliation) take precedence over #2, #2 over #3.
3. Tasks aligned with NONE of the three are deprioritized — let them sit in the queue or trigger them manually only if there's a hard external deadline.
4. When in doubt, read the tracker doc for that directive before adding a new front.

## Discoveries that shape priority

- **The 60 ghost rows oxi reaped on 2026-04-28** were largely T0/T1 work from Feb-Apr that was already shipped via direct human commits. The "obvious" backlog has been worked off.
- **What's left in the Q2 roadmap is mostly T2-T4 epics** — large-scope features (Mobile App, MLOps, Multi-Firm Analytics, Billing/Metering). These need ≥180 turns each (per-tier max_turns shipped 2026-04-28 PR #242).
- **The 3 directives narrow the remaining queue** to a small subset of T1/T2/T3 items, plus net-new work the operator hand-adds.

## Memory hooks

When evaluating any of:
- "Should oxi dispatch task X?"
- "What's next on the roadmap?"
- "Is this work worth the spend?"

→ Always cross-check against this priority list first. The three directives are operator-set, not engine-derived; they override anything the routing/scoring layer would pick on its own.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre set the 3 priorities + asked oxi to use them as the main driver. Master tracker located across `go-live-gap-analysis`, `monthly-closing-inventory`, `copiloto-gamificacao-apresentacao`. (Source: user-feedback — operator directive during engine restart session)
