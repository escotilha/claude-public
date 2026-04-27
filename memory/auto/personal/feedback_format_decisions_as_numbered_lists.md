---
name: format-decisions-as-numbered-lists
description: Pierre prefers every decision list (options, sub-tasks, halt-points, follow-ups) formatted as a numbered list, not bullets, so he can refer to them by number.
type: feedback
originSessionId: 706921c3-0302-451b-8e8a-634ac7e49113
---
When presenting Pierre with anything decision-shaped — option menus, halt-point lists, sub-task enumerations, follow-up actions, alternatives, trade-off forks — render the list as **numbered** (`1.`, `2.`, `3.`), not bulleted. Same goes for "what's left" or "next steps" lists where he might pick one to act on.

**Why:** he refers to items by number ("do gap #3", "do option 1") and bullets force him to quote text instead. Numbering shortens his reply and removes ambiguity about which item he means. He explicitly asked for this on 2026-04-27 after a long string of bullet-formatted decision lists in the OXi cutover session.

**How to apply:**
- Anything Pierre might pick from → numbered.
- Pure prose, status updates, or reports where he's not picking → bullets are fine.
- Acceptance criteria checklists → keep `- [ ]` markdown checkboxes (they have semantics in Markdown).
- Mixed output (e.g. summary + decision list at the end) → number the decision list portion.

When unsure, prefer numbered. The cost of an unwanted number is zero; the cost of an unnumbered decision list is a re-quote.

---

## Timeline

- **2026-04-27** — [user-feedback] Pierre: "Every time you give me a list of decisions, please number it." Came after the OXi Phase 3 audit halt-point list and the "three actions, one halt point" summary. (Source: user-feedback — direct ask during cutover session)
