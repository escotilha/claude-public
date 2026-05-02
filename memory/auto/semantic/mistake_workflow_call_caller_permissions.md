---
name: mistake_workflow_call_caller_permissions
description: A reusable workflow (workflow_call) cannot be granted MORE permissions than its caller. If ci.yml declares pull-requests:read but deploy-staging.yml only has contents:read, GitHub returns startup_failure with no jobs created. Cost ~6h Deploy Staging blackout 2026-05-02.
type: mistake
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
**The bug:**

When you add a permission scope to a reusable workflow (`on: workflow_call`), every workflow that *calls* that reusable workflow must declare the SAME OR BROADER permissions. GitHub silently fails the caller workflow with `startup_failure` if the caller's `permissions:` block is too narrow — no jobs get created, no error logs are produced via the API, the run page just shows blank circles.

**Specific failure mode:**

```
.github/workflows/deploy-staging.yml (Line: 41, Col: 3):
Error calling workflow 'Contably/contably/.github/workflows/ci.yml@<sha>'.
The workflow is requesting 'pull-requests: read', but is only allowed 'pull-requests: none'.
```

This message appears ONLY in the GitHub web UI on the run page (under "Workflow file" tab area). It is NOT exposed via:
- `gh run view <id>` (returns "startup_failure" only)
- `gh api repos/.../actions/runs/<id>` (returns conclusion + status, not the error string)
- `gh api .../actions/runs/<id>/jobs` (returns total_count: 0 with no jobs)
- `gh run view <id> --log-failed` (returns "log not found")
- The check-runs API (returns 404)

The web UI is the only diagnostic surface. So when investigating a startup_failure, **ALWAYS open the GitHub run URL in a browser and look at the workflow file tab** before exhausting CLI hypotheses.

**Detection signature:**
- `conclusion: startup_failure`
- `status: completed`
- `run_started_at` exists but `started_at` on jobs is null
- `total_count: 0` for jobs
- `run_duration_ms: ~3000` (consistent — GHA gives up at 3s)

**The fix:**

Add the matching permission scope to every workflow that calls the reusable workflow:

```yaml
# .github/workflows/deploy-staging.yml
permissions:
  contents: read
  pull-requests: read   # required to call ci.yml under workflow_call
```

Same applies to `validate-pr.yml` or any other caller of `ci.yml`.

**How this happened on 2026-05-02:**

1. PR #890 (P6-INF-6) added `pull-requests: read` to `ci.yml` to fix the dorny/paths-filter "Resource not accessible by integration" error
2. ci.yml is `on: workflow_call` — it inherits permissions from its caller
3. `deploy-staging.yml` only declared `contents: read`
4. After #890 merged, every Deploy Staging push event hit startup_failure
5. Cost: ~6 hours of staging blackout (16:16-16:30 UTC), 60+ commits stranded on main without staging deploys

**Other callers of ci.yml in the repo (verify they all have pull-requests:read):**
- `validate-pr.yml` — already has it (added in #890)
- `deploy-staging.yml` — fixed in this commit
- `psos-staging-deploy.yml` — already has `pull-requests: write` (broader, fine)

**Prevention:**

- Workflow lint pre-push hook already checks for top-level `permissions:` blocks. Extend it to: when a callee declares `permissions: <X>`, every caller must also declare `<X>` or broader. (queue this as ENGINE-V2 task)
- When adding a permission to a `workflow_call` workflow, grep the repo for `uses: ./.github/workflows/<name>.yml` and update each caller in the same PR.

**Source:** Pierre + Claude, 2026-05-02 ~16:30 UTC. Diagnosed via GitHub web UI after CLI diagnostics exhausted.
