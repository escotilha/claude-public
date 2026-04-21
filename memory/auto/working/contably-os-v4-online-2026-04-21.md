---
name: Contably OS v3+v4 online 2026-04-21 — architecture snapshot
description: What's running in production as of 2026-04-21 end-of-day. Resume block for future sessions.
type: project
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
Contably OS v3 + v4 are merged to main and running autonomously on VPS (100.77.51.51) + Mac mini (100.66.244.112).

## Runtime layout

**VPS (100.77.51.51, Tailscale, root@):**
- Package at `/opt/contably-os/packages/contably-os/` (pip install -e; source rsync'd from build worktree until auto-deploy CI has a self-hosted runner)
- DB at `/opt/contably-os/db/contably-os.db` with contably_os_task + contably_os_ledger (v4 schema includes council_pending + council_reviewed)
- Systemd timers: contably-os-v3.timer (15min plan-one), -dashboard.timer (5min), -deadman.timer (30min), -pr-watcher.timer (10min)
- Dashboard at `/opt/contably-os/DASHBOARD.md`; killswitch sentinel at `/opt/contably-os/KILLSWITCH`
- Env (systemd drop-in /etc/systemd/system/contably-os-v3.service.d/oauth.conf): `CONTABLY_OS_ORCHESTRATOR_AUTH=oauth`, `CONTABLY_OS_CLIENT_SSH_HOSTNAME=100.66.244.112`

**Mac mini (100.66.244.112, Tailscale, 24/7):**
- `~/.claude-code-v3/dispatch.sh` + `~/.claude-code-v3/dispatch.sb` (SSH entrypoint from VPS with macOS sandbox-exec wrapper)
- Max plan OAuth at `~/.claude/.credentials.json` (token expires ~2026-08-27)
- LaunchAgent `ai.contably.os.refresh-creds` refreshes credentials.json from Keychain every 30 min
- Phase 6 hooks: PreCompact + SessionEnd call `contably-os handoff snapshot` for interactive sessions

## Autonomy gap list (end-of-day 2026-04-21)

Still needs a human:
1. **PR merging** — Pierre merges. Low-risk auto-merge is Task 36.
2. **Queue replenishment** — idle when seeds drain. Task 34.
3. **Ship-step recovery** — claude writes code then dies. Task 33 (in progress).
4. **Auto-deploy CI** — workflow exists, needs self-hosted runner. Task 35.
5. **OAuth token refresh** — 90d cycle. Task 37.
6. **Brief generation** — SQL-by-hand. Task 38.

## PRs merged to main today

#203 T1-4 skeleton loaders (autonomous), #204 Phase 5 observability (dogfooded), #205 Phase 6 interactive handoff (dogfooded), #206 T1-3 CSV export, #207 v3+v4 umbrella.

## How to resume

Read `docs/contably-os-v4/03-plan.md` on main for plan + decisions. Use `/primer` for session continuity.

Manual deploy (until Task 35):
```
cd /Volumes/AI/Code/contably-os4-build
rsync -az --exclude __pycache__ packages/contably-os/ root@100.77.51.51:/opt/contably-os/packages/contably-os/
ssh root@100.77.51.51 '/opt/contably-os/venv/bin/pip install -e /opt/contably-os/packages/contably-os --quiet'
```

Halt all: `ssh root@100.77.51.51 'touch /opt/contably-os/KILLSWITCH'`

---

## Timeline

- **2026-04-21** — [session] v3 shipped + autonomous loop live ~11am Brazil. v4 Phases 0-6 built + dogfooded in afternoon. pr_watcher_v3 added late afternoon. All merged to main via PR #207. Self-audit task dispatched as first post-v4 action per Pierre directive: "the first thing v4 will do is check recursively on what it just built and improve it."
