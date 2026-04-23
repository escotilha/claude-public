---
name: psos-migration-2026-04-23-complete
description: PSOS engine fully migrated from /opt/contably-os → /opt/psos on VPS 2026-04-23 08:50Z. Engine running 20 dispatched tasks, killswitch off, Max 20x plan-tier default. Canonical path cleanup complete.
type: project
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
VPS at root@100.77.51.51 — full migration out of legacy `/opt/contably-os/` into canonical `/opt/psos/` hierarchy. Engine healthy: 20 running tasks, 8 planned, 204 merged, rate 110/900.

**Layout (new canonical):**
- `/opt/psos/venv/` — rebuilt Python 3.12 venv, `pip install -e /opt/psos/psos-repo/psos-core`
- `/opt/psos/psos/` — instance state (DB, BRIEF.md, DASHBOARD.md, sprint.state, STATE.md, push-relay, backups/)
- `/opt/psos/psos/psos.db` — live DB (moved from `/opt/contably-os/db/contably-os.db`)
- `/opt/psos/psos/backups/` — pre-cutover DB + code backups (retain 30d then archive)
- `/opt/psos/.env` — moved from `/opt/contably-os/.env`
- `/opt/psos/psos-repo/` — git checkout of escotilha/psos (v0.5.0)

**Why:** User wanted every `/opt/contably-os/` reference gone after the 2026-04-23 cutover. Simple rename impossible (`/opt/psos/psos/` already held instance state). Used a per-subdir move-then-rebuild-venv approach.

**How to apply:**
- Never pass `--db /opt/contably-os/...` to any psos CLI — the DB lives at `/opt/psos/psos/psos.db`
- Systemd units at `/etc/systemd/system/psos-v3*.service` all use `/opt/psos/venv/bin/psos` now
- Backups at `/root/systemd-backup-20260423/` contain original unit files for rollback
- Harness at `/opt/contably-os-harness/` is separate and unaffected

## Runtime bugs fixed in same session

1. **"no such table: psos_task"** — `psos_core.defaults.db_path()` returned `/opt/psos/psos/psos.db` but data was at `/opt/contably-os/db/contably-os.db`. CLI commands without `--db` hit the wrong DB. Fix: moved DB to match defaults.
2. **Plan-tier hardcoded to 5x** — engine reported "rate_limit: N/225 msg (5h window, Max 5x)" even though the account is Max 20x (900 msgs / 5h). Patched `cli.py` + `v3/dashboard.py` + `v3/dashboard_html.py` + `v3/deadman.py` to default to `20x`.
3. **Hardcoded legacy DB fallback in `ledger_events.py:168`** — `Path("/opt/contably-os/db/contably-os.db")` fallback when `DB_URL` unset. Patched in-place to `/opt/psos/psos/psos.db` (same code path will be cleaned up via proper PR later).

## Follow-ups (not blockers)

- Open PR upstream against `escotilha/psos` to carry forward: (a) `ledger_events.py` fallback using `defaults.db_path()` instead of hardcoded constant, (b) plan-tier default 20x, (c) all `/opt/contably-os/` help-text scrubbed.
- The "Harness installations set CONTABLY_OS_DB_URL" docstring in `db.py` is stale — the env var name is `PSOS_DB_URL` now.
- Delete `/opt/psos/psos/backups/` after 30 days of stable operation (2026-05-23).
- User confirmed: no rate limit, lock files all removed (no KILLSWITCH, no RELEASE_LOCK).

## Timeline

- **2026-04-23 08:36Z** — [investigation] User asked to look at PSOS. Found engine crashed with `no such table: psos_task`, main timer dead, killswitch set.
- **2026-04-23 08:38Z** — [discovery] Diagnosed DB mismatch: defaults pointed at `/opt/psos/psos/psos.db` (empty stub) while real data lived at `/opt/contably-os/db/contably-os.db`.
- **2026-04-23 08:42Z** — [action] Cleared killswitch, stopped all 16 psos-v3 timers, moved DB to new canonical path, migrated scratch state files (BRIEF/DASHBOARD/sprint.state/STATE.md), moved code dirs (psos-repo/docs/spec/sprints/engine/packages/logs/scaffolding), moved `.env`.
- **2026-04-23 08:44Z** — [action] Rebuilt venv at `/opt/psos/venv/` with editable install. `psos v3 status` now succeeds.
- **2026-04-23 08:45Z** — [action] Patched `ledger_events.py` hardcoded path + plan-tier defaults 5x→20x across cli.py + v3/dashboard.py + v3/dashboard_html.py + v3/deadman.py.
- **2026-04-23 08:46Z** — [action] Rewrote all 16 systemd service/timer units to use `/opt/psos/venv/bin/psos`, `/opt/psos/.env`, `/opt/psos/psos/psos.db`. Backed up originals to `/root/systemd-backup-20260423/`. `daemon-reload`. Patched `psos-v3-unlock.service` RELEASE_LOCK path.
- **2026-04-23 08:47Z** — [verification] Started timers + dashboard server. Ran manual tick — dispatched `t4-4-auto` successfully.
- **2026-04-23 08:48Z** — [action] User said "remove RELEASE AND ANY OTHER LOCKS". Found & removed `/opt/psos/psos/RELEASE_LOCK`.
- **2026-04-23 08:48Z** — [action] Moved all DB backups + `repo.pre-cutover/` into `/opt/psos/psos/backups/`. Deleted `/opt/contably-os/` entirely.
- **2026-04-23 08:50Z** — [verification] Engine status: 20 dispatched, 8 planned, 204 merged. Rate 110/900 Max 20x. Timer firing every 3 min. Zero `contably-os` references in systemd or runtime config.

## Gotchas discovered

1. **Rebuilding the venv is required** when moving install dir — old venv has absolute shebangs to `/opt/contably-os/venv/bin/python`. Fast (~30s) because psos-core is a small dep tree.
2. **Argparse `prog=` string still says "contably-os"** in CLI help output — cosmetic, not functional. Need upstream fix.
3. **`contably-os-harness` directory is unrelated** to the engine — don't touch it during PSOS migrations.
4. **`daemon-reload` required after patching unit files** — systemd caches loaded units. Started timers won't pick up path changes without reload.
5. **Dashboard server must be stopped before moving the DB** — it opens a read handle on the sqlite file. Systemctl stop it, then move, then restart.

## Related

- [psos-cutover-2026-04-23-complete](psos_cutover_2026-04-23_complete.md) — 2026-04-23 06:33Z cutover (the predecessor that set up this migration)
- `/Volumes/AI/Code/contably/docs/psos-cutover-2026-04-23.md` — original cutover runbook
