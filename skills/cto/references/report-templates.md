# /cto — Report Templates & Artifact Contract

The orchestrator writes exactly ONE artifact per review: `.cto/review-{YYYY-MM-DD}-{slug}.md`. This file is the durable handoff to `/architect`, `/ship`, future `/cto` sessions, and the user. The chat summary is secondary — the file is canonical.

---

## Artifact path & naming

- Directory: `.cto/` in the project root (create if missing, add to `.gitignore` unless the user explicitly wants it tracked).
- Filename: `review-{YYYY-MM-DD}-{slug}.md`
- `slug` is a short hyphenated descriptor derived from the review scope:
  - Full review: `full`
  - Focused: the scope keyword (`security`, `performance`, `architecture`, `quality`)
  - Plan review: `plan-{plan-doc-basename}` (e.g., `plan-serpro-integra-contador`)
  - Incident diagnosis: `incident-{terse-description}` (e.g., `incident-staging-prod-shared-db`)

Multiple reviews on the same day get a suffix: `review-2026-04-23-full.md`, `review-2026-04-23-full-2.md`.

---

## Artifact schema

```markdown
---
project: {project-name}
scope: {full | security | architecture | performance | quality | plan | incident}
mode: {sequential | swarm}
date: {YYYY-MM-DD}
duration_seconds: {int}
analysts: [{list of analyst roles that ran}]
verdict: {APPROVE | REJECT | APPROVE_WITH_CHANGES | DIAGNOSTIC}
confidence_gate: 8  # findings below this score are in "candidates" only
---

# CTO Review — {project} ({date}, {scope})

## Verdict

**{APPROVE | REJECT | APPROVE WITH CHANGES | DIAGNOSTIC}**

{1-2 sentence rationale. For APPROVE WITH CHANGES, list the blocking changes explicitly. For DIAGNOSTIC, state the root cause found.}

## Executive Summary

{2-3 sentence overview of findings and key recommendations.}

**Findings:** {N} critical, {N} high, {N} medium, {N} low. {N} candidates (below confidence gate).

**Top 3 priorities:**
1. {priority 1} — {severity}
2. {priority 2} — {severity}
3. {priority 3} — {severity}

**Quick wins available:** {Y/N — list if yes, each <1hr single-file change}

---

## Findings

Sorted: critical quick-wins first, then critical significant, then high quick-wins, etc. Within each severity, sorted by confidence score descending.

### CRITICAL

| # | confidence | file:line | issue | recommendation | effort |
|---|---|---|---|---|---|
| 1 | 10/10 | src/auth/jwt.ts:42 | Algorithm confusion — accepts HS256 with RS256 public key as HMAC secret | Reject any JWT where alg header != configured algorithm | QUICK_WIN |

### HIGH

{table}

### MEDIUM

{table}

### LOW

{table}

---

## Candidates (below confidence gate)

Findings below the 8/10 confidence threshold. Not actionable yet — included for audit trail and possible re-investigation.

| # | confidence | file:line | issue | why uncertain |
|---|---|---|---|---|

---

## Cross-Concern Correlations

Findings flagged by 2+ analysts on the same file or issue type. Elevated severity.

| file | analysts | issue | elevation |
|---|---|---|---|

---

## Emerging Patterns

Issue types that appeared in 3+ files. Indicates systemic habit, not one-off.

| pattern | count | example files | recommendation |
|---|---|---|---|

---

## Fix Order (Dependency-Aware)

1. {first fix} — unblocks: {what this enables}
2. {second fix} — depends on: #1
3. {parallel-safe fix}
4. {parallel-safe fix}

---

## Confidence Assessment

- **Overall confidence in findings:** {X}% (weighted average)
- **Strongest evidence:** {what supports conclusions most}
- **What would change these recommendations:**
  - {factor} → would shift to {alternative}
- **Assumptions made:**
  - ⚠️ {assumption} — {why we believe this holds}
- **Known unknowns:** {what we couldn't determine from static analysis — candidates for runtime testing, /ultrareview pre-merge, or Claude Code Security SAST}

---

## Prioritized Action Items

### Immediate (this week)
1. [ ] {critical issue to fix}

### Short-term (this month)
1. [ ] {important improvement}

### Long-term (this quarter)
1. [ ] {strategic initiative}

---

## Technical Debt Register

| Item | Origin | Impact | Estimated Effort | Priority |
|---|---|---|---|---|

---

## Architecture Decision Records (if architecture review)

### ADR-{NNN}: {Title}

**Status:** Proposed
**Context:** {Why is this decision needed?}
**Decision:** {What is the proposed solution?}
**Consequences:** {What are the trade-offs?}

---

## Analyst Notes

### security-analyst
{raw notes from this analyst — useful for debugging the synthesis later}

### architecture-analyst
...

### performance-analyst
...

### quality-analyst
...

### history-analyst (if P2+)
...

---

## Recommendations for follow-up skills

- `/architect` — if verdict is APPROVE or APPROVE WITH CHANGES on a plan review
- `/ultrareview` — if this review is preparing for a pre-merge check on substantial changes ($5-20/run, 5-10min, cloud-sandboxed reproduction)
- `/alembic-chain-repair` — if findings include migration-chain issues
- Claude Code Security — for auth flows / RLS policies / multi-hop data flow SAST
```

---

## Verdict definitions

| Verdict | When to use |
|---|---|
| **APPROVE** | Zero critical findings, zero high findings that block the stated goal. Plan / change is ready to proceed. |
| **APPROVE_WITH_CHANGES** | Specific blocking items enumerated in the verdict section. Fix them, then proceed without another full review. |
| **REJECT** | Fundamental issue that requires redesign before proceeding. Another full review is warranted after redesign. |
| **DIAGNOSTIC** | Used for incident-mode reviews. No approval semantics — the artifact documents root cause and recommended fixes. |

---

## Severity definitions

| Level | Meaning |
|---|---|
| **CRITICAL** | Production outage risk, data loss, security breach, auth bypass. Must be fixed before merge/launch. |
| **HIGH** | Significant performance degradation, major security flaw, data integrity risk. Should be fixed before next release. |
| **MEDIUM** | Code quality issues affecting maintainability, moderate performance impact. Plan to fix in the current quarter. |
| **LOW** | Style issues, minor tech debt, nice-to-have improvements. Backlog. |

For findings at the boundary between levels, err toward the higher severity.

---

## Effort definitions

| Label | Meaning |
|---|---|
| **QUICK_WIN** | <1 hour, single-file change, low risk. Prioritize to unblock larger work. |
| **MODERATE** | 1-4 hours, multiple files, some testing needed. |
| **SIGNIFICANT** | 1-2 days, architectural change, thorough testing. |
| **MAJOR** | 3+ days, cross-cutting refactor, migration planning. |

---

## Final chat summary (after writing the artifact)

```
## CTO Review Complete — {date}

**Verdict:** {VERDICT}

**Artifact:** `.cto/review-{YYYY-MM-DD}-{slug}.md`

**Top 3:**
1. {priority 1} — {severity}
2. {priority 2} — {severity}
3. {priority 3} — {severity}

**Next step:** {/architect if APPROVE plan | fix the N blockers then re-run | redesign — see artifact}
```

Ask ONLY after this summary:

```
AskUserQuestion:
  question: "Implement the recommendations?"
  header: "Next"
  options:
    - label: "Yes, all (via /architect)"
      description: "Read the .cto/review artifact and implement the full prioritized action list"
    - label: "Yes, selected only"
      description: "Choose which to implement"
    - label: "No, just the report"
      description: "Keep the artifact, I'll act manually"
    - label: "Pre-merge check"
      description: "Run /ultrareview on the changes before merging"
```

Never auto-implement without explicit approval.

---

## `cto-requirements.md` — project-level configuration

If a project wants to steer `/cto` invocations, it places this file at its root:

```markdown
# CTO Requirements

## Focus Areas
<!-- Which areas should receive priority attention? -->
- [ ] Architecture review
- [ ] Code quality
- [ ] Security audit
- [ ] Performance analysis
- [ ] Tech stack evaluation
- [ ] Testing strategy

## Mode
<!-- sequential | swarm (default: auto-detected by orchestrator) -->
mode: auto

## Constraints
- Budget: [Limited/Moderate/Flexible]
- Timeline: [Urgent/Normal/Long-term]
- Team size: [X developers]
- Team expertise: [Junior/Mixed/Senior]

## Known Issues
1. [Known issue 1]
2. [Known issue 2]

## Out of Scope
- [Area to skip]

## Priority Questions
1. [Question 1]
2. [Question 2]
```

---

## Status JSON (completion signal)

Every invocation ends by returning a status object to the caller (used when `/cto` is invoked from another skill like `/architect` or `/orchestrate`).

### Success — sequential mode

```json
{
  "status": "complete",
  "analysisType": "sequential",
  "summary": "Completed focused security audit of authentication system",
  "findings": { "critical": 1, "high": 2, "medium": 3, "low": 5, "candidates": 7 },
  "artifact": ".cto/review-2026-04-23-security.md",
  "verdict": "APPROVE_WITH_CHANGES",
  "topPriorities": [
    "Fix hardcoded JWT secret (CRITICAL)",
    "Add rate limiting to login endpoint (HIGH)",
    "Implement CSRF protection (HIGH)"
  ],
  "userActionRequired": "Review artifact and approve implementation"
}
```

### Success — swarm mode

```json
{
  "status": "complete",
  "analysisType": "swarm",
  "summary": "Completed full codebase review with 4 parallel analysts",
  "swarmMetrics": {
    "analysts": 4,
    "duration": "3m 42s",
    "crossConcerns": 2,
    "emergingPatterns": 3
  },
  "findings": { "critical": 1, "high": 4, "medium": 8, "low": 7, "candidates": 12 },
  "artifact": ".cto/review-2026-04-23-full.md",
  "verdict": "APPROVE_WITH_CHANGES",
  "analystSummaries": {
    "security": "1 critical, 3 high findings (incl. dep CVEs)",
    "architecture": "0 critical, 1 high, 3 medium findings",
    "performance": "0 critical, 2 medium findings",
    "quality": "0 critical, 5 low findings"
  },
  "userActionRequired": "Review prioritized action items and approve fixes"
}
```

### Partial — some analysts timed out

```json
{
  "status": "partial",
  "analysisType": "swarm",
  "summary": "3 of 4 analysts completed, 1 timed out",
  "completedAnalysts": ["security", "architecture", "performance"],
  "incompleteAnalysts": ["quality"],
  "partialFindings": { "critical": 1, "high": 3, "medium": 4, "low": 0 },
  "artifact": ".cto/review-2026-04-23-full.md",
  "verdict": "APPROVE_WITH_CHANGES",
  "reason": "Quality analyst exceeded 5m timeout",
  "userActionRequired": "Review partial artifact or re-run incomplete analysts"
}
```

### Blocked — cannot start

```json
{
  "status": "blocked",
  "analysisType": "sequential",
  "summary": "Cannot access codebase — directory not readable",
  "blockers": [
    "Project directory not found at specified path",
    "No package.json or requirements.txt detected"
  ],
  "userInputRequired": "Navigate to project root or specify correct path"
}
```

### Failed — error during run

```json
{
  "status": "failed",
  "analysisType": "swarm",
  "summary": "Swarm analysis failed — unable to spawn analysts",
  "errors": ["Agent tool unavailable"],
  "fallbackAction": "Retry with sequential mode",
  "recoverySuggestions": [
    "Use 'sequential' mode instead of 'swarm'",
    "Reduce scope to specific area (e.g., security only)"
  ]
}
```
