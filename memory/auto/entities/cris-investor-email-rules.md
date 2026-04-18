---
name: cris-investor-email-rules
description: Cris email triage rules — investor classification, PERSONAL_REPLY_NEEDED flag, VIP routing
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Cris flags investor emails with PERSONAL_REPLY_NEEDED when Pierre's personal voice is irreplaceable: first impressions with new investors, sensitive IR moments, or relationship-critical exchanges. All other investor emails get a draft that Pierre can send with minor edits.

## Investor Tiers

| Tier     | Definition                                                    | Routing Default              |
| -------- | ------------------------------------------------------------- | ---------------------------- |
| VIP      | Board members, lead investors, check writers ≥ $500K          | Always PERSONAL_REPLY_NEEDED |
| Board    | Board observers and advisors with governance rights           | Always PERSONAL_REPLY_NEEDED |
| New      | First contact from any investor (no prior thread in last 90d) | PERSONAL_REPLY_NEEDED        |
| Standard | Known investors, update requests, routine questions           | Draft (no flag)              |
| Prospect | Inbound cold outreach from unknown funds                      | Draft unless warm intro      |

## Rules That Trigger PERSONAL_REPLY_NEEDED

### Automatic triggers (always flag, regardless of tier)

1. **First touch from any investor** — no prior email thread in last 90 days
2. **Warm intro relayed by a mutual contact** — sender mentions a mutual, or email is forwarded with "introducing"
3. **Board member or lead investor emails** — see cris-vip-senders.json
4. **Cap table or equity discussions** — mentions: SAFE, note, term sheet, pro-rata, dilution, vesting, valuation, cap table
5. **Negative sentiment or concern** — mentions: concerned, disappointed, worried, unexpected, underperformed, miss, behind
6. **Legal or governance triggers** — mentions: consent, board approval, information rights, drag-along, liquidation preference
7. **Personal relationship signals** — mentions: coffee, lunch, call to catch up, in town, personal update
8. **Fundraising process milestones** — mentions: closing, wire, signed, committed, leading the round, term sheet
9. **Crisis or bad news** — mentions: lawsuit, regulator, breach, incident, delay, pivot, layoff
10. **Request for Pierre specifically** — "I'd love to hear from Pierre directly", "can Pierre jump on a call"

### Soft triggers (flag unless email is clearly routine)

- Follow-up after a board meeting or investor call
- Reply to a Pierre-authored email (keeps the conversational thread with his voice)
- Any email containing an attachment named: deck, term-sheet, loi, agreement, offer, contract
- Investor mentions they are sharing with a partner or committee ("sharing with my team")

## Red-Flag Keywords (auto-scan subject + body)

```
# Relationship risk
"disappointed", "concerned", "frustrated", "expected more", "not what we discussed",
"reconsidering", "stepping back", "pausing", "stepping down"

# Governance / legal
"information rights", "board seat", "consent", "drag-along", "ROFR", "pro-rata",
"side letter", "amendment", "breach", "cure period", "default"

# Fundraising critical path
"term sheet", "closing", "wire instructions", "signed documents", "committed capital",
"lead investor", "anchoring the round", "bridge"

# Relationship milestones
"first time", "introduction", "referred by", "met you at", "heard about you from",
"warm intro", "in town next week", "grabbing coffee"

# Negative performance signals
"miss", "behind plan", "runway", "burn rate", "underperformed", "pivoting away"
```

## Emails That Do NOT Need Personal Reply (use draft)

- Monthly / quarterly update acknowledgments ("Thanks for the update, keep it up!")
- Routine meeting scheduling when an EA or Calendly link is appropriate
- Standard data room access requests from known investors
- LP update distribution confirmations
- Automated cap table platform notifications forwarded to Pierre

## Rationale Template

When PERSONAL_REPLY_NEEDED is set, Cris includes a one-line rationale:

```
PERSONAL_REPLY_NEEDED: {reason}
```

Reason templates:

- "First contact with [Firm] — sets the tone for the relationship."
- "VIP/board member [Name] — always requires Pierre's voice."
- "Sensitive topic: [keyword] — draft risks sounding impersonal."
- "Warm intro from [mutual] — first impression moment."
- "Fundraising milestone: [topic] — personal commitment expected."
- "Negative signal: [keyword] — requires empathy and ownership."
- "Investor requested Pierre directly."
- "Reply to Pierre-authored thread — keeps voice consistent."

---

## Timeline

- **2026-04-11** — [session] Created by Cris approval task apr-1775840427635. Initial rule set covering 4 investor tiers, 10 automatic triggers, 5 soft triggers, red-flag keyword list, and rationale templates.
