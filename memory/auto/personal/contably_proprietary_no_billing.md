---
name: contably_proprietary_no_billing
description: Contably is Nuvini-internal proprietary tooling — no external paying customers, no billing, no pricing tiers, no payment processors. Strategic position confirmed by Pierre 2026-04-28.
type: user
originSessionId: f67cf8de-b579-4f3a-ae2b-2d3eab52353d
---
Contably is operated as **proprietary internal tooling for Nuvini-owned firms**. There are no external paying customers, no usage-based billing, no plan tiers, no Stripe/payment processor integration, and no pricing strategy work to be done.

This is a STRATEGIC position, not a "for now" deferral. Future sessions should NOT propose:
- Billing modules / usage metering
- Plan tiers / feature gates / "upgrade to use" prompts
- Pricing pages / pricing strategy work
- Payment processor integration
- External-customer-facing GA roadmap items
- Marketing pages with pricing

Internal cost tracking (LLM token spend, infra cost) is fine — that's operational monitoring, not customer billing.

Affected surfaces (as of 2026-04-28):
- PR #706 (`feat/oxi-t3-7` — billing/usage metering module): closed without merge.
- Staging DB had ghost row `t3_7_billing_usage_metering` from a prior deploy of #706 — removed.
- Roadmap docs (Q2, Q3, alpha) had billing items — stripped.

If a teammate or skill (e.g. `/cpo`, `/growth`) asks about Contably pricing or billing, the correct answer is "not applicable, internal Nuvini tooling."

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre confirmed Contably is Nuvini-internal proprietary tooling, no external customers, no billing of any kind. Decision made while triaging the t3_7_billing_usage_metering staging DB ghost from PR #706. (Source: user-feedback — explicit statement in PR #716 deploy unblock thread)
