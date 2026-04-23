# /cto — Archaeology Analyst Spec

Fifth analyst in the swarm. Runs code-archaeology (Glasswing-style deep vulnerability hunting + bug-archaeology on unchanged code) as a dedicated lens rather than a buried section inside `security.md`.

Specification only — not yet wired into Step 4 of `SKILL.md`. Wiring is gated on the evaluation harness in this document being populated with ≥10 labeled fixtures and passing the regression check.

Per self-review finding #1 (2026-04-23): ship with a harness, not as bare analyst. Without calibration, confidence scoring on a new analyst is theater.

---

## When it runs

Archaeology is slow and expensive — it reads `git log`, `git blame`, commit messages, PR descriptions, and traces trust boundaries across versions. It earns its keep on full reviews but is pure overhead on focused ones.

| Mode / Scope | Run archaeology-analyst? |
|---|---|
| `full` (full codebase review) | Yes |
| `plan` (plan review before `/architect`) | Yes if plan modifies security-critical or long-lived code |
| `incident` (infrastructure diagnosis) | Yes — "what changed recently vs what's been there for years" is the first question |
| `security` (focused security audit) | Yes — archaeology IS the deep-security lens |
| `performance` (focused performance review) | No — archaeology adds little to perf analysis |
| `architecture` (focused architecture review) | Optional — useful for understanding module-ownership history, but not required |
| `quality` (focused quality review) | No |

**Rule:** run by default for `full`, `plan`, `incident`, `security`; skip by default for others; the mode gate in SKILL.md Step 2 applies this.

This keeps swarm analyst count at **4 for most runs, 5 for deep runs** — staying within the AGENT-TEAMS-STRATEGY "3-5 rule" and bounding the 25% cost increase to cases where it's justified.

---

## File ownership

Owns: `.git/` (via `git log`, `git blame`, `git show`), commit messages, PR descriptions (via `gh pr list` if GitHub CLI available), and all source files for read-only history analysis. Does NOT perform static pattern-matching on current code — that's the security-analyst's job. This analyst's job is **time**.

### Where there's overlap with security-analyst

Today `references/security.md` has a Code Archaeology section (Phases 1-4). That section stays there for sequential mode — when someone runs `/cto security`, they get archaeology folded into the one lens. In swarm mode with archaeology-analyst present, the boundary is:

- **security-analyst**: current code, current patterns, current configs.
- **archaeology-analyst**: time dimension — what changed, when, by whom, what got quiet, what was abandoned.

Cross-concern flag when both analysts flag the same file: elevate severity one level (already the rule in `references/synthesis.md`).

---

## Checklist

Inherits the four phases from `references/security.md` Code Archaeology section, but applies them as the analyst's primary lens rather than a subsection:

### Phase 1 — Identify high-value targets

- `git log --format='%H %ai %s' --diff-filter=M -- {file}` on security-critical paths (auth, crypto, parsers, serializers, FFI, middleware, session mgmt).
- Flag files with no meaningful change in 2+ years in security-critical paths.
- Identify load-bearing code: functions with many call sites but few modifications.
- `git blame` for functions whose original author is no longer active in the repo (abandoned ownership).

### Phase 2 — Trace trust boundaries across time

- For each target file: what enters from outside? What exits to a privileged context? Where does the code assume input is already validated?
- Map the trust gradient: user input → validation → business logic → data store. Check for gradient transitions where one layer trusts another to have already validated.
- Check functions that were secure when written but became vulnerable because callers added later pass different input shapes (API evolution drift).

### Phase 3 — Pattern-specific hunting (time-shifted)

Standard list from `references/security.md` — integer overflow, UAF, FFI boundary trust, parser edge cases, type coercion, state machine violations, race conditions, deserialization sinks — but filtered to **patterns that were safe at introduction and became unsafe through evolution**:

- Function added in 2022 that only handled signed input; unsigned path added in 2024 → check for overflow.
- Auth middleware written when only 1 role existed; N roles added later → check for authorization gaps.
- Parser written for ASCII input; UTF-8 support added later → check for encoding confusion.

### Phase 4 — Contextual analysis

- Read the COMMIT MESSAGE and PR description for security-critical changes. Understand intent, then check if the implementation matches.
- Error paths — the happy path is reviewed; the error/exception path is where auth state leaks, partial writes corrupt data, and cleanup skips.
- "Defensive code that doesn't defend" — try/catch blocks around auth that return default-allow on exception; validation functions that log-and-continue; middleware that calls `next()` in both success and error branches.
- Cross-function invariant violations: function A assumes B validates input; B assumes A validates input; neither actually validates. Trace the chain.

### Priority for archaeology findings

Trust-boundary violations in code unchanged 2+ years → **CRITICAL** minimum. Per `references/security.md`. Same bar applies here.

---

## Output format

```
severity | file:line | CWE | confidence (/10) | age (years unchanged) | issue | recommendation
```

The extra **age** column is archaeology-specific — signals how long this specific pattern has been latent. Important for prioritization: a CRITICAL unchanged 6 years is less likely to be exploited today than one introduced last month, but far more embarrassing when it is.

Write findings to `.cto/raw/archaeology.md` during swarm runs. Message the lead with CRITICAL findings immediately.

---

## Evaluation harness

**Blocks merge of this analyst into Step 4 of SKILL.md.** Cannot wire the analyst into the swarm until this section has content that passes.

### Fixture format

Each fixture lives in `references/fixtures/archaeology/{NNN}-{slug}.md` and has the shape:

```markdown
---
id: "001"
slug: "log4shell-style-deserialization-in-old-logger"
introduced_commit: "abc1234"
introduced_date: "2018-06-15"
vuln_type: "unsafe-deserialization"
cwe: "CWE-502"
ground_truth_confidence: 10
ground_truth_severity: "CRITICAL"
ground_truth_age_years: 5
---

## Setup

Minimal repro — a small code snippet + a git history that reproduces the pattern. Either:
- A real public CVE with a repo link at the vulnerable commit, OR
- A synthetic fixture committed to a dedicated fixture repo with known history.

## Expected analyst output

The archaeology-analyst should produce:
- confidence: ≥ {ground_truth_confidence - 1}
- severity: {ground_truth_severity}
- age: approximately {ground_truth_age_years} years (±1)
- file:line referencing the actual vulnerable line

## Known false-positive trap

If the fixture includes code that LOOKS like the vulnerability but isn't (e.g., deserialization on trusted server-side input), the analyst must NOT flag it. Record the FP trap here explicitly so regressions show up.
```

### Required fixtures

At least **10 labeled fixtures** covering:

| Category | Minimum count | Source |
|---|---|---|
| Real CVEs in code-archaeology's sweet spot (unchanged code with latent bugs) | 5 | public CVE database — log4shell, ShellShock, HeartBleed-style old-code-quietly-broken issues |
| Synthetic fixtures for pattern-specific Phase 3 checks | 3 | hand-crafted, committed to a fixture repo with real git history |
| Known false-positive traps (look like archaeology wins but aren't) | 2 | code that's been unchanged for years but is NOT vulnerable, often because surrounding validation covers it |

Total: 10 minimum, 15-20 ideal.

### Regression gate

Before merging `archaeology-analyst` into Step 4 of SKILL.md:

1. Run the analyst against every fixture.
2. Record results in `references/fixtures/archaeology/_results.md`:
   - True positive: confidence ≥8 on a real fixture → ✓
   - False positive: confidence ≥8 on a false-positive-trap fixture → ✗
   - False negative: confidence <5 on a real fixture → ✗
3. Gate: **≥80% agreement** (8 of 10, or 12 of 15).
4. For any failure, either (a) adjust the analyst's prompt / reference content in `references/security.md` Code Archaeology section, or (b) re-categorize the fixture with justification. Don't lower the gate silently.

### Periodic re-calibration

After every 10 real `/cto` swarm runs that include archaeology-analyst:

1. Pick 3 archaeology findings that the user acted on.
2. Check: were they true positives? (Did `/architect` actually fix them? Did the fix turn out to be load-bearing?)
3. Pick 3 archaeology findings that the user dismissed.
4. Check: were they true false positives? (Did the user's dismissal hold up, or was there a later incident?)
5. Append to `references/fixtures/archaeology/_calibration-log.md` with one-line verdicts.
6. If TP rate drops below 70%, re-read the analyst prompt, look for noise patterns, tighten the checklist.

---

## Current status

**Analyst spec:** defined (this file).

**Evaluation harness:** NOT populated. `references/fixtures/archaeology/` is empty. Merging this analyst into Step 4 of SKILL.md is blocked until the harness has ≥10 fixtures with passing regression.

**Expected effort to populate harness:** MODERATE (4-8 hours). Most of the effort is finding real CVEs with accessible pre-patch commits; the synthetic fixtures are faster to craft.

**Gating:** do NOT add `archaeology-analyst` to Step 4 swarm spawn in SKILL.md until this block reads "Evaluation harness: populated, last regression passed {date}."

---

## Timeline (append-only)

- **2026-04-23** — [design] Archaeology-analyst spec written per self-review finding #1. Renamed from "history-analyst" per finding #8. Opt-in mode gate per finding #5. Harness gating per finding #1. Source: `.cto/review-2026-04-23-cto-p2-p5-roadmap.md`.
