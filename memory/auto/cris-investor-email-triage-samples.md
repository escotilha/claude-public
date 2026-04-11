---
name: cris-investor-email-triage-samples
description: Sample triage output showing PERSONAL_REPLY_NEEDED flag with rationale — 5 examples
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

# Cris Investor Email Triage — Sample Output

Format: each triage entry shows subject, sender tier, flag status, rationale, and draft readiness.

---

## Example 1 — PERSONAL_REPLY_NEEDED (first touch, new investor)

```
FROM:    sarah.chen@sequoiacap.com
SUBJECT: Introduction via Jason — excited to connect
TIER:    New (no prior thread)
FLAG:    PERSONAL_REPLY_NEEDED: First contact with Sequoia relayed via warm intro from Jason — sets the tone for the relationship.
DRAFT:   Held — awaiting Pierre's personal reply.
```

---

## Example 2 — PERSONAL_REPLY_NEEDED (VIP board member, sensitive topic)

```
FROM:    roberto.silva@kaszek.com
SUBJECT: Quick question on Q1 numbers
TIER:    VIP / Board
FLAG:    PERSONAL_REPLY_NEEDED: VIP/board member Roberto — always requires Pierre's voice. Sensitive topic: performance figures.
DRAFT:   Held — awaiting Pierre's personal reply.
```

---

## Example 3 — PERSONAL_REPLY_NEEDED (negative sentiment, relationship risk)

```
FROM:    mark.taylor@accel.com
SUBJECT: Re: March update — a few concerns
TIER:    Standard investor
FLAG:    PERSONAL_REPLY_NEEDED: Negative signal: "concerns" — requires empathy and ownership, not a template.
DRAFT:   Held — awaiting Pierre's personal reply.
```

---

## Example 4 — NO FLAG (routine update acknowledgment, draft ready)

```
FROM:    lp-updates@a16z.com
SUBJECT: Re: Nuvini February investor update
TIER:    Standard LP
FLAG:    none
DRAFT:   Ready — "Thanks for the update, Pierre! Excited to see the traction on the SourceRank side. Keep it up." — minor edit or send as-is.
```

---

## Example 5 — NO FLAG (routine meeting scheduling)

```
FROM:    assistant@atomico.com
SUBJECT: Scheduling our quarterly check-in with Pierre
TIER:    Standard investor (EA outreach)
FLAG:    none
DRAFT:   Ready — Calendly link + "Pierre looks forward to connecting" — no personal voice required, EA-to-EA exchange.
```

---

## Timeline

- **2026-04-11** — [session] Created as companion to cris-investor-email-rules.md (apr-1775840427635).
