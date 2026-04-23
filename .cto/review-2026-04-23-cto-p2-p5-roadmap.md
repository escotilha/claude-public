---
project: claude-setup (/cto skill itself)
scope: plan
mode: sequential
date: 2026-04-23
duration_seconds: 240
analysts: [cto-orchestrator-sequential]
verdict: APPROVE_WITH_CHANGES
confidence_gate: 8
---

# CTO Review — /cto P2-P5 Roadmap (2026-04-23, plan)

## Verdict

**APPROVE WITH CHANGES**

The four-phase roadmap is directionally sound — P2 (history-analyst) and P3 (skill-dispatch) compound well, P4 leverages P3 correctly, and P5 correctly defers Agent Teams to a measurement-gated decision. Three changes block straightforward approval: (1) P2 must ship with an evaluation harness, not just "wire into synthesis" — otherwise confidence scoring is performative; (2) P3's dispatch layer needs an explicit signed-skill / allowlist policy before P4 installs external skills; (3) P5 must define the measurement protocol up front, not "once out of experimental," because "out of experimental" is not a falsifiable trigger.

Individual phase verdicts: **P2 APPROVE_WITH_CHANGES**, **P3 APPROVE_WITH_CHANGES**, **P4 REJECT (in current form; re-approve after P3 hardens supply-chain policy)**, **P5 APPROVE_WITH_CHANGES**.

## Executive Summary

This is a plan review of a self-directed roadmap for the `/cto` skill. Phases decompose cleanly along the analyst→dispatch→delegation→coordination axis, and the order is correct (you must have dispatch before you install foreign skills, and you must have measurement before you migrate to Agent Teams). The two dominant risks are (a) the history-analyst becoming a 5th noise generator if its confidence scoring isn't calibrated against ground truth, and (b) the skill-dispatch layer becoming a supply-chain entry point if it installs arbitrary third-party skills without signing / pinning / review. Effort estimates are roughly right; P3 is under-estimated relative to the security work it actually requires if done properly.

**Findings:** 0 critical, 4 high, 3 medium, 2 low. 1 candidate (below confidence gate).

**Top 3 priorities:**
1. Define P2 evaluation harness (ground-truth fixtures + regression suite) before merging — HIGH
2. Block P4 until P3 ships an allowlist + manifest-hash pinning policy for installed skills — HIGH
3. Define P5 measurement protocol up front: token cost, coordination quality, cross-concern detection delta vs. subagent baseline — HIGH

**Quick wins available:** Yes — the P5 measurement protocol can be drafted in <1hr as an addition to `references/synthesis.md` and does not block P2/P3 work.

---

## Findings

### CRITICAL

_None._ No single phase, as described, creates immediate production outage risk or data loss — the skill runs locally, writes artifacts, and is not in any auto-implementation path.

### HIGH

| # | confidence | file:line | issue | recommendation | effort |
|---|---|---|---|---|---|
| 1 | 9/10 | P2 — history-analyst | Adding a 5th analyst without an evaluation harness converts confidence scoring from a gate into theater. The existing ≥8/10 gate in `references/synthesis.md:13` presumes analysts can self-assess accurately; history-analyst has no prior calibration. | Ship P2 with a `references/history-fixtures.md` containing ≥10 labeled archaeology findings (real CVEs / real bug patterns from git history) and a regression check: on each fixture, history-analyst must produce confidence ≥8 for true positives and ≤5 for curated false positives. Gate merge on ≥80% agreement. | MODERATE |
| 2 | 9/10 | P3 — skill-dispatch | Detecting "installed published skills" and delegating to them is the same attack surface as `npm install`: a malicious or typo-squatted skill runs with the CTO orchestrator's full tool budget. No allowlist or manifest-hash policy is described. | Before P3 ships, add to `references/dispatch-policy.md`: (a) explicit allowlist of skill names `/cto` will delegate to; (b) SHA-256 manifest pinning on first install; (c) drift detection — if a previously-allowed skill's manifest hash changes, require re-approval; (d) tool-capability whitelist — dispatched skills can only use the tools the parent `/cto` already holds. | SIGNIFICANT |
| 3 | 9/10 | P4 — Trail of Bits + pr-review-toolkit install | Installing three external skill packages and wiring them into P3 dispatch is the concrete supply-chain risk P3 was supposed to mitigate. If P3 ships without the policy above, P4 is net-negative: more surface, more dependencies, no defense. | Block P4 on completion of the P3 policy items (finding #2). Additionally: before install, run each third-party skill's YAML + prompt through a manual review; pin versions by commit SHA not tag; document the "why this skill" decision for each in `references/external-skills.md`. | SIGNIFICANT |
| 4 | 8/10 | P5 — Agent Teams re-evaluation | "Once it's out of experimental" is not a falsifiable trigger — Anthropic has left features "experimental" for >12 months before either promoting or removing them. Without a measurement protocol defined now, P5 becomes a backlog item that never fires, or fires reactively under cost pressure. | Define the measurement protocol in the current roadmap doc, not at P5 start: (a) baseline — run 3 swarm reviews on a reference project today, record token cost / findings / cross-concerns / duration; (b) P5 trigger — Agent Teams exits experimental _OR_ token cost of subagent swarms crosses a pre-stated threshold; (c) re-eval uses the same 3 reference projects; (d) decision gate — promote iff token delta ≤2x AND cross-concerns found ≥ subagent baseline. | MODERATE |

### MEDIUM

| # | confidence | file:line | issue | recommendation | effort |
|---|---|---|---|---|---|
| 5 | 9/10 | P2 — analyst count | Going from 4 to 5 analysts at `model: sonnet` raises token cost by ~25% on every swarm run. Sequential mode is unaffected, but swarm becomes costlier. The `AGENT-TEAMS-STRATEGY.md` "3-5 rule" sits at the boundary — 5 is the upper end. | Make history-analyst opt-in via mode gate: run automatically on `plan` / `full` reviews, skip on focused `security` / `performance` reviews where archaeology adds less value. Document this in the mode gate (Step 2 of SKILL.md). | QUICK_WIN |
| 6 | 8/10 | P3 — dispatch overhead | Every `/cto` run paying a discovery tax (scan installed skills, match triggers, compute delegation) even when no delegation happens. At ~50-200 tokens per scan this is small, but it's on every run, and the discovery output is not cached. | Cache the installed-skill manifest in `.cto/skill-manifest.json` with a short TTL (e.g., 1 day) or mtime-invalidation. Re-scan only when `~/.claude/skills/` mtime is newer than cache. | QUICK_WIN |
| 7 | 8/10 | P2/P3 boundary | P2 ships inline history-analyst. P3 ships skill-dispatch. If a published `history-analyst` skill exists or appears, P3 should delegate to it instead of running the inline version. The roadmap doesn't state which wins when both exist. | Add a tie-break rule to the dispatch policy: published skill wins over inline implementation, with a one-line provenance note in the artifact (`analysts: [... history-analyst@sha256:...]`). Falls out of P3 naturally but worth stating explicitly so P2's inline code isn't stranded. | QUICK_WIN |

### LOW

| # | confidence | file:line | issue | recommendation | effort |
|---|---|---|---|---|---|
| 8 | 8/10 | P2 — naming | "history-analyst" collides lightly with git-history search. "archaeology-analyst" or "code-history-analyst" would be more precise and harder to confuse with `git log` grep in instructions. | Rename to `archaeology-analyst`. | QUICK_WIN |
| 9 | 8/10 | P4 — three skills is a specific number | The roadmap says "2-3 Trail of Bits skills + Anthropic pr-review-toolkit" without naming them. Selection of 2 vs 3 should be driven by what's missing from existing lenses in `references/security.md` + `references/architecture-quality.md`, not a predetermined count. | List candidate ToB skills by name in P4 scope and justify each against current lens gaps. Installing skills that duplicate `references/security.md` coverage is waste. | QUICK_WIN |

---

## Candidates (below confidence gate)

| # | confidence | file:line | issue | why uncertain |
|---|---|---|---|---|
| C1 | 6/10 | P3 — mode-gate interaction | Skill dispatch may interact awkwardly with the deterministic mode gate in Step 2 of SKILL.md: if a third-party skill also claims "full review" triggers, which one runs? Ambiguous until dispatch rules are written. | Hypothesis not verified against an actual published skill's trigger YAML — need to see a real one before calling this a real issue. |

---

## Cross-Concern Correlations

| file | analysts | issue | elevation |
|---|---|---|---|
| P3 (skill-dispatch) | architecture + security | Dispatch layer is _both_ the architectural decomposition boundary AND the supply-chain trust boundary | HIGH confirmed — two lenses converge on the same root cause: this one layer is load-bearing for two different concerns and must be designed accordingly |
| P2 + P3 boundary | architecture + quality | Inline vs. published history-analyst — same capability, two implementations, no declared winner | MEDIUM confirmed — finding #7 |

---

## Emerging Patterns

| pattern | count | example files | recommendation |
|---|---|---|---|
| "ship feature first, harden later" | 3 | P2 (analyst without harness), P3 (dispatch without allowlist), P4 (install without review) | Each phase is shipping the happy path first and treating the guardrail as a follow-up. Invert: ship the guardrail as part of the same PR, not a later phase. |
| "measurement deferred" | 2 | P5 ("once out of experimental"), P2 (no ground-truth fixtures) | State measurement protocol at design time, not at promotion time. If you can't measure it now, you can't measure it later. |

---

## Fix Order (Dependency-Aware)

1. **Draft P5 measurement protocol** — unblocks: everything, because baseline numbers inform P2/P3 effort estimates. Do this first, it's <1hr.
2. **P2 with evaluation harness** (finding #1) — depends on: #1 (baseline understanding of current analyst accuracy).
3. **P3 with dispatch policy** (finding #2) — depends on: P2 shipped (so dispatch has a real inline analyst to compare against a published one).
4. **P4 third-party installs** (finding #3) — depends on: P3 policy complete AND per-skill justification written (finding #9).
5. **P5 Agent Teams re-eval** — depends on: Agent Teams graduating OR token-cost trigger firing AND baseline measurements from step 1.

Parallel-safe within phases: renames (finding #8), skill-manifest cache (finding #6), mode-gate skip of history-analyst on focused reviews (finding #5).

---

## Confidence Assessment

- **Overall confidence in findings:** 86% (weighted average of finding confidences)
- **Strongest evidence:** The supply-chain concern (P3/P4) is well-precedented — npm, PyPI, VS Code extension marketplace, MCP marketplace all show the same failure mode. The measurement concern (P5) is well-precedented in the existing `AGENT-TEAMS-STRATEGY.md` which already prescribes measurement-first migration.
- **What would change these recommendations:**
  - If a signed-skill / capability-scoped dispatch mechanism already exists in Claude Code (not just "trigger matching") → finding #2 downgrades to MEDIUM
  - If the roadmap already includes a P2 harness in an earlier doc I don't have context for → finding #1 downgrades to MEDIUM
  - If Agent Teams is known to exit experimental within 30 days → finding #4 downgrades to MEDIUM (the trigger becomes near-term and concrete)
- **Assumptions made:**
  - ⚠️ P2's "wired into synthesis" means only orchestrator changes, no new eval harness — the proposal didn't mention fixtures, so I assumed none planned
  - ⚠️ P3's "skill-dispatch" means invoking other skills via the Skill tool, inheriting tool budget — the proposal didn't describe sandboxing
  - ⚠️ P4's "2-3 ToB skills" are real skills on a public registry, not internal forks — if internal, supply-chain concern drops sharply
- **Known unknowns:**
  - Whether the Claude Code platform has any first-party skill-signing or capability-scoping primitives (if yes, P3 gets cheaper and safer)
  - Current per-run token cost of `/cto` swarm mode — the P5 delta calculation needs this number
  - Whether `/ultrareview` (already in the skill's Step 7 handoff) provides a cheaper substitute for some of what P4's third-party skills would do — may make some P4 installs redundant

---

## Prioritized Action Items

### Immediate (this week)

1. [ ] Draft P5 measurement protocol (≤1hr, addition to `references/synthesis.md` or new `references/measurement.md`) — baseline token cost, findings-per-run, cross-concern rate on 3 reference projects
2. [ ] Write P2 evaluation harness spec — fixture format, pass/fail criteria, regression gate — before any code

### Short-term (this month)

1. [ ] Ship P2 with harness + ≥10 labeled fixtures + passing regression — `archaeology-analyst` name, opt-in for focused reviews
2. [ ] Ship P3 with dispatch policy: allowlist + manifest pinning + drift detection + tool-capability whitelist + manifest cache
3. [ ] Document P2/P3 tie-break: published > inline

### Long-term (this quarter)

1. [ ] P4 after P3 policy review — per-skill justification against lens-coverage gaps, commit-SHA pinning, manual review of each external skill's YAML + prompts
2. [ ] P5 trigger watch — Agent Teams graduation OR token-cost threshold crossed, measured against baseline from step 1

---

## Technical Debt Register

| Item | Origin | Impact | Estimated Effort | Priority |
|---|---|---|---|---|
| No confidence-gate calibration data for existing 4 analysts | Pre-existing, highlighted by P2 | Without baseline, can't tell if P2 adds or subtracts signal | MODERATE | Should-have before P2 |
| No measurement protocol for swarm-mode cost | Pre-existing, highlighted by P5 | Every strategic migration decision (P5 and beyond) is blind | QUICK_WIN | Must-have before P5 |
| Mode gate at Step 2 doesn't interact with future dispatch | New debt added by P3 unless resolved | Ambiguous trigger resolution | QUICK_WIN | Must-have during P3 |

---

## Architecture Decision Records

### ADR-001: Analyst count and cost ceiling

**Status:** Proposed
**Context:** P2 raises analyst count from 4 to 5 at `model: sonnet`. `AGENT-TEAMS-STRATEGY.md` caps effective coordination at 3-5 teammates. Going above 5 in a future phase would cross a stated red line.
**Decision:** Cap swarm analyst count at 5. Any future analyst proposal must replace an existing one or be opt-in per mode, not additive.
**Consequences:** Keeps coordination quality and token cost bounded. Forces real trade-off discussions when new lens ideas surface.

### ADR-002: Skill-dispatch trust boundary

**Status:** Proposed
**Context:** P3 turns `/cto` into an orchestrator that invokes other skills. Other skills run with inherited tool budget. This is a trust boundary that the codebase doesn't currently have.
**Decision:** Dispatch only to skills on an explicit allowlist with pinned manifest hashes. Tool-capability whitelist per dispatched skill. Drift detection on manifest changes. No unrestricted discovery-and-invoke.
**Consequences:** P3 is more work than estimated — SIGNIFICANT not MODERATE. P4 is feasible (third-party skills pass through the same gate). `/cto` remains trustworthy as a pre-merge advisor.

### ADR-003: Measurement-first migration for P5

**Status:** Proposed
**Context:** Agent Teams migration is a large architectural change with variable token-cost implications (per `AGENT-TEAMS-STRATEGY.md` 2-3x multiplier in the wrong patterns, savings in the right ones). Deferring the decision to "once out of experimental" defers measurement too.
**Decision:** Baseline swarm-mode performance on 3 reference projects NOW. Re-measure on the same projects when P5 triggers. Decision gate: Agent Teams wins only if token delta ≤2x AND cross-concern detection ≥ subagent baseline.
**Consequences:** P5 becomes data-driven rather than vibes-driven. Trigger becomes concrete: either Agent Teams graduates, or subagent cost crosses a stated threshold, or the decision stays on hold indefinitely (which is fine).

---

## Analyst Notes

### cto-orchestrator (sequential mode)

Four lenses applied inline (no subagent spawn — single-area review per the mode gate):

- **Architecture:** Phases decompose cleanly. P2→P3→P4 is the correct order (analyst → dispatch → delegation). P5 is correctly at the end. Main concern: P3 is the architectural center of gravity — it's the trust boundary, the caching boundary, and the tie-break point between inline and published capability. Under-specified relative to its importance.
- **Security:** Supply-chain is the dominant concern. P3/P4 read like "install npm packages and run them" without the security work npm did (signatures, provenance, vulnerability scanning). Fail-open risk in dispatch: if signature check fails, does `/cto` skip the skill silently or refuse to run? Must be explicit.
- **Performance:** Analyst count bump (25% token increase per swarm run) is real but bounded. Dispatch overhead is trivial with caching. P5's dominant performance question (does Agent Teams cost more or less than subagents?) is unanswerable without baseline data.
- **Quality:** The roadmap has a recurring "ship the happy path, harden later" pattern across three of four phases. Calling it out as an emerging pattern above. Not a phase-level issue; a roadmap-level one.

Confidence scoring: most findings at 8-9/10 because they're about the plan-as-written, not about runtime code I haven't seen. The one 6/10 candidate (C1) is a genuine uncertainty about published-skill trigger semantics.

---

## Recommendations for follow-up skills

- `/architect` — if verdict stays APPROVE_WITH_CHANGES after the three blocker resolutions, `/architect` can implement P2 (with harness) as the first deliverable
- `/deep-plan` — P3's dispatch policy is worth a dedicated planning pass; "allowlist + manifest pinning + drift detection + tool-capability whitelist" is a design doc, not a ticket
- `/cto` re-review — after P3 ships, re-review P4 with the specific third-party skills named and their YAMLs in hand (this review was abstract because the skills aren't named yet)
- `/ultrareview` — not applicable here (nothing to merge), but worth remembering: some P4 third-party skills may overlap with `/ultrareview` coverage and become redundant
