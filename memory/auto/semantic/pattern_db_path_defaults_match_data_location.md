---
name: pattern-db-path-defaults-match-data-location
description: When a CLI resolves DB path via `defaults.db_path()` with an env override, the default MUST match where data actually lives — otherwise interactive commands silently open a stub DB and fail with "no such table", while systemd services with explicit `--db` flags keep working. Audit both paths during version cutovers.
type: pattern
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
When a tool resolves a DB path via a defaults helper with an env var override, **the default MUST match where data actually lives on every deployment**. If systemd units pass `--db /abs/path` but interactive CLI falls through to `defaults.db_path()`, the two will diverge the moment a version bump changes the default.

**Why:** Hit 2026-04-23 on PSOS. Engine v0.4.9 → v0.5.0 cutover. `psos_core.defaults.db_path()` returns `/opt/psos/<instance>/psos.db`, but real data lived at `/opt/contably-os/db/contably-os.db`. Systemd services passed `--db` explicitly and kept working. But any operator running `psos v3 status` interactively hit an auto-created empty stub DB and saw `OperationalError: no such table: psos_task`. This masks the actual engine state and makes debugging pure guesswork.

**How to apply:**
- During any install-path or version cutover, run the CLI **without** any `--db` flag and confirm it opens the real DB. If it doesn't, either (a) move the data to match the new default, or (b) export the env var (`PSOS_DB_URL`) in the EnvironmentFile the shell sources.
- When writing a `defaults.db_path()` style helper, the docstring should list every env var override so operators don't have to grep the source.
- Prefer moving data to canonical locations over perpetual env-var bridges — bridges rot silently.
- After any path migration, verify with: `<cli> status` interactively (no flags) + `systemctl start <svc>` (uses flags) + read journal. Both must succeed.

## Timeline

- **2026-04-23** — [failure] PSOS engine post-cutover: systemd tick worked, but `psos v3 status` crashed with "no such table: psos_task". Root cause: `defaults.db_path()` pointed at `/opt/psos/psos/psos.db` while data lived at `/opt/contably-os/db/contably-os.db`. Fix: moved DB to match defaults. (Source: session — PSOS migration 2026-04-23, Contably VPS root@100.77.51.51)

## Related

- [psos-migration-2026-04-23-complete](../projects/psos_migration_2026-04-23_complete.md) — the migration that surfaced this
