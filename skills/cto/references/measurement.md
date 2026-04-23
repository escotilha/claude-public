# /cto — Measurement Protocol

Baseline metrics for swarm mode, stored durably so future migration decisions (P5 Agent Teams, future analyst additions, cost-control changes) can be data-driven instead of vibes-driven.

Per self-review finding #4 (2026-04-23): "once out of experimental" is not a falsifiable trigger. This file defines the protocol that makes migration decisions concrete.

---

## Purpose

Give every strategic decision about `/cto` a comparable number to reason about:

- **Before P5:** have baseline cost / quality / coverage from today's subagent-based swarm.
- **When P5 fires:** re-measure on the same projects, compare, decide.
- **When adding a new analyst** (e.g., P2 archaeology-analyst): measure its marginal cost and marginal findings.
- **When raising the confidence gate:** measure how many findings would have been dropped at each threshold.

Without this file, every optimization is intuition. With it, each decision produces an artifact the next decision can build on.

---

## Reference projects

Select 3 projects that exercise `/cto` across its actual use cases. Current choices (update as the portfolio evolves):

| # | Project | Why | Location |
|---|---|---|---|
| 1 | **Contably** | Real B2B SaaS, Next.js + Supabase + Python. The dominant `/cto` user in current logs (10 of 16 invocations). Represents the "plan review + incident diagnosis" path. | `~/claude-setup-cto-p2/..` or your checkout |
| 2 | **AgentWave** | Different stack (Docker/container ops). Represents the "infrastructure incident" swarm path (6 of 16 invocations). | `~/agentwave/` |
| 3 | **claude-setup itself** | The skills system. Small-to-medium codebase, meta-tooling. Represents the "focused single-area" sequential path and plan-reviews like the P2-P5 one. | `~/.claude-setup/` |

If a reference project is unavailable (private, rotated, decomposed), replace it and note the substitution in the measurement log — keep reference count at 3. Don't let the baseline drift silently.

---

## Metrics to capture

Every run emits a JSON record. Store at `.cto/measurements/{YYYY-MM-DD}-{project}.json` inside the `/cto` worktree or skill repo so measurements ship with the code.

### Schema

```json
{
  "timestamp": "2026-04-23T15:00:00Z",
  "project": "contably",
  "scope": "full | security | plan | incident",
  "mode": "sequential | swarm",
  "analystCount": 4,
  "cost": {
    "inputTokens": 0,
    "outputTokens": 0,
    "totalTokens": 0,
    "estimatedUSD": 0.0,
    "modelsUsed": ["opus-4.7", "sonnet-4.6", "haiku-4.5"]
  },
  "duration": {
    "totalSeconds": 0,
    "perAnalystSeconds": { "security": 0, "architecture": 0, "performance": 0, "quality": 0 },
    "synthesisSeconds": 0
  },
  "findings": {
    "critical": 0, "high": 0, "medium": 0, "low": 0,
    "candidates": 0,
    "crossConcerns": 0,
    "emergingPatterns": 0
  },
  "confidenceDistribution": {
    "10": 0, "9": 0, "8": 0, "7": 0, "6": 0, "5": 0, "4": 0, "3": 0, "2": 0, "1": 0
  },
  "qualitativeNotes": [
    "Free-text observations: did the swarm find something sequential missed? Did an analyst time out? Was the artifact consumable by /architect without edits?"
  ],
  "infra": {
    "agentTeamsEnabled": false,
    "claudeCodeVersion": "2.1.86",
    "opusVersion": "4.7"
  }
}
```

### Minimum viable first baseline

Capturing all of the above on the first baseline is too expensive. For the initial baseline (do this before merging archaeology-analyst), capture at minimum:

- `totalTokens` (rough — from Anthropic dashboard or inferred from session length)
- `findings` counts by severity
- `crossConcerns` count
- `duration.totalSeconds`
- `qualitativeNotes` — one paragraph per run

Later baselines can fill in the rest as the measurement tooling matures. Don't let perfect be the enemy of having any numbers at all.

---

## How to run the baseline (one-time, before next roadmap phase)

1. **Pick one concrete scope per reference project** — same scope across all 3 is easier to compare than three different scopes:
   - Scope choice: **full swarm review** on each. Reason: this is the most expensive mode, and if we can justify its cost, cheaper modes are self-justifying.
2. **Run `/cto` in swarm mode** on each reference project against `origin/master` (no uncommitted changes — makes the baseline reproducible).
3. **Record the JSON** per the schema above. Commit to `.cto/measurements/` in the target project (NOT in `~/.claude-setup` — each project's measurements live with the project so they track the project's evolution).
4. **Write a one-paragraph summary per run** in the `qualitativeNotes` field — what did the swarm find, what was the most expensive phase, what would have been missed in sequential mode.
5. **Commit a measurement index** at `~/.claude-setup/.cto/measurement-index.md` listing every recorded baseline across all projects, with links. This is the cross-project aggregator.

**Total effort for first baseline:** 3 swarm runs × ~5 min each = ~15 min active time, ~30 min wall time with synthesis. Plus ~30 min to write the records. Under 1 hour total.

---

## P5 trigger conditions

Agent Teams migration fires IF either:

1. **Graduation trigger:** Anthropic removes the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` flag requirement (confirmed via docs.claude.com or release notes). Check monthly.
2. **Cost trigger:** subagent swarm cost on any reference project crosses **2x the baseline** captured above AND the reason is coordination overhead (not new analysts added). This prevents silent cost drift.

If neither triggers, `/cto` stays on subagents. No migration for its own sake.

---

## P5 re-measurement

When a trigger fires:

1. Fork a branch: `experiment/cto-agent-teams-eval`.
2. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (if graduation) or switch Step 4 of SKILL.md to use Agent Teams primitives.
3. Re-run baseline on the same 3 reference projects, same scope, same `origin/master` commits if possible (use `git rev-parse HEAD` from the original baseline).
4. Capture the same JSON per project.
5. Compare.

### Decision gate — Agent Teams wins IF both hold:

- **Token delta ≤ 2x** — cost no more than double. If more, the coordination benefit must be overwhelming.
- **Cross-concerns found ≥ subagent baseline** — same or better signal. If fewer, coordination hasn't helped review quality.

If both hold: merge the Agent Teams branch.
If either fails: document the failure in `references/measurement.md` timeline section below, archive the branch, keep subagents.

**Escape hatch:** if a specific review scope (e.g., incident diagnosis) shows strong Agent Teams wins while others don't, migrate that scope only. Don't forced-migrate the whole skill.

---

## New-analyst evaluation (generalizes P2 pattern)

Same protocol applies to every future analyst proposal:

1. Baseline swarm run WITHOUT the new analyst.
2. Apply the analyst proposal (new checklist, new file ownership, etc.).
3. Re-run on the same projects.
4. Compute marginal cost (tokens delta) and marginal findings (unique findings the new analyst produced that no existing analyst would have).
5. Decision gate: new analyst merges only if it produces ≥1 unique finding per reference project AND cost increase ≤ 25%.

This prevents analyst proliferation — every new lens must earn its keep against hard data.

---

## Confidence-gate calibration (pre-existing debt, QUICK_WIN)

The current ≥8/10 confidence gate is a guess, not calibrated. Periodically:

1. Read 3 prior artifacts at `.cto/review-*.md` across all projects.
2. For each finding at each confidence score, retrospectively label: did this turn out to be a true positive in the codebase at the time?
3. Compute accuracy at each threshold. If <70% true-positive at 8/10, raise the gate. If >90% true-positive at 7/10, consider lowering.

Do this quarterly. Append results to the timeline at the bottom of this file.

---

## Timeline (append-only)

<!--
Each entry:
- Date
- What was measured / evaluated
- Decision made
- Where the data lives
-->

- **2026-04-23** — [design] Measurement protocol defined per self-review finding #4. No baseline captured yet. Source: session review of P2-P5 roadmap, `~/.claude-setup/.cto/review-2026-04-23-cto-p2-p5-roadmap.md`.
