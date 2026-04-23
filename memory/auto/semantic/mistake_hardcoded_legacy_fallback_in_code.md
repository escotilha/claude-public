---
name: mistake-hardcoded-legacy-fallback-in-code
description: During rename refactors (e.g. `contably-os` → `psos`), hardcoded legacy path fallbacks inside source files (not config) are the sneakiest source of regression — they only fire on env-var-absent code paths and silently write or read the wrong location. Grep the entire codebase for the legacy literal after the rename.
type: mistake
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
During rename refactors (project X → project Y), the ones that bite are **hardcoded fallback literals inside source files**, not config. They fire only on the less-common env-var-absent code paths and corrupt state silently.

**Why:** Hit 2026-04-23 on PSOS. After `contably-os` → `psos` rename, `psos_core/v3/ledger_events.py:168` still had:
```python
# Default: VPS path. Harness installations set CONTABLY_OS_DB_URL; if absent...
return Path("/opt/contably-os/db/contably-os.db")
```
Systemd units passed explicit paths so this fallback never executed in production. But any code path that called `ledger_events._db_path()` without setting `DB_URL` would write events to a nonexistent legacy file. Test suites and new code paths would hit it first.

Similarly, argparse `help=` defaults contained `/opt/contably-os/BRIEF.md` and `/opt/contably-os/DASHBOARD.md` — operators following the help text would write to the legacy path.

**How to apply:**
- After any rename, run: `grep -rn '<old-name>' <pkg>/ --include='*.py'` and categorize every hit as either:
  1. **Runtime path** — MUST patch (hardcoded fallbacks, argparse defaults, systemd ExecStart)
  2. **Documentation** — CAN leave (module docstrings, comments, help text about historical behavior)
  3. **Code-path literal** — e.g. `.contably-os/` as a per-project directory name (not the VPS install path) — DON'T blindly sed
- Write a follow-up PR to replace hardcoded fallbacks with calls to the defaults helper (`defaults.db_path()`, `defaults.brief_path()`, etc.) so the single source of truth is the helper.
- Grep test fixtures and CI configs too — they're the second-most-common place stale literals hide.

## Timeline

- **2026-04-23** — [failure] Post-cutover `/opt/contably-os/db/contably-os.db` still referenced in `v3/ledger_events.py:168` + CLI help text despite the rest of the codebase being migrated. Patched in-place, needs follow-up PR to use `defaults.db_path()`. (Source: session — PSOS migration 2026-04-23)

## Related

- [pattern-db-path-defaults-match-data-location](pattern_db_path_defaults_match_data_location.md) — adjacent gotcha about defaults/data mismatch
- [psos-migration-2026-04-23-complete](../projects/psos_migration_2026-04-23_complete.md)
