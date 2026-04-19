---
name: qa-conta-gate
description: "Pre-production UX/UI gate for Contably. Tests actual feature pages in staging with parallel browser testers, fix-loops bugs, writes ux_approved signal. Triggers on: qa conta gate, ux gate, pre-prod qa, test staging feature."
argument-hint: "<commit_sha> [--force-full-suite] [--max-iterations=3]"
user-invocable: true
context: fork
model: opus
effort: high
skills: [agent-browser, investigate, qa-fix, verify-conta, slack, deploy-conta-staging]
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
  Bash: { destructiveHint: false, idempotentHint: false, openWorldHint: true }
  Read: { readOnlyHint: true, idempotentHint: true }
  Glob: { readOnlyHint: true, idempotentHint: true }
  Grep: { readOnlyHint: true, idempotentHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
  Edit: { destructiveHint: false, idempotentHint: true }
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

# QA Conta Gate — Pre-Production UX/UI Gate for Contably

You are the pre-production UX gating layer for Contably. Your job is to test what was actually changed in a commit, run parallel browser journeys against staging, loop on failures, and write a cryptographically-pinned approval signal that `/deploy-conta-production` checks before promoting.

**Hard rules:**

1. **NEVER promote to production** — this skill only gates; `/deploy-conta-production` does the promotion
2. **NEVER auto-fix CRITICAL UX issues** (data loss, auth bypass, broken payment flows) without user confirmation via `AskUserQuestion`
3. **Contably-only** — no project auto-detection, no generic paths
4. **Parallel-first** — if 2+ journeys, spawn them all in a single message
5. **3-strike rule** — after 3 failed fix iterations, escalate to user; never silently abandon
6. **Tag all staging test data with a session prefix.** Records created in staging (companies, users, bank connections, tickets, invoices, etc.) must include a session-tag prefix in their name/description — e.g. `[sa] Test Bank Connection` or `[0419] Test Invoice`. Derive the tag from `git rev-parse --abbrev-ref HEAD | head -c 8` or the `SESSION_TAG` env var. Pass the tag to every haiku tester in their spawn prompt. Rationale: concurrent sessions running the same journeys would otherwise create duplicate records and corrupt each other's test assertions.

## Model Tiers

| Task                                      | Model      | Rationale                                 |
| ----------------------------------------- | ---------- | ----------------------------------------- |
| Orchestration, synthesis, triage          | **opus**   | Cross-domain reasoning (you)              |
| Journey spec generation (missing specs)   | **sonnet** | Needs to write meaningful prose           |
| Browser journey testers                   | **haiku**  | Navigate + check console — deterministic  |
| Fix investigation + root cause            | **sonnet** | Code understanding + bounded judgment     |

## Staging Environment

- **API health**: `https://staging-api.contably.ai/health`
- **Admin app**: `https://staging.contably.ai`
- **Client portal**: `https://staging-portal.contably.ai`
- **K8s namespace**: `contably-staging`
- **Staging credentials file**: `~/.claude-setup/secrets/contably-staging.env` (read by spawned agents — never read or echo secrets in the orchestrator)
- **GitHub repo**: `Contably/contably`

## Architecture

```
┌───────────────────────────────────────────────────────────┐
│               OPUS ORCHESTRATOR (you)                      │
│                                                           │
│  Phase 0: Validate state + parse args                     │
│       │                                                   │
│       ▼                                                   │
│  Phase 1: Diff analysis → journey list                    │
│       │                                                   │
│       ▼                                                   │
│  Phase 2: Load / generate journey specs                   │
│       │                                                   │
│       ▼                                                   │
│  ┌────────────────────────────────────────────────────┐   │
│  │  Phase 3: PARALLEL HAIKU BROWSER TESTERS (swarm)   │   │
│  │  haiku × N — one per journey, batch of 3-5         │   │
│  └────────────────────────────────────────────────────┘   │
│       │                                                   │
│       ▼                                                   │
│  Phase 4: FIX LOOP (max 3 iterations)                    │
│    /investigate → /qa-fix → commit → push                │
│    → wait for staging redeploy → retest failing only     │
│       │                                                   │
│       ▼                                                   │
│  Phase 5: Write UX approval signal                       │
│       │                                                   │
│       ▼                                                   │
│  Phase 6: Slack report → C0AS64REV4J                    │
└───────────────────────────────────────────────────────────┘
```

---

## Phase 0: Detect State + Input Validation

Parse arguments from the user's invocation:

```
/qa-conta-gate <sha>                     # Test journeys touched by this SHA
/qa-conta-gate <sha> --force-full-suite  # Run ALL journeys regardless of diff
/qa-conta-gate <sha> --max-iterations=2  # Cap fix iterations (default: 3)
/qa-conta-gate                           # Default to HEAD
```

**Steps:**

1. **Resolve SHA:**

   ```bash
   SHA="${ARG:-$(git rev-parse HEAD)}"
   echo "Gating SHA: $SHA"
   ```

2. **Verify SHA is on origin/main** (skill only runs after a green staging deploy):

   ```bash
   git fetch origin main --quiet
   git merge-base --is-ancestor "$SHA" origin/main \
     && echo "SHA is on origin/main — OK" \
     || { echo "ERROR: $SHA not on origin/main. Run after staging deploy."; exit 1; }
   ```

3. **Check staging API health** (poll 3× if not immediately healthy):

   ```bash
   for i in 1 2 3; do
     HEALTH=$(curl -sf --max-time 10 https://staging-api.contably.ai/health 2>/dev/null)
     echo "$HEALTH" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('status')=='healthy' else 1)" \
       && echo "Staging healthy" && break
     echo "Attempt $i: staging unhealthy — waiting 30s..."
     sleep 30
   done || { echo "ABORT: staging API unhealthy after 3 attempts"; exit 1; }
   ```

4. **Verify deployed image_tag matches SHA:**

   ```bash
   DEPLOYED_TAG=$(kubectl get deploy -n contably-staging -o jsonpath='{.items[0].spec.template.spec.containers[0].image}' 2>/dev/null | awk -F: '{print $NF}')
   SHORT_SHA=$(git rev-parse --short "$SHA")
   echo "Deployed: $DEPLOYED_TAG / Expected short SHA: $SHORT_SHA"
   # Warn (not abort) if tag doesn't match — staging may use abbreviated forms
   echo "$DEPLOYED_TAG" | grep -q "$SHORT_SHA" || echo "WARN: image tag mismatch — proceeding anyway"
   ```

5. **Check for existing approval** (idempotency guard):

   ```bash
   if [ -f ".qa-approvals/$SHA.json" ]; then
     echo "Signal already exists for $SHA — skipping. To re-run, delete .qa-approvals/$SHA.json"
     exit 0
   fi
   ```

---

## Phase 0.5: Acquire Concurrent-Run Lock

Only one `/qa-conta-gate` run may be active at a time per-repo. The Pluggy
sandbox and staging test users are shared resources — concurrent runs race on
them and produce flaky or destructive results (e.g. two sessions trying to
connect/disconnect the same sandbox CPF simultaneously).

### Lock file

Path: `.qa-approvals/.lock` (gitignored — never committed)

Format: JSON
```json
{
  "sha": "<the SHA this run is testing>",
  "started_at": "<ISO8601>",
  "session": "<short session tag, e.g. sa, 0419>",
  "pid": 12345,
  "host": "<hostname>"
}
```

### Acquire

```bash
mkdir -p .qa-approvals
LOCK=".qa-approvals/.lock"
SESSION=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | grep -oE '[a-z0-9]+' | head -1 || echo "${USER:-unknown}")
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

1. Check for `.qa-approvals/.lock`:
   - **Absent** → write the lock with this run's metadata and proceed:
     ```bash
     echo "{\"sha\":\"$SHA\",\"started_at\":\"$NOW\",\"session\":\"$SESSION\",\"pid\":$$,\"host\":\"$(hostname)\"}" > "$LOCK"
     echo "Lock acquired by session=$SESSION for SHA=$SHA"
     ```
   - **Present** → read it:
     - If `started_at` is **older than 30 minutes**: treat as stale, log a warning, overwrite, and proceed.
     - Otherwise: **ABORT** with a clear message:
       ```
       /qa-conta-gate is already running:
         session: <session>
         sha:     <sha>
         started: <started_at> (N minutes ago)
         host:    <host>
       Wait for it to finish, or if you know it is stuck, delete
       .qa-approvals/.lock manually and re-run.
       ```

### Release

The lock **MUST** be released on every exit path.

#### Lock release checklist

- **Success (Phase 5 all-green):** `rm .qa-approvals/.lock` — include the deletion in the same `git add` + `git commit` that writes the approval signal.
- **Rejected (fix loop exhausted):** `rm .qa-approvals/.lock` — commit the deletion in the same commit that writes the rejected signal.
- **Abort (user Ctrl+C, hard crash):** Lock is left behind. The 30-minute staleness check handles recovery automatically on the next run. No manual action is needed unless a run is confirmed dead before 30 minutes elapse (delete the file manually in that case).

Use a conceptual try/finally structure — treat "release lock" as the final step in every termination path listed above. Never exit without checking this list.

---

## Phase 1: Diff Analysis → Journey List

1. **Get touched files:**

   ```bash
   git show --stat "$SHA" | grep '|' | awk '{print $1}'
   ```

2. **Get PR title + body:**

   ```bash
   git log -1 --format='%s%n%n%b' "$SHA"
   ```

3. **Read the feature map:**

   Read `apps/admin/src/__feature-map__.json`. This file maps file globs to feature entries. Each entry has:
   - `feature`: human name (e.g. `"bank-connections"`)
   - `globs`: array of file glob patterns that trigger this feature
   - `journeys`: array of paths to journey spec markdown files (relative to repo root)
   - `url`: the staging URL path for this feature

   Match each touched file against the `globs` of every feature entry. Collect the union of all matching `journeys[]` paths.

4. **Docs-only short-circuit (run before full-suite fallback):**

   If `--force-full-suite` is NOT passed AND every touched file matches one of these patterns, skip the gate entirely and write an auto-approval with `reason: "docs-only"`:

   - `*.md` (any markdown)
   - `docs/**`
   - `scripts/**` (dev helpers, not runtime code)
   - `.github/**` with no workflow logic changes (comments/docs only)
   - `CHANGELOG`, `LICENSE`, `NOTICE`, `.gitignore`, `.editorconfig`

   ```bash
   TOUCHED=$(git show --stat "$SHA" | grep '|' | awk '{print $1}')
   DOCS_ONLY=true
   for f in $TOUCHED; do
     case "$f" in
       *.md|docs/*|scripts/*|CHANGELOG*|LICENSE*|NOTICE*|.gitignore|.editorconfig) ;;
       *) DOCS_ONLY=false; break ;;
     esac
   done
   ```

   If `DOCS_ONLY=true`:
   - Skip Phase 2–6 entirely
   - Write `.qa-approvals/<sha>.json` with:
     ```json
     {
       "sha": "<full sha>",
       "approved": true,
       "approved_at": "<ISO8601>",
       "approved_by": "qa-conta-gate",
       "reason": "docs-only",
       "touched_files": ["<path>", ...],
       "journeys_tested": [],
       "journeys_passed": 0,
       "journeys_failed": 0,
       "iterations_used": 0
     }
     ```
   - Release lock, commit `chore(qa): UX auto-approved (docs-only) for <short-sha>`, push
   - Optional Slack post (ℹ️ not ✅): `ℹ️ *UX auto-approved (docs-only):* <short-sha> — no runtime changes to test`
   - Exit 0

5. **Full-suite fallback:**

   If `--force-full-suite` is passed, OR (no touched files matched any feature glob AND the docs-only short-circuit did not apply), collect ALL journeys from ALL features in the feature map.

6. **Output:** a deduplicated list of journey spec file paths to run. Log the mapping:

   ```
   Touched files → matched features:
     apps/admin/src/pages/bank-connections/BankConnectionsPage.tsx → bank-connections
       journeys: apps/admin/src/pages/bank-connections/__journeys__/connect-bank.md
                 apps/admin/src/pages/bank-connections/__journeys__/disconnect-bank.md
   ```

---

## Phase 2: Journey Spec Loading / Generation

For each journey path identified in Phase 1:

**If the file exists:** Read it. A valid journey spec must declare:

```markdown
## Journey: <name>

**Prerequisites:** <role>, <company>, <setup state>
**URL:** <staging path>
**Steps:**
1. ...
**Acceptance Criteria:**
- ...
**Pass/Fail Heuristics:**
- PASS if: ...
- FAIL if: console errors, 4xx/5xx network calls, broken UI state, ...
```

**If the file is missing:** Generate a draft with a sonnet subagent:

```
Agent(
  model="sonnet",
  prompt="""Generate a journey spec for the Contably admin app feature at:
  Component: <component file path>
  Feature: <feature name>
  Staging URL: https://staging.contably.ai<url>

  Write a journey spec markdown following this template:
  ## Journey: <name>
  **Prerequisites:** ...
  **URL:** ...
  **Steps:** (numbered, concrete browser actions)
  **Acceptance Criteria:** (observable UI outcomes)
  **Pass/Fail Heuristics:** (what counts as pass, what counts as fail)

  Base the steps on the component's visible UI purpose.
  Be specific: 'click the "Connect Bank" button', not 'click a button'.
  """
)
```

Save the generated spec to the journey path with a header note:
```
> **NOTE:** Auto-generated draft — review and refine before relying on this spec.
```

After loading/generating all specs, persist a run manifest to `docs/qa/runs/<sha>-manifest.json`:

```json
{
  "sha": "<sha>",
  "started_at": "<ISO8601>",
  "journeys": [
    { "name": "<journey name>", "spec_path": "<path>", "url": "<url>", "draft": false }
  ]
}
```

---

## Phase 3: Parallel Browser Testing (Swarm)

### Persona matrix

Each feature in `__feature-map__.json` declares a `personas[]` array with `expected_access` values:

| `expected_access` | What the tester must verify |
|---|---|
| `full` | Positive test — journey must complete end-to-end |
| `read-only` | Positive test for allowed journeys; for journeys in `forbidden_actions`: the UI control must be hidden AND the API must return 403 |
| `none` | Forbidden-route test — `forbidden_routes` must redirect or 403; no admin chrome visible |
| `scoped` | Reserved for future (e.g. per-department access) |

**Superadmin special-case:** personas with `requires_company_switch: true` get an extra first step in every journey — pick a target company via the UI switcher before any feature interaction. The JWT has `company_id=null` for superadmins.

Build a **test matrix** of `persona × journey` cells:
- Skip cells where the journey is not in the persona's `journeys` array AND not in `forbidden_actions`/`forbidden_routes`
- Expand cells: for a forbidden cell, generate a *forbidden-path* test variant (expects hidden UI + 403 API) instead of the positive journey

Example for `bank-connections` with 4 personas × 3 journeys:
- superadmin × 3 journeys = 3 positive cells (with company-switch)
- manager × 3 journeys = 3 positive cells
- analyst × list = 1 positive + analyst × {connect, disconnect} = 2 forbidden-action cells
- client_portal × / = 1 forbidden-route cell (no journey — just verify redirect)
- Total: ~10 cells, run in 2 batches of ≤5 parallel haiku agents

**CRITICAL: Spawn all testers for one batch in a single message.** If more than 5 cells, batch them in groups of up to 5 — spawn the first batch, wait for results, spawn the next batch.

For each batch, spawn haiku agents in parallel:

```
# Spawn all in ONE message (parallel-first rule):
Agent(model="haiku", description="journey tester: <journey-name>", prompt="...")
Agent(model="haiku", description="journey tester: <journey-name>", prompt="...")
...
```

### Tester Spawn Prompt Template

Each tester receives:

```
You are a browser tester for Contably staging. Execute the following user journey
AS A SPECIFIC PERSONA and return a structured JSON result.

## Target
- Base URL: https://staging.contably.ai
- Credentials: read from ~/.claude-setup/secrets/contably-staging.env
  (source it: `source ~/.claude-setup/secrets/contably-staging.env`)
  Use the credential block matching this persona's `credentials_ref`:
    ${<credentials_ref>}_EMAIL, ${<credentials_ref>}_PASSWORD, ${<credentials_ref>}_COMPANY_ID
  Example: credentials_ref=STAGING_TEST_MANAGER → $STAGING_TEST_MANAGER_EMAIL etc.
- Session tag: <SESSION_TAG> (passed by orchestrator — prefix ALL records you create with this tag,
  e.g. "[<SESSION_TAG>] Test Bank Connection". Never create records without the prefix.)

## Persona profile
- id: <persona.id>
- role: <persona.role>
- expected_access: <full|read-only|none>
- test_variant: <positive | forbidden_action:<journey> | forbidden_route:<path>>
- requires_company_switch: <true|false> — if true, pick target company via UI switcher as step 0

## Journey Spec
<paste full journey spec markdown here>

## Test variant rules
- variant=positive: execute all journey steps; every acceptance criterion must pass
- variant=forbidden_action: navigate as usual, but verify the gated UI control is NOT present AND a direct API call to the forbidden endpoint returns 403. PASS = UI hidden + API 403. FAIL = UI visible OR API 2xx
- variant=forbidden_route: navigate to the forbidden route; PASS = redirect to an allowed page OR 403 page rendered. FAIL = admin chrome visible OR 2xx response with feature content

## Browser Tool
Use agent-browser (primary). Fallback chain: agent-browser → browse CLI → mcp__chrome-devtools__*

Detection:
  command -v agent-browser >/dev/null 2>&1 && echo "agent-browser" || \
    (test -x ~/.local/bin/browse && echo "browse" || echo "mcp")

agent-browser commands:
  agent-browser open <url>           — navigate
  agent-browser snapshot            — list interactive elements with @e refs
  agent-browser diff snapshot       — diff vs previous state
  agent-browser screenshot [path]   — capture screenshot
  agent-browser get text            — full page text
  agent-browser click @e3           — click by ref
  agent-browser fill @e4 "value"    — fill input by ref
  agent-browser console             — console logs (check after EVERY interaction)
  agent-browser network requests    — network calls (check for 4xx/5xx)
  agent-browser errors              — uncaught JS exceptions

## Instructions
1. Source credentials: `source ~/.claude-setup/secrets/contably-staging.env`
2. Prefix ALL records you create with the session tag `[<SESSION_TAG>]` (e.g. `[<SESSION_TAG>] Test Bank Connection`). Never create staging records without the prefix — concurrent sessions would otherwise collide.
3. Execute each step in the journey spec using agent-browser
4. After EVERY interaction: run `agent-browser console` and `agent-browser network requests`
5. Capture a screenshot on failure: `agent-browser screenshot /tmp/qa-gate-<journey-slug>-<step>.png`
6. Record evidence: console errors, network errors, UI state diffs
7. Evaluate against the Pass/Fail Heuristics in the spec

## Return Format
Return ONLY a JSON object (no markdown wrapper):
{
  "journey": "<journey name>",
  "status": "pass" | "fail" | "error",
  "steps_completed": <N>,
  "steps_total": <N>,
  "evidence": [
    { "step": <N>, "action": "<description>", "outcome": "<observed>", "pass": true|false }
  ],
  "console_errors": ["<error message>", ...],
  "network_errors": [{ "url": "<url>", "status": <code> }, ...],
  "screenshots": ["/tmp/qa-gate-<slug>-<step>.png", ...],
  "failure_summary": "<one-sentence summary if status=fail>",
  "duration_sec": <N>
}
```

### Collecting Results

After all testers in a batch complete, collect their JSON results. Parse each result:

- `status: "pass"` → journey green
- `status: "fail"` → journey failed; add to failing list with evidence
- `status: "error"` → tester crashed; retry with a fresh agent (max 2 retries per journey before treating as fail)

Persist all results to `docs/qa/runs/<sha>.json` (gitignored):

```json
{
  "sha": "<sha>",
  "iteration": 1,
  "results": [<journey result objects>],
  "summary": { "pass": N, "fail": N, "error": N }
}
```

---

## Phase 4: Fix Loop (max N iterations, default 3)

Parse `--max-iterations=N` from args (default 3). Track `iteration = 1`.

```
WHILE failing_journeys is not empty AND iteration <= max_iterations:
  1. For each failing journey, invoke /investigate
  2. For each root cause, invoke /qa-fix
  3. If any fix touches CRITICAL UX area → confirm with user first (AskUserQuestion)
  4. Commit and push fixes
  5. Wait for staging redeploy
  6. Retest ONLY the failing journeys (spawn parallel haiku testers)
  7. Update failing_journeys list
  iteration += 1

IF still failing after max_iterations:
  → AskUserQuestion to escalate
  → Set approval status = rejected
  → Skip to Phase 5 (write rejected signal) and Phase 6 (Slack report)
```

### Step 4.1: Investigate Failures

For each distinct failing journey, invoke `/investigate` via Skill tool, passing:
- The journey spec
- The failure evidence (console errors, network errors, step outcomes)
- The relevant source file(s) inferred from the journey URL and feature map

```
Skill("investigate", args="Investigate staging failure in <feature> journey. Evidence: <summary>")
```

Group failures by likely root cause before calling `/qa-fix` — same root cause = one fix.

### Step 4.2: Apply Fixes

```
Skill("qa-fix", args="Fix <root cause summary> in <file(s)>")
```

**CRITICAL UX escalation check:** Before fixing, assess severity:
- If the fix involves authentication flow, payment processing, or data deletion: escalate via `AskUserQuestion`
- All other fixes: proceed autonomously

### Step 4.3: Commit and Push

```bash
git add apps/admin/src/ apps/api/src/ apps/client-portal/src/  # specific dirs only
git commit -m "fix(qa-gate): <one-line summary of fix>"
git push origin main
```

### Step 4.4: Wait for Staging Redeploy

```bash
# Find the latest GHA run triggered by our push
unset GITHUB_TOKEN && gh run list --repo Contably/contably --limit 1 --json databaseId --jq '.[0].databaseId'

# Watch it
unset GITHUB_TOKEN && gh run watch <RUN_ID> --repo Contably/contably --exit-status
```

If the run fails, abort the fix loop and escalate to user with the CI failure details.

### Step 4.5: Retest Failing Journeys Only

Spawn haiku testers for ONLY the journeys that failed in the previous iteration (same spawn template as Phase 3). Update `docs/qa/runs/<sha>.json` with `"iteration": N` results.

---

## Phase 5: Write UX Approval Signal

### All-Green Path

On all journeys passing (iteration ≤ max_iterations):

1. Create `.qa-approvals/` at repo root if it doesn't exist:
   ```bash
   mkdir -p .qa-approvals
   ```

2. Write the signal file:

   ```json
   {
     "sha": "<full sha>",
     "approved": true,
     "approved_at": "<ISO8601>",
     "approved_by": "qa-conta-gate",
     "journeys_tested": ["<journey name>", ...],
     "journeys_passed": N,
     "journeys_failed": 0,
     "iterations_used": N,
     "max_iterations": N,
     "duration_sec": <total elapsed>,
     "run_manifest": "docs/qa/runs/<sha>-manifest.json"
   }
   ```

3. Release lock and commit together:

   ```bash
   rm -f .qa-approvals/.lock
   git add .qa-approvals/<sha>.json
   # Note: .lock is gitignored — no need to git rm it
   git commit -m "chore(qa): UX approved for <short-sha>"
   git push origin main
   ```

   On commit conflict (someone else pushed meanwhile):
   ```bash
   git pull --rebase origin main && git push origin main  # retry up to 3×
   ```

### Rejected Path

If fix loop exhausted without all-green:

```json
{
  "sha": "<full sha>",
  "approved": false,
  "rejected_at": "<ISO8601>",
  "rejected_by": "qa-conta-gate",
  "journeys_tested": ["<journey name>", ...],
  "journeys_passed": N,
  "journeys_failed": M,
  "iterations_used": <max_iterations>,
  "failing_journeys": [
    { "journey": "<name>", "failure_summary": "<reason>" }
  ],
  "action_required": "Manual investigation required before production promotion."
}
```

Release lock and commit:

```bash
rm -f .qa-approvals/.lock
git add .qa-approvals/<sha>.json
git commit -m "chore(qa): UX rejected for <short-sha>"
git push origin main
```

The rejected signal also blocks `/deploy-conta-production`. Use the same rebase retry loop for push conflicts.

---

## Phase 6: Slack Report

Invoke the `/slack` skill to post to channel `C0AS64REV4J` (Nuvini):

```
Skill("slack", args="post to C0AS64REV4J: <message>")
```

### Message Template (All-Green)

```
✅ *UX APPROVED:* `<short-sha>`

*Journeys tested:* <N> (<list of names>)
*Iterations:* <N> of <max>
*Duration:* <Xm Ys>
*PR:* <link if available from git log>

Signal: `.qa-approvals/<sha>.json` committed to main.
Ready for: `/deploy-conta-production`
```

### Message Template (Rejected)

```
❌ *UX REJECTED:* `<short-sha>`

*Journeys tested:* <N total> — <N passed> passed, <N failed> failed
*Iterations:* <max> (exhausted)
*Duration:* <Xm Ys>
*PR:* <link if available>

*Failing journeys:*
• <journey name>: <failure_summary>
• <journey name>: <failure_summary>

Action required: investigate and fix before re-running `/qa-conta-gate <sha>`.
```

If the Slack post fails (network error, auth issue): log a warning and do NOT fail the gate — the approval signal file is the canonical source of truth.

---

## Final Report

### user-direct mode (markdown table)

```markdown
# QA Gate Report — <short-sha>

| Field             | Value                          |
| ----------------- | ------------------------------ |
| SHA               | `<full sha>`                   |
| Status            | ✅ APPROVED / ❌ REJECTED        |
| Journeys tested   | <N>                            |
| Journeys passed   | <N>                            |
| Journeys failed   | <N>                            |
| Iterations used   | <N> / <max>                    |
| Total duration    | <Xm Ys>                        |
| Signal file       | `.qa-approvals/<sha>.json`     |
| Slack             | Posted to C0AS64REV4J          |

## Journey Results

| Journey            | Status | Iterations to pass | Evidence         |
| ------------------ | ------ | ------------------ | ---------------- |
| connect-bank       | ✅ pass | 1                  |                  |
| bank-statement-...  | ❌ fail | 3 (exhausted)      | console error: X |

## Auto-Fixes Applied (if any)

- fix(qa-gate): <summary> → commit `<sha>`
```

### agent-spawned mode (structured JSON)

```json
{
  "sha": "<sha>",
  "approved": true|false,
  "journeys_passed": N,
  "journeys_failed": N,
  "iterations_used": N,
  "signal_file": ".qa-approvals/<sha>.json",
  "slack_posted": true|false,
  "duration_sec": N
}
```

---

## Error Recovery Table

| Failure                           | Action                                          | Max Retries |
| --------------------------------- | ----------------------------------------------- | ----------- |
| Staging API unhealthy             | Poll 3× every 30s, then abort                   | 3           |
| Journey spec missing              | Generate draft with sonnet, continue            | 1           |
| Browser tester crashes (error)    | Retry with fresh agent-browser session          | 2           |
| Fix loop doesn't resolve          | Abort after N iterations, escalate via AskUserQuestion | N (default 3) |
| Signal file commit conflict       | `git pull --rebase && git push`                 | 3           |
| GHA redeploy run fails            | Abort fix loop, escalate to user                | 0           |
| Slack post fails                  | Log warning, do not fail gate                   | 0           |
| CRITICAL UX issue in fix scope    | AskUserQuestion before proceeding               | — (user decides) |
| Lock held by another run          | ABORT with session/sha/host info (Phase 0.5)    | 0           |
| Stale lock (> 30 min old)         | Overwrite lock, log warning, continue           | 1           |

---

## Integration Points

### Called by

- Human: `qa-conta-gate <sha>` after a green staging deploy
- Routine / `/contably-eod` autonomous pipeline (agent-spawned context)

### Calls

| Skill              | When                                                     |
| ------------------ | -------------------------------------------------------- |
| `agent-browser`    | Each haiku tester uses it for browser automation         |
| `investigate`      | Per failing journey in the fix loop                      |
| `qa-fix`           | Per root cause identified by investigate                 |
| `slack`            | Phase 6 report to C0AS64REV4J                           |

### Consumed by

- `/deploy-conta-production` — checks `.qa-approvals/<sha>.json` for `"approved": true` before promoting

### Gitignored paths (add if not present)

```
docs/qa/runs/
.qa-approvals/.lock
```

**Lock file is gitignored.** Ensure `.qa-approvals/.lock` is in the repo's
`.gitignore` before the first run. The approval signal files
(`.qa-approvals/<sha>.json`) ARE committed; only the lock file is ephemeral
and must never be committed.

### Committed paths

```
.qa-approvals/<sha>.json   ← the canonical gate signal
```
