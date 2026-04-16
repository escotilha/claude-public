---
name: deploy-conta-production
description: "Promote Contably staging to production on OCI. Verifies, approves gate, monitors, validates. Triggers on: deploy conta production, promote to production, push to production, production deploy, go live."
argument-hint: "[--skip-staging-check]"
user-invocable: true
context: fork
model: opus
effort: high
skills: [oci-health, contably-snapshot]
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

# Deploy Production — Contably OCI

Promotes Contably from staging to production via GitHub Actions workflow_dispatch.

**Flow:** Push to main deploys to STAGING (contably-staging namespace). This skill triggers `deploy-production.yml` workflow_dispatch to promote a tested staging image to PRODUCTION (contably namespace).

**Requires:** A staging image tag (e.g., `stg-abc1234`) from a successful staging deploy. Use `/deploy-conta-staging` first.

## Arguments

- `--skip-staging-check` — skip the staging health verification (use when you've already manually verified)
- `--auto-approve` — skip the confirmation prompt and auto-approve the OCI DevOps production gate (used by `/deploy-conta-full` after staging is verified green)

## Infrastructure Context

- **OCI Region:** `sa-saopaulo-1`
- **OCIR Registry:** `sa-saopaulo-1.ocir.io/gr5ovmlswwos`
- **K8s Namespace (staging):** `contably-staging`
- **K8s Namespace (production):** `contably`
- **OKE Cluster OCID:** `ocid1.cluster.oc1.sa-saopaulo-1.aaaaaaaarqeang2k3wo452nek7zaw5ufjtdmaqxupo6m2zgofckxzb7tcsvq`
- **Staging URLs:**
  - API: `https://staging-api.contably.ai`
  - Dashboard: `https://staging.contably.ai`
  - Portal: `https://staging-portal.contably.ai`
- **Production URLs:**
  - API: `https://api.contably.ai`
  - Dashboard: `https://contably.ai` / `https://admin.contably.ai`
  - Portal: `https://portal.contably.ai`

### GitHub CLI Commands Reference

```bash
# List recent workflow runs
unset GITHUB_TOKEN && gh run list --repo Contably/contably --limit 5

# Watch a run in real-time
unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably

# Check job-level status
unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'

# Trigger production deploy (workflow_dispatch)
unset GITHUB_TOKEN && gh workflow run deploy-production.yml --repo Contably/contably -f image_tag=stg-<sha> -f confirm=yes
```

## Workflow

### Phase 1: Pre-Deploy Verification (unless `--skip-staging-check`)

1. **Check current production health:**

   ```bash
   curl -s --max-time 10 https://api.contably.ai/health 2>/dev/null
   curl -sI --max-time 10 https://contably.ai/ 2>/dev/null | head -3
   curl -sI --max-time 10 https://portal.contably.ai/ 2>/dev/null | head -3
   ```

2. **Run /oci-health production:**
   - Invoke the `oci-health` skill via the Skill tool with argument `production`
   - If DEGRADED or DOWN: warn the user but allow proceeding (deploy might fix it)

### Phase 2: Confirm and Trigger Production Deploy

1. **Determine the staging image tag.** This must be provided as an argument or extracted from the latest successful staging deploy:

   ```bash
   unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy to Staging" --status success --limit 1 --json headSha -q '.[0].headSha' | head -c 7
   ```

   The image tag is `stg-<7-char-sha>`.

2. **If `--auto-approve` is set**, skip the confirmation prompt and trigger directly.

3. **Otherwise, present the deployment details to the user:**

   ```
   Ready to promote to production.

   Staging image tag: stg-{sha}
   Source commit: {full sha}

   Production URLs:
   - API: https://api.contably.ai
   - Dashboard: https://contably.ai
   - Portal: https://portal.contably.ai

   Trigger production deploy? (yes/no)
   ```

   If the user says no: exit.

4. **Trigger production deploy via workflow_dispatch:**

   ```bash
   unset GITHUB_TOKEN && gh workflow run deploy-production.yml --repo Contably/contably -f image_tag=stg-<sha> -f confirm=yes
   ```

   **IMPORTANT:** Production deploys via `workflow_dispatch` on `deploy-production.yml`, NOT via `git push origin main`. Pushing to main only triggers staging.

### Phase 3: Monitor Production Deploy

1. **Wait 5 seconds**, then find the workflow run:

   ```bash
   sleep 5 && unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy to Production" --limit 1
   ```

2. **Watch the run** (use `run_in_background: true`):

   ```bash
   unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably --exit-status
   ```

3. **On completion, check results:**

   ```bash
   unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
   ```

4. **On failure**:
   - Get logs: `unset GITHUB_TOKEN && gh run view <RUN_ID> --repo Contably/contably --log`
   - Report failure details
   - Suggest rollback: `kubectl rollout undo deployment/contably-api -n contably`
   - Ask user if they want to rollback
   - Do NOT auto-fix production — always ask first

### Phase 5: Production Health Check

1. **Wait 30 seconds** for pods to settle after rollout.

2. **Run /oci-health production:**
   - Invoke the `oci-health` skill via the Skill tool with argument `production`

3. **Quick production smoke tests:**

   ```bash
   curl -s --max-time 10 https://api.contably.ai/health 2>/dev/null
   curl -sI --max-time 10 https://contably.ai/ 2>/dev/null | head -3
   curl -sI --max-time 10 https://portal.contably.ai/ 2>/dev/null | head -3

   # Verify security headers
   curl -sI https://contably.ai/ 2>/dev/null | grep -iE 'x-frame|x-content|x-xss|referrer|permissions|content-security'
   ```

4. **If ALL UP**: proceed to final report.

5. **If issues found**:
   - Report the diagnostic details
   - Suggest rollback command if critical
   - Ask user for next steps
   - **Never auto-fix production**

### Phase 5a: Refresh Codebase Snapshot

After a successful production health check (ALL UP), refresh the codebase reference:

1. **Invoke `/contably-snapshot`** via the Skill tool
2. This runs in the background — do not block the final report on it
3. If the snapshot fails, log a warning but do not fail the deploy

**Why:** Every deploy may change the codebase structure (new routes, models, dependencies). Keeping the snapshot fresh means the next session starts with accurate context.

### Phase 6: Final Report

```markdown
# Production Deploy Complete

| Stage             | Status   | Duration |
| ----------------- | -------- | -------- |
| Staging Health    | ALL UP   | 15s      |
| Approval          | APPROVED | —        |
| Production Deploy | PASS     | 3m       |
| Production Health | ALL UP   | 30s      |

**Total time:** ~5m
**Image tag:** {IMAGE_TAG}

Production is live at:

- https://api.contably.ai
- https://contably.ai
- https://portal.contably.ai
```

## Error Recovery Summary

| Failure                | Action                                        | Max Retries |
| ---------------------- | --------------------------------------------- | ----------- |
| Staging health DOWN    | STOP — tell user to run /deploy-conta-staging | 0           |
| No pending deployment  | STOP — tell user to run /deploy-conta-staging | 0           |
| Production deploy fail | Report + suggest rollback                     | 0           |
| Production health DOWN | Report + suggest rollback (NO auto-fix)       | 0           |

## Rules

1. **NEVER auto-fix production** — always report and ask the user
2. **ALWAYS confirm before pushing** — unless `--auto-approve` is passed (used by `/deploy-conta-full`)
3. **If `gh` CLI fails** — fall back to push-only mode with manual monitoring at github.com/Contably/contably/actions
4. **Log timing for each phase** — report durations in the final summary
5. **Suggest rollback on any production failure** — `kubectl rollout undo deployment/contably-api -n contably`

## Subagent Model Tiers

| Task                   | Model  |
| ---------------------- | ------ |
| /oci-health production | haiku  |
| GHA run monitoring     | direct |
