# /cto — Architecture & Quality Lenses Reference

Two analyst roles share this file because they inspect overlapping concerns (component boundaries, testing, conventions) and are the cheapest to keep together.

---

## Architecture analyst

### File ownership

Owns: `{src_dirs}` structure (not their internals — that's for the owning analyst), directory layout, module boundaries, API layer design. Do NOT deep-read files in `{auth_dirs}` (security), `{db_dirs}` (performance), or `{test_dirs}` (quality).

### Checklist

- Component boundaries — are modules cohesive? Do they expose clean interfaces?
- Dependency graph — circular dependencies, god modules, cross-cutting concerns bleeding through layers.
- API layer design — REST conventions, versioning strategy, OpenAPI/contract coverage.
- Data flow — where state lives, where it mutates, whether boundaries between client/server/DB are enforced.
- Separation of concerns — presentation vs business logic vs data access. Flag when they're mixed in one file.
- Scalability readiness — does the current layout handle 10x the current load without a rewrite? If not, what's the first thing that breaks?
- Multi-perspective investigation for major decisions:
  - Primary analysis (direct codebase evidence)
  - Literature review (established patterns and best practices via WebSearch)
  - Expert consensus (what domain experts recommend)
  - Contrarian view (what could go wrong, who disagrees and why)

### Output format

```
severity | file:line | issue | recommendation
```

Write findings to `.cto/review-{date}-{slug}.md` under `## Architecture`. Message security-analyst if you find auth design flaws. Message performance-analyst if you find patterns that imply bad query shapes.

### Inline commands

```bash
# Main source directories
find . -type d \( -name "src" -o -name "app" -o -name "lib" -o -name "components" \) 2>/dev/null | head -10

# Import / dependency overview
grep -r "import.*from" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | head -50

# Large files (potential god objects)
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" \) \
  ! -path '*/node_modules/*' -exec wc -l {} \; 2>/dev/null | sort -rn | head -20
```

### Patterns to flag

- Circular dependencies
- God components / modules (>500 lines with >10 exports)
- Mixed presentation + business logic + data access in a single file
- API layer that leaks DB schema into responses
- Database access happening outside a data-access layer (DAL)

---

## Quality analyst

### File ownership

Owns: `{test_dirs}`, linter/formatter configs, CI configs (`.github/workflows/*`, `.gitlab-ci.yml`), dependency version currency, `AGENTS.md` / `CLAUDE.md` / `CONVENTIONS.md` alignment.

### Checklist

- **Test coverage** — ratio of test files to source files, whether critical paths have tests (not just "is there a tests/ directory").
- **Code complexity** — cyclomatic complexity outliers, deep nesting, functions >50 lines.
- **Tech debt markers** — `TODO` / `FIXME` / `HACK` / `XXX` comments, especially on security-critical paths.
- **Dead code** — unused exports, commented-out blocks, feature flags that are never toggled.
- **Naming conventions** — consistency across modules. Flag when a codebase mixes `snake_case` and `camelCase` inconsistently.
- **Error handling patterns** — swallowed errors, `try/catch` with no-op catch, unhandled promise rejections.
- **Logging** — structured vs ad-hoc, PII leakage into logs.
- **Type safety** — `any` / `unknown` in TypeScript without justification, disabled linter rules without justification.
- **Framework version currency** — major versions behind, deprecated package usage, known-vulnerable ranges.
- **Migration paths** — if the framework recommends a new pattern (Next.js App Router over Pages, React 19 over 18), is the project stuck on the old pattern?

### Anti-patterns to enforce

- Unnecessary comments and JSDoc that add no value
- `any` / `unknown` types without justification
- Disabled linter rules without justification
- Missing `tsc --noEmit` in the pre-commit / CI pipeline

### Output format

```
severity | file:line | issue | recommendation
```

Write findings to `.cto/review-{date}-{slug}.md` under `## Quality`. Message architecture-analyst if you find systemic patterns (3+ files with the same anti-pattern — that's an architecture concern, not a quality one). Message security-analyst if deprecated/vulnerable dependencies are found.

### Inline commands

```bash
# TODO/FIXME/HACK
grep -rn "TODO\|FIXME\|HACK\|XXX" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" 2>/dev/null | head -20

# Test vs source ratio
test_count=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.py" \) ! -path '*/node_modules/*' | wc -l)
src_count=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" \) ! -path '*/node_modules/*' ! -name "*.test.*" ! -name "*.spec.*" | wc -l)
echo "tests: $test_count / src: $src_count"

# Disabled eslint rules
grep -rn "eslint-disable" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | head -20

# `any` / `unknown` usage
grep -rn ": any\|: unknown" --include="*.ts" --include="*.tsx" 2>/dev/null | head -20

# Deprecated / outdated deps (project-specific)
[ -f package.json ] && pnpm outdated 2>/dev/null | head -30
[ -f package.json ] && npm outdated 2>/dev/null | head -30
[ -f pyproject.toml ] && pip list --outdated 2>/dev/null | head -30
```

---

## Tech Stack Evaluation Matrix

When evaluating technology choices as part of an architecture review:

| Criterion | Weight | Description |
|---|---|---|
| **Fit** | 25% | Solves the specific problem well |
| **Maturity** | 20% | Production-ready, active community |
| **Team Fit** | 20% | Team can learn/use effectively |
| **Scalability** | 15% | Handles growth requirements |
| **Ecosystem** | 10% | Libraries, tools, integrations |
| **Cost** | 10% | Licensing, hosting, operations |

### Scoring Template

| Option | Fit | Maturity | Team | Scale | Ecosystem | Cost | **Score** |
|---|---|---|---|---|---|---|---|
| [Option A] | /10 | /10 | /10 | /10 | /10 | /10 | [Weighted] |
