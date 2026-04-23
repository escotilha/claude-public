# /cto — Synthesis Reference

How the orchestrator merges raw analyst findings into the final artifact (`.cto/review-{date}-{slug}.md`). Used in swarm mode after all analysts complete; simplified to a single pass in sequential mode.

---

## Confidence gate (applied before synthesis)

Every finding from every analyst carries a confidence score (0-10). The orchestrator applies a gate BEFORE synthesis:

- **≥8/10** → main findings section (by severity)
- **6-7/10** → "Candidates (below confidence gate)" section — documented but not actionable
- **<6/10** → drop silently, not included in the artifact

Rationale: Semgrep 2026 research showed identical prompts on identical code produced 3, 6, and 11 distinct findings across three runs. Without a confidence gate, swarm output is noise-dominated. Anthropic's canonical multi-agent code-review plugin uses a similar threshold (80/100, equivalent to 8/10).

The gate can be lowered for the initial rollout (6/10 for the first week) and raised to 8/10 once the signal-to-noise is validated by usage.

### How an analyst computes confidence

Score the MIN of these two axes, each on 10:

- **Exploitability / reproducibility**: can you point to `file:line` and describe the concrete trigger? (10 = concrete path + PoC ready; 5 = plausible if misconfigured; 2 = theoretical)
- **Correctness of the flag**: how confident are you the code does what you think it does? (10 = re-read the file and traced callers; 5 = grep match, didn't verify; 2 = pattern match only)

---

## Synthesis pipeline

Swarm mode: after all analysts complete (or timeout), the orchestrator runs three parallel synthesis agents (`model: haiku`, `run_in_background: true`), then merges their outputs. Sequential mode: skip the pipeline and apply the rules inline.

### Synthesis Agent 1 — severity-ranker

```
Input: {all raw analyst findings as JSON}

Task: Rank every finding by severity using these rules:
- CRITICAL: production outage risk, data loss, security breach, auth bypass
- HIGH: significant performance degradation, major security flaw, data integrity risk
- MEDIUM: code quality issues affecting maintainability, moderate performance impact
- LOW: style issues, minor tech debt, nice-to-have improvements

For findings at the boundary between levels, err toward the higher severity.

Output: JSON array of {finding_id, severity, justification}
```

### Synthesis Agent 2 — cross-concern-detector

```
Input: {all raw analyst findings as JSON, grouped by analyst}

Task: Find cross-concern patterns:
1. SAME FILE flagged by 2+ analysts → elevate one severity level
2. SAME ISSUE TYPE across 3+ files → flag as emerging pattern
3. CONTRADICTIONS between analysts (one says "good", another says "bad") → flag for lead review
4. REINFORCEMENTS where multiple analysts confirm the same root cause

Examples:
- architecture finds loop in orders.ts + performance confirms N+1 → elevate to HIGH
- security finds vulnerable lodash + quality finds deprecated usage → consolidate
- quality finds missing error handling in 5 files + security finds unhandled auth → emerging pattern

Output: JSON with {elevations[], emergingPatterns[], contradictions[], consolidations[]}
```

### Synthesis Agent 3 — effort-estimator

```
Input: {all raw analyst findings as JSON}

Task: For each finding, estimate implementation effort:
- QUICK_WIN: <1 hour, single-file change, low risk
- MODERATE: 1-4 hours, multiple files, some testing needed
- SIGNIFICANT: 1-2 days, architectural change, thorough testing
- MAJOR: 3+ days, cross-cutting refactor, migration planning

Also identify the optimal fix ORDER — dependencies between fixes, quick wins that
unblock larger changes.

Output: JSON array of {finding_id, effort, dependencies[], quickWin: boolean}
```

---

## Merge rules (applied by the orchestrator after all 3 synthesis agents complete)

1. Apply severity rankings from severity-ranker.
2. Apply elevations from cross-concern-detector — override severity where cross-concerns found.
3. Consolidate duplicate findings flagged by cross-concern-detector.
4. Annotate each finding with effort estimate from effort-estimator.
5. Sort: `CRITICAL + QUICK_WIN` first, then `CRITICAL + SIGNIFICANT`, then `HIGH + QUICK_WIN`, etc. Within each bucket, sort by confidence descending.
6. Compute the verdict:
   - If plan review: any CRITICAL or HIGH → `APPROVE_WITH_CHANGES` (list blockers) or `REJECT` (if fundamental)
   - If incident diagnosis: `DIAGNOSTIC` (no approval semantics)
   - Else: `APPROVE_WITH_CHANGES` if HIGH+ findings exist, `APPROVE` if only MEDIUM/LOW
7. Generate the artifact per `references/report-templates.md`.

---

## Fallback (when parallel synthesis unavailable)

If the `Agent` tool is unavailable or fewer than 10 findings exist across all analysts, do single-pass synthesis:

- The lead orchestrator applies the three synthesis rubrics (severity, cross-concern, effort) in sequence within one turn.
- Produces the same artifact format.
- Expected to take 30-60 seconds of orchestrator thinking time.

---

## Lead orchestrator behavior during swarm

- When an analyst messages completion → update the tracking list → shut them down immediately (saves tokens — idle analysts still consume context on every broadcast).
- When an analyst reports a critical finding mid-run → log it for the synthesis, do NOT interrupt other analysts.
- When all analysts complete → proceed to synthesis.
- If an analyst exceeds 5 minutes → mark incomplete, synthesize available findings, set status to `partial`.
- Never broadcast messages between analysts. Analysts only message the lead or message each other directly for cross-concern flags.
