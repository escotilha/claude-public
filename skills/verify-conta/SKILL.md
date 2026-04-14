---
name: verify-conta
description: "Full Contably verification suite: ruff, mypy, pytest (unit+integration), tsc, eslint, vite/next build, vitest, gitleaks. Parallel execution. Triggers on: verify conta, contably verify, full verify, run all tests, test everything, contably tests."
argument-hint: "[layer: lint|types|tests|build|security|all] [--fix]"
user-invocable: true
context: fork
model: sonnet
effort: medium
maxTurns: 50
allowed-tools:
  - Agent
  - Bash
  - Read
  - Edit
  - Glob
  - Grep
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - AskUserQuestion
tool-annotations:
  Bash: { readOnlyHint: true, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
    outputFormat: structured
---

# Verify Conta — Full Contably Verification Suite

Run every verification layer available in the Contably monorepo. Parallel where possible, sequential where dependencies exist.

## Codebase Layout

```
/Volumes/AI/Code/contably/
├── apps/
│   ├── api/              # FastAPI (Python 3.12)
│   │   ├── src/          # Source code
│   │   ├── tests/
│   │   │   ├── unit/     # 66+ test files, pytest
│   │   │   └── integration/ # 6 test files, needs DB
│   │   ├── pytest.ini
│   │   └── requirements.txt
│   ├── admin/            # React + Vite + TypeScript
│   │   ├── src/**/*.test.{ts,tsx}  # 30 vitest files
│   │   └── package.json
│   ├── client-portal/    # Next.js + TypeScript
│   │   └── package.json
│   └── mobile/           # (future)
├── package.json          # Turborepo root
├── pyproject.toml        # Python config (ruff, mypy, pytest)
└── pnpm-workspace.yaml
```

## Verification Layers

There are **9 layers** organized in 3 parallel tracks:

```
TRACK A: Backend (Python)         TRACK B: Frontend (TypeScript)    TRACK C: Security
┌─────────────────────────┐      ┌──────────────────────────┐     ┌────────────────┐
│ L1: ruff check src/     │      │ L5: pnpm typecheck       │     │ L9: gitleaks   │
│ L2: mypy src/            │      │ L6: pnpm lint            │     └────────────────┘
│ L3: pytest tests/unit/   │      │ L7: pnpm build           │
│ L4: pytest tests/integ/  │      │ L8: vitest (admin+portal)│
└─────────────────────────┘      └──────────────────────────┘
```

Tracks A, B, and C are **fully independent** — run them in parallel.

Within each track:

- **Track A**: L1 and L2 are independent. L3 depends on nothing. L4 needs a DB (skip if unavailable).
- **Track B**: L5 runs first (fastest). L6 is independent. L7 depends on L5 passing. L8 is independent.
- **Track C**: Single step, always runs.

## Execution Plan

### Phase 1 — Parallel Blast (all independent checks)

Launch **5 parallel agents** (all haiku — these are mechanical):

| Agent         | Layer | Command                                                        | Working Dir | Timeout |
| ------------- | ----- | -------------------------------------------------------------- | ----------- | ------- |
| `ruff`        | L1    | `ruff check src/`                                              | `apps/api`  | 30s     |
| `mypy`        | L2    | `mypy src/ --ignore-missing-imports`                           | `apps/api`  | 120s    |
| `pytest-unit` | L3    | `python3 -m pytest tests/unit/ -q --tb=short`                  | `apps/api`  | 120s    |
| `tsc`         | L5    | `pnpm typecheck`                                               | root        | 120s    |
| `gitleaks`    | L9    | `gitleaks detect --source . --no-git --verbose 2>&1 \|\| true` | root        | 60s     |

### Phase 2 — Parallel Follow-ups

After Phase 1 completes, launch:

| Agent           | Layer | Command                                                             | Condition                                              |
| --------------- | ----- | ------------------------------------------------------------------- | ------------------------------------------------------ |
| `eslint`        | L6    | `pnpm lint`                                                         | Always                                                 |
| `build`         | L7    | `pnpm build`                                                        | Always (even if tsc failed — catches different issues) |
| `vitest-admin`  | L8a   | `cd apps/admin && pnpm test:run`                                    | Always                                                 |
| `vitest-portal` | L8b   | `cd apps/client-portal && pnpm test`                                | Always                                                 |
| `pytest-integ`  | L4    | `cd apps/api && python3 -m pytest tests/integration/ -q --tb=short` | Only if `--with-integration` flag or DB is available   |

### Phase 3 — Report

Produce a summary table:

```
┌──────────────────────────────────────────────────────────┐
│                CONTABLY VERIFICATION REPORT               │
├──────────┬────────┬──────────────────────────────────────┤
│ Layer    │ Status │ Details                              │
├──────────┼────────┼──────────────────────────────────────┤
│ Ruff     │ PASS   │ 0 errors                             │
│ Mypy     │ WARN   │ 1695 errors (pre-existing, continue) │
│ Unit     │ PASS   │ 220 passed, 0 failed, 0.4s           │
│ Integ    │ SKIP   │ No DB available                      │
│ TSC      │ PASS   │ admin + client-portal clean           │
│ ESLint   │ WARN   │ client-portal ajv crash (known)       │
│ Build    │ PASS   │ admin + client-portal built            │
│ Vitest   │ PASS   │ admin: 30 passed, portal: 0           │
│ Gitleaks │ PASS   │ No secrets detected                   │
├──────────┼────────┼──────────────────────────────────────┤
│ OVERALL  │ PASS   │ 7/9 passed, 2 known warnings          │
└──────────┴────────┴──────────────────────────────────────┘
```

## Known Issues (don't fail on these)

These are pre-existing and tracked — mark as WARN, not FAIL:

| Layer      | Issue                                           | Tracking                      |
| ---------- | ----------------------------------------------- | ----------------------------- |
| Mypy       | 1,695 pre-existing type errors                  | CI: `continue-on-error: true` |
| ESLint     | client-portal ajv crash                         | CI: `continue-on-error: true` |
| Unit tests | 1 flaky MFA test (`test_code_format_xxxx_xxxx`) | CI: `continue-on-error: true` |

## Arguments

```
/verify-conta                    # Full suite (all 9 layers)
/verify-conta lint               # L1 (ruff) + L6 (eslint) only
/verify-conta types              # L2 (mypy) + L5 (tsc) only
/verify-conta tests              # L3 (unit) + L4 (integ) + L8 (vitest) only
/verify-conta build              # L7 (build) only
/verify-conta security           # L9 (gitleaks) only
/verify-conta backend            # L1-L4 only
/verify-conta frontend           # L5-L8 only
/verify-conta --fix              # Run full suite, then auto-fix lint/type errors
/verify-conta --with-integration # Include integration tests (L4)
```

## --fix Mode

When `--fix` is passed, after the report:

1. **Ruff auto-fix**: `ruff check src/ --fix` (safe, deterministic)
2. **ESLint auto-fix**: `pnpm lint -- --fix` (safe, deterministic)
3. Do NOT auto-fix mypy errors (too many, requires judgment)
4. Do NOT auto-fix test failures (requires investigation)
5. After fixes, re-run only the layers that had fixable issues to confirm

## Model Tiering

| Task                                 | Model            | Rationale                              |
| ------------------------------------ | ---------------- | -------------------------------------- |
| Running any verification command     | **haiku**        | Mechanical: run command, report output |
| Analyzing failures / proposing fixes | **sonnet**       | Needs code understanding               |
| Orchestration + report synthesis     | **sonnet** (you) | Cross-layer reasoning                  |

## Rules

1. **Parallel-first**: always launch independent checks simultaneously
2. **Never modify code** unless `--fix` flag is set
3. **Pre-existing issues are WARN, not FAIL** — consult the Known Issues table
4. **New failures are FAIL** — anything not in Known Issues
5. **Report every layer** even if it passes — the user wants the full picture
6. **Exit codes matter**: 0 = pass, non-zero = fail. Some tools return non-zero for warnings — handle accordingly
7. **Timeout protection**: kill any check that exceeds its timeout, mark as TIMEOUT
8. Environment setup: backend checks need `cd apps/api` and the venv active. Frontend checks need `pnpm` available at root.
