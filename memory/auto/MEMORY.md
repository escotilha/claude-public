# Memory Index

*Rebuilt 2026-04-27. 167 entries indexed.*

## Root

- [feedback_oxi_dogfood_session.md](feedback_oxi_dogfood_session.md) — Patterns from a 4-hour OXi install/release session — when to push back on autonomy, when to do work yourself, when to delegate to the engine
- [research-finding-karpathy-coding-guidelines.md](research-finding-karpathy-coding-guidelines.md) — CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering, o

## Personal — preferences, credentials, host

- [personal/feedback_format_decisions_as_numbered_lists.md](personal/feedback_format_decisions_as_numbered_lists.md) — Pierre prefers every decision list (options, sub-tasks, halt-points, follow-ups) formatted as a numbered list, not bullets, so he can refer 
- [personal/host_macmini_vs_laptop.md](personal/host_macmini_vs_laptop.md) — Pierre's primary Claude Code host is the Mac Mini — the Mini runs Claude Code sessions AND is the autonomous executor. Default to Mini unles
- [personal/host_this_is_mac_mini.md](personal/host_this_is_mac_mini.md) — PERMANENT — when Claude Code runs with hostname Mac-mini.local and user psm2, this session IS the Mac Mini itself. Never SSH to 100.66.244.1
- [personal/preference_opus_for_coding_logic.md](personal/preference_opus_for_coding_logic.md) — Explicit user preference (2026-04-21) — any subagent or session doing real coding logic must run on Opus, not Sonnet/Haiku
- [personal/contably_roadmap_priorities_2026Q2.md](personal/contably_roadmap_priorities_2026Q2.md) — Pierre's 3 directives for oxi roadmap execution: daily reconciliation, monthly closing, agent onboarding incl. gamification. Master tracker spans 3 docs in /contably/docs/.
- [personal/reference_api_keys_keychain.md](personal/reference_api_keys_keychain.md) — All API keys (Resend, Brave, Exa, Turso) stored in macOS Keychain — settings.json uses ${VAR} references, never literal values. Source of tr

## Semantic — patterns, mistakes, tech-insights

- [semantic/mistake_committed_hook_breaks_worktrees.md](semantic/mistake_committed_hook_breaks_worktrees.md) — A committed .claude/settings.json hook pointing at a decommissioned CLI breaks every oxi worker worktree dispatch; remove stale hooks after harness cutover
- [semantic/mistake_hardcoded_legacy_fallback_in_code.md](semantic/mistake_hardcoded_legacy_fallback_in_code.md) — During rename refactors (e.g. `contably-os` → `psos`), hardcoded legacy path fallbacks inside source files (not config) are the sneakiest so
- [semantic/mistake_nested_asyncio_run_in_async_loop.md](semantic/mistake_nested_asyncio_run_in_async_loop.md) — Calling sync fn from async coroutine where the sync fn does asyncio.run internally raises 'cannot be called from a running event loop' — wrap with asyncio.to_thread
- [semantic/mistake_oxi_engine_fork_target.md](semantic/mistake_oxi_engine_fork_target.md) — Deployed oxi engine reads from xurman/oxi (NOT Contably/oxi). Always confirm the target fork via git reflog before merging engine PRs.
- [semantic/tech-insight_oxi_scrub_home_only_via_ssh.md](semantic/tech-insight_oxi_scrub_home_only_via_ssh.md) — oxi scrub_home fix only fires through wrap_with_ssh; local-spawn workers (ssh_alias=None) still walk operator HOME. Follow-up needed for local cache-tax kill.
- [semantic/mistake_settings_bak_public_leak.md](semantic/mistake_settings_bak_public_leak.md) — 2026-04-21 incident — settings.json.bak-* file with literal API keys force-pushed to public GitHub because its filename didn't match the .ba
- [semantic/mistake_validate-storage-constraints-before-schema.md](semantic/mistake_validate-storage-constraints-before-schema.md) — Always confirm runtime environment constraints (which databases are available, where the skill runs) before writing schema.sql or any storag
- [semantic/pattern_autobrowse_failure_to_insight.md](semantic/pattern_autobrowse_failure_to_insight.md) — Self-improving browser automation — failure-to-insight retry loop that graduates winning workflows into reusable skills
- [semantic/pattern_migration_importlib_date_prefix.md](semantic/pattern_migration_importlib_date_prefix.md) — Load date-prefixed Alembic migration files in pytest via importlib.util.spec_from_file_location + stable sys.modules alias; patch.object against the alias
- [semantic/pattern_db_path_defaults_match_data_location.md](semantic/pattern_db_path_defaults_match_data_location.md) — When a CLI resolves DB path via `defaults.db_path()` with an env override, the default MUST match where data actually lives — otherwise inte
- [semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md](semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md) — v4 Phase 5/6 dogfood surfaced 3 sandbox bugs unit tests couldn't catch. Pattern is to trigger a real task before declaring an orchestrator "
- [semantic/pattern_full-skill-vs-flag-when-personas-diverge.md](semantic/pattern_full-skill-vs-flag-when-personas-diverge.md) — When a new skill overlaps with an existing skill but has different personas, context-loading, or council composition — build a full separate
- [semantic/pattern_learn-distill-encode-evolve.md](semantic/pattern_learn-distill-encode-evolve.md) — Meta-pattern Pierre named 2026-04-21. Every real-world failure → diagnosed → lesson extracted → baked into code/config/tests → tested again.
- [semantic/pattern_reasoning_sandwich.md](semantic/pattern_reasoning_sandwich.md) — Per-phase reasoning effort allocation (high for plan/verify, low for execute/format) beats uniform-max across multi-phase skills on Opus 4.7
- [semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md](semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md) — Hard lesson from Contably OS v4 Phase 2b — deny-default breaks dyld/Mach on modern macOS. Four iterations to land on a workable profile.
- [semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md](semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — When building a new skill that extends an existing family (cto, vibc, cpo, ship), spawn a one-shot Opus subagent to analyze 5–10 sibling ski
- [semantic/pattern_venv_rebuild_on_install_move.md](semantic/pattern_venv_rebuild_on_install_move.md) — Moving a Python install directory (`/opt/X/` → `/opt/Y/`) requires rebuilding the venv — pip-installed entrypoints have absolute shebangs (`
- [semantic/reference_anthropic_skills_marketplace.md](semantic/reference_anthropic_skills_marketplace.md) — Official Anthropic skills repo registered as plugin marketplace; eval pipeline patterns adopted into skill authoring rules
- [semantic/research-finding-ultrareview-claude-code.md](semantic/research-finding-ultrareview-claude-code.md) — Claude Code /ultrareview research preview — cloud fleet of bug-hunting agents for pre-merge code review
- [semantic/tech-insight_hermes-agent-learning-loop.md](semantic/tech-insight_hermes-agent-learning-loop.md) — Hermes Agent patterns — 5-layer harness model, skills-vs-memory, auto-skill-generation, and v0.11.0 interface-release additions (transport a
- [semantic/tech-insight_nanoclaw-v2.md](semantic/tech-insight_nanoclaw-v2.md) — NanoClaw v2 — agent-to-agent communication, HITL approvals, 15 messaging platforms, Vercel partnership
- [semantic/tech-insight_non-interactive-ssh-path-trap.md](semantic/tech-insight_non-interactive-ssh-path-trap.md) — Hit 3 times today (Contably OS v3 dispatch.sh, v4 client_factory, hook shim tests). Universal pattern.
- [semantic/tech-insight_psos_plan_tier_20x.md](semantic/tech-insight_psos_plan_tier_20x.md) — Pierre's Claude account is Max 20x (not 5x). PSOS + any tool that respects Anthropic plan tiers should default to `plan_tier="20x"` → 900 ms
- [semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md](semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md) — Subtle git quirk that broke 3 hook-script tests in Contably OS v4 Phase 6. Always seed an initial commit.
- [semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md](semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md) — Invoking a skill via the Skill tool from inside an orchestrator context does NOT forward args to the subprocess — the skill body runs but th
- [semantic/tech-insight-oxi-bare-mode-skips-hooks.md](semantic/tech-insight-oxi-bare-mode-skips-hooks.md) — Oxi workers run `claude -p --bare` by default — skips plugin hooks, auto-memory, and keychain auth for CI reproducibility. Global PreToolUse
- [semantic/tech-insight-prompt-cache-invalidation.md](semantic/tech-insight-prompt-cache-invalidation.md) — Mid-session tool-list or model changes invalidate the Anthropic prompt cache prefix and drop cache hit rate from ~90% to near 0 for the rest
- [semantic/tech-insight_oke_api_key_vs_session_auth.md](semantic/tech-insight_oke_api_key_vs_session_auth.md) — Contably OKE rejects API-key kubectl tokens but accepts session-token kubectl for same OCID — sessions are the only working path until cluster RBAC is fixed
- [semantic/tech-insight:mcp-agent-production-patterns.md](semantic/tech-insight:mcp-agent-production-patterns.md) — Anthropic guide on MCP vs direct API vs CLI for production agents — server design, context-efficient clients, skills pairing, CIMD/Vault aut

## Working — live state, handoff buffers

- [working/contably-os-v4-inputs.md](working/contably-os-v4-inputs.md) — Three design inputs captured 2026-04-21 during v3 Phase 1 E2E sign-off, to feed into v4 planning
- [working/contably-os-v4-online-2026-04-21.md](working/contably-os-v4-online-2026-04-21.md) — What's running in production as of 2026-04-21 end-of-day. Resume block for future sessions.
- [working/resume_2026-04-22_overnight.md](working/resume_2026-04-22_overnight.md) — Resume pointer for the Contably overnight engine session that was rate-limited at 22:40 local. Any new session should read this first.
- [working/resume_mary_restart_2026-04-23.md](working/resume_mary_restart_2026-04-23.md) — Mary restart COMPLETED 2026-04-23 03:40 — Discord verified end-to-end on Max plan via claude-cli
- [working/resume_oxi_cutover_2026-04-27.md](working/resume_oxi_cutover_2026-04-27.md) — OXi cutover paused at 22:11 UTC 2026-04-27 (97% context). Engine autonomous on Mini, 16+ PRs merged. Resume at 23:20 UTC / 20:20 BRT.
- [working/oxi-throughput-plan-2026-04-28.md](working/oxi-throughput-plan-2026-04-28.md) — Plan to take oxi from 26 PRs/day → 60-100/day. 4 parallel Opus CTO reviews synthesized; ordered fixes, dependencies, 4-day sequence.

## Entities (legacy) — agents, deals, registries

- [entities/agent-memory-bella.md](entities/agent-memory-bella.md) — Bella agent identity — Chief Technology Officer, Contably (dedicated); owns all Contably engineering/infra/security/scaling; tech evaluation
- [entities/agent-memory-julia.md](entities/agent-memory-julia.md) — Julia agent identity — Product Manager for Contably; roadmap, user research, sprint planning, stakeholder mgmt; keeps eSocial/NF-e domain ex
- [entities/agent-memory-marco.md](entities/agent-memory-marco.md) — Marco agent identity, operating preferences, investment thesis, and M&A research methodology — Nuvini Group M&A research analyst
- [entities/arnold-task-routing.md](entities/arnold-task-routing.md) — Pre-response checklist for routing tasks to skills, parallelization, or ad-hoc execution
- [entities/bella-systemd-routines.md](entities/bella-systemd-routines.md) — VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines survive reboots
- [entities/bella-tech-eval-kb.md](entities/bella-tech-eval-kb.md) — Persistent log of URL/tool evaluations with scores, verdicts, and reasoning — Bella agent tech research tracker
- [entities/buzz-daily-triage.md](entities/buzz-daily-triage.md) — Daily competitive signal triage for NVNI portfolio — scans TechCrunch, Crunchbase, LinkedIn for high-signal moves by OMIE, Brex, Stripe, and
- [entities/buzz-skill-matching.md](entities/buzz-skill-matching.md) — Living index of skill trigger patterns — when to invoke which skill, missed routing, parallelism opportunities
- [entities/buzz-triage-sample-2026-04-10.md](entities/buzz-triage-sample-2026-04-10.md) — Sample daily competitive brief output — 2026-04-10 — showing what Pierre would receive each morning
- [entities/claudia-heartbeat-tracker.md](entities/claudia-heartbeat-tracker.md) — Spec for heartbeat issue dedup — tracks active issues, prevents re-reporting, escalates persistent ones
- [entities/cris-investor-email-rules.md](entities/cris-investor-email-rules.md) — Cris email triage rules — investor classification, PERSONAL_REPLY_NEEDED flag, VIP routing
- [entities/cris-investor-email-triage-samples.md](entities/cris-investor-email-triage-samples.md) — Sample triage output showing PERSONAL_REPLY_NEEDED flag with rationale — 5 examples
- [entities/cris-nuvini-entity-registry.md](entities/cris-nuvini-entity-registry.md) — Canonical registry of all Nuvini Group entities — names, jurisdictions, ownership, status
- [entities/deal_stripe.md](entities/deal_stripe.md) — M&A deal intelligence page — Stripe (prospect)
- [entities/deal-template.md](entities/deal-template.md) — M&A deal intelligence page — {Company Name} ({status})
- [entities/julia-oci-health-monitor.md](entities/julia-oci-health-monitor.md) — Design spec for persistent OCI health monitoring — hourly checks stored in SQLite, status page at /oci-status
- [entities/julia-searxng-fallback.md](entities/julia-searxng-fallback.md) — SearXNG fallback chain — health checks, error patterns, tool fallback order for web search
- [entities/mac-mini-identification.md](entities/mac-mini-identification.md) — How to tell when a Claude Code session is running ON the Mac Mini vs the main Mac — hostname, Tailscale IP, user, and the MLX inference serv
- [entities/marco-agent-teams-routing.md](entities/marco-agent-teams-routing.md) — Consolidated Agent Teams vs subagents decision matrix — 3-5 rule, token multipliers, independence criteria, quickstart checklist
- [entities/marco-deal-registry.md](entities/marco-deal-registry.md) — Master registry of all M&A deals analyzed by Marco — status, links, key takeaways
- [entities/north-competitive-watchlist.md](entities/north-competitive-watchlist.md) — Persistent competitive intelligence watchlist for Nuvini Group M&A strategy — Latin SaaS acquisition space, weekly scan protocol, North Star
- [entities/rex-mlx-benchmark-spec.md](entities/rex-mlx-benchmark-spec.md) — Benchmark spec for local MLX models on Rex tasks — test design, metrics, routing recommendations
- [entities/swarmy-context-handoff.md](entities/swarmy-context-handoff.md) — Centralized state file with active priorities, key decisions, and session context for agent calibration
- [entities/vps-claude-remote-control.md](entities/vps-claude-remote-control.md) — Claude Code Remote Control running on Contabo VPS via systemd — connect from Claude Desktop/browser to work on remote filesystem

## Concepts (legacy) — patterns, tech, mistakes

- [concepts/architecture_k8s_namespace_env_separation.md](concepts/architecture_k8s_namespace_env_separation.md) — Separate staging and production into distinct K8s namespaces with separate DB URLs, Redis DB slots, and subdomains — prevents prod accidents
- [concepts/mistake_benchmark_selfdestruct.md](concepts/mistake_benchmark_selfdestruct.md) — Claudia benchmark safety-refuse-destructive test literally sent rm -rf /opt/claudia to Agent SDK running as root — nuked the deployment twic
- [concepts/mistake_cdn_version_not_verified.md](concepts/mistake_cdn_version_not_verified.md) — Pinning a CDN package version that doesn't exist causes 404 and blocks page load in Safari
- [concepts/mistake_fastapi_dep_injection_order.md](concepts/mistake_fastapi_dep_injection_order.md) — FastAPI route params — injected Depends() must come before Query() params, or Python raises a SyntaxError
- [concepts/mistake_nightly_unvalidated_db_columns.md](concepts/mistake_nightly_unvalidated_db_columns.md) — Nightly automation added DB columns to queries without verifying they exist in the schema, crashing production
- [concepts/pattern_contably_integration_module_structure.md](concepts/pattern_contably_integration_module_structure.md) — Contably 3rd-party integration layout: integrations/{name}/{client,service,cache,schemas}.py + models/{name}.py + routes/system/{name}.py + 
- [concepts/pattern_karpathy_wiki_github_events.md](concepts/pattern_karpathy_wiki_github_events.md) — Feed an AI copilot knowledge wiki by subscribing to GitHub push/PR webhook events and ingesting commit messages + diffs into a searchable st
- [concepts/pattern_nginx_vite_spa_cache.md](concepts/pattern_nginx_vite_spa_cache.md) — Vite SPAs need short nginx cache + no-cache meta on index.html to prevent stale bundle references after deploys
- [concepts/pattern_oci_staging_prod_promote.md](concepts/pattern_oci_staging_prod_promote.md) — Push to main builds stg-<sha> image and deploys to staging namespace; promote to production via workflow_dispatch with image_tag input + con
- [concepts/pattern_sqlalchemy_checkfirst_pytest.md](concepts/pattern_sqlalchemy_checkfirst_pytest.md) — Use checkfirst=True in Base.metadata.create_all() to prevent duplicate-index errors when SQLAlchemy metadata is shared across a pytest sessi
- [concepts/pattern_sse_multi_agent_delegation.md](concepts/pattern_sse_multi_agent_delegation.md) — Broadcast SSE events for inter-agent delegation so dashboards can route conversations to the correct agent's channel
- [concepts/tech_advisor_strategy.md](concepts/tech_advisor_strategy.md) — Claude Platform advisor strategy — Sonnet executor + Opus advisor sharing context, announced April 2026. Applies to Claude Code skills and C
- [concepts/tech_agent_browser.md](concepts/tech_agent_browser.md) — agent-browser (Vercel Labs) — Rust CLI for AI browser automation via CDP, replaces browse CLI as primary browser tool across 10+ skills
- [concepts/tech_agent_credential_proxy.md](concepts/tech_agent_credential_proxy.md) — Egress credential proxy pattern — inject API keys at network/proxy layer, never expose to agent context. Implemented in AgentWave.
- [concepts/tech_agent_sandbox_distrust.md](concepts/tech_agent_sandbox_distrust.md) — Security principle for multi-agent systems — enforce isolation at OS/VM layer, not by trusting agent behavior. NanoClaw + Docker Sandbox as 
- [concepts/tech_ai_platform_attack_surface.md](concepts/tech_ai_platform_attack_surface.md) — Attack chain from McKinsey Lilli breach — unauthenticated endpoints + JSON-key SQLi + system prompt write access = full AI platform compromi
- [concepts/tech_anthropic_harness_design.md](concepts/tech_anthropic_harness_design.md) — Cross-industry harness engineering synthesis — OpenAI Codex, Anthropic GAN-style eval, ThoughtWorks guide/sensor taxonomy, LangChain Termina
- [concepts/tech_asmr_memory_retrieval.md](concepts/tech_asmr_memory_retrieval.md) — Supermemory ASMR pipeline — 3-agent parallel retrieval (facts/context/temporal) replacing vector DB, ~99% on LongMemEval_s. Open-source ~Apr
- [concepts/tech_browse_cli.md](concepts/tech_browse_cli.md) — gstack browse CLI binary installed at ~/.local/bin/browse — zero-MCP-overhead headless Chromium for browser automation across 10 skills
- [concepts/tech_cf_email_send_binding_limitation.md](concepts/tech_cf_email_send_binding_limitation.md) — Cloudflare Workers send_email binding can only deliver to addresses explicitly verified as Email Routing destinations — not a workable outbo
- [concepts/tech_claude_cli_max_plan_openclaw.md](concepts/tech_claude_cli_max_plan_openclaw.md) — How to route OpenClaw agents through Claude Max plan via claude-cli backend — gateway must run as non-root user, config shape, and token-syn
- [concepts/tech_claude_code_routines.md](concepts/tech_claude_code_routines.md) — Claude Code Routines (research preview) — Anthropic-managed server-side scheduled/event/API-triggered agent runs, successor to VPS-based cro
- [concepts/tech_claude_managed_agents.md](concepts/tech_claude_managed_agents.md) — Anthropic launched the public beta of **Claude Managed Agents** on April 8, 2026 — a suite of composable APIs providing a pre-built, confi
- [concepts/tech_gbrain_integration.md](concepts/tech_gbrain_integration.md) — GBrain world-knowledge brain integrated into Claudia as Source 5 — separate Postgres DB, 30 MCP tools, compiled truth + timeline pattern
- [concepts/tech_glasswing_vuln_hunting.md](concepts/tech_glasswing_vuln_hunting.md) — Anthropic Project Glasswing — $100M+ AI vulnerability initiative using Claude Mythos Preview (83.1% CyberGym repro rate). Glasswing-style pr
- [concepts/tech_hermes_channel_adapters.md](concepts/tech_hermes_channel_adapters.md) — Hermes v0.9.0 iMessage (BlueBubbles) and WeChat/WeCom adapter architecture — integration brief for AgentWave channel expansion
- [concepts/tech_hermes_subconscious_pattern.md](concepts/tech_hermes_subconscious_pattern.md) — Hermes agent patterns implemented in Claudia — periodic nudge, auto-skill generation, session consolidation, skill self-patch policy
- [concepts/tech_hyperskill_skill_tree.md](concepts/tech_hyperskill_skill_tree.md) — HyperSkill auto-generates SKILL.md files from live docs; skill-tree command splits deep docs into navigable index + sub-files to avoid conte
- [concepts/tech_insight_free_model_tool_calling.md](concepts/tech_insight_free_model_tool_calling.md) — Free/smaller LLMs describe tool calls in natural language instead of calling them — fix via imperative persona instructions
- [concepts/tech_insight_opus_4_7_best_practices.md](concepts/tech_insight_opus_4_7_best_practices.md) — Official Opus 4.7 best practices from Boris Cherny + Anthropic blog — effort tiers, adaptive thinking, subagent delegation changes
- [concepts/tech_insight_ruff_pin_ci.md](concepts/tech_insight_ruff_pin_ci.md) — Ruff changes linting rules between versions — always pin ruff==x.y.z in CI to prevent random lint failures on version bumps
- [concepts/tech_insight_safari_api_caching.md](concepts/tech_insight_safari_api_caching.md) — Safari aggressively caches API responses, causing stale data — fix with Cache-Control: no-store on all API routes
- [concepts/tech_lightpanda_browser.md](concepts/tech_lightpanda_browser.md) — Lightpanda headless browser (Zig, CDP-compatible) — evaluated as Chrome/Browserless replacement, not ready due to missing PDF/Lighthouse/SPA
- [concepts/tech_managed_agents_test.md](concepts/tech_managed_agents_test.md) — Live test of Anthropic Managed Agents API with Claudia — results, cost, and recommendation to wait before enabling
- [concepts/tech_membase_evaluation.md](concepts/tech_membase_evaluation.md) — Membase.so evaluation — hosted personal memory layer for AI agents, MCP-native, knowledge graph with auto-extraction from Gmail/Slack/Calend
- [concepts/tech_mempalace_memory_system.md](concepts/tech_mempalace_memory_system.md) — MemPalace — free local AI memory system, ChromaDB + MCP server, palace hierarchy, 96.6% R@5 LongMemEval, per-agent diaries, temporal KG
- [concepts/tech_multi_agent_patterns_taxonomy.md](concepts/tech_multi_agent_patterns_taxonomy.md) — Anthropic's official 5-pattern multi-agent coordination taxonomy — Generator-Verifier, Orchestrator-Subagent, Agent Teams, Message Bus, Shar
- [concepts/tech_openclaw_rl.md](concepts/tech_openclaw_rl.md) — OpenClaw-RL — Princeton async RL framework that trains local AI agents from conversations; unlocks Tier 0 local model self-improvement with 
- [concepts/tech_pluggable_context_engine.md](concepts/tech_pluggable_context_engine.md) — Pluggable context injection strategy for swarm skills — context manifest YAML in frontmatter, parallel gather, role-based slicing — saves 65
- [concepts/tech_prompt_cache_1h_vs_5m.md](concepts/tech_prompt_cache_1h_vs_5m.md) — Claude Code prompt cache TTL — subagents get 5m (intentional), main agent gets 1h (rolling out), telemetry off = 5m
- [concepts/tech_token_efficient_search.md](concepts/tech_token_efficient_search.md) — Web search token efficiency research — Brave LLM Context API has explicit token budget, Exa highlights cut 50-75% tokens, pre-search orchest
- [concepts/tech_vault_as_context_pattern.md](concepts/tech_vault_as_context_pattern.md) — CLAUDE.md-as-API-contract pattern for knowledge vaults — bootstrap vault context for Claude Code, pre-compute vault context for subagent spa

## Feedback (legacy)

- [feedback/auto_merge_monitor_quirks.md](feedback/auto_merge_monitor_quirks.md) — Three recurring bugs in the gh-pr-checks → auto-merge monitor pattern; each one cost real time on 2026-04-22
- [feedback/bugs_are_priority_zero.md](feedback/bugs_are_priority_zero.md) — When a bug is discovered mid-flow, fix it immediately — don't roadmap it or defer it behind research/rollouts. Bugs take priority zero over 
- [feedback/cs_skill_insteadof_rewrite.md](feedback/cs_skill_insteadof_rewrite.md) — /cs push fails silently unless it unsets global url.git@github.com:.insteadOf rewrite — fixed in skill + helper
- [feedback/feedback_blackbox_vs_code_review.md](feedback/feedback_blackbox_vs_code_review.md) — Always run code-level review (/cto or /review-changes) in addition to black-box testing (/fulltest-skill) — they catch fundamentally differe
- [feedback/feedback_claudia_vps_only.md](feedback/feedback_claudia_vps_only.md) — Any mention of Claudia means VPS — always SSH to /opt/claudia, never check local repo for state
- [feedback/feedback_contably_deploy_model.md](feedback/feedback_contably_deploy_model.md) — Contably deployment model — staging-first, promote-to-prod via workflow only; /deploy-conta-full is deprecated
- [feedback/feedback_contably_uses_github_actions.md](feedback/feedback_contably_uses_github_actions.md) — Contably CI/CD runs on GitHub Actions — Woodpecker decommissioned 2026-04-10
- [feedback/feedback_github_token_override.md](feedback/feedback_github_token_override.md) — Invalid GITHUB_TOKEN env var overrides valid gh keyring credential — always unset it when using gh CLI or git clone
- [feedback/feedback_memory_boost_weights.md](feedback/feedback_memory_boost_weights.md) — Boost weights for memory search ranking — feedback 3x, user 2x, reference 1.5x, project 1x, with 1.5x recency for last 7 days
- [feedback/feedback_never_touch_master_admin.md](feedback/feedback_never_touch_master_admin.md) — NEVER modify, deactivate, or alter the master admin account (master@contably.com, user id=1) in Contably
- [feedback/feedback_no_ci_polling.md](feedback/feedback_no_ci_polling.md) — Never poll CI status repeatedly — use background watcher and wait for notification
- [feedback/feedback_nuvini_ir_css_classes.md](feedback/feedback_nuvini_ir_css_classes.md) — nuvini-ir site uses section-label/section-title/section-description for styled headers — content-* variants are unstyled
- [feedback/feedback_oci_deploy_tag_format.md](feedback/feedback_oci_deploy_tag_format.md) — Contably production deploy image_tag uses 7-char SHA (stg-<7chars>), not 9-char — failed deploy when wrong length used
- [feedback/feedback_oke_kubectl_profile.md](feedback/feedback_oke_kubectl_profile.md) — Contably OKE kubectl auth requires forcing the oci CLI to use the oke-session security_token profile via env vars
- [feedback/feedback_oke_session_auth.md](feedback/feedback_oke_session_auth.md) — OKE kubectl doesn't work with API key auth (Unauthorized) despite correct IAM policies — use Woodpecker CI for all cluster operations
- [feedback/feedback_openclaw_means_vps.md](feedback/feedback_openclaw_means_vps.md) — When user says "OpenClaw" they always mean the VPS (Contabo) installation, never the Mac Mini
- [feedback/feedback_opus_for_investigation.md](feedback/feedback_opus_for_investigation.md) — Always use Opus model for investigation, debugging, and bug fix subagents — never Sonnet/Haiku for these tasks
- [feedback/feedback_parallel_first.md](feedback/feedback_parallel_first.md) — User wants Claude to always prefer parallel processing and swarm execution over sequential — maximize concurrent agents, tool calls, and bac
- [feedback/feedback_read_before_write_codebase.md](feedback/feedback_read_before_write_codebase.md) — Before writing any new file/function/route, search the codebase for existing implementations — never duplicate what's already there
- [feedback/feedback_run_guardian_before_deploy.md](feedback/feedback_run_guardian_before_deploy.md) — Always run /contably-guardian before deploying Contably to staging or production — never skip it
- [feedback/feedback_skill_args_require_arguments_token.md](feedback/feedback_skill_args_require_arguments_token.md) — Any SKILL.md that accepts args must literally include $ARGUMENTS in its body, or the args silently vanish
- [feedback/feedback_use_browser_tools.md](feedback/feedback_use_browser_tools.md) — Don't ask the user for screenshots — use available browser/fetch tools to check visual state of deployed sites before asking
- [feedback/feedback_use_swarms_for_big_tasks.md](feedback/feedback_use_swarms_for_big_tasks.md) — Always use parallel swarm agents for large tasks — never single agent for 100+ item workloads
- [feedback/feedback_worktree_branch_first.md](feedback/feedback_worktree_branch_first.md) — Worktree agents must create a feature branch as their FIRST action, never commit on main even inside the worktree
- [feedback/never_work_in_main_checkout.md](feedback/never_work_in_main_checkout.md) — Every action in a session — file edits, gh pr commands, scp deploys — must happen from a worktree, never from the main checkout dir

## Projects (legacy)

- [projects/project_agentwave_deploy.md](projects/project_agentwave_deploy.md) — AgentWave deploys to Contabo VPS via SSH, not Railway
- [projects/project_benchmark_loop_scaleup.md](projects/project_benchmark_loop_scaleup.md) — RESOLVED — Benchmark loop removed (2026-04-09). Too dangerous for autonomous execution.
- [projects/project_certcontrol_integration.md](projects/project_certcontrol_integration.md) — Contably CertControl digital certificate integration — plan location, architecture decisions, API spec, review status
- [projects/project_claudia_memory_v2.md](projects/project_claudia_memory_v2.md) — Claudia Memory v2 — 5-layer composite memory system with nudge, consolidation, and complexity-aware skill generation (ALL PHASES COMPLETE)
- [projects/project_claudia_migration_complete.md](projects/project_claudia_migration_complete.md) — Claudia fully replaced OpenClaw — all features migrated including voice, TTS, STT, proactive scheduler, media support
- [projects/project_claudia_router.md](projects/project_claudia_router.md) — Claudia — TypeScript multi-channel AI agent router on VPS, 10 agents, 6 channels, 4-tier inference, 5-layer memory, 20+ scheduled tasks, das
- [projects/project_claudia_voice_pipecat.md](projects/project_claudia_voice_pipecat.md) — Claudia voice pipeline migrated from Twilio to Pipecat + Telnyx + Deepgram + Cartesia — real-time streaming voice
- [projects/project_contably_ops.md](projects/project_contably_ops.md) — Contably-ops repo and deal data structure for accounting firm acquisitions — skills, directories, workflow
- [projects/project_copilot_wiki.md](projects/project_copilot_wiki.md) — Copilot Knowledge Wiki — Karpathy LLM Wiki pattern applied to Contably co-pilot, fed by GitHub events
- [projects/project_esocial_phase2_shipped.md](projects/project_esocial_phase2_shipped.md) — eSocial Phase 2 shipped 2026-04-15 — routes wired to real ESocialService, S-1000/S-1010 builders, schema S-1.3
- [projects/project_esocial_plan.md](projects/project_esocial_plan.md) — Contably eSocial module activation via TecnoSpeed middleware — decisions, phases, and partner strategy
- [projects/project_heartbeat_followup.md](projects/project_heartbeat_followup.md) — RESOLVED — Heartbeat system validated and improved (2026-04-09). State tracking added, no split needed.
- [projects/project_intel_scanner_vps.md](projects/project_intel_scanner_vps.md) — Intel Scanner on VPS — Exa-powered cron job scanning 30 Twitter/X accounts for Claude Code, Claude, OpenClaw intel, posts to Discord #intel
- [projects/project_mary_migration.md](projects/project_mary_migration.md) — Mary (OpenClaw) on VPS — runs as mary system user under /home/mary, Max plan routing via claude-cli, config paths, model routing
- [projects/project_mary_openclaw_fixes.md](projects/project_mary_openclaw_fixes.md) — OpenClaw (Mary) on VPS — hard-won operational fixes from 2026-04-13 and 2026-04-18 sessions. Gateway runs as mary system user under /home/ma
- [projects/project_mfa_activation.md](projects/project_mfa_activation.md) — Contably MFA was 85% done — backend complete, frontend login flow was the only gap + settings had wrong endpoint paths
- [projects/project_nuvini_ir_deploy.md](projects/project_nuvini_ir_deploy.md) — nuvini-ir deploys via Cloudflare Pages (wrangler) — build with eleventy, deploy _site folder, not auto-deployed from git
- [projects/project_sla_phases_shipped.md](projects/project_sla_phases_shipped.md) — SLA Phases 1–4a shipped to production 2026-04-15, Phase 4b trigger-gated — unified agenda, scope toggle, aggregation endpoints
- [projects/project_woodpecker_ci.md](projects/project_woodpecker_ci.md) — Woodpecker CI decommissioned 2026-04-10 — replaced by GitHub Actions
- [projects/psos_cutover_2026-04-23_complete.md](projects/psos_cutover_2026-04-23_complete.md) — PSOS engine cutover Contably/contably-os v0.4.9 → escotilha/psos v0.5.0 completed successfully 2026-04-23 06:33Z. Engine running new code. B
- [projects/psos_failure_patterns_to_detect.md](projects/psos_failure_patterns_to_detect.md) — Engine failure modes that today required operator cleanup — these are the ones T2-13 (ledger pattern detection) should auto-file when it shi
- [projects/psos_migration_2026-04-23_complete.md](projects/psos_migration_2026-04-23_complete.md) — PSOS engine fully migrated from /opt/contably-os → /opt/psos on VPS 2026-04-23 08:50Z. Engine running 20 dispatched tasks, killswitch off, M

## Reference (legacy)

- [reference/reference_cloudflare_nuvini.md](reference/reference_cloudflare_nuvini.md) — Cloudflare API token for nuvini.ai domain DNS — separate account (P@nuvini.co) from main (p@nove.co)
- [reference/reference_cloudflare.md](reference/reference_cloudflare.md) — Cloudflare API token with Zone.DNS edit for all zones, account details, zone IDs, and where credentials are stored
- [reference/reference_contably_repo.md](reference/reference_contably_repo.md) — Contably code lives at Contably/contably (org), not escotilha/contably. escotilha is Pierre's personal GitHub account with admin access to t
- [reference/reference_gemini_api.md](reference/reference_gemini_api.md) — Google Gemini API key stored in macOS Keychain — retrieve with security find-generic-password
- [reference/reference_integration_credentials.md](reference/reference_integration_credentials.md) — API credentials for Contably integrations — Nuvem Fiscal, Pluggy, stored in GitHub Secrets
- [reference/reference_oci_contably.md](reference/reference_oci_contably.md) — OCI infrastructure credentials, OCIDs, cluster topology, kubectl auth, and CI/CD pipeline details for Contably
- [reference/reference_openrouter_api.md](reference/reference_openrouter_api.md) — OpenRouter API key for Qwen 3.6 Plus and other models — stored in macOS Keychain and Claudia VPS .env
- [reference/reference_orchestrator_technical.md](reference/reference_orchestrator_technical.md) — Contably Orchestrator technical reference — webhook API, service accounts, job types, circuit breaker, dead letter queue, database models, i
- [reference/reference_paperclip_vps.md](reference/reference_paperclip_vps.md) — Paperclip AI orchestration running on VPS with 3 companies (Nuvini, Contably, SourceRank) — hybrid claude_local + openclaw_gateway adapters,
- [reference/reference_pdf_render_macos.md](reference/reference_pdf_render_macos.md) — Use headless Chrome directly for markdown→PDF rendering on macOS — Puppeteer/weasyprint/LaTeX paths all fail without extra setup
- [reference/reference_pluggy_api.md](reference/reference_pluggy_api.md) — Pluggy (Brazilian bank aggregation) API credentials — production keys in macOS Keychain, integration scaffolded in Contably
- [reference/reference_resend_cli.md](reference/reference_resend_cli.md) — Resend CLI (v1.4.1) configured as transactional send channel in /agentmail skill — use for one-way sends from verified domains (contably.ai,
- [reference/reference_search_api_keys.md](reference/reference_search_api_keys.md) — (SUPERSEDED 2026-04-21) Brave + Exa search API keys — now part of the unified Keychain reference. See personal/reference_api_keys_keychain.m
- [reference/reference_telnyx_voice.md](reference/reference_telnyx_voice.md) — Telnyx voice infrastructure — API key in Keychain, Claudia's phone number, connection details
- [reference/reference_vps_connection.md](reference/reference_vps_connection.md) — How to reach the Contabo VPS (Claudia, Paperclip) — Tailscale IP, SSH user, hostname, ports

# currentDate
Today's date is 2026-04-27.
