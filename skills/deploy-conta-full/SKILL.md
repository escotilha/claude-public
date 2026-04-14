---
name: deploy-conta-full
description: "Full Contably deploy: staging → production in one command. Runs /deploy-conta-staging, and if all green, auto-promotes to production via /deploy-conta-production. Triggers on: deploy conta full, full deploy, staging to production, deploy all."
argument-hint: "[--skip-guardian] [--skip-verify]"
user-invocable: true
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

## Workflow

### Phase 1: Deploy to Staging

1. Invoke the `deploy-conta-staging` skill via the Skill tool, passing through any `--skip-guardian` or `--skip-verify` flags from the user's arguments.

2. **Evaluate the result:**
   - If staging deploy succeeded and health checks pass → proceed to Phase 2
   - If staging deploy failed or health checks failed → **STOP**. Report the failure. Do not touch production.

### Phase 2: Promote to Production

1. Get the staging image tag from the GHA deploy run (format: `stg-<sha>`):

   ```bash
   unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy to Staging" --limit 1 --json headSha -q '.[0].headSha[:7]'
   ```

   The image tag is `stg-<sha>`.

2. Trigger the production deploy via GitHub Actions workflow_dispatch:

   ```bash
   unset GITHUB_TOKEN && gh workflow run deploy-production.yml --repo Contably/contably -f image_tag=stg-<sha> -f confirm=yes
   ```

3. Monitor the production deploy:

   ```bash
   unset GITHUB_TOKEN && gh run list --repo Contably/contably --workflow "Deploy to Production" --limit 1
   unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably
   ```

4. Run production health checks:

   ```bash
   curl -s https://api.contably.ai/health
   ```

5. **Evaluate the result:**
   - If production deploy succeeded → proceed to Phase 3
   - If production deploy failed → report failure. The production skill will suggest rollback.

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

1. **Staging must be fully green before touching production** — any staging failure aborts the entire pipeline
2. **Pass `--skip-staging-check` to production skill** — staging was just verified, don't waste time re-checking
3. **Never auto-fix production** — the production skill handles this (always asks the user)
4. **Forward arguments** — `--skip-guardian` and `--skip-verify` are passed to staging only
5. **Report combined timing** — show both staging and production phases in the final summary
6. **Auto-approve production** — the whole point of this skill is hands-off staging→production. No confirmation prompt for the production gate.

## Subagent Model Tiers

| Task                     | Model |
| ------------------------ | ----- |
| /deploy-conta-staging    | opus  |
| /deploy-conta-production | opus  |
