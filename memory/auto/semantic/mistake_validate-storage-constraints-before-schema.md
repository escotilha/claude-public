---
name: mistake:validate-storage-constraints-before-schema
description: Always confirm runtime environment constraints (which databases are available, where the skill runs) before writing schema.sql or any storage layer code
type: reference
originSessionId: 83e0ba78-5cea-4191-8d3d-6552e29eaaa5
---
Writing a schema before validating the runtime environment is expensive to fix. The pattern to avoid:

1. Copy an existing skill's schema (e.g. `/vibc`'s Postgres schema)
2. Build out 10+ migration files / schema.sql
3. Discover the constraint: skill must run on Mac mini AND VPS → no Postgres available
4. Port everything to SQLite

**Fix/correct approach:**
Before writing any schema or storage layer for a new skill:
1. Ask: "Where does this skill run?" (local Mac, VPS, cloud, all of the above?)
2. Ask: "What databases are guaranteed to be available at all those locations?"
3. For Claude Code skills running on personal infra: prefer SQLite at `~/.claude-setup/data/{skill}.db` unless Postgres availability is confirmed
4. Portability default: SQLite unless explicitly scoped to one machine that has Postgres

**General principle:** Validate environment constraints (OS, available services, network access, file paths) before designing the storage layer, not after.

---

## Related

- Cross-ref: mistake_settings_bak_public_leak — same class: writing artefacts before validating constraints (2026-04-21)
- Cross-ref: pattern:full-skill-vs-flag-when-personas-diverge — storage constraints are one of the key divergence factors in the skill vs flag decision (2026-04-21)

## Timeline

- **2026-04-21** — [failure] Initially cloned /vibc's Postgres schema for /conta-cpo, then had to port to SQLite after user confirmed skill must run on Mac mini OR VPS (no Postgres). Source: failure — schema rewrite during conta-cpo build session
- **2026-04-21** — Relevance score: 7. Use count: 0
