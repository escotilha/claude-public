---
name: contably-ci-rescue
description: "Diagnose and fix failing Contably CI. Classifies failure, targeted fix. Triggers: ci rescue, ci failing, fix ci."
argument-hint: "[run-url | --latest | --branch=<name>]"
user-invocable: true
paths:
  - "**/contably/**"
  - "**/contably-*/**"
  - "**/.claude/contably/**"
context: fork
model: opus
effort: high
alwaysThinkingEnabled: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - AskUserQuestion
  - Monitor
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
tool-annotations:
  Bash: { destructiveHint: true, idempotentHint: false }
---

# `/contably-ci-rescue` — Triage + Fix a Failing Contably CI Run

Built from the 45 `fix(ci)` + 10 `fix(deploy)` + 3 `fix(migration)` commits in the last 17 days. Classifies the failure, applies the known fix, re-triggers CI.

**Scope**: Contably repo only. GitHub Actions pipeline (`ci.yml`, `deploy-staging.yml`, `deploy-production.yml`). OKE + MySQL 8 production, staging MySQL.

**Approval password**: `go` (same as `/orchestrate`).

---

## Invocation

```bash
# Diagnose the most recent failed run on current branch
/contably-ci-rescue --latest

# Diagnose a specific run
/contably-ci-rescue https://github.com/<org>/contably/actions/runs/12345

# Diagnose a branch's last failure
/contably-ci-rescue --branch=feature/sla-phase-5
```

---

## Phase 1: Fetch + Classify

1. Resolve target run:
   - `--latest` → `gh run list --branch $(git branch --show-current) --limit 5 --json databaseId,status,conclusion,workflowName` — pick the most recent failed/cancelled.
   - URL → extract run ID.
   - `--branch=<name>` → same as `--latest` but for the specified branch.
2. Pull logs: `gh run view <run-id> --log-failed` (or `--log` if nothing flagged).
3. Match against the classifier table below. Emit `failure_class`, `confidence`, `evidence`.

### Classifier Table (failure → signal → fix family)

| failure_class | Signal regex / substring | Fix family |
|---|---|---|
| `alembic-chain-broken` | `Multiple head revisions`, `Can't locate revision identified by`, `branchpoint`, `can't find parent` | → invoke `/alembic-chain-repair` |
| `alembic-mysql-incompat` | `RETURNING`, `UUID() function does not exist`, `SERIAL`, `DEFAULT gen_random_uuid`, MySQL parser error on migration | → Fix family: MySQL compat rewrite |
| `secret-missing` | `KeyError: '<KEY>'`, `secret "<name>" not found`, env var empty in pod logs | → Fix family: patch secret into K8s / ConfigMap |
| `pod-crash-loop` | `CrashLoopBackOff`, `ImagePullBackOff`, `Readiness probe failed`, container exit code 1 | → Fix family: fetch pod logs, determine root cause recursively |
| `kubectl-oke-auth` | `Unauthorized`, `oracle-actions/configure-kubectl-oke`, `kubeconfig`, `OCI_CLI_KEY_CONTENT` | → Fix family: OCI CLI kubeconfig path |
| `rbac-missing` | `forbidden: User "system:serviceaccount"`, `cannot watch resource`, `cannot patch` | → Fix family: add verb to RBAC ClusterRole |
| `docker-cache-stale` | "works locally but not in CI", same bug after rebuild, `COPY` before code change visible | → Fix family: cache-bust RUN after COPY / bust GHA cache scope |
| `lint-blocking` | `ruff check`, `eslint`, exit 1, import-sort, `ajv` crash | → Fix family: auto-fix + pin version OR restore `continue-on-error` |
| `type-blocking` | `mypy`, `1695 errors` class patterns | → Fix family: continue-on-error (pre-existing type errors accepted) |
| `test-collection` | `ImportError while importing test module`, `collected 0 items / 1 error`, missing export | → Fix family: skip broken test file, fix import |
| `test-flaky` | single test passes on re-run, `MFA` test, Redis-timing | → Fix family: continue-on-error on the test step |
| `gitleaks` | `gitleaks`, `hardcoded`, `leaked secret` | → Fix family: remove literal key, replace with `${{ secrets.* }}` |
| `docker-build-path` | `COPY failed: file not found`, `requirements.txt` path mismatch | → Fix family: restore correct COPY path |
| `db-url-overwrite` | staging deploy wipes `DATABASE_URL`, pod gets placeholder | → Fix family: `always patch DATABASE_URL in production` |
| `migration-order` | migrations run before rollout, stale pod runs old migrations | → Fix family: run migrations AFTER rollout |
| `pnpm-version` | `pnpm` version mismatch, lockfile error | → Fix family: remove explicit version, use `packageManager` field |
| `concurrency-conflict` | workflow cancels itself, push+workflow_call double-trigger | → Fix family: remove push trigger from reusable workflow |

If confidence < 0.75 → ask user to confirm class via `AskUserQuestion`.

---

## Phase 2: Gate

Display:
```
Detected failure: <failure_class> (confidence 0.92)
Evidence: <top 3 log lines>
Proposed fix: <fix family summary>
Files to touch: <list>
Risk: <low|medium|high>

Reply 'go' to apply, anything else to abort.
```

If risk=`high` (prod deploy, DB drop, force push), require `go` regardless of invocation mode.

---

## Phase 3: Apply Fix (per family)

### `alembic-chain-broken` → delegate
Invoke `/alembic-chain-repair` via Skill tool. Pass: `{ target: mysql|postgres, env: staging|production, branch: <current> }`. Wait for its completion, then re-trigger CI.

### `alembic-mysql-incompat`
Rewrite the offending migration for MySQL 8:
- `RETURNING` → `LAST_INSERT_ID()` + separate SELECT
- `gen_random_uuid()` → `UUID()`
- `SERIAL` → `INTEGER AUTO_INCREMENT PRIMARY KEY`
- `JSONB` → `JSON`
- `ARRAY` → normalized table
- PostgreSQL-only indexes → skip or replace with MySQL index

Files: `apps/api/alembic/versions/*.py`. After edit, run `alembic upgrade head` locally against a MySQL 8 container to verify. Then `git commit -m "fix(migration): rewrite NN for MySQL 8 compatibility"`.

### `secret-missing`
Options (ask user if ambiguous):
1. Add to GitHub Actions secret (`gh secret set <NAME>`).
2. Patch into K8s Secret in deploy workflow:
   ```yaml
   - name: Patch secret
     run: kubectl patch secret contably-api-secrets -n contably-staging --type=merge -p='{"data":{"<KEY>":"${{ secrets.<KEY> | base64 }}"}}'
   ```
3. Add to base ConfigMap if non-sensitive.

Never commit raw values. If gitleaks blocks, the fix family is `gitleaks`, not this one.

### `pod-crash-loop`
```bash
kubectl logs -n contably-staging <pod> --previous --tail=200
kubectl describe pod -n contably-staging <pod>
```
Recurse: classify the crash reason (usually surfaces as `secret-missing`, `alembic-*`, or `docker-build-path`) and apply its fix family.

### `kubectl-oke-auth`
Replace the `oracle-actions/configure-kubectl-oke` step with direct OCI CLI kubeconfig setup:
```yaml
- name: Setup OCI CLI + kubectl
  env:
    OCI_CLI_KEY_CONTENT: ${{ secrets.OCI_CLI_KEY_CONTENT }}
  run: |
    mkdir -p ~/.oci
    echo "$OCI_CLI_KEY_CONTENT" > ~/.oci/key.pem
    chmod 600 ~/.oci/key.pem
    oci ce cluster create-kubeconfig --cluster-id <OCID> --file ~/.kube/config --region sa-saopaulo-1 --token-version 2.0.0
```

### `rbac-missing`
Add the missing verb to the ClusterRole. Common missing verbs: `watch`, `patch`, `get` on `secrets`/`pods`/`deployments`.
File: `infra/k8s/rbac/*.yaml` (or wherever the ServiceAccount is defined).

### `docker-cache-stale`
Two mitigations, apply in order:
1. Add cache-bust `RUN` after `COPY`:
   ```dockerfile
   COPY src/ /app/src/
   RUN echo "cache-bust $(date +%s)"
   ```
2. Bust the GHA cache scope:
   ```yaml
   cache-from: type=gha,scope=api-v2
   cache-to: type=gha,scope=api-v2,mode=max
   ```
Increment the scope suffix to force a fresh cache.

### `lint-blocking`
Try in order:
1. Auto-fix: `ruff check --fix --unsafe-fixes apps/api/` then re-run CI.
2. If still failing: pin ruff version in CI to match local (`uv add ruff==<version>`), commit `uv.lock`.
3. If pre-existing errors class (>100 errors, many unrelated): restore `continue-on-error: true` on the lint step with a TODO comment to tighten later.

### `type-blocking`
Always → `continue-on-error: true` on the mypy step. Contably has 1695 pre-existing type errors; enforcement happens via gradual typing, not CI gate. Leave a TODO.

### `test-collection`
Replace the failing test file with a module-level skip:
```python
import pytest
pytestmark = pytest.mark.skip(reason="broken import after <refactor>; tracked in <ticket>")
```
Then commit `fix(tests): skip broken test file <name>`. Don't delete — someone will need to revisit.

### `test-flaky`
Add `continue-on-error: true` on the test step in CI (Contably already uses this pattern for the MFA flake). Leave a TODO comment naming the flaky test.

### `gitleaks`
Remove the literal secret from the file. Replace with `${{ secrets.<NAME> }}` (GHA) or `$VAR` (script). Rotate the leaked credential:
- Anthropic: regenerate in dashboard
- Resend: regenerate in dashboard
- OCI: rotate via `oci iam user api-key rotate`
- AWS/S3: rotate in IAM

Then `gitleaks detect --no-git` locally to confirm clean.

### `docker-build-path`
Inspect the Dockerfile `COPY` lines vs actual repo layout. Common fix: `COPY apps/api/requirements.txt /app/requirements.txt` (the `apps/api/` prefix is the frequent miss).

### `db-url-overwrite`
In the deploy workflow's env-patching step, add an explicit skip for production:
```yaml
- name: Patch DATABASE_URL
  if: env.DEPLOY_ENV == 'staging'
  run: ...
# Never overwrite prod DATABASE_URL — it's managed via Secret only
```

### `migration-order`
Move the migration step to **after** `kubectl rollout status`:
```yaml
- name: Deploy
  run: kubectl apply -k infra/k8s/overlays/staging/
- name: Wait rollout
  run: kubectl rollout status deployment/contably-api -n contably-staging --timeout=5m
- name: Run migrations
  run: kubectl exec deploy/contably-api -n contably-staging -- alembic upgrade heads
```

### `pnpm-version`
Remove `version:` from `pnpm/action-setup`, let it pick up from `packageManager` in `package.json`:
```yaml
- uses: pnpm/action-setup@v4
  # No version: field — uses packageManager from root package.json
```

### `concurrency-conflict`
If `ci.yml` is called via `workflow_call` from `deploy-*.yml`, remove the `push:` trigger from `ci.yml` — it causes double-runs.

---

## Phase 4: Commit + Re-Trigger

1. Stage the fix: `git add <specific files>`.
2. Commit with Contably convention: `fix(<scope>): <one-line description>`.
3. Push: `git push origin <current-branch>`.
4. Re-trigger CI if the push doesn't auto-run: `gh workflow run ci.yml --ref <branch>` or `gh run rerun <failed-run-id>`.
5. Watch: `gh run watch <new-run-id>` in background. Notify via Monitor when done.

**Never** `git push --force` or `git commit --amend` unless the user explicitly approves.

---

## Phase 5: Report

Write `.orchestrate/<run-id>/ci-rescue.md` (or stdout if standalone):
```markdown
# CI Rescue Report

Run: <url>
Failure class: <name> (confidence 0.92)
Fix family applied: <name>
Files changed: <list>
Commit: <sha>
New CI run: <url> (status: <pending|passing|failing>)
```

If the new run also fails:
- Re-run `/contably-ci-rescue --latest` up to 3 times.
- After 3 attempts, hard-stop and escalate to user with full classification history.

---

## Anti-Patterns (do NOT do these)

- **Don't add `continue-on-error: true` without a TODO + reason.** Makes CI performative. Only use for pre-existing flake classes documented elsewhere.
- **Don't blanket-skip migrations.** If `migration-order` is the class, fix the order — don't set `non-blocking: true` unless the migration itself is broken and already in a rescue loop.
- **Don't rotate prod secrets without telling Pierre.** If a `gitleaks` rescue touches a prod key, pause and ask.
- **Don't force-push.** Contably's main and staging branches have protections; force push breaks the deploy history.
- **Don't run `alembic downgrade`.** Always fix forward. Use `/alembic-chain-repair` for chain damage.

---

## Integration with Other Skills

| Skill | Relationship |
|---|---|
| `/alembic-chain-repair` | Invoked when `failure_class = alembic-chain-broken` |
| `/contably-guardian` | Run AFTER successful rescue before re-deploying to production |
| `/verify-conta` | Run on the local branch post-fix to confirm ruff/mypy/tsc pass |
| `/deploy-conta-staging` | Next step after green CI if the rescue was on a deploy workflow |
| `/orchestrate` | Can invoke this skill as a Phase 6 (Verify) sub-phase when CI fails mid-run |

---

## Version

**v1.0.0** — 2026-04-17. Built from 17-day commit history pattern analysis.
