---
name: deploy-conta-full
description: "Contably deploy: staging → production, auto-promotes if green. Triggers: deploy conta full, full deploy."
argument-hint: "[--skip-guardian] [--skip-verify] [--force-staging-redeploy] [--sha=<7-char-sha>]"
user-invocable: true
paths:
  - "**/contably/**"
  - "**/contably-*/**"
  - "**/.claude/contably/**"
context: fork
model: opus
effort: high
skills:
  [
    verify,
    contably-guardian,
    oci-health,
    deploy-conta-staging,
    deploy-conta-production,
  ]
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

# Full Deploy — Contably OCI (Staging → Production)

Runs the complete deployment pipeline: staging deploy followed by automatic production promotion. Chains `/deploy-conta-staging` and `/deploy-conta-production` into a single command.

**If staging fails at any point, production is never touched.**

## Arguments

- `--skip-guardian` — passed through to `/deploy-conta-staging`
- `--skip-verify` — passed through to `/deploy-conta-staging`
- `--force-staging-redeploy` — always run `/deploy-conta-staging` even if staging is already green for the target SHA. Default: skip when staging is already green.
- `--sha=<7-char-sha>` — promote a specific SHA. Default: `git rev-parse HEAD` (current main).

## Workflow

### Phase 0: Staging Freshness Check (fast-path detection)

Before running staging, check whether staging is already green for the target SHA. If yes, skip Phase 1 entirely and jump to Phase 2.

1. **Resolve the target SHA:**

   ```bash
   TARGET_SHA="${SHA_ARG:-$(git rev-parse HEAD)}"
   TARGET_SHORT="${TARGET_SHA:0:7}"
   ```

2. **Check the most recent `Deploy Staging` run for that SHA:**

   ```bash
   STAGING_RUN=$(unset GITHUB_TOKEN && gh run list --repo Contably/contably \
     --workflow "Deploy Staging" --limit 10 \
     --json databaseId,status,conclusion,headSha \
     --jq ".[] | select(.headSha | startswith(\"$TARGET_SHORT\")) | select(.status == \"completed\") | .[0]")
   ```

3. **Decision matrix:**

   | Condition                                                                | Action                              |
   | ------------------------------------------------------------------------ | ----------------------------------- |
   | Staging run found, conclusion=success, no `--force-staging-redeploy`     | **SKIP Phase 1**, jump to Phase 2   |
   | Staging run found, conclusion=success, `--force-staging-redeploy` passed | Run Phase 1 anyway (user override)  |
   | Staging run found, conclusion=failure/cancelled                          | Run Phase 1 (need to retry staging) |
   | No staging run found for SHA                                             | Run Phase 1 (first deploy of SHA)   |

4. **When skipping Phase 1, verify staging health is currently up** (the green run could be hours old):

   ```bash
   curl -fsS https://staging-api.contably.ai/health || { echo "Staging health failing — falling back to Phase 1"; FORCE_PHASE1=1; }
   ```

   If staging is unhealthy now even though the last run succeeded, fall through to Phase 1.

5. **Announce the decision** to the user before proceeding so they can intercept:

   ```
   Staging already green for SHA abc1234 (run #12345, completed 8m ago, health OK).
   Skipping staging redeploy. Promoting to prod in 5s — interrupt to abort.
   ```

### Phase 1: Deploy to Staging (conditional — only if Phase 0 said so)

1. Invoke the `deploy-conta-staging` skill via the Skill tool, passing through any `--skip-guardian` or `--skip-verify` flags from the user's arguments.

2. **Evaluate the result:**
   - If staging deploy succeeded and health checks pass → proceed to Phase 2
   - If staging deploy failed or health checks failed → **STOP**. Report the failure. Do not touch production.

### Phase 2: Promote to Production

1. Use the `TARGET_SHORT` from Phase 0 (or, if Phase 1 ran, re-derive from the just-completed staging run):

   ```bash
   if [ -z "$TARGET_SHORT" ]; then
     TARGET_SHORT=$(unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy Staging" --status success --limit 1 --json headSha -q '.[0].headSha' | head -c 7)
   fi
   echo "Promoting image tag: stg-$TARGET_SHORT"
   ```

   The image tag is `stg-<7-char-sha>`. Never re-query "latest success" if the user passed `--sha=` — promote what they asked for.

2. Trigger the production deploy via GitHub Actions workflow_dispatch:

   ```bash
   unset GITHUB_TOKEN && gh workflow run deploy-production.yml --repo Contably/contably -f image_tag=stg-$SHA -f confirm=yes
   ```

   **IMPORTANT:** Production deploys via `workflow_dispatch` on `deploy-production.yml`, NOT via `git push origin main`. Pushing to main only triggers staging.

3. Wait 5 seconds, then monitor the production deploy (use `run_in_background: true`):

   ```bash
   sleep 5
   RUN_ID=$(unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy to Production" --limit 1 --json databaseId -q '.[0].databaseId')
   unset GITHUB_TOKEN && gh run watch $RUN_ID --repo Contably/contably --exit-status
   ```

4. On completion, check results and run production health checks:

   ```bash
   unset GITHUB_TOKEN && gh run view $RUN_ID --repo Contably/contably --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
   curl -s https://api.contably.ai/health
   ```

5. **Evaluate the result:**
   - If production deploy succeeded → proceed to Phase 3
   - If production deploy failed → report failure, suggest rollback: `kubectl rollout undo deployment/contably-api -n contably`

### Phase 3: Final Report

Output a combined summary of the full pipeline:

```markdown
# Full Deploy Complete — Staging → Production

## Staging

| Stage          | Status   | Duration |
| -------------- | -------- | -------- |
| Verify         | PASS     | —        |
| Guardian       | APPROVED | —        |
| Push           | {sha}    | —        |
| CI Pipeline    | PASS     | —        |
| Build+Push     | PASS     | —        |
| Staging Deploy | PASS     | —        |
| Staging Health | ALL UP   | —        |

## Production

| Stage             | Status   | Duration |
| ----------------- | -------- | -------- |
| Approval          | APPROVED | —        |
| Production Deploy | PASS     | —        |
| Production Health | ALL UP   | —        |

**Image tag:** {IMAGE_TAG}

Production is live at:

- https://api.contably.ai
- https://contably.ai
- https://portal.contably.ai
```

## Rules

1. **Staging must be fully green before touching production** — Phase 0 verifies this; any staging failure (or unhealthy staging now) aborts the entire pipeline
2. **Skip staging redeploy when SHA already green** — default behavior. Saves ~10 min per promotion and avoids destabilizing a known-good staging. Use `--force-staging-redeploy` to override.
3. **Promote what the user asked for** — if `--sha=<x>` was passed, never silently substitute "latest success"
4. **Pass `--skip-staging-check` to production skill** — staging was just verified by Phase 0 or Phase 1
5. **Never auto-fix production** — the production skill handles this (always asks the user)
6. **Forward arguments** — `--skip-guardian` and `--skip-verify` are passed to staging only
7. **Report combined timing** — show both staging and production phases in the final summary, and note when Phase 1 was skipped
8. **Auto-approve production** — the whole point of this skill is hands-off staging→production. No confirmation prompt for the production gate.
9. **Deploy only via GitHub Actions — this skill delegates entirely to `/deploy-conta-staging` and `/deploy-conta-production`; it never runs `kubectl set image`, `kubectl rollout restart`, or any direct cluster command itself.** Both sub-skills enforce the same constraint. No cluster mutation ever originates from this session directly.

## Future: UX gate integration (planned)

When `/qa-conta-gate` is operational, Phase 0 should also check for a `ux_approvals` row matching the target SHA before promoting. If absent, prompt the user to run `/qa-conta-gate <sha>` first (or pass `--skip-ux-gate` to bypass). Until then, GitHub Actions green is the only gate.

## Subagent Model Tiers

| Task                     | Model |
| ------------------------ | ----- |
| /deploy-conta-staging    | opus  |
| /deploy-conta-production | opus  |
