# /conta-cpo Report: {DECISION_TITLE}

**Decision ID:** {UUID}
**Date:** {DATE}
**Mode:** {full|quick} | **Type:** {DECISION_TYPE}
**Council Size:** {8|4} seats
**Contably OS v3 context hash:** {SHA1 of context block used}

---

## Decision Framing

{The neutral framing sent to all council members}

---

## Contably OS v3 Context (at time of deliberation)

{Collapsed summary of the context block — tiers active, open risks referenced, CTO verdicts applied}

---

## Council Deliberation Summary

### Agreements ({N}/{8|4} seats align)

{What the council broadly agrees on — positions held by 3+ members in full mode, 2+ in quick}

### Contradictions ({N} pairs)

{Key disagreements and their resolution via steelman debates}

For each contradiction:

- **{Seat A} ({name}) vs {Seat B} ({name}):** {nature of disagreement}
- **Resolution:** {synthesis | conditional | trade-off | clear_winner}
- **Key insight:** {what the exchange revealed}

### Orphan Insights

{Unique perspectives raised by only one seat — often the most valuable}

- **Seat {N} ({Archetype}, {name}):** {insight}

### Anti-Corruption Flags

- [ ] Unanimity detected (groupthink risk)
- [ ] Mandatory dissent triggered
- [ ] Low variance warning (std dev < 1.5)
- [ ] Context-block check failed (no seat referenced OS v3 state)

---

## Options

### Option 1: {Title} — Score: {X.XX}/10

**Description:** {1-2 sentences}
**Core Bets:** {what must be true for this to succeed}
**Kill Conditions:** {observable signals of failure}
**Reversibility:** {X}/10
**Champions:** Seats {N, N} ({Archetype, Archetype})
**Opponents:** Seats {N, N} ({Archetype, Archetype})

| Dimension              | Score | Weight | Weighted   |
| ---------------------- | ----- | ------ | ---------- |
| Regulatory & Compliance | {X}  | {X}%   | {X.XX}     |
| Technical Integrity    | {X}   | {X}%   | {X.XX}     |
| Accountant UX          | {X}   | {X}%   | {X.XX}     |
| Feasibility            | {X}   | {X}%   | {X.XX}     |
| Business Viability     | {X}   | {X}%   | {X.XX}     |
| Reversibility & Risk   | {X}   | {X}%   | {X.XX}     |
| **Total**              |       |        | **{X.XX}** |

### Option 2: {Title} — Score: {X.XX}/10

{Same structure}

---

## Pre-Commitment Record

**Selected option:** {Title or "User to decide"}
**Core bet:** {The key assumption}
**Kill condition:** {When to abandon}
**Check-in dates:** {30 days, 90 days, 180 days}
**Leading indicators:** {What to measure early}
**Lagging indicators:** {What to measure later}
**Linked Contably OS v3 artifact:** {risk code / task id if applicable, e.g., R-OS3-019 or t2-pluggy-canonicalization-03}

---

## Council Batting Average

{Historical accuracy from conta_cpo_batting_average view, if retrospectives exist}

| Seat | Archetype | Name | Decisions | Avg Accuracy | Times Best | Times Worst |
| ---- | --------- | ---- | --------- | ------------ | ---------- | ----------- |

{rows from conta_cpo_batting_average view}

---

## Raw Council Input

<details>
<summary>Click to expand full council responses</summary>

### Seat 1: Head of Product (Camila)

{Full JSON response}

### Seat 2: UX Lead (Renata)

{Full JSON response}

{... all 8 seats ...}

</details>
