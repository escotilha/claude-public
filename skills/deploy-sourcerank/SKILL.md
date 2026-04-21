---
name: deploy-sourcerank
description: "Deploy SourceRank AI to Render. Verify → guardian → push → monitor → health check. Auto-fixes. Triggers on: deploy sourcerank, deploy source, sourcerank deploy, push sourcerank."
argument-hint: "[--skip-guardian] [--skip-verify] [--skip-monitoring]"
user-invocable: true
paths:
  - "**/sourcerank/**"
  - "**/source-rank/**"
context: fork
model: opus
effort: high
skills: [verify, sourcerank-guardian]
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

# Deploy — SourceRank AI Render Deployment Pipeline

End-to-end deployment skill that takes code from current state to production on Render. Runs pre-flight checks, auto-fixes issues, pushes to trigger Render auto-deploy, monitors the deploy, runs health checks, and optionally triggers brand monitoring.

## Arguments

- `/deploy-sourcerank` — deploy (default)
- `--skip-guardian` — skip the /sourcerank-guardian pre-deploy check
- `--skip-verify` — skip the /verify type-check/lint/build step
- `--skip-monitoring` — skip triggering brand monitoring after deploy

## Infrastructure Context

- **Platform:** Render (render.yaml blueprint)
- **Git Remote:** `origin` → `https://github.com/escotilha/Sourcerankai.git`
- **Main Branch:** `master`

### Services

| Service               | Render ID                  | URL                                   | Health Check |
| --------------------- | -------------------------- | ------------------------------------- | ------------ |
| **sourcerank-api**    | `srv-d5rktsp4tr6s73e58im0` | `https://sourcerank-api.onrender.com` | `/health`    |
| **sourcerank-web**    | `srv-d5rkttur433s738nao00` | `https://sourcerank-web.onrender.com` | `/`          |
| **sourcerank-worker** | `srv-d5rktushg0os73d20r9g` | N/A (background worker)               | N/A          |

### Render API Access

```bash
# API key is stored in ~/.render/cli.yaml
RENDER_API_KEY=$(python3 -c "import yaml; print(yaml.safe_load(open('$HOME/.render/cli.yaml'))['api']['key'])" 2>/dev/null)

# If yaml parsing fails, extract with grep
RENDER_API_KEY=$(grep 'key:' ~/.render/cli.yaml | head -1 | awk '{print $2}')

# List deploys for a service
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$SERVICE_ID/deploys?limit=1" | python3 -m json.tool

# Deploy status fields: build_in_progress, update_in_progress, live, failed, deactivated
```

### Supabase Admin Key (for post-deploy monitoring)

```bash
# Get from Render API env vars
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/srv-d5rktsp4tr6s73e58im0/env-vars" | \
  python3 -c "import json,sys; [print(e['envVar']['value']) for e in json.load(sys.stdin) if e['envVar']['key']=='SUPABASE_SERVICE_ROLE_KEY']"
```

## Workflow

### Phase 0: Parse Arguments & Detect State

1. Parse the user's arguments to determine skip flags.

2. Detect current state:

   ```bash
   git status --short                       # Uncommitted changes?
   git log --oneline -1                     # Current HEAD
   git log --oneline origin/master..HEAD    # Unpushed commits?
   ```

3. If there are uncommitted changes, ask the user: "There are uncommitted changes. Should I commit them first?" If yes, stage and commit with a conventional commit message.

### Phase 1: Local Verification Loop (auto-fix until clean)

**Goal:** Ensure the code passes all local checks before pushing. Loop up to 3 times.

**Iteration N:**

1. **Run /verify** (unless `--skip-verify`):
   - Invoke the `verify` skill via the Skill tool
   - If FAIL: invoke the `test-and-fix` skill to auto-fix
   - Re-run /verify after fixes
   - If still failing after 3 iterations, ask the user whether to proceed or abort

2. **Run /sourcerank-guardian** (unless `--skip-guardian`):
   - Invoke the `sourcerank-guardian` skill via the Skill tool
   - If `DEPLOY BLOCKED`: analyze the blocking issues
     - For code-level issues: attempt auto-fix using Edit tool, then re-run guardian
     - For infra issues: report to user — these typically need manual intervention
     - For runtime issues: skip if unreachable (will be checked post-deploy)
   - If `DEPLOY APPROVED` or `DEPLOY APPROVED WITH WARNINGS`: proceed

3. **Run /review-changes** on any auto-fix commits:
   - If fixes were applied, invoke `review-changes` skill to validate the fixes don't introduce new issues
   - If review finds CRITICAL issues, fix and re-review (max 2 iterations)

4. After all checks pass, commit any fix changes:
   ```
   fix(deploy): auto-fix {summary of what was fixed}
   ```

### Phase 2: Push to Trigger Render Auto-Deploy

1. Push to master:

   ```bash
   GITHUB_TOKEN= git push origin master
   ```

2. Record the commit SHA for tracking:

   ```bash
   COMMIT_SHA=$(git rev-parse --short HEAD)
   ```

3. Report to user:
   ```
   Pushed {COMMIT_SHA} to origin/master. Render auto-deploy triggered.
   ```

### Phase 3: Monitor Render Deploy

Render auto-deploys on push to master. The deploy takes 3-5 minutes typically.

1. **Get the Render API key:**

   ```bash
   RENDER_API_KEY=$(grep 'key:' ~/.render/cli.yaml | head -1 | awk '{print $2}')
   ```

2. **Poll API service deploy** (every 30 seconds, max 10 minutes):

   ```bash
   curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
     "https://api.render.com/v1/services/srv-d5rktsp4tr6s73e58im0/deploys?limit=1" | \
     python3 -c "import json,sys; d=json.load(sys.stdin); dep=d[0].get('deploy',d[0]); print(dep.get('status','unknown'))"
   ```

   Report progress:
   - `build_in_progress` → "Building on Render..."
   - `update_in_progress` → "Deploying new version..."
   - `live` → "API deploy complete."
   - `failed` → Proceed to Phase 3a

3. **Also check web and worker deploys** in parallel (same pattern with their service IDs).

4. **If Render API key is not available:**
   - Report: "Push complete. Monitor deploys at https://dashboard.render.com"
   - Skip to Phase 4 with a 5-minute delay.

### Phase 3a: Deploy Failure Recovery

If a Render deploy fails:

1. Check Render deploy logs via API:

   ```bash
   curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
     "https://api.render.com/v1/services/$SERVICE_ID/deploys?limit=1" | python3 -m json.tool
   ```

2. Common failures:
   - **Build failure** (typecheck, dependency): auto-fix locally, commit, re-push
   - **Start failure** (runtime error): check the error, auto-fix if code bug, re-push
   - **Health check failure**: wait and retry (Render has its own retry logic)

3. After fix: return to Phase 2 (push again). Max 3 deploy retry cycles.

### Phase 4: Health Check

After all services show `live` status:

1. **Wait 15 seconds** for services to stabilize.

2. **Check API health:**

   ```bash
   curl -s "https://sourcerank-api.onrender.com/health" | python3 -m json.tool
   ```

   Expect: `{"status":"ok", ...}`

3. **Check web health:**

   ```bash
   curl -s -o /dev/null -w "%{http_code}" "https://sourcerank-web.onrender.com/"
   ```

   Expect: `200`

4. **Check public API:**

   ```bash
   curl -s "https://sourcerank-api.onrender.com/api/public/v1/health" | python3 -m json.tool
   ```

   Expect: `{"success":true, "data":{"status":"healthy"}}`

5. **If any health check fails:**
   - Pull recent Render logs if available via API
   - If code bug: auto-fix, commit, re-push (return to Phase 2)
   - If infra issue: report to user
   - Max 2 health-check retry cycles

### Phase 5: Post-Deploy Monitoring (optional)

Unless `--skip-monitoring`:

1. **Trigger monitoring for all active brands:**

   ```bash
   # Get Supabase service role key from Render API
   ADMIN_KEY=$(curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
     "https://api.render.com/v1/services/srv-d5rktsp4tr6s73e58im0/env-vars" | \
     python3 -c "import json,sys; [print(e['envVar']['value']) for e in json.load(sys.stdin) if e['envVar']['key']=='SUPABASE_SERVICE_ROLE_KEY']")

   # Trigger for a specific brand (or iterate over active brands)
   curl -s -X POST "https://sourcerank-api.onrender.com/api/v1/admin/brands/$BRAND_ID/monitor/trigger" \
     -H "X-Admin-Key: $ADMIN_KEY" \
     -H "X-Requested-With: XMLHttpRequest" \
     -H "Content-Type: application/json" \
     -d '{"queryCount": 5}'
   ```

2. Report monitoring trigger results.

### Phase 6: Final Report

Output a deployment summary:

```markdown
# Deploy Complete

| Stage              | Status   | Duration |
| ------------------ | -------- | -------- |
| Verify             | PASS     | 45s      |
| Guardian           | APPROVED | 2m       |
| Push               | {sha}    | 1s       |
| API Deploy         | LIVE     | 4m       |
| Web Deploy         | LIVE     | 3m       |
| Worker Deploy      | LIVE     | 4m       |
| Health Check       | ALL OK   | 15s      |
| Monitoring Trigger | SENT     | 5s       |

**Total time:** ~15m
**Auto-fixes applied:** {count} ({summary})
**Commits:** {list of commit SHAs}
```

## Error Recovery Summary

| Failure                      | Action                                 | Max Retries |
| ---------------------------- | -------------------------------------- | ----------- |
| /verify fails                | Invoke /test-and-fix, re-verify        | 3           |
| /sourcerank-guardian BLOCKED | Auto-fix code issues, re-run guardian  | 2           |
| /review-changes CRITICAL     | Fix and re-review                      | 2           |
| Render build fail            | Auto-fix locally, re-push              | 3           |
| Render start fail            | Check error, auto-fix if code, re-push | 2           |
| Health check fail            | Auto-fix if code bug, re-push          | 2           |
| Monitoring trigger fail      | Report (non-blocking)                  | 0           |

## Rules

1. **Commit fixes with conventional commits** — `fix(deploy): {description}`
2. **Track all auto-fix commits** — report them in the final summary
3. **Max 3 full push cycles** — if code still fails after 3 rounds, stop and report
4. **Never force push** — always regular push to master
5. **If Render API key is unavailable** — fall back to push-only mode with manual monitoring instructions
6. **Log timing for each phase** — report durations in the final summary
7. **Use GITHUB_TOKEN= prefix** — to bypass any invalid env var overriding gh keyring credentials
8. **Monitoring is non-blocking** — a monitoring trigger failure should not fail the deploy
9. **If invoked as agent-spawned** — skip user confirmations for uncommitted changes (auto-commit)

## Subagent Model Tiers

| Task                            | Model                                       |
| ------------------------------- | ------------------------------------------- |
| /verify invocation              | haiku (inherits from verify skill)          |
| /test-and-fix invocation        | sonnet (inherits from test-and-fix skill)   |
| /sourcerank-guardian invocation | opus (inherits from guardian skill)         |
| /review-changes invocation      | sonnet (inherits from review-changes skill) |
| Render API polling              | direct (no subagent — run in orchestrator)  |
| Auto-fix edits                  | direct (run in orchestrator)                |
