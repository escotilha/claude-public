---
name: mistake:gha-concurrency-cancel-no-replacement
description: GHA workflow with `concurrency.cancel-in-progress: true` sometimes cancels the in-flight run on a fresh push but never fires the replacement run — leaves PR in UNSTABLE state with no recourse except close+reopen
type: feedback
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
When a GitHub Actions workflow has `concurrency: { group: <expr>, cancel-in-progress: ${{ github.event_name != 'push' }} }`, a fresh `pull_request: synchronize` event sometimes cancels the active run AND fails to register the new run in its place. The PR's check list shows the cancelled run as the latest, no new run ever fires, and the PR stays UNSTABLE forever.

**Symptom**: `gh run list --branch <pr-branch> --workflow "Deploy Staging" --limit 5` shows the latest run with `conclusion: cancelled`, no `queued` or `in_progress` rows.

**Recovery**: close + reopen the PR. The `pull_request: reopened` event re-fires all workflows that listen on it.

```bash
gh pr close $N --comment "..."; sleep 2; gh pr reopen $N
```

**Why this happens**: GitHub's concurrency manager registers the new run, sees it conflicts with the in-flight run, cancels the in-flight, then the trigger logic decides "concurrent already exists" (the cancelled one, since cancel hasn't propagated) and discards the new request. Race condition.

**How to apply**:
- Don't bulk-rebase PRs without watching for this.
- If a PR shows `mergeStateStatus: UNSTABLE` AND its real CI gates are all green AND the only "failure" is `Deploy Staging`/`SAST`/etc. that actually completed-cancelled rather than completed-failure, check `gh run list` for an active replacement run. If `active=0`, close+reopen.
- Long-term fix: change `cancel-in-progress: true` to `cancel-in-progress: false` on the deploy-staging workflow's PR-event branch, OR add a `workflow_dispatch` fallback so the script can manually retrigger without close/reopen.

---

## Timeline

- **2026-04-30** — [failure] Hit on PRs #775, #744, #657 during throughput-scaling overnight session. Each had Deploy Staging cancelled by concurrency-group on rebase push, no replacement run fired. Fixed all three by close+reopen. (Source: failure — deploy-staging.yml concurrency config in throughput-scaling cascade)
