---
name: full-review
description: "Pre-merge multi-reviewer audit. Spawns 5 parallel reviewers (code-review-agent swarm, /cto subset, security-agent, performance-agent if perf-touching, convention-compliance) + opus aggregator. Use after `gh pr create`, before pushing, or when reviewing someone else's PR. Triggers on: full review, audit this PR, review pull request, pre-merge check, review my changes, ship gate."
argument-hint: "<pr-number> | uncommitted | <commit-range>"
user-invocable: true
context: fork
model: opus
effort: high
alwaysThinkingEnabled: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - Skill
  - AskUserQuestion
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: false
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
    outputFormat: structured
---

# /full-review — Pre-Merge Multi-Reviewer Audit

Pre-merge gate. Spawns up to 5 parallel reviewers, each with a different lens, then synthesizes findings with an opus aggregator. Output is a durable artifact at `.review/{pr-or-slug}-{date}.md` and a verdict: APPROVE / APPROVE_WITH_CHANGES / REQUEST_CHANGES / BLOCK.

Designed to run **after** `gh pr create` (per `auto_review_own_prs.md` policy) — the author has already shipped, this is the catch-net before merge. Also invocable manually for self-review before push (`/full-review uncommitted`) or for reviewing someone else's PR (`/full-review 715`).

## Why this exists

The author of a PR cannot reliably review their own work — they share context with the code and miss the same blind spots. `/full-review` brings independent reviewers, each with a disjoint lens, that the author cannot bias. Five lenses catch what one cannot.

This skill **does not replace `/review-changes`** (lighter pre-commit pass) or `/cto` (full architecture audit, broader scope). It sits between them: focused on the diff, but multi-perspective.

## Reasoning Sandwich (Opus 4.7 effort allocation per phase)

- **Phase 1 (Identify scope):** "Prioritize responding quickly. Parse args, pull diff."
- **Phase 2 (Plan reviewers):** "Think carefully. Decide which 4 of the 5 reviewers apply (perf is conditional on perf-touching files). Pre-compute shared context to avoid each reviewer re-reading the diff."
- **Phase 3 (Spawn reviewers):** Mechanical. All 5 in parallel in a single message.
- **Phase 4 (Aggregate):** "Think carefully and step-by-step. De-duplicate findings, resolve severity disagreements, identify cross-concern issues that no single reviewer caught (e.g., security says 'fail-open is intentional' but architecture says 'this assumes upstream validation that doesn't exist')."
- **Phase 5 (Auto-fix trivials):** "Prioritize responding quickly. Mechanical lint/import/format fixes only."
- **Phase 6 (Verdict + artifact):** "Prioritize responding quickly. Format."

---

## Phase 1 — Identify scope

Argument forms:

| Arg | Meaning |
|---|---|
| `<n>` (e.g. `/full-review 716`) | Review GitHub PR #n. Pull diff via `gh pr diff`. |
| `uncommitted` | Review current uncommitted + unpushed changes vs `origin/main`. |
| `<sha>..<sha>` | Review commit range (e.g. `HEAD~3..HEAD`). |
| (no arg) | Default to `uncommitted` if any uncommitted changes exist; else fail with usage hint. |

Resolve to:
- A diff string (`gh pr diff <n>` or `git diff origin/main...HEAD` or similar)
- A "slug" for the artifact filename (PR title or branch name, sanitized)
- The list of changed files
- The PR body if available (acceptance criteria, test plan)

## Phase 2 — Plan reviewers

Decide which reviewers run. **Always run 4. Run perf only if any of these patterns appear in the diff:**
- `*.sql`, `alembic/versions/*.py`, files in `models/`
- `select(...)` / `join(...)` / new ORM relationships
- `useEffect`, `useMemo`, `useCallback` additions
- Bundle-size-relevant imports (new heavy deps in package.json)
- Files in `apps/*/src/pages/` or `apps/*/src/routes/` (page-level perf)
- Files with `cache`, `memo`, `redis` in their path

Pre-compute shared context to inject into spawn prompts (saves N redundant reads):

1. **Project mission**: read `CLAUDE.md` once. Distill to ~100 tokens (project type, multi-tenancy model, non-goals).
2. **Conventions**: read top-level `apps/*/CLAUDE.md`. Distill another ~100 tokens.
3. **Diff summary**: file count by directory, lines added/removed by file type. Pass as a table.
4. **Recent related memory**: run `mem-search "<topic from PR title>" --limit 3`. Pass any high-relevance hits.

Total shared-context budget: ~500 tokens, compressed.

## Phase 3 — Spawn reviewers (parallel, single message)

Spawn 4 or 5 agents in **one message** (not sequential). Each gets:
- Shared context (~500 tokens)
- The full diff (no chunking — let each reviewer pick their files)
- Their lens-specific instructions (below)
- Their output schema (JSON for the aggregator)

### Reviewer 1: `code-review-agent` swarm (sonnet)

Spawn `subagent_type: code-review-agent` (the existing one at `~/.claude/agents/review/code-review-agent.md`). It internally fans out to 4-8 stack-specific specialists. **Do not duplicate its specialists in /full-review's reviewers — let it do its thing.** It owns: language conventions, type safety, accessibility, framework idioms.

### Reviewer 2: Security (sonnet)

Spawn `subagent_type: security-agent` with the diff. It owns: OWASP Top 10, fail-open patterns, secret leakage, auth/authz gaps, input validation, prompt injection if AI-touching, IDOR, RLS regressions.

Project-specific cues to feed it (Contably): "company-scoped RLS at ORM layer is fail-closed; any change that bypasses `company_access` Depends() is P0; JWT TTL is 15-60 min — short windows are the design, don't flag them."

### Reviewer 3: Architecture + correctness (sonnet)

`subagent_type: general-purpose, model: sonnet`. Spawn prompt:

> Lens: architecture and correctness. Read the diff [provided]. Look for: (a) coupling regressions — cross-module imports that violate boundaries; (b) duplication of logic that already exists elsewhere — grep for similar patterns before flagging "missing"; (c) error handling gaps — unhandled paths, swallowed exceptions, missing rollback; (d) missing-callers — if a function signature changed, find every call site; (e) test gaps — does the diff add code without adding tests, and are existing tests still valid?
>
> Output JSON: `{"findings": [{"severity": "P0|P1|P2", "file": "...", "line": N, "issue": "...", "fix": "..."}], "verdict": "APPROVE|REQUEST_CHANGES|BLOCK"}`. Be terse. Only flag P0 if blocking. Cap response at 800 words.

### Reviewer 4: Convention compliance (sonnet)

`subagent_type: general-purpose, model: sonnet`. Spawn prompt:

> Lens: project conventions. Read CLAUDE.md, apps/*/CLAUDE.md, and ~5 sibling files of each changed file. Compare the diff against established patterns. Look for:
> - Naming drift (variable_case, file naming, route paths)
> - Import ordering / unused imports (run `ruff check --select I,F`)
> - Frontend: Tailwind class ordering, component file structure, hook naming
> - Backend: Pydantic schema conventions, async/await consistency, dependency injection style
> - Migration filename format (per `apps/api/alembic/versions/NAMING.md`)
> - Documentation: docstrings on new public functions, type hints
> - Memory: any committed `*.bak`, `*.tmp`, `.DS_Store`, IDE files
>
> Output JSON same schema as Reviewer 3. Cap 600 words.

### Reviewer 5 (conditional): Performance (sonnet)

Skip unless Phase 2 perf-touching heuristic matched.

Spawn `subagent_type: performance-agent`. Project-specific cues: "Brazilian SaaS, multi-tenant, MySQL 8.4 + pgvector, Celery for async, FastAPI sync routes for hot path. N+1s in the 3-stage pipeline (raw→normalized→canonical) are the most common perf regression here."

### Spawn budget

5 sonnet agents in parallel, ~$0.10-0.15 each. Plus 1 opus aggregator at ~$0.15-0.30. Total per /full-review: **~$0.65-1.00**. Pierre's cap: this is fine ("acceptable" per skill-first design conversation).

## Phase 4 — Aggregate (opus)

Aggregator runs in the parent session (not a spawned agent — opus orchestrator already in context). Takes 5 JSON reports + the diff + shared context. Output:

1. **De-duplicated findings**, ranked by severity (P0 → P2). When two reviewers flag the same line, merge, keep the more specific finding.
2. **Cross-concern findings**: issues no single reviewer caught alone. E.g., security says "this trusts the input is sanitized" + architecture says "the sanitization callsite was removed in this same PR" → cross-concern P0.
3. **Severity reconciliation**: if reviewers disagree on severity, side with the higher one unless the lower-severity reviewer presents new evidence. Note disagreements explicitly.
4. **Verdict**:
   - **APPROVE**: zero P0/P1 findings, P2 only or none.
   - **APPROVE_WITH_CHANGES**: P1 findings exist but author can address them in a follow-up; nothing blocks merge.
   - **REQUEST_CHANGES**: P1 findings need fixing before merge.
   - **BLOCK**: any P0 finding.

## Phase 5 — Auto-fix trivials (optional, opt-in via `--fix` flag)

If the user passed `--fix`, after the aggregator runs, attempt auto-fix for these categories only:

- Lint (ruff `--fix`, eslint `--fix`)
- Import ordering (ruff I001)
- Trailing whitespace, EOL newline
- Trivially unused imports (F401)

**Do not auto-fix anything that touches logic.** Commit auto-fixes as a separate `chore(review): auto-fix lint/imports` commit. Re-run aggregator on the post-fix diff to confirm those findings are gone.

## Phase 6 — Verdict + artifact

Write `.review/{slug}-{YYYY-MM-DD}.md` with:

```markdown
# Review: {PR title or commit summary}

**Date:** {YYYY-MM-DD HH:MM} UTC
**Diff:** {n} files, +{add}/-{del}
**Reviewers ran:** code-review-agent, security, architecture, conventions[, performance]
**Verdict:** {APPROVE | APPROVE_WITH_CHANGES | REQUEST_CHANGES | BLOCK}

## Summary
{1-2 sentence top-line.}

## Findings

### P0 (blocks merge)
- [{file}:{line}] {issue} → {fix}

### P1 (must fix before merge)
- ...

### P2 (informational)
- ...

## Cross-concern findings
- {issue}: {reviewer A said X; reviewer B said Y; combined this is {severity}}

## Severity disagreements
- {file:line}: security said P1, conventions said P2 → kept P1 because {reason}

## What was checked
- code-review-agent (subagent): {short verdict}
- security: {short verdict}
- architecture: {short verdict}
- conventions: {short verdict}
- performance: {short verdict or "skipped — no perf-touching files"}

## Auto-fixes applied (if --fix)
- {commit sha}: {what was fixed}
```

Then post a chat summary back to the user — short, scannable.

If invoked from CI (Layer 2), also post the artifact's findings as a PR comment via `gh pr comment`.

## Failure modes to handle

- **PR has 1000+ files** (e.g. mass rename). Skip and tell the user to chunk it. Not a sensible target.
- **Diff includes binary files** (e.g. images). Reviewers ignore those.
- **One reviewer crashes**: continue with the others, note in the artifact ("performance reviewer failed: {error}").
- **All reviewers approve but you have a gut feeling**: this is fine. The verdict is APPROVE. Do not invent findings.
- **Author is /full-review itself recursively** (e.g. if /ship invokes /full-review): keep going. The check should not infinite-loop because aggregator runs in parent context, not spawned.

## When NOT to invoke

- Trivial 1-line changes (typo, version bump). Use `/review-changes` or skip.
- PRs already reviewed in the last 24h with the same diff hash. Check `.review/` first.
- Doc-only PRs that don't touch CLAUDE.md or roadmap. `/review-changes` is enough.

## Notes

- Default model is opus (orchestrator + aggregator). All spawned reviewers are sonnet — they're bounded scope and don't need opus reasoning.
- This skill is **the** auto-review entrypoint. CI Layer 2 (pr-review.yml) calls it via `claude -p --bare /full-review <pr-num>`.
- Artifact directory `.review/` is gitignored by convention — add to root `.gitignore` if not already.
- For full architecture/security audits beyond the diff, escalate to `/cto`.
