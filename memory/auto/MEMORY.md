# Memory Index

## Personal

- [this-session-is-on-the-mac-mini](personal/host_this_is_mac_mini.md) — **PERMANENT** — hostname=Mac-mini.local + user=psm2 + tailscale 100.66.244.112 means THIS session IS the Mini; never SSH to self

## Projects

- [mary-openclaw-operational-fixes](projects/project_mary_openclaw_fixes.md) — Mary/OpenClaw on VPS hard-won fixes from 2026-04-13, 2026-04-18, and 2026-04-23. Includes the 10-step Max-plan-via-claude-cli recovery sequence and the per-agent-vs-top-level sessions.json distinction that breaks Discord silently.
- [psos-cutover-2026-04-23-complete](projects/psos_cutover_2026-04-23_complete.md) — VPS swapped from contably-os 0.4.9 to psos-core 0.5.0. Blocked at dispatch by 7-day rate limit, resumes 19:00Z.
- [psos-migration-2026-04-23-complete](projects/psos_migration_2026-04-23_complete.md) — `/opt/contably-os/` fully migrated to `/opt/psos/` 2026-04-23 08:50Z. Engine live at 20 dispatched, Max 20x plan default, all locks cleared.

## Working (session state)

- [resume-mary-restart-2026-04-23](working/resume_mary_restart_2026-04-23.md) — Mary restart COMPLETED 2026-04-23 03:40. Discord verified on Max plan opus-4-7. Open items: OpenClaw 4.16→4.20 upgrade, MLX audit pending, memory reconciliation pending.

## Semantic

- [pattern-db-path-defaults-match-data-location](semantic/pattern_db_path_defaults_match_data_location.md) — After any version/install cutover, CLI defaults must open the same DB as systemd `--db` flags — else interactive commands silently hit a stub DB.
- [pattern-reasoning-sandwich](semantic/pattern_reasoning_sandwich.md) — Per-phase reasoning directives (plan=high, execute=low, verify=high) beat uniform-max on Opus 4.7 — applied to /ship, /parallel-dev, /cto.
- [mistake-hardcoded-legacy-fallback-in-code](semantic/mistake_hardcoded_legacy_fallback_in_code.md) — Rename refactors leak through hardcoded path literals inside source — grep the full codebase for the legacy name after the rename.
- [pattern-venv-rebuild-on-install-move](semantic/pattern_venv_rebuild_on_install_move.md) — Moving a Python install dir requires rebuilding the venv — pip entrypoints have absolute shebangs.
- [tech-insight-psos-plan-tier-20x](semantic/tech-insight_psos_plan_tier_20x.md) — Pierre's Claude account is Max 20x (900 msgs / 5h), not 5x. Default all plan-tier configs to `20x`.

## References

- [research-finding-karpathy-coding-guidelines.md](research-finding-karpathy-coding-guidelines.md) — CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering, orthogonal edits, and vague success criteria

# currentDate
Today's date is 2026-04-23.
