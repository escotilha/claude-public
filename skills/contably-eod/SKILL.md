---
name: contably-eod
description: "Contably end-of-day autonomous pipeline. Phase 1: full bug hunt + autofix (verify-conta, qa-conta, fulltest, virtual-user, qa-fix loop). Phase 2: meditate + lessons learned. Phase 3: daily agenda email to p@contably.ai. Schedulable via --as-routine. Triggers on: contably eod, end of day, contably end of day, nightly contably, daily agenda, /contably-eod."
argument-hint: "[--as-routine '<cron>'] [--budget=<usd>] [--no-email] [--max-fix-iterations=N] [--dry-run]"
user-invocable: true
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
  - WebFetch
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
tool-annotations:
  Bash: { destructiveHint: true, idempotentHint: false }
  Skill: { destructiveHint: false, idempotentHint: false }
contably-eod-config:
  default-budget-usd: 30
  budget-warn-usd: 20
  approval-password: "go"
  agenda-recipient: "p@contably.ai"
  discord-fail-webhook-env: "CONTABLY_EOD_DISCORD_WEBHOOK"
  max-fix-iterations: 3
  never-auto-merge-to-main: true
  never-deploy-to-prod: true
  model: opus
---

# `/contably-eod` — Contably End-of-Day Autonomous Pipeline

Runs three phases nightly:
1. **Bug hunt + autofix** (parallel QA + fix loop)
2. **Lessons learned** (meditate + memory + skill proposals)
3. **Daily agenda** (what shipped today → email to p@contably.ai)

**Scope:** Contably repo only. MUST be run from within the Contably working directory or it aborts.

**Safety floors (always on, mode-independent):**
- Never merges to `main` automatically
- Never deploys to production
- Never force-pushes
- Hard budget cap $30 (configurable)
- Fails loud to Discord when Phase 1 can't clear P0s after 3 iterations

---

## Invocation

```bash
# Manual run (gated by default)
/contably-eod

# Scheduled routine — 10pm BRT weekdays (01:00 UTC Tue-Sat)
/contably-eod --as-routine "0 1 * * 2-6"

# Tighter budget
/contably-eod --budget=20

# No email (just write the agenda file)
/contably-eod --no-email

# Dry run — print the plan, don't execute
/contably-eod --dry-run
```

---

## Execution Modes

`/contably-eod` runs in one of two modes:

| Mode | Detected by | Gate behavior | Branch target |
|---|---|---|---|
| **Interactive** | running inside a `claude` REPL, user present | `go` gates honored | current feature branch |
| **Routine** | env var `CLAUDE_ROUTINE_ID` set OR `--autonomous` flag | No gates (impossible in cloud); safety floors still enforced | `claude/eod-<date>` branch |

Routine mode is what fires on Anthropic's cloud at 22:00 BRT. Everything below adapts.

## Pre-Flight

1. **Repo lock:** `git remote get-url origin` must match Contably's origin. Abort otherwise.
2. **Mode detection:** set `MODE=routine` if `$CLAUDE_ROUTINE_ID` or `--autonomous`, else `MODE=interactive`.
3. **Clean working dir** (interactive only): uncommitted changes → abort. In Routine mode, the env is fresh-cloned so this is always clean.
4. **Branch check**:
   - Interactive: must be on a feature/work branch, NOT `main`/`master`.
   - Routine: create/checkout `claude/eod-$(date +%Y-%m-%d)` from `main` — never work on `main` directly.
5. **Budget bounds:** $10 ≤ budget ≤ $50.
6. **Required env vars (Routine mode)**: `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`, `RESEND_API_KEY`, `CONTABLY_EOD_DISCORD_WEBHOOK`. Missing any → write failure to stdout + Discord, exit 1.
7. **Optional env vars**: `KUBECONFIG_B64` (if present, decode to `~/.kube/config` for CI rescue paths), `OCI_CLI_KEY_CONTENT` (decode for OCI kubectl).
8. **Skip in Routine mode**: the startup summary gate. Proceed directly to Phase 1.

### Startup Summary

```
╔════════════════════════════════════════════════════════════╗
║ /contably-eod                                               ║
╠════════════════════════════════════════════════════════════╣
║ Repo     : contably (verified)                              ║
║ Branch   : <current>                                        ║
║ Date     : YYYY-MM-DD (BRT)                                 ║
║ Budget   : warn $20 / cap $30                               ║
║ Run dir  : .orchestrate/eod-YYYY-MM-DD/                     ║
║ Recipient: p@contably.ai                                    ║
║ Discord  : <webhook configured | NOT SET — fallback console>║
╠════════════════════════════════════════════════════════════╣
║ Safety floors (always on):                                   ║
║  · Never merges to main                                      ║
║  · Never deploys to production                               ║
║  · Never force-pushes                                        ║
║  · Fails loud to Discord if P0s remain after 3 iterations    ║
╚════════════════════════════════════════════════════════════╝
Type 'go' to proceed (or --autonomous to skip this gate in Routines).
```

In Routine mode: skip the gate, proceed automatically.

---

## Phase 1: Bug Hunt + Autofix (~30–60 min)

### 1.1 Parallel Discovery (single tool-call batch)

Spawn four discovery agents in parallel (per `parallel-first.md`):

| Agent | Skill | Model | Purpose |
|---|---|---|---|
| verify | `/verify-conta` | sonnet | ruff + mypy + pytest + tsc + eslint + build + vitest + gitleaks |
| api-qa | `/qa-conta` | sonnet | 395+ API endpoint tests + browser tests |
| pages | `/fulltest-skill` | haiku | Swarm page testers (console/network/visual) |
| personas | `/virtual-user-testing` | haiku | Role-based persona flows (manager/junior/group_admin/AF admin) |

**Opus 4.7 fan-out instruction** (required):
> Do not spawn a subagent for work you can complete directly. Spawn all four discovery agents in the same turn.

All results write to the QA DB (consolidated per project convention). Collect the consolidated issue count when all four return.

### 1.2 Fix Loop

For up to `max-fix-iterations` (default 3):

1. `/qa-fix` — picks highest-severity open issues, investigates, implements fixes. Uses model=opus per `feedback_opus_for_investigation.md`.
2. `/qa-verify` — re-runs the relevant tests, updates issue status.
3. Check budget: if spent ≥ warn threshold, inject a `go` gate on next iteration (unless `--autonomous`).
4. Check CI: if CI broke during the loop, auto-invoke `/contably-ci-rescue --latest`. If that fails after 3 rescue attempts, escalate.
5. Break early if all P0/P1/P2 are CLOSED/VERIFIED.

### 1.3 Commit Strategy

After each successful fix batch:
- Commit with `fix(<scope>): <description>` convention
- Push to current feature branch (NEVER `main`/`master`)
- NO PR creation during EOD (manual review in morning)

### 1.4 Failure Escalation → Discord

If after `max-fix-iterations` there are still open P0s:

```bash
curl -X POST "$CONTABLY_EOD_DISCORD_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "🚨 **Contably EOD — P0 remaining**",
    "embeds": [{
      "title": "EOD failed to clear P0s after 3 iterations",
      "color": 15158332,
      "fields": [
        {"name": "Date", "value": "<YYYY-MM-DD>", "inline": true},
        {"name": "Branch", "value": "<branch>", "inline": true},
        {"name": "P0 open", "value": "<count>", "inline": true},
        {"name": "Top issue", "value": "<title + ID>", "inline": false},
        {"name": "Run dir", "value": ".orchestrate/eod-YYYY-MM-DD/", "inline": false}
      ]
    }]
  }'
```

Write `phase-1-failed.json` with full issue list. Continue to Phase 2 anyway — lessons-learned and agenda still produce value.

### 1.5 Phase 1 Artifact

`.orchestrate/eod-<date>/phase-1-report.md`:
- Discovery counts (issues found per agent)
- Fix iterations (N of max)
- Issues closed / open / escalated
- CI rescue invocations (if any)
- Commits made today (SHAs)
- Budget spent so far

---

## Phase 2: Lessons Learned (~5–10 min)

Invoke `/meditate` with EOD context:

```
/meditate --context=eod --date=YYYY-MM-DD --run-dir=.orchestrate/eod-<date>/
```

`/meditate` runs its standard pipeline:
- Phase 1: Gather session context (tool calls, errors, corrections from the day's EOD run)
- Phase 3: Score and filter observations
- Phase 4: Save to `~/.claude-setup/memory/auto/` with source `session — /contably-eod`
- Phase 5: Generate meditation report
- Phase 5b: Wiki ingest for Contably
- **Phase 6 + 6a** (skill auto-generation): detect repeated patterns in last-30-days `.orchestrate/eod-*/` and propose new canonical chains or skills

### Skill Proposals Handling

If Phase 6a proposes a new skill/chain:
- In manual mode: surface to user via `AskUserQuestion` with `go` to save
- In Routine mode: save proposal to `.orchestrate/eod-<date>/skill-proposals.md` for morning review. **Never auto-commit a new skill during a Routine.**

### Phase 2 Artifact

`.orchestrate/eod-<date>/phase-2-meditate.md`:
- New memory entities created (names + types)
- Memory entities updated
- Skill proposals (for morning review)
- Top 3 learnings (1-line each)

---

## Phase 3: Daily Agenda (~2–5 min)

### 3.1 Collect

Run in parallel:

```bash
# Commits made today (08:00 BRT → now)
git log --since="today 08:00 BRT" --pretty=format:"%h|%ad|%an|%s" --date=iso

# Grouped by scope
git log --since="today 08:00 BRT" --pretty=format:"%s" | grep -oE '^(fix|feat|chore|refactor|test|perf|revert|debug)\([^)]+\)' | sort | uniq -c | sort -rn

# Deploys today (GitHub Actions)
gh run list --workflow=deploy-staging.yml --created=">=$(date -u +%Y-%m-%d)" --json databaseId,conclusion,headSha,displayTitle
gh run list --workflow=deploy-production.yml --created=">=$(date -u +%Y-%m-%d)" --json databaseId,conclusion,headSha,displayTitle

# PRs opened/merged today
gh pr list --state=all --search "created:>=$(date -u +%Y-%m-%d)" --json number,title,state,author,url
```

Consolidate:
- QA DB stats (fixed today, still open, new today)
- Phase 1 outcomes (counts + top unresolved)
- Today's tomorrow focus (pull from `/primer` or last few commit messages' trailers)

### 3.2 Agenda Markdown

Write `.orchestrate/eod-<date>/agenda-YYYY-MM-DD.md`:

```markdown
# Contably — Daily Agenda YYYY-MM-DD

## TL;DR
- N commits across M scopes
- K features shipped (feat)
- J fixes deployed (fix)
- Staging deploys: X green / Y failed
- Production deploys: Z (none, or list)

## What Shipped Today

### Features
- feat(sla): ... (SHA, PR#)
- feat(esocial): ... (SHA, PR#)

### Fixes
- fix(ci): ...
- fix(auth): ...

### Maintenance
- chore: ...

## QA Today
- Discovered: N issues (P0: a, P1: b, P2: c)
- Fixed + verified: M
- Still open: K (P0: x, P1: y) — see qa-db for details
- EOD autofix result: {clean | N P0s escalated to Discord}

## Lessons Learned (from /meditate)
- {top 3 insights}

## Proposed New Skills (from /meditate Phase 6a)
- {skill name} — {rationale}  [saved to skill-proposals.md for your review]

## Tomorrow's Top 3
1. {from QA DB unresolved P0/P1}
2. {from git log trailers or todo markers}
3. {from memory — stale TODOs}

## Cost
- EOD run: $X.XX / budget $30
- Tokens: orchestrator + subagents breakdown
```

### 3.3 Email via Resend CLI

```bash
resend emails send \
  --from "contably-eod@contably.ai" \
  --to "p@contably.ai" \
  --subject "Contably EOD — $(date +%Y-%m-%d)" \
  --html "$(cat .orchestrate/eod-<date>/agenda-<date>.html)"
```

Convert MD → HTML via pandoc or a minimal template. If Resend send fails:
- Fall back to `/agentmail` skill (AgentMail inbox relay)
- If both fail: write to file only and ping Discord: "EOD agenda saved locally, email unavailable"

### 3.4 Phase 3 Artifact

`.orchestrate/eod-<date>/phase-3-agenda.md` (same content as the emailed version, plus email delivery status).

---

## Final Report

`.orchestrate/eod-<date>/EOD-REPORT.md`:
- All three phase summaries
- Total cost
- Total duration
- Escalations (Discord alerts fired, if any)
- Skill proposals pending review
- Links to all sub-artifacts

If run as Routine: do NOT invoke `/meditate` recursively on the EOD run itself (Phase 2 already is `/meditate`). Just close out.

---

## Scheduling as a Claude Code Routine

Routines are cloud-hosted (Anthropic infrastructure), so `/contably-eod` runs nightly without any local machine being on.

**Create via web UI** (recommended — supports env vars + setup script):
1. Go to https://claude.ai/code/routines → **New routine**
2. Paste config from `~/.claude-setup/skills/contably-eod/routine-config.md`
3. Set trigger: daily 22:00 local (BRT), weekdays
4. Bind repo: `escotilha/contably`, enable "Allow unrestricted branch pushes" (scoped to `claude/*`)
5. Add env vars + setup script per `routine-setup.sh`

**Create via `/schedule` skill** (simpler, prompt-only):
```bash
/schedule create \
  --name contably-eod \
  --cron "0 22 * * 1-5" \
  --prompt "/contably-eod --autonomous" \
  --repo escotilha/contably
```
Note: this path doesn't expose env-var or setup-script config, so `/contably-ci-rescue` subtasks that need kubectl will fall back to console-only reporting.

**Routine limits:**
- Pro: 5 runs/day · Max: 15 · Team: 25
- Cloud MCP connectors only (no local MCP servers)
- Repo clones fresh each run; `claude/`-prefixed branches for writes
- No interactive prompts; `--autonomous` implicit

To manage: claude.ai/code/routines OR `/schedule list|pause|resume|delete`

---

## Environment Variables

| Var | Purpose | Required |
|---|---|---|
| `CONTABLY_EOD_DISCORD_WEBHOOK` | Discord webhook URL for P0 escalations | Recommended |
| `RESEND_API_KEY` | Email sender (already in Contably deploy secrets) | Required for email |
| `ANTHROPIC_API_KEY` | Model calls | Required |

Store all in macOS Keychain + `~/.claude-setup/.env` (excluded from git).

---

## Anti-Patterns

- **Never auto-merge to main.** EOD pushes to feature branches only. Morning review approves merges.
- **Never deploy to production.** Period. EOD is development-hygiene, not release.
- **Never force-push.** Protected branches + safety floor.
- **Never skip Phase 2 on the rationalization "Phase 1 was clean".** Lessons compound even on clean days.
- **Never silently fail.** If any of the 3 phases errors, the agenda says so (and Phase 1 hard-failures go to Discord).
- **Never exceed budget.** Hard stop at $30. No `go`-to-extend for scheduled runs.

---

## Integration with Other Skills

| Skill | Relationship |
|---|---|
| `/verify-conta` | Phase 1 discovery |
| `/qa-conta` | Phase 1 discovery |
| `/fulltest-skill` | Phase 1 discovery |
| `/virtual-user-testing` | Phase 1 discovery |
| `/qa-fix` + `/qa-verify` | Phase 1 fix loop |
| `/contably-ci-rescue` | Phase 1 when CI breaks |
| `/alembic-chain-repair` | Transitively via `/contably-ci-rescue` |
| `/meditate` | Phase 2 |
| `/schedule` | Scheduling via `--as-routine` |
| `/agentmail` | Phase 3 email fallback |
| `/orchestrate` | Can wrap `/contably-eod` as a canonical chain |

---

## Version

**v1.0.0** — 2026-04-17. Decisions locked: budget $30, never-merge-to-main, Discord fail-loud, agenda to p@contably.ai.
