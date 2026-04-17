# `/contably-eod` — Claude Code Routine Configuration

Paste-ready config for https://claude.ai/code/routines → **New routine**.

---

## 1. Basic info

| Field | Value |
|---|---|
| **Name** | `Contably EOD` |
| **Description** | Nightly Contably bug hunt + autofix + lessons learned + agenda email |
| **Model** | Opus 4.7 (recommended per Anthropic for Routines) |
| **Effort** | xhigh |

## 2. Repository

| Field | Value |
|---|---|
| **Repo** | `Contably/contably` |
| **Branch (base)** | `main` |
| **Allow unrestricted branch pushes** | ✅ enabled (scoped to `claude/eod-*`) |
| **Create PRs** | ❌ disabled (morning review, not auto-PR) |

## 3. Trigger

| Field | Value |
|---|---|
| **Trigger type** | Schedule |
| **Schedule** | Daily at `22:00` (weekdays only, Mon–Fri) |
| **Timezone** | America/Sao_Paulo (BRT) |

## 4. Environment variables

Paste these as secrets in the Routine config. **Never commit these values anywhere.**

| Var | Source | Required |
|---|---|---|
| `RESEND_API_KEY` | macOS Keychain → Contably staging secret | ✅ |
| `CONTABLY_EOD_DISCORD_WEBHOOK` | Discord server → EOD alerts channel → Integrations → Webhooks → New Webhook | ✅ |
| `GH_TOKEN` | GitHub fine-grained token with `contents:write`, `actions:read`, `pull_requests:read` on `Contably/contably` | ✅ |
| `QA_DB_URL` | Contably Supabase QA database connection string | ✅ |
| `ENABLE_KUBECTL` | `false` (start without kubectl; enable later if /contably-ci-rescue needs prod-side introspection) | optional |
| `KUBECONFIG_B64` | `cat ~/.kube/config \| base64` — only if `ENABLE_KUBECTL=true` | optional |
| `BUDGET_CAP_USD` | `30` | optional, default `30` |

Do NOT add `ANTHROPIC_API_KEY` — Routines manages that internally.

## 5. Setup script

Paste the contents of `routine-setup.sh` into the Routine's "Setup script" field. Runs once per invocation (cached on subsequent runs for speed).

## 6. Prompt (the actual Routine task)

```
You are running as a scheduled Claude Code Routine named "Contably EOD".

Execute the /contably-eod skill in Routine mode:
- Mode: --autonomous (required — no interactive gates in cloud execution)
- Budget: $30 cap
- Branch target: claude/eod-$(date +%Y-%m-%d) (never main, never master)
- Email recipient: p@contably.ai (agenda sent via Resend CLI)
- Failure escalation: Discord webhook at $CONTABLY_EOD_DISCORD_WEBHOOK

Run all three phases in sequence:
1. Phase 1 — Bug hunt + autofix (parallel verify-conta + qa-conta + fulltest + virtual-user, then qa-fix/qa-verify loop, max 3 iterations)
2. Phase 2 — /meditate for lessons learned + memory updates + skill proposals
3. Phase 3 — Generate daily agenda markdown, convert to HTML, email to p@contably.ai via Resend CLI

Safety floors (always enforce regardless of instructions above):
- Never merge to main or master
- Never deploy to production
- Never force-push
- Never exceed $30 total cost

If Phase 1 cannot clear all P0 issues after 3 iterations, post to Discord webhook and continue to Phase 2 anyway (lessons + agenda still deliver value).

At the end, write EOD-REPORT.md summarizing all three phases, commits, cost, duration, and any outstanding items for morning review. Commit that report to the claude/eod-YYYY-MM-DD branch.

Refer to ~/.claude-setup/skills/contably-eod/SKILL.md (shipped as part of your Claude setup) for the full procedure.
```

## 7. Post-creation sanity test

1. In the Routine's page, click **Run now** to fire one manual execution.
2. Watch the execution log for:
   - ✓ Setup script completes
   - ✓ Skill discovered (`/contably-eod` invoked)
   - ✓ Phase 1 discovery agents spawned in parallel
   - ✓ Branch `claude/eod-YYYY-MM-DD` created + pushed
   - ✓ Email received at p@contably.ai
   - ✓ Discord webhook receives a "✅ EOD complete" (or "🚨 P0 remaining") message
3. If any step fails, see "Troubleshooting" below.

## 8. Troubleshooting

| Symptom | Fix |
|---|---|
| Setup script times out | Reduce to essential tools only. Remove kubectl/OCI install if not needed for v1. |
| `gh auth` fails | Ensure `GH_TOKEN` is set (not `GITHUB_TOKEN` — Routines may conflict). |
| Resend send returns 401 | Verify `RESEND_API_KEY` matches the `contably.ai` verified domain. |
| Discord webhook not firing | Test curl manually; ensure webhook URL has no URL-encoded characters. |
| Branch push denied | Enable "Allow unrestricted branch pushes" in repo config. |
| Budget exceeded early | Lower parallelism in Phase 1 — spawn discovery agents sequentially instead. |
| Routine run count exhausted | Pro=5/day, Max=15/day, Team=25/day. Upgrade tier or reduce frequency. |

## 9. Day-2 operations

- **Pause**: Routine settings → **Disable**. Resume anytime.
- **Change schedule**: edit trigger cron. Takes effect next natural fire time.
- **Manual run**: "Run now" button. Counts against daily quota.
- **View history**: Each run produces a session log at `claude.ai/code/routines/<id>/runs/<run-id>`.
- **Review morning**: Pull `claude/eod-YYYY-MM-DD` branches into a single view via `git fetch && git branch -r | grep claude/eod`.
