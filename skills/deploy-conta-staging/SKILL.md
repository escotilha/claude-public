---
name: deploy-conta-staging
description: "Deploy Contably to OCI staging. Verify → guardian → push → CI → deploy → health check. Auto-fixes. Triggers on: deploy conta staging, deploy staging, push to staging, staging deploy."
argument-hint: "[--skip-guardian] [--skip-verify] [--review|--skip-review]"
user-invocable: true
context: fork
model: opus
effort: high
skills: [verify, contably-guardian, oci-health, contably-snapshot]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - Skill
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - AskUserQuestion
memory: user
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: true, openWorldHint: true }
  Read: { readOnlyHint: true, idempotentHint: true }
  Glob: { readOnlyHint: true, idempotentHint: true }
  Grep: { readOnlyHint: true, idempotentHint: true }
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

# Deploy Staging — Contably OCI

Deploys Contably to the staging environment via GitHub Actions. Push to main triggers GHA deploy to the `contably-staging` namespace. Staging serves at staging.contably.ai.

To promote staging to production, use `/deploy-conta-production` which triggers the `deploy-production.yml` workflow_dispatch with the staging image tag.

## Arguments

- `--skip-guardian` — skip the /contably-guardian pre-deploy check
- `--skip-verify` — skip the /verify type-check/lint/build step
- `--review` — force /ultrareview multi-reviewer code review (runs regardless of diff size)
- `--skip-review` — explicitly skip /ultrareview (default when diff is small or docs-only)

## Infrastructure Context

- **OCI Region:** `sa-saopaulo-1`
- **OCIR Registry:** `sa-saopaulo-1.ocir.io/gr5ovmlswwos`
- **K8s Namespace:** `contably-staging`
- **OKE Cluster OCID:** `ocid1.cluster.oc1.sa-saopaulo-1.aaaaaaaarqeang2k3wo452nek7zaw5ufjtdmaqxupo6m2zgofckxzb7tcsvq`
- **Git Remote:** `origin` → `https://github.com/Contably/contably.git`
- **Main Branch:** `main`
- **Staging URLs:**
  - API: `https://staging-api.contably.ai`
  - Dashboard: `https://staging.contably.ai`
  - Portal: `https://staging-portal.contably.ai`

### GitHub Actions Pipeline

```
git push origin main
    ↓ (webhook)
CI Workflow (.github/workflows/ci.yml)
  → Frontend CI (typecheck, lint, build) — parallel
  → Backend lint (ruff) — parallel
  → Security scan (gitleaks + trivy) — parallel
    ↓ (on success)
Deploy Workflow (.github/workflows/deploy.yml)
  → Build 3 images (Buildx + GHA cache) → push to OCIR
  → kubectl set image → rollout restart → wait → alembic migrate
  → Health check (api.contably.ai/health)
```

### GitHub CLI Commands Reference

```bash
# List recent workflow runs
unset GITHUB_TOKEN && gh run list --repo Contably/contably --limit 5

# Watch a run in real-time
unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably

# View run details and logs
unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --log

# Check job-level status
unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
```

## Workflow

### Phase 0: Detect State

1. Detect current state:

   ```bash
   git status --short                    # Uncommitted changes?
   git log --oneline -1                  # Current HEAD
   git log --oneline origin/main..HEAD   # Unpushed commits?
   ```

2. If there are uncommitted changes, ask the user: "There are uncommitted changes. Should I commit them first?" If yes, stage and commit with a conventional commit message.

### Phase 1: Local Verification Loop (auto-fix until clean)

**Goal:** Ensure the code passes all local checks before pushing. Loop up to 3 times.

1. **Run /verify** (unless `--skip-verify`):
   - Invoke the `verify` skill via the Skill tool
   - If FAIL: invoke the `test-and-fix` skill to auto-fix
   - Re-run /verify after fixes
   - If still failing after 3 iterations, ask the user whether to proceed or abort

2. **Run /ultrareview** (optional, diff-gated):
   - **Skip** if `--skip-review` is passed, OR if diff is trivial: `git diff origin/main...HEAD --shortstat` shows < 20 lines changed, OR only touches `*.md` / `docs/**`
   - **Run** if `--review` is passed, OR if the diff is non-trivial (≥20 LOC or touches `apps/api/src/`, `apps/admin/src/`, `apps/client-portal/src/`, `alembic/versions/`, or `infrastructure/`)
   - Invoke `/ultrareview` via the Skill tool. This spawns parallel cloud reviewers (security, performance, architecture, quality) on the uncommitted + unpushed diff against `origin/main`
   - If reviewers flag CRITICAL issues: attempt auto-fix with Edit tool, then re-run /ultrareview (max 2 iterations)
   - If reviewers return only warnings/suggestions: log them in the final report and proceed
   - If /ultrareview is unavailable in this Claude Code version: skip silently with a log note

3. **Run /contably-guardian** (unless `--skip-guardian`):
   - Invoke the `contably-guardian` skill via the Skill tool
   - If `DEPLOY BLOCKED`: analyze the blocking issues
     - For code-level issues (CHECK 1-5): attempt auto-fix using Edit tool, then re-run guardian
     - For infra issues (Layer 2): report to user — these typically need manual intervention
     - For runtime issues (Layer 3): skip if staging is unreachable (will be checked post-deploy)
   - If `DEPLOY APPROVED` or `DEPLOY APPROVED WITH WARNINGS`: proceed

4. **Run /review-changes** on any auto-fix commits:
   - If fixes were applied, invoke `review-changes` skill to validate the fixes don't introduce new issues
   - If review finds CRITICAL issues, fix and re-review (max 2 iterations)

5. After all checks pass, commit any fix changes:
   ```
   fix(deploy): auto-fix {summary of what was fixed}
   ```

### Phase 2: Push to Trigger GitHub Actions

1. Push to main:

   ```bash
   unset GITHUB_TOKEN && git push origin main
   ```

2. Record the commit SHA for tracking:

   ```bash
   IMAGE_TAG=$(git rev-parse --short HEAD)
   ```

3. Report to user:
   ```
   Pushed {commit_sha} to origin/main. GitHub Actions deploy workflow will trigger.
   IMAGE_TAG: {IMAGE_TAG}
   ```

### Phase 3: Monitor GitHub Actions Pipeline

The GHA deploy workflow triggers immediately on push to main. It runs CI first, then builds images, then deploys.

1. **Find the workflow run:**

   ```bash
   unset GITHUB_TOKEN && gh run list --repo Contably/contably --limit 1
   ```

   The most recent run should match your commit.

2. **Watch the run in background** (use `run_in_background: true`):

   ```bash
   unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably --exit-status
   ```

3. **On completion, check job-level results:**

   ```bash
   unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
   ```

   Expected jobs: `ci / Frontend CI`, `ci / Backend CI`, `ci / Security Scan`, `Build & Push Images`, `Deploy to OKE`

4. **If any job failed**, get the logs:

   ```bash
   unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --log 2>&1 | grep -B2 -A10 "error\|Error\|FAILED\|exit code"
   ```

   Then proceed to Phase 3a.

### Phase 3a: CI Failure Recovery (auto-fix loop)

If the GitHub Actions pipeline fails:

1. Parse the failure from the logs (see Phase 3 step 4).

2. Identify the failing job:
   - **Frontend CI failure** (typecheck, lint, build): auto-fix locally, commit, re-push
   - **Backend lint failure** (ruff): auto-fix locally, commit, re-push
   - **Security scan failure** (gitleaks): BLOCK — report to user, do not auto-fix (may be a real secret leak)
   - **Security scan failure** (trivy CRITICAL): report to user with CVE details, suggest dependency update
   - **Build & Push failure**: likely Dockerfile or registry issue — report to user
   - **Deploy to OKE failure**: check kubectl errors in logs — report to user

3. After fix: return to Phase 2 (push again). Max 3 CI retry cycles.

4. If still failing after 3 cycles: report all failures and ask the user for guidance.

### Phase 4: Staging Health Check

After staging deployment succeeds (or after a timeout if we couldn't poll):

1. **Wait 30 seconds** for pods to settle after rollout.

2. **Run /oci-health staging:**
   - Invoke the `oci-health` skill via the Skill tool with argument `staging`
   - If ALL UP: proceed to final report
   - If DEGRADED or DOWN:
     - Pull pod logs: `kubectl logs -n contably-staging -l app=contably-api --tail=50`
     - If the issue is a code bug (import error, config error): auto-fix, commit, re-push (return to Phase 2)
     - If the issue is infra (node pressure, image pull failure): report to user
     - Max 2 health-check retry cycles

3. **Additional staging smoke tests:**

   ```bash
   # Test staging endpoints
   curl -sI https://staging.contably.ai/ 2>/dev/null | head -5
   curl -s --max-time 10 https://staging-api.contably.ai/health 2>/dev/null
   curl -sI https://staging-portal.contably.ai/ 2>/dev/null | head -5

   # Verify security headers on staging
   curl -sI https://staging.contably.ai/ 2>/dev/null | grep -iE 'x-frame|x-content|x-xss|referrer|permissions|content-security'
   ```

### Phase 4a: Refresh Codebase Snapshot

After a successful staging health check (ALL UP), refresh the codebase reference:

1. **Invoke `/contably-snapshot`** via the Skill tool
2. This runs in the background — do not block the final report on it
3. If the snapshot fails, log a warning but do not fail the deploy

**Why:** Every deploy may change the codebase structure (new routes, models, dependencies). Keeping the snapshot fresh means the next session starts with accurate context.

### Phase 5: Final Report

Output a deployment summary:

```markdown
# Staging Deploy Complete

| Stage          | Status   | Duration |
| -------------- | -------- | -------- |
| Verify         | PASS     | 45s      |
| Ultrareview    | PASS/SKIPPED | 3m   |
| Guardian       | APPROVED | 2m       |
| Push           | {sha}    | 1s       |
| CI Pipeline    | PASS     | 8m       |
| Build+Push     | PASS     | 12m      |
| Staging Deploy | PASS     | 3m       |
| Staging Health | ALL UP   | 30s      |

**Total time:** ~26m
**Auto-fixes applied:** {count} ({summary})
**Commits:** {list of commit SHAs}

Staging is live at:

- https://staging-api.contably.ai
- https://staging.contably.ai
- https://staging-portal.contably.ai

To promote to production: `/deploy-conta-production`
```

## Error Recovery Summary

| Failure                     | Action                                | Max Retries |
| --------------------------- | ------------------------------------- | ----------- |
| /verify fails               | Invoke /test-and-fix, re-verify       | 3           |
| /ultrareview CRITICAL       | Auto-fix reviewer issues, re-review   | 2           |
| /contably-guardian BLOCKED  | Auto-fix code issues, re-run guardian | 2           |
| /review-changes CRITICAL    | Fix and re-review                     | 2           |
| CI lint/typecheck fail      | Auto-fix locally, re-push             | 3           |
| CI test fail                | Invoke /test-and-fix, re-push         | 3           |
| CI security fail (gitleaks) | STOP — report to user                 | 0           |
| Build+Push fail             | Report to user (usually infra)        | 0           |
| Staging deploy fail         | Report + suggest rollback             | 0           |
| Staging health DOWN         | Auto-fix if code bug, re-push         | 2           |

## Rules

1. **This skill NEVER touches production** — it stops after staging health check
2. **Never skip security scan failures** — gitleaks BLOCK is absolute
3. **Commit fixes with conventional commits** — `fix(deploy): {description}`
4. **Track all auto-fix commits** — report them in the final summary
5. **Max 3 full push cycles** — if code still fails CI after 3 rounds, stop and report
6. **Respect the pipeline chain** — don't bypass GitHub Actions by deploying directly via kubectl
7. **If `gh` CLI fails** — fall back to push-only mode with manual monitoring at github.com/Contably/contably/actions
8. **Log timing for each phase** — report durations in the final summary

## Subagent Model Tiers

| Task                          | Model  |
| ----------------------------- | ------ |
| /verify invocation            | haiku  |
| /test-and-fix invocation      | sonnet |
| /ultrareview invocation       | cloud  |
| /contably-guardian invocation | opus   |
| /review-changes invocation    | sonnet |
| /oci-health invocation        | haiku  |
| GHA run monitoring            | direct |
| Auto-fix edits                | direct |
