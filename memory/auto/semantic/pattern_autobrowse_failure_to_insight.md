---
name: pattern:autobrowse-failure-to-insight
description: Self-improving browser automation — failure-to-insight retry loop that graduates winning workflows into reusable skills
type: pattern
originSessionId: 4fab66fd-9943-408e-bb8e-706d704906d0
---
The autobrowse pattern (Karpathy-inspired) runs browser tasks iteratively: each failed attempt extracts a failure reason (console error, selector mismatch, timeout), injects it as a constraint into the next attempt, and loops until a reliable workflow emerges. Once stable, the winning action sequence is emitted as a reusable skill file.

Key elements:
1. Failure-to-insight extraction: capture WHY the action failed, not just that it failed
2. Constraint accumulation: each retry adds constraints from prior failures
3. Convergence gate: stop after N consecutive successes (not just one)
4. Graduation: emit a parameterized SKILL.md stub from the winning run

Applies to `/agent-browser` skill — add retry-with-reflection phase and optional "graduate to skill" exit step. The `/meditate` skill already extracts session learnings; this is the browser-specific analog.

---

## Timeline

- **2026-04-23** — [research] Discovered from @shreypandya (Browserbase team) tweet introducing /autobrowse. Source: research — https://x.com/shreypandya/status/2047100550446280792
- **2026-04-23** — [research] Applied to: /agent-browser skill recommendation — Score 8/10. Not yet implemented.
