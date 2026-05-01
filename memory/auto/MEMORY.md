# Memory Index

*Rebuilt 2026-04-30. 185 entries indexed.*

## Root

- [research-finding-karpathy-coding-guidelines.md](research-finding-karpathy-coding-guidelines.md) — CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering,

## Personal — preferences, credentials, host

- [personal/auto_review_own_prs.md](personal/auto_review_own_prs.md) — After opening any PR, Claude must auto-review it before reporting back. Spawn an independent reviewer agent (sonnet+, no shared context with
- [personal/cicd_runs_on_vps.md](personal/cicd_runs_on_vps.md) — All CI/CD for Contably (and Pierre's other repos) runs on the Contabo VPS via self-hosted GitHub Actions runners. No GitHub-hosted runners.
- [personal/contably_proprietary_no_billing.md](personal/contably_proprietary_no_billing.md) — Contably is Nuvini-internal proprietary tooling — no external paying customers, no billing, no pricing tiers, no payment processors. Strat
- [personal/contably_roadmap_priorities_2026Q2.md](personal/contably_roadmap_priorities_2026Q2.md) — Pierre's 3 priority directives for oxi engine roadmap execution as of 2026-04-28. Daily reconciliation, monthly closing, agent onboarding (i
- [personal/contably_staging_test_users.md](personal/contably_staging_test_users.md) — Canonical email + password mapping for the 6 Contably staging dev-switcher users (Master, Pedro, Sevilha, Ana, Carlos, Maria) — passwords 
- [personal/contably_test_user_ana.md](personal/contably_test_user_ana.md) — Ana is the canonical placeholder Sevilha analyst in Contably for narrative examples and test scenarios — use her, not made-up names
- [personal/contably_worktree_discipline.md](personal/contably_worktree_discipline.md) — All Contably work must be done in a dedicated worktree — never on main, never on oxi branches
- [personal/feedback_format_decisions_as_numbered_lists.md](personal/feedback_format_decisions_as_numbered_lists.md) — Pierre prefers every decision list (options, sub-tasks, halt-points, follow-ups) formatted as a numbered list, not bullets, so he can refer 
- [personal/feedback_full_review_correct_worktree.md](personal/feedback_full_review_correct_worktree.md) — When user asks to run /full-review (or any branch-gating skill) on work that lives in a different worktree, switch cwd to that worktree firs
- [personal/host_macmini_vs_laptop.md](personal/host_macmini_vs_laptop.md) — Pierre's primary Claude Code host is the Mac Mini — the Mini runs Claude Code sessions AND is the autonomous executor. Default to Mini unl
- [personal/host_this_is_mac_mini.md](personal/host_this_is_mac_mini.md) — PERMANENT — when Claude Code runs with hostname Mac-mini.local and user psm2, this session IS the Mac Mini itself. Never SSH to 100.66.244
- [personal/pierre_all_in_no_tap_outs.md](personal/pierre_all_in_no_tap_outs.md) — Pierre operates all-in. Don't recommend stopping, deferring, or "going to bed." Recommend the next action, even if it's hard or long.
- [personal/preference_opus_for_coding_logic.md](personal/preference_opus_for_coding_logic.md) — Explicit user preference (2026-04-21) — any subagent or session doing real coding logic must run on Opus, not Sonnet/Haiku
- [personal/reference_api_keys_keychain.md](personal/reference_api_keys_keychain.md) — All API keys (Resend, Brave, Exa, Turso) stored in macOS Keychain — settings.json uses ${VAR} references, never literal values. Source of 

## Semantic — patterns, mistakes, tech-insights

- [semantic/mistake_committed_hook_breaks_worktrees.md](semantic/mistake_committed_hook_breaks_worktrees.md) — A committed .claude/settings.json SessionEnd hook pointing at a decommissioned CLI binary silently breaks every oxi worker dispatch — work
- [semantic/mistake_gamification_oxi_branch_contamination.md](semantic/mistake_gamification_oxi_branch_contamination.md) — Accidentally committed a fix to the oxi worktree branch feat/sa-nfe-phase2-classification instead of main
- [semantic/mistake_gha_concurrency_cancel_no_replacement.md](semantic/mistake_gha_concurrency_cancel_no_replacement.md) — GHA workflow with `concurrency.cancel-in-progress: true` sometimes cancels the in-flight run on a fresh push but never fires the replacement
- [semantic/mistake_hardcoded_legacy_fallback_in_code.md](semantic/mistake_hardcoded_legacy_fallback_in_code.md) — During rename refactors (e.g. `contably-os` → `psos`), hardcoded legacy path fallbacks inside source files (not config) are the sneakiest 
- [semantic/mistake_main_dir_edits_during_oxi_run.md](semantic/mistake_main_dir_edits_during_oxi_run.md) — Editing in main working dir while oxi (or any concurrent agent) runs caused a stale-tree commit that deleted a file — always use a worktre
- [semantic/mistake_nested_asyncio_run_in_async_loop.md](semantic/mistake_nested_asyncio_run_in_async_loop.md) — Calling a sync function from an async coroutine, where the sync function does asyncio.run() internally, raises 'cannot be called from a runn
- [semantic/mistake_orchestrator_inMemory_state.md](semantic/mistake_orchestrator_inMemory_state.md) — Orchestrator tracking in-flight work only in RAM causes re-dispatch loops on restart — always persist status before launching
- [semantic/mistake_rebase_script_stale_origin_main.md](semantic/mistake_rebase_script_stale_origin_main.md) — Rebase helper that merges origin/main without first fetching it produces a no-op merge — branch ends up still missing the latest main comm
- [semantic/mistake_settings_bak_public_leak.md](semantic/mistake_settings_bak_public_leak.md) — 2026-04-21 incident — settings.json.bak-* file with literal API keys force-pushed to public GitHub because its filename didn't match the .
- [semantic/mistake_validate-storage-constraints-before-schema.md](semantic/mistake_validate-storage-constraints-before-schema.md) — Always confirm runtime environment constraints (which databases are available, where the skill runs) before writing schema.sql or any storag
- [semantic/pattern_autobrowse_failure_to_insight.md](semantic/pattern_autobrowse_failure_to_insight.md) — Self-improving browser automation — failure-to-insight retry loop that graduates winning workflows into reusable skills
- [semantic/pattern_db_path_defaults_match_data_location.md](semantic/pattern_db_path_defaults_match_data_location.md) — When a CLI resolves DB path via `defaults.db_path()` with an env override, the default MUST match where data actually lives — otherwise in
- [semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md](semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md) — v4 Phase 5/6 dogfood surfaced 3 sandbox bugs unit tests couldn't catch. Pattern is to trigger a real task before declaring an orchestrator "
- [semantic/pattern_full-skill-vs-flag-when-personas-diverge.md](semantic/pattern_full-skill-vs-flag-when-personas-diverge.md) — When a new skill overlaps with an existing skill but has different personas, context-loading, or council composition — build a full separa
- [semantic/pattern_learn-distill-encode-evolve.md](semantic/pattern_learn-distill-encode-evolve.md) — Meta-pattern Pierre named 2026-04-21. Every real-world failure → diagnosed → lesson extracted → baked into code/config/tests → teste
- [semantic/pattern_migration_importlib_date_prefix.md](semantic/pattern_migration_importlib_date_prefix.md) — Alembic migration files with date-prefix filenames (YYYYMMDD_HHMMSS_<hash>_slug.py) cannot be imported via dotted-path form — use importli
- [semantic/pattern_reasoning_sandwich.md](semantic/pattern_reasoning_sandwich.md) — Per-phase reasoning effort allocation (high for plan/verify, low for execute/format) beats uniform-max across multi-phase skills on Opus 4.7
- [semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md](semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md) — Hard lesson from Contably OS v4 Phase 2b — deny-default breaks dyld/Mach on modern macOS. Four iterations to land on a workable profile.
- [semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md](semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — When building a new skill that extends an existing family (cto, vibc, cpo, ship), spawn a one-shot Opus subagent to analyze 5–10 sibling s
- [semantic/pattern_transcript_to_memory_synthesis.md](semantic/pattern_transcript_to_memory_synthesis.md) — Overnight synthesis of raw transcripts into tier-routed memory pages, with cross-file motif promotion (≥3 sources → pattern page). Adopt
- [semantic/pattern_venv_rebuild_on_install_move.md](semantic/pattern_venv_rebuild_on_install_move.md) — Moving a Python install directory (`/opt/X/` → `/opt/Y/`) requires rebuilding the venv — pip-installed entrypoints have absolute shebang
- [semantic/reference_anthropic_skills_marketplace.md](semantic/reference_anthropic_skills_marketplace.md) — Official Anthropic skills repo registered as plugin marketplace; eval pipeline patterns adopted into skill authoring rules
- [semantic/research-finding-ultrareview-claude-code.md](semantic/research-finding-ultrareview-claude-code.md) — Claude Code /ultrareview research preview — cloud fleet of bug-hunting agents for pre-merge code review
- [semantic/tech-insight-prompt-cache-invalidation.md](semantic/tech-insight-prompt-cache-invalidation.md) — Mid-session tool-list or model changes invalidate the Anthropic prompt cache prefix and drop cache hit rate from ~90% to near 0 for the rest
- [semantic/tech-insight:mcp-agent-production-patterns.md](semantic/tech-insight:mcp-agent-production-patterns.md) — Anthropic guide on MCP vs direct API vs CLI for production agents — server design, context-efficient clients, skills pairing, CIMD/Vault a
- [semantic/tech-insight_contably_db_is_mysql_heatwave.md](semantic/tech-insight_contably_db_is_mysql_heatwave.md) — Contably production DB is MySQL HeatWave on OCI — not Postgres, not local Docker. Migrated 2026-03-28.
- [semantic/tech-insight_hermes-agent-learning-loop.md](semantic/tech-insight_hermes-agent-learning-loop.md) — Hermes Agent patterns — 5-layer harness model, skills-vs-memory, auto-skill-generation, and v0.11.0 interface-release additions (transport
- [semantic/tech-insight_nanoclaw-v2.md](semantic/tech-insight_nanoclaw-v2.md) — NanoClaw v2 — agent-to-agent communication, HITL approvals, 15 messaging platforms, Vercel partnership
- [semantic/tech-insight_non-interactive-ssh-path-trap.md](semantic/tech-insight_non-interactive-ssh-path-trap.md) — Hit 3 times today (Contably OS v3 dispatch.sh, v4 client_factory, hook shim tests). Universal pattern.
- [semantic/tech-insight_oke_api_key_vs_session_auth.md](semantic/tech-insight_oke_api_key_vs_session_auth.md) — Contably OKE on OCI sa-saopaulo-1 binds RBAC to a specific API key fingerprint, not the user OCID — only the Apr 19 2026 key works; new ke
- [semantic/tech-insight_psos_plan_tier_20x.md](semantic/tech-insight_psos_plan_tier_20x.md) — Pierre's Claude account is Max 20x (not 5x). PSOS + any tool that respects Anthropic plan tiers should default to `plan_tier="20x"` → 900 
- [semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md](semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md) — Subtle git quirk that broke 3 hook-script tests in Contably OS v4 Phase 6. Always seed an initial commit.
- [semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md](semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md) — Invoking a skill via the Skill tool from inside an orchestrator context does NOT forward args to the subprocess — the skill body runs but 

## Working — live state, handoff buffers

- [working/contably-os-v4-inputs.md](working/contably-os-v4-inputs.md) — Three design inputs captured 2026-04-21 during v3 Phase 1 E2E sign-off, to feed into v4 planning
- [working/contably-os-v4-online-2026-04-21.md](working/contably-os-v4-online-2026-04-21.md) — What's running in production as of 2026-04-21 end-of-day. Resume block for future sessions.
- [working/contably-overnight-cascade-2026-04-30.md](working/contably-overnight-cascade-2026-04-30.md) — Autonomous overnight CI cascade resolution — Pierre approved /loop self-pacing through PR merge cascade, throughput-scaling chain still in
- [working/resume_2026-04-22_overnight.md](working/resume_2026-04-22_overnight.md) — Resume pointer for the Contably overnight engine session that was rate-limited at 22:40 local. Any new session should read this first.
- [working/resume_mary_restart_2026-04-23.md](working/resume_mary_restart_2026-04-23.md) — Mary restart COMPLETED 2026-04-23 03:40 — Discord verified end-to-end on Max plan via claude-cli

## Entities (legacy) — agents, deals, registries

- [entities/agent-memory-bella.md](entities/agent-memory-bella.md) — Bella agent identity — Chief Technology Officer, Contably (dedicated); owns all Contably engineering/infra/security/scaling; tech evaluati
- [entities/agent-memory-julia.md](entities/agent-memory-julia.md) — Julia agent identity — Product Manager for Contably; roadmap, user research, sprint planning, stakeholder mgmt; keeps eSocial/NF-e domain 
- [entities/agent-memory-marco.md](entities/agent-memory-marco.md) — Marco agent identity, operating preferences, investment thesis, and M&A research methodology — Nuvini Group M&A research analyst
- [entities/arnold-task-routing.md](entities/arnold-task-routing.md) — Pre-response checklist for routing tasks to skills, parallelization, or ad-hoc execution
- [entities/bella-systemd-routines.md](entities/bella-systemd-routines.md) — VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines survive reboots
- [entities/bella-tech-eval-kb.md](entities/bella-tech-eval-kb.md) — Persistent log of URL/tool evaluations with scores, verdicts, and reasoning — Bella agent tech research tracker
