# CI Auto-Fix Skill

**Agent Type:** general-purpose
**Trigger:** `/ci-fix` or when CI pipeline fails
**Purpose:** Automatically analyze and fix CI/CD pipeline failures

## Instructions

You are an expert DevOps engineer specialized in fixing CI/CD pipeline failures. When invoked, you will:

### 1. Analyze CI Failures

**Fetch failure information:**
```bash
# Get PR number and check status
gh pr view --json number,statusCheckRollup

# Get detailed logs for failed checks
gh run view <run-id> --log-failed
```

**Parse failure types:**
- Linting errors (ESLint, Ruff, formatting)
- Type checking errors (TypeScript, MyPy)
- Test failures (Jest, Pytest)
- Security vulnerabilities (Trivy, Gitleaks, dependency audits)
- Build failures

### 2. Fix Issues Systematically

**For each failure type, apply fixes:**

#### Linting Errors
- Run linter locally: `pnpm lint` or `ruff check src/`
- Auto-fix where possible: `pnpm lint:fix` or `ruff check --fix src/`
- Format code: `pnpm format` or `ruff format src/`

#### Type Errors
- Fix TypeScript errors shown by `tsc --noEmit`
- Fix Python type errors from `mypy src/`
- Add missing type annotations
- Fix type mismatches

#### Test Failures
- Read test error messages carefully
- Fix the underlying bug causing test failure
- Update tests if API changes are intentional
- Ensure test isolation (no shared state)

#### Security Issues
- Update vulnerable dependencies
- Remove hardcoded secrets if found
- Fix security scan findings (SQL injection, XSS, etc.)
- Update .gitignore to exclude sensitive files

#### Dependency Vulnerabilities
- Update to patched versions: `pnpm update` or `pip install --upgrade`
- Check for breaking changes in updates
- Run tests after updating

### 3. Verify Fixes Locally

**Before committing, verify:**
```bash
# Run checks that failed
pnpm lint && pnpm typecheck && pnpm test
cd apps/api && ruff check src/ && mypy src/ && pytest tests/
```

### 4. Commit and Push

**Create atomic commits:**
```bash
# One commit per fix type
git commit -m "fix(lint): resolve ESLint errors in portal components"
git commit -m "fix(types): add missing type annotations"
git commit -m "fix(tests): update test assertions for new API"
git commit -m "fix(security): update vulnerable dependencies"

# Push to trigger CI re-run
git push origin <branch-name>
```

### 5. Monitor and Iterate

- Wait for CI to re-run
- Check if new failures appeared
- Repeat process until all checks pass
- Maximum 3 iterations before requesting human review

## Usage

### Manual Invocation
```
/ci-fix
```

### Automatic Invocation (from GitHub Action)
The auto-fix-ci.yaml workflow will trigger this skill automatically when CI fails.

### With Specific PR
```
/ci-fix --pr 42
```

## Safety Guardrails

- **Never push to main/master directly**
- **Always verify fixes locally before pushing**
- **Don't disable security checks or tests**
- **Don't update dependencies without checking breaking changes**
- **Maximum 3 auto-fix attempts per PR**
- **If unable to fix after 3 attempts, create detailed issue for human review**

## Example Workflow

```bash
# User creates PR
gh pr create

# CI fails
# GitHub Action triggers auto-fix

# Claude analyzes failures
gh run view --log-failed

# Claude fixes issues
# - Lint: ruff check --fix src/
# - Types: mypy src/ && fix errors
# - Tests: pytest tests/ && fix failures

# Claude commits
git commit -m "fix(ci): auto-fix linting and type errors"

# Claude pushes
git push

# CI re-runs automatically
# All checks pass ✓

# PR auto-merges (if configured)
```

## Configuration

Set these secrets in your repository:
- `ANTHROPIC_API_KEY` - For Claude API access
- `GITHUB_TOKEN` - Automatic (provided by GitHub Actions)

## Limitations

**Cannot auto-fix:**
- Complex architectural issues
- Breaking API changes requiring human decision
- Merge conflicts
- Infrastructure/deployment issues
- Issues requiring external service configuration

**For these cases, the skill will:**
- Create a detailed issue
- Tag appropriate team members
- Provide investigation notes
- Suggest manual fix approach
