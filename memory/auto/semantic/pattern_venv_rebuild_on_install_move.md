---
name: pattern-venv-rebuild-on-install-move
description: Moving a Python install directory (`/opt/X/` → `/opt/Y/`) requires rebuilding the venv — pip-installed entrypoints have absolute shebangs (`#!/opt/X/venv/bin/python`) that break on rename. Use `python -m venv` + `pip install -e .` to rebuild; fast (~30s) for small dep trees.
type: pattern
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
Moving a Python install directory requires **rebuilding the venv**, not renaming it. Pip-installed console scripts (entry points) have absolute shebangs like `#!/opt/X/venv/bin/python` burned in at install time. `mv /opt/X /opt/Y` leaves every binary pointing at the now-missing `/opt/X/venv/bin/python`.

**Why:** Hit 2026-04-23 on PSOS. Migrating engine from `/opt/contably-os/` → `/opt/psos/`. Any attempt to `mv` the venv would have broken every `psos`, `contably-os`, `pip` binary. Instead: fresh `python3.12 -m venv /opt/psos/venv` + `pip install -e /opt/psos/psos-repo/psos-core`. Took ~30s for a small editable install.

**How to apply:**
- For the install move, the repo (source code) can be `mv`'d freely — only the venv needs rebuild.
- Command pattern:
  ```bash
  python3.12 -m venv /opt/Y/venv
  source /opt/Y/venv/bin/activate
  pip install --upgrade pip wheel
  pip install -e /opt/Y/path/to/pkg
  ```
- Verify: `which <cli>` shows new path; `<cli> --help` runs without errors; run a smoke command before swapping systemd units.
- If the venv has non-editable site-packages that are hard to reinstall (compiled C extensions with specific versions), pin via `pip freeze > /tmp/old-reqs.txt` before the move and `pip install -r /tmp/old-reqs.txt` after.
- systemd ExecStart lines must be patched to point at the new venv binary path in the same commit as the move.

## Timeline

- **2026-04-23** — [implementation] PSOS migration `/opt/contably-os/` → `/opt/psos/`. Rebuilt venv fresh in ~30s. Zero pip errors, all entrypoints worked. Alternative (rename + patch shebangs with sed) would have been brittle. (Source: session — PSOS migration 2026-04-23)

## Related

- [psos-migration-2026-04-23-complete](../projects/psos_migration_2026-04-23_complete.md)
