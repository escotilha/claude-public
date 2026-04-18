---
name: marco:deal-registry
description: Master registry of all M&A deals analyzed by Marco — status, links, key takeaways
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Marco's longitudinal deal database. Every company Marco triages, investigates, or tracks gets a row here and a linked deal page.

**Status legend:** prospect | pipeline | in-dd | ic-approved | closed | rejected | watch

---

## Active Pipeline

| Deal        | Date Added | Status   | Sector             | Size (est.) | Memory File                      | Key Takeaway                                                            |
| ----------- | ---------- | -------- | ------------------ | ----------- | -------------------------------- | ----------------------------------------------------------------------- |
| [Stripe](#) | 2026-04-11 | prospect | Fintech / Payments | $65B+       | [deal_stripe.md](entities/deal_stripe.md) | Dominant market position; public exit likely before any M&A opportunity |

## Closed Deals

| Deal         | Close Date | Outcome | Entry Multiple | Notes |
| ------------ | ---------- | ------- | -------------- | ----- |
| _(none yet)_ | —          | —       | —              | —     |

## Rejected / Passed

| Deal         | Date | Reason | Memory File |
| ------------ | ---- | ------ | ----------- |
| _(none yet)_ | —    | —      | —           |

## Watch List

_(Companies not yet actionable but worth monitoring)_

| Company      | Industry | Why Watching | Next Review |
| ------------ | -------- | ------------ | ----------- |
| _(none yet)_ | —        | —            | —           |

---

## How to Add a Deal

1. Create `deal_{slug}.md` in `~/.claude-setup/memory/auto/` using `deal-template.md`
2. Add a row to the Active Pipeline table above
3. Run `~/.claude-setup/tools/mem-search --reindex`

---

## Timeline

- **2026-04-11** — [session] Registry created, deal-template.md authored, Stripe example deal added (Source: session — marco)
