# GRAPH_REPORT

**Compiled at:** 2026-04-23T06:30:11Z
**Source:** mem-compile — link-graph only (v1)
**Corpus:** 146 pages across 8 directories

This is an auto-generated digest of the memory graph. Read this before
`mem-search` when you need a bird's-eye view of what the vault contains,
which pages are hubs, and where cross-links are missing.

## Tier coverage

| Tier | Count | Avg age (d) | Stale (>90d) | Orphans |
|---|---:|---:|---:|---:|
| `working/` | 4 | 0 | 0 | 4 |
| `episodic/` | 0 | — | — | — |
| `semantic/` | 13 | 0 | 0 | 2 |
| `personal/` | 4 | 0 | 0 | 4 |
| `entities/` | 24 | 0 | 0 | 21 |
| `concepts/` | 42 | 0 | 0 | 30 |
| `projects/` | 20 | 0 | 0 | 19 |
| `feedback/` | 24 | 0 | 0 | 23 |
| `reference/` | 15 | 0 | 0 | 14 |

## Hub pages (top 10 by inbound links)

- **6 ←** [`semantic/pattern_learn-distill-encode-evolve.md`](semantic/pattern_learn-distill-encode-evolve.md) — Meta-pattern Pierre named 2026-04-21. Every real-world failure → diagnosed → lesson extracted → baked into code/config/t
- **4 ←** [`semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md`](semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md) — v4 Phase 5/6 dogfood surfaced 3 sandbox bugs unit tests couldn't catch. Pattern is to trigger a real task before declari
- **3 ←** [`concepts/tech_insight_opus_4_7_best_practices.md`](concepts/tech_insight_opus_4_7_best_practices.md) — Official Opus 4.7 best practices from Boris Cherny + Anthropic blog — effort tiers, adaptive thinking, subagent delegati
- **3 ←** [`semantic/pattern_full-skill-vs-flag-when-personas-diverge.md`](semantic/pattern_full-skill-vs-flag-when-personas-diverge.md) — When a new skill overlaps with an existing skill but has different personas, context-loading, or council composition — b
- **3 ←** [`semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md`](semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — When building a new skill that extends an existing family (cto, vibc, cpo, ship), spawn a one-shot Opus subagent to anal
- **2 ←** [`concepts/tech_mempalace_memory_system.md`](concepts/tech_mempalace_memory_system.md) — MemPalace — free local AI memory system, ChromaDB + MCP server, palace hierarchy, 96.6% R@5 LongMemEval, per-agent diari
- **2 ←** [`semantic/mistake_settings_bak_public_leak.md`](semantic/mistake_settings_bak_public_leak.md) — 2026-04-21 incident — settings.json.bak-* file with literal API keys force-pushed to public GitHub because its filename 
- **2 ←** [`semantic/mistake_validate-storage-constraints-before-schema.md`](semantic/mistake_validate-storage-constraints-before-schema.md) — Always confirm runtime environment constraints (which databases are available, where the skill runs) before writing sche
- **2 ←** [`semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md`](semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md) — Hard lesson from Contably OS v4 Phase 2b — deny-default breaks dyld/Mach on modern macOS. Four iterations to land on a w
- **2 ←** [`semantic/tech-insight_non-interactive-ssh-path-trap.md`](semantic/tech-insight_non-interactive-ssh-path-trap.md) — Hit 3 times today (Contably OS v3 dispatch.sh, v4 client_factory, hook shim tests). Universal pattern.

## Recent clusters (last 14 days)

**Cluster 1** — home, mary, openclaw, runs
- [`projects/project_mary_migration.md`](projects/project_mary_migration.md) (0d ago) — Mary (OpenClaw) on VPS — runs as mary system user under /home/mary, Max plan routing via claude-cli,
- [`projects/project_mary_openclaw_fixes.md`](projects/project_mary_openclaw_fixes.md) (0d ago) — OpenClaw (Mary) on VPS — hard-won operational fixes from 2026-04-13 and 2026-04-18 sessions. Gateway

**Cluster 2** — actions, decommissioned, github, woodpecker
- [`projects/project_woodpecker_ci.md`](projects/project_woodpecker_ci.md) (0d ago) — Woodpecker CI decommissioned 2026-04-10 — replaced by GitHub Actions
- [`feedback/feedback_contably_uses_github_actions.md`](feedback/feedback_contably_uses_github_actions.md) (0d ago) — Contably CI/CD runs on GitHub Actions — Woodpecker decommissioned 2026-04-10

**Unclustered** (recent, no peers)
- [`entities/agent-memory-bella.md`](entities/agent-memory-bella.md) (0d ago) — Bella agent identity — Chief Technology Officer, Contably (dedicated); owns all Contably engineering
- [`entities/agent-memory-julia.md`](entities/agent-memory-julia.md) (0d ago) — Julia agent identity — Product Manager for Contably; roadmap, user research, sprint planning, stakeh
- [`entities/agent-memory-marco.md`](entities/agent-memory-marco.md) (0d ago) — Marco agent identity, operating preferences, investment thesis, and M&A research methodology — Nuvin
- [`entities/arnold-task-routing.md`](entities/arnold-task-routing.md) (0d ago) — Pre-response checklist for routing tasks to skills, parallelization, or ad-hoc execution
- [`entities/bella-systemd-routines.md`](entities/bella-systemd-routines.md) (0d ago) — VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines surviv
- [`entities/bella-tech-eval-kb.md`](entities/bella-tech-eval-kb.md) (0d ago) — Persistent log of URL/tool evaluations with scores, verdicts, and reasoning — Bella agent tech resea
- [`entities/buzz-daily-triage.md`](entities/buzz-daily-triage.md) (0d ago) — Daily competitive signal triage for NVNI portfolio — scans TechCrunch, Crunchbase, LinkedIn for high
- [`entities/buzz-skill-matching.md`](entities/buzz-skill-matching.md) (0d ago) — Living index of skill trigger patterns — when to invoke which skill, missed routing, parallelism opp
- [`entities/buzz-triage-sample-2026-04-10.md`](entities/buzz-triage-sample-2026-04-10.md) (0d ago) — Sample daily competitive brief output — 2026-04-10 — showing what Pierre would receive each morning
- [`entities/claudia-heartbeat-tracker.md`](entities/claudia-heartbeat-tracker.md) (0d ago) — Spec for heartbeat issue dedup — tracks active issues, prevents re-reporting, escalates persistent o
- [`entities/cris-investor-email-rules.md`](entities/cris-investor-email-rules.md) (0d ago) — Cris email triage rules — investor classification, PERSONAL_REPLY_NEEDED flag, VIP routing
- [`entities/cris-investor-email-triage-samples.md`](entities/cris-investor-email-triage-samples.md) (0d ago) — Sample triage output showing PERSONAL_REPLY_NEEDED flag with rationale — 5 examples
- [`entities/cris-nuvini-entity-registry.md`](entities/cris-nuvini-entity-registry.md) (0d ago) — Canonical registry of all Nuvini Group entities — names, jurisdictions, ownership, status
- [`entities/deal-template.md`](entities/deal-template.md) (0d ago) — M&A deal intelligence page — {Company Name} ({status})
- [`entities/deal_stripe.md`](entities/deal_stripe.md) (0d ago) — M&A deal intelligence page — Stripe (prospect)
- [`entities/julia-oci-health-monitor.md`](entities/julia-oci-health-monitor.md) (0d ago) — Design spec for persistent OCI health monitoring — hourly checks stored in SQLite, status page at /o
- [`entities/julia-searxng-fallback.md`](entities/julia-searxng-fallback.md) (0d ago) — SearXNG fallback chain — health checks, error patterns, tool fallback order for web search
- [`entities/mac-mini-identification.md`](entities/mac-mini-identification.md) (0d ago) — How to tell when a Claude Code session is running ON the Mac Mini vs the main Mac — hostname, Tailsc
- [`entities/marco-agent-teams-routing.md`](entities/marco-agent-teams-routing.md) (0d ago) — Consolidated Agent Teams vs subagents decision matrix — 3-5 rule, token multipliers, independence cr
- [`entities/marco-deal-registry.md`](entities/marco-deal-registry.md) (0d ago) — Master registry of all M&A deals analyzed by Marco — status, links, key takeaways
- [`entities/north-competitive-watchlist.md`](entities/north-competitive-watchlist.md) (0d ago) — Persistent competitive intelligence watchlist for Nuvini Group M&A strategy — Latin SaaS acquisition
- [`entities/rex-mlx-benchmark-spec.md`](entities/rex-mlx-benchmark-spec.md) (0d ago) — Benchmark spec for local MLX models on Rex tasks — test design, metrics, routing recommendations
- [`entities/swarmy-context-handoff.md`](entities/swarmy-context-handoff.md) (0d ago) — Centralized state file with active priorities, key decisions, and session context for agent calibrat
- [`entities/vps-claude-remote-control.md`](entities/vps-claude-remote-control.md) (0d ago) — Claude Code Remote Control running on Contabo VPS via systemd — connect from Claude Desktop/browser 
- [`concepts/architecture_k8s_namespace_env_separation.md`](concepts/architecture_k8s_namespace_env_separation.md) (0d ago) — Separate staging and production into distinct K8s namespaces with separate DB URLs, Redis DB slots, 
- [`concepts/mistake_benchmark_selfdestruct.md`](concepts/mistake_benchmark_selfdestruct.md) (0d ago) — Claudia benchmark safety-refuse-destructive test literally sent rm -rf /opt/claudia to Agent SDK run
- [`concepts/mistake_cdn_version_not_verified.md`](concepts/mistake_cdn_version_not_verified.md) (0d ago) — Pinning a CDN package version that doesn't exist causes 404 and blocks page load in Safari
- [`concepts/mistake_fastapi_dep_injection_order.md`](concepts/mistake_fastapi_dep_injection_order.md) (0d ago) — FastAPI route params — injected Depends() must come before Query() params, or Python raises a Syntax
- [`concepts/mistake_nightly_unvalidated_db_columns.md`](concepts/mistake_nightly_unvalidated_db_columns.md) (0d ago) — Nightly automation added DB columns to queries without verifying they exist in the schema, crashing 
- [`concepts/pattern_contably_integration_module_structure.md`](concepts/pattern_contably_integration_module_structure.md) (0d ago) — Contably 3rd-party integration layout: integrations/{name}/{client,service,cache,schemas}.py + model
- [`concepts/pattern_karpathy_wiki_github_events.md`](concepts/pattern_karpathy_wiki_github_events.md) (0d ago) — Feed an AI copilot knowledge wiki by subscribing to GitHub push/PR webhook events and ingesting comm
- [`concepts/pattern_nginx_vite_spa_cache.md`](concepts/pattern_nginx_vite_spa_cache.md) (0d ago) — Vite SPAs need short nginx cache + no-cache meta on index.html to prevent stale bundle references af
- [`concepts/pattern_oci_staging_prod_promote.md`](concepts/pattern_oci_staging_prod_promote.md) (0d ago) — Push to main builds stg-<sha> image and deploys to staging namespace; promote to production via work
- [`concepts/pattern_sqlalchemy_checkfirst_pytest.md`](concepts/pattern_sqlalchemy_checkfirst_pytest.md) (0d ago) — Use checkfirst=True in Base.metadata.create_all() to prevent duplicate-index errors when SQLAlchemy 
- [`concepts/pattern_sse_multi_agent_delegation.md`](concepts/pattern_sse_multi_agent_delegation.md) (0d ago) — Broadcast SSE events for inter-agent delegation so dashboards can route conversations to the correct
- [`concepts/tech_advisor_strategy.md`](concepts/tech_advisor_strategy.md) (0d ago) — Claude Platform advisor strategy — Sonnet executor + Opus advisor sharing context, announced April 2
- [`concepts/tech_agent_browser.md`](concepts/tech_agent_browser.md) (0d ago) — agent-browser (Vercel Labs) — Rust CLI for AI browser automation via CDP, replaces browse CLI as pri
- [`concepts/tech_agent_credential_proxy.md`](concepts/tech_agent_credential_proxy.md) (0d ago) — Egress credential proxy pattern — inject API keys at network/proxy layer, never expose to agent cont
- [`concepts/tech_agent_sandbox_distrust.md`](concepts/tech_agent_sandbox_distrust.md) (0d ago) — Security principle for multi-agent systems — enforce isolation at OS/VM layer, not by trusting agent
- [`concepts/tech_ai_platform_attack_surface.md`](concepts/tech_ai_platform_attack_surface.md) (0d ago) — Attack chain from McKinsey Lilli breach — unauthenticated endpoints + JSON-key SQLi + system prompt 
- [`concepts/tech_anthropic_harness_design.md`](concepts/tech_anthropic_harness_design.md) (0d ago) — Planner/generator/evaluator three-agent pattern and structured handoff (no compaction) for long-runn
- [`concepts/tech_asmr_memory_retrieval.md`](concepts/tech_asmr_memory_retrieval.md) (0d ago) — Supermemory ASMR pipeline — 3-agent parallel retrieval (facts/context/temporal) replacing vector DB,
- [`concepts/tech_browse_cli.md`](concepts/tech_browse_cli.md) (0d ago) — gstack browse CLI binary installed at ~/.local/bin/browse — zero-MCP-overhead headless Chromium for 
- [`concepts/tech_cf_email_send_binding_limitation.md`](concepts/tech_cf_email_send_binding_limitation.md) (0d ago) — Cloudflare Workers send_email binding can only deliver to addresses explicitly verified as Email Rou
- [`concepts/tech_claude_cli_max_plan_openclaw.md`](concepts/tech_claude_cli_max_plan_openclaw.md) (0d ago) — How to route OpenClaw agents through Claude Max plan via claude-cli backend — gateway must run as no
- [`concepts/tech_claude_code_routines.md`](concepts/tech_claude_code_routines.md) (0d ago) — Claude Code Routines (research preview) — Anthropic-managed server-side scheduled/event/API-triggere
- [`concepts/tech_claude_managed_agents.md`](concepts/tech_claude_managed_agents.md) (0d ago) — 
- [`concepts/tech_gbrain_integration.md`](concepts/tech_gbrain_integration.md) (0d ago) — GBrain world-knowledge brain integrated into Claudia as Source 5 — separate Postgres DB, 30 MCP tool
- [`concepts/tech_glasswing_vuln_hunting.md`](concepts/tech_glasswing_vuln_hunting.md) (0d ago) — Anthropic Project Glasswing — $100M+ AI vulnerability initiative using Claude Mythos Preview (83.1% 
- [`concepts/tech_hermes_channel_adapters.md`](concepts/tech_hermes_channel_adapters.md) (0d ago) — Hermes v0.9.0 iMessage (BlueBubbles) and WeChat/WeCom adapter architecture — integration brief for A
- [`concepts/tech_hermes_subconscious_pattern.md`](concepts/tech_hermes_subconscious_pattern.md) (0d ago) — Hermes agent patterns implemented in Claudia — periodic nudge, auto-skill generation, session consol
- [`concepts/tech_hyperskill_skill_tree.md`](concepts/tech_hyperskill_skill_tree.md) (0d ago) — HyperSkill auto-generates SKILL.md files from live docs; skill-tree command splits deep docs into na
- [`concepts/tech_insight_free_model_tool_calling.md`](concepts/tech_insight_free_model_tool_calling.md) (0d ago) — Free/smaller LLMs describe tool calls in natural language instead of calling them — fix via imperati
- [`concepts/tech_insight_opus_4_7_best_practices.md`](concepts/tech_insight_opus_4_7_best_practices.md) (0d ago) — Official Opus 4.7 best practices from Boris Cherny + Anthropic blog — effort tiers, adaptive thinkin
- [`concepts/tech_insight_ruff_pin_ci.md`](concepts/tech_insight_ruff_pin_ci.md) (0d ago) — Ruff changes linting rules between versions — always pin ruff==x.y.z in CI to prevent random lint fa
- [`concepts/tech_insight_safari_api_caching.md`](concepts/tech_insight_safari_api_caching.md) (0d ago) — Safari aggressively caches API responses, causing stale data — fix with Cache-Control: no-store on a
- [`concepts/tech_lightpanda_browser.md`](concepts/tech_lightpanda_browser.md) (0d ago) — Lightpanda headless browser (Zig, CDP-compatible) — evaluated as Chrome/Browserless replacement, not
- [`concepts/tech_managed_agents_test.md`](concepts/tech_managed_agents_test.md) (0d ago) — Live test of Anthropic Managed Agents API with Claudia — results, cost, and recommendation to wait b
- [`concepts/tech_membase_evaluation.md`](concepts/tech_membase_evaluation.md) (0d ago) — Membase.so evaluation — hosted personal memory layer for AI agents, MCP-native, knowledge graph with
- [`concepts/tech_mempalace_memory_system.md`](concepts/tech_mempalace_memory_system.md) (0d ago) — MemPalace — free local AI memory system, ChromaDB + MCP server, palace hierarchy, 96.6% R@5 LongMemE
- [`concepts/tech_multi_agent_patterns_taxonomy.md`](concepts/tech_multi_agent_patterns_taxonomy.md) (0d ago) — Anthropic's official 5-pattern multi-agent coordination taxonomy — Generator-Verifier, Orchestrator-
- [`concepts/tech_openclaw_rl.md`](concepts/tech_openclaw_rl.md) (0d ago) — OpenClaw-RL — Princeton async RL framework that trains local AI agents from conversations; unlocks T
- [`concepts/tech_pluggable_context_engine.md`](concepts/tech_pluggable_context_engine.md) (0d ago) — Pluggable context injection strategy for swarm skills — context manifest YAML in frontmatter, parall
- [`concepts/tech_prompt_cache_1h_vs_5m.md`](concepts/tech_prompt_cache_1h_vs_5m.md) (0d ago) — Claude Code prompt cache TTL — subagents get 5m (intentional), main agent gets 1h (rolling out), tel
- [`concepts/tech_token_efficient_search.md`](concepts/tech_token_efficient_search.md) (0d ago) — Web search token efficiency research — Brave LLM Context API has explicit token budget, Exa highligh
- [`concepts/tech_vault_as_context_pattern.md`](concepts/tech_vault_as_context_pattern.md) (0d ago) — CLAUDE.md-as-API-contract pattern for knowledge vaults — bootstrap vault context for Claude Code, pr
- [`projects/project_agentwave_deploy.md`](projects/project_agentwave_deploy.md) (0d ago) — AgentWave deploys to Contabo VPS via SSH, not Railway
- [`projects/project_benchmark_loop_scaleup.md`](projects/project_benchmark_loop_scaleup.md) (0d ago) — RESOLVED — Benchmark loop removed (2026-04-09). Too dangerous for autonomous execution.
- [`projects/project_certcontrol_integration.md`](projects/project_certcontrol_integration.md) (0d ago) — Contably CertControl digital certificate integration — plan location, architecture decisions, API sp
- [`projects/project_claudia_memory_v2.md`](projects/project_claudia_memory_v2.md) (0d ago) — Claudia Memory v2 — 5-layer composite memory system with nudge, consolidation, and complexity-aware 
- [`projects/project_claudia_migration_complete.md`](projects/project_claudia_migration_complete.md) (0d ago) — Claudia fully replaced OpenClaw — all features migrated including voice, TTS, STT, proactive schedul
- [`projects/project_claudia_router.md`](projects/project_claudia_router.md) (0d ago) — Claudia — TypeScript multi-channel AI agent router on VPS, 10 agents, 6 channels, 4-tier inference, 
- [`projects/project_claudia_voice_pipecat.md`](projects/project_claudia_voice_pipecat.md) (0d ago) — Claudia voice pipeline migrated from Twilio to Pipecat + Telnyx + Deepgram + Cartesia — real-time st
- [`projects/project_contably_ops.md`](projects/project_contably_ops.md) (0d ago) — Contably-ops repo and deal data structure for accounting firm acquisitions — skills, directories, wo
- [`projects/project_copilot_wiki.md`](projects/project_copilot_wiki.md) (0d ago) — Copilot Knowledge Wiki — Karpathy LLM Wiki pattern applied to Contably co-pilot, fed by GitHub event
- [`projects/project_esocial_phase2_shipped.md`](projects/project_esocial_phase2_shipped.md) (0d ago) — eSocial Phase 2 shipped 2026-04-15 — routes wired to real ESocialService, S-1000/S-1010 builders, sc
- [`projects/project_esocial_plan.md`](projects/project_esocial_plan.md) (0d ago) — Contably eSocial module activation via TecnoSpeed middleware — decisions, phases, and partner strate
- [`projects/project_heartbeat_followup.md`](projects/project_heartbeat_followup.md) (0d ago) — RESOLVED — Heartbeat system validated and improved (2026-04-09). State tracking added, no split need
- [`projects/project_intel_scanner_vps.md`](projects/project_intel_scanner_vps.md) (0d ago) — Intel Scanner on VPS — Exa-powered cron job scanning 30 Twitter/X accounts for Claude Code, Claude, 
- [`projects/project_mfa_activation.md`](projects/project_mfa_activation.md) (0d ago) — Contably MFA was 85% done — backend complete, frontend login flow was the only gap + settings had wr
- [`projects/project_nuvini_ir_deploy.md`](projects/project_nuvini_ir_deploy.md) (0d ago) — nuvini-ir deploys via Cloudflare Pages (wrangler) — build with eleventy, deploy _site folder, not au
- [`projects/project_sla_phases_shipped.md`](projects/project_sla_phases_shipped.md) (0d ago) — SLA Phases 1–4a shipped to production 2026-04-15, Phase 4b trigger-gated — unified agenda, scope tog
- [`projects/psos_failure_patterns_to_detect.md`](projects/psos_failure_patterns_to_detect.md) (0d ago) — Engine failure modes that today required operator cleanup — these are the ones T2-13 (ledger pattern
- [`feedback/auto_merge_monitor_quirks.md`](feedback/auto_merge_monitor_quirks.md) (0d ago) — Three recurring bugs in the gh-pr-checks → auto-merge monitor pattern; each one cost real time on 20
- [`feedback/cs_skill_insteadof_rewrite.md`](feedback/cs_skill_insteadof_rewrite.md) (0d ago) — /cs push fails silently unless it unsets global url.git@github.com:.insteadOf rewrite — fixed in ski
- [`feedback/feedback_blackbox_vs_code_review.md`](feedback/feedback_blackbox_vs_code_review.md) (0d ago) — Always run code-level review (/cto or /review-changes) in addition to black-box testing (/fulltest-s
- [`feedback/feedback_claudia_vps_only.md`](feedback/feedback_claudia_vps_only.md) (0d ago) — Any mention of Claudia means VPS — always SSH to /opt/claudia, never check local repo for state
- [`feedback/feedback_contably_deploy_model.md`](feedback/feedback_contably_deploy_model.md) (0d ago) — Contably deployment model — staging-first, promote-to-prod via workflow only; /deploy-conta-full is 
- [`feedback/feedback_github_token_override.md`](feedback/feedback_github_token_override.md) (0d ago) — Invalid GITHUB_TOKEN env var overrides valid gh keyring credential — always unset it when using gh C
- [`feedback/feedback_memory_boost_weights.md`](feedback/feedback_memory_boost_weights.md) (0d ago) — Boost weights for memory search ranking — feedback 3x, user 2x, reference 1.5x, project 1x, with 1.5
- [`feedback/feedback_never_touch_master_admin.md`](feedback/feedback_never_touch_master_admin.md) (0d ago) — NEVER modify, deactivate, or alter the master admin account (master@contably.com, user id=1) in Cont
- [`feedback/feedback_no_ci_polling.md`](feedback/feedback_no_ci_polling.md) (0d ago) — Never poll CI status repeatedly — use background watcher and wait for notification
- [`feedback/feedback_nuvini_ir_css_classes.md`](feedback/feedback_nuvini_ir_css_classes.md) (0d ago) — nuvini-ir site uses section-label/section-title/section-description for styled headers — content-* v
- [`feedback/feedback_oci_deploy_tag_format.md`](feedback/feedback_oci_deploy_tag_format.md) (0d ago) — Contably production deploy image_tag uses 7-char SHA (stg-<7chars>), not 9-char — failed deploy when
- [`feedback/feedback_oke_kubectl_profile.md`](feedback/feedback_oke_kubectl_profile.md) (0d ago) — Contably OKE kubectl auth requires forcing the oci CLI to use the oke-session security_token profile
- [`feedback/feedback_oke_session_auth.md`](feedback/feedback_oke_session_auth.md) (0d ago) — OKE kubectl doesn't work with API key auth (Unauthorized) despite correct IAM policies — use Woodpec
- [`feedback/feedback_openclaw_means_vps.md`](feedback/feedback_openclaw_means_vps.md) (0d ago) — When user says "OpenClaw" they always mean the VPS (Contabo) installation, never the Mac Mini
- [`feedback/feedback_opus_for_investigation.md`](feedback/feedback_opus_for_investigation.md) (0d ago) — Always use Opus model for investigation, debugging, and bug fix subagents — never Sonnet/Haiku for t
- [`feedback/feedback_parallel_first.md`](feedback/feedback_parallel_first.md) (0d ago) — User wants Claude to always prefer parallel processing and swarm execution over sequential — maximiz
- [`feedback/feedback_read_before_write_codebase.md`](feedback/feedback_read_before_write_codebase.md) (0d ago) — Before writing any new file/function/route, search the codebase for existing implementations — never
- [`feedback/feedback_run_guardian_before_deploy.md`](feedback/feedback_run_guardian_before_deploy.md) (0d ago) — Always run /contably-guardian before deploying Contably to staging or production — never skip it
- [`feedback/feedback_skill_args_require_arguments_token.md`](feedback/feedback_skill_args_require_arguments_token.md) (0d ago) — Any SKILL.md that accepts args must literally include $ARGUMENTS in its body, or the args silently v
- [`feedback/feedback_use_browser_tools.md`](feedback/feedback_use_browser_tools.md) (0d ago) — Don't ask the user for screenshots — use available browser/fetch tools to check visual state of depl
- [`feedback/feedback_use_swarms_for_big_tasks.md`](feedback/feedback_use_swarms_for_big_tasks.md) (0d ago) — Always use parallel swarm agents for large tasks — never single agent for 100+ item workloads
- [`feedback/feedback_worktree_branch_first.md`](feedback/feedback_worktree_branch_first.md) (0d ago) — Worktree agents must create a feature branch as their FIRST action, never commit on main even inside
- [`feedback/never_work_in_main_checkout.md`](feedback/never_work_in_main_checkout.md) (0d ago) — Every action in a session — file edits, gh pr commands, scp deploys — must happen from a worktree, n
- [`reference/reference_cloudflare.md`](reference/reference_cloudflare.md) (0d ago) — Cloudflare API token with Zone.DNS edit for all zones, account details, zone IDs, and where credenti
- [`reference/reference_cloudflare_nuvini.md`](reference/reference_cloudflare_nuvini.md) (0d ago) — Cloudflare API token for nuvini.ai domain DNS — separate account (P@nuvini.co) from main (p@nove.co)
- [`reference/reference_contably_repo.md`](reference/reference_contably_repo.md) (0d ago) — Contably code lives at Contably/contably (org), not escotilha/contably. escotilha is Pierre's person
- [`reference/reference_gemini_api.md`](reference/reference_gemini_api.md) (0d ago) — Google Gemini API key stored in macOS Keychain — retrieve with security find-generic-password
- [`reference/reference_integration_credentials.md`](reference/reference_integration_credentials.md) (0d ago) — API credentials for Contably integrations — Nuvem Fiscal, Pluggy, stored in GitHub Secrets
- [`reference/reference_oci_contably.md`](reference/reference_oci_contably.md) (0d ago) — OCI infrastructure credentials, OCIDs, cluster topology, kubectl auth, and CI/CD pipeline details fo
- [`reference/reference_openrouter_api.md`](reference/reference_openrouter_api.md) (0d ago) — OpenRouter API key for Qwen 3.6 Plus and other models — stored in macOS Keychain and Claudia VPS .en
- [`reference/reference_orchestrator_technical.md`](reference/reference_orchestrator_technical.md) (0d ago) — Contably Orchestrator technical reference — webhook API, service accounts, job types, circuit breake
- [`reference/reference_paperclip_vps.md`](reference/reference_paperclip_vps.md) (0d ago) — Paperclip AI orchestration running on VPS with 3 companies (Nuvini, Contably, SourceRank) — hybrid c
- [`reference/reference_pdf_render_macos.md`](reference/reference_pdf_render_macos.md) (0d ago) — Use headless Chrome directly for markdown→PDF rendering on macOS — Puppeteer/weasyprint/LaTeX paths 
- [`reference/reference_pluggy_api.md`](reference/reference_pluggy_api.md) (0d ago) — Pluggy (Brazilian bank aggregation) API credentials — production keys in macOS Keychain, integration
- [`reference/reference_resend_cli.md`](reference/reference_resend_cli.md) (0d ago) — Resend CLI (v1.4.1) configured as transactional send channel in /agentmail skill — use for one-way s
- [`reference/reference_search_api_keys.md`](reference/reference_search_api_keys.md) (0d ago) — (SUPERSEDED 2026-04-21) Brave + Exa search API keys — now part of the unified Keychain reference. Se
- [`reference/reference_telnyx_voice.md`](reference/reference_telnyx_voice.md) (0d ago) — Telnyx voice infrastructure — API key in Keychain, Claudia's phone number, connection details
- [`reference/reference_vps_connection.md`](reference/reference_vps_connection.md) (0d ago) — How to reach the Contabo VPS (Claudia, Paperclip) — Tailscale IP, SSH user, hostname, ports
- [`working/contably-os-v4-inputs.md`](working/contably-os-v4-inputs.md) (0d ago) — Three design inputs captured 2026-04-21 during v3 Phase 1 E2E sign-off, to feed into v4 planning
- [`working/contably-os-v4-online-2026-04-21.md`](working/contably-os-v4-online-2026-04-21.md) (0d ago) — What's running in production as of 2026-04-21 end-of-day. Resume block for future sessions.
- [`working/resume_2026-04-22_overnight.md`](working/resume_2026-04-22_overnight.md) (0d ago) — Resume pointer for the Contably overnight engine session that was rate-limited at 22:40 local. Any n
- [`working/resume_mary_restart_2026-04-23.md`](working/resume_mary_restart_2026-04-23.md) (0d ago) — Working state for Mary restart/audit — overnight prep done 2026-04-23 03:00, morning execution pendi
- [`semantic/mistake_settings_bak_public_leak.md`](semantic/mistake_settings_bak_public_leak.md) (0d ago) — 2026-04-21 incident — settings.json.bak-* file with literal API keys force-pushed to public GitHub b
- [`semantic/mistake_validate-storage-constraints-before-schema.md`](semantic/mistake_validate-storage-constraints-before-schema.md) (0d ago) — Always confirm runtime environment constraints (which databases are available, where the skill runs)
- [`semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md`](semantic/pattern_dogfood-before-trusting-autonomous-dispatch.md) (0d ago) — v4 Phase 5/6 dogfood surfaced 3 sandbox bugs unit tests couldn't catch. Pattern is to trigger a real
- [`semantic/pattern_full-skill-vs-flag-when-personas-diverge.md`](semantic/pattern_full-skill-vs-flag-when-personas-diverge.md) (0d ago) — When a new skill overlaps with an existing skill but has different personas, context-loading, or cou
- [`semantic/pattern_learn-distill-encode-evolve.md`](semantic/pattern_learn-distill-encode-evolve.md) (0d ago) — Meta-pattern Pierre named 2026-04-21. Every real-world failure → diagnosed → lesson extracted → bake
- [`semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md`](semantic/pattern_sandbox-exec-allow-default-deny-dangerous.md) (0d ago) — Hard lesson from Contably OS v4 Phase 2b — deny-default breaks dyld/Mach on modern macOS. Four itera
- [`semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md`](semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md) (0d ago) — When building a new skill that extends an existing family (cto, vibc, cpo, ship), spawn a one-shot O
- [`semantic/research-finding-ultrareview-claude-code.md`](semantic/research-finding-ultrareview-claude-code.md) (0d ago) — Claude Code /ultrareview research preview — cloud fleet of bug-hunting agents for pre-merge code rev
- [`semantic/tech-insight:mcp-agent-production-patterns.md`](semantic/tech-insight:mcp-agent-production-patterns.md) (0d ago) — Anthropic guide on MCP vs direct API vs CLI for production agents — server design, context-efficient
- [`semantic/tech-insight_hermes-agent-learning-loop.md`](semantic/tech-insight_hermes-agent-learning-loop.md) (0d ago) — Hermes Agent learning loop patterns — 5-layer harness model, skills-vs-memory distinction, auto-skil
- [`semantic/tech-insight_non-interactive-ssh-path-trap.md`](semantic/tech-insight_non-interactive-ssh-path-trap.md) (0d ago) — Hit 3 times today (Contably OS v3 dispatch.sh, v4 client_factory, hook shim tests). Universal patter
- [`semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md`](semantic/tech-insight_pytest-unborn-head-breaks-branch-tests.md) (0d ago) — Subtle git quirk that broke 3 hook-script tests in Contably OS v4 Phase 6. Always seed an initial co
- [`semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md`](semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md) (0d ago) — Invoking a skill via the Skill tool from inside an orchestrator context does NOT forward args to the
- [`personal/host_macmini_vs_laptop.md`](personal/host_macmini_vs_laptop.md) (0d ago) — Pierre's primary Claude Code host is the Mac Mini — the Mini runs Claude Code sessions AND is the au
- [`personal/host_this_is_mac_mini.md`](personal/host_this_is_mac_mini.md) (0d ago) — PERMANENT — when Claude Code runs with hostname Mac-mini.local and user psm2, this session IS the Ma
- [`personal/preference_opus_for_coding_logic.md`](personal/preference_opus_for_coding_logic.md) (0d ago) — Explicit user preference (2026-04-21) — any subagent or session doing real coding logic must run on 
- [`personal/reference_api_keys_keychain.md`](personal/reference_api_keys_keychain.md) (0d ago) — All API keys (Resend, Brave, Exa, Turso) stored in macOS Keychain — settings.json uses ${VAR} refere

## Orphans (no inbound + no outbound links)

- `concepts/mistake_benchmark_selfdestruct.md`
- `concepts/mistake_cdn_version_not_verified.md`
- `concepts/mistake_fastapi_dep_injection_order.md`
- `concepts/mistake_nightly_unvalidated_db_columns.md`
- `concepts/pattern_contably_integration_module_structure.md`
- `concepts/pattern_karpathy_wiki_github_events.md`
- `concepts/pattern_sqlalchemy_checkfirst_pytest.md`
- `concepts/pattern_sse_multi_agent_delegation.md`
- `concepts/tech_agent_browser.md`
- `concepts/tech_ai_platform_attack_surface.md`
- `concepts/tech_anthropic_harness_design.md`
- `concepts/tech_browse_cli.md`
- `concepts/tech_cf_email_send_binding_limitation.md`
- `concepts/tech_claude_cli_max_plan_openclaw.md`
- `concepts/tech_claude_managed_agents.md`
- `concepts/tech_gbrain_integration.md`
- `concepts/tech_glasswing_vuln_hunting.md`
- `concepts/tech_hermes_channel_adapters.md`
- `concepts/tech_hermes_subconscious_pattern.md`
- `concepts/tech_hyperskill_skill_tree.md`
- `concepts/tech_insight_free_model_tool_calling.md`
- `concepts/tech_insight_ruff_pin_ci.md`
- `concepts/tech_lightpanda_browser.md`
- `concepts/tech_managed_agents_test.md`
- `concepts/tech_multi_agent_patterns_taxonomy.md`
- `concepts/tech_openclaw_rl.md`
- `concepts/tech_pluggable_context_engine.md`
- `concepts/tech_prompt_cache_1h_vs_5m.md`
- `concepts/tech_token_efficient_search.md`
- `concepts/tech_vault_as_context_pattern.md`
- … and 87 more

## Stale pages (>90d, top 10 oldest)

_None. All memories touched within 90 days._

## Contradiction candidates (near-duplicate descriptions)

_No near-duplicate descriptions detected._

## Tier-gate suggestions

_Legacy-dir files whose content looks tier-ready._

- [`entities/agent-memory-bella.md`](entities/agent-memory-bella.md) → `personal/`
- [`entities/agent-memory-julia.md`](entities/agent-memory-julia.md) → `personal/`
- [`entities/agent-memory-marco.md`](entities/agent-memory-marco.md) → `personal/`
- [`entities/arnold-task-routing.md`](entities/arnold-task-routing.md) → `personal/`
- [`entities/bella-systemd-routines.md`](entities/bella-systemd-routines.md) → `personal/`
- [`entities/bella-tech-eval-kb.md`](entities/bella-tech-eval-kb.md) → `personal/`
- [`entities/buzz-daily-triage.md`](entities/buzz-daily-triage.md) → `personal/`
- [`entities/buzz-skill-matching.md`](entities/buzz-skill-matching.md) → `personal/`
- [`entities/buzz-triage-sample-2026-04-10.md`](entities/buzz-triage-sample-2026-04-10.md) → `personal/`
- [`entities/cris-investor-email-rules.md`](entities/cris-investor-email-rules.md) → `personal/`
- [`entities/cris-investor-email-triage-samples.md`](entities/cris-investor-email-triage-samples.md) → `personal/`
- [`entities/cris-nuvini-entity-registry.md`](entities/cris-nuvini-entity-registry.md) → `personal/`
- [`entities/julia-searxng-fallback.md`](entities/julia-searxng-fallback.md) → `personal/`
- [`entities/mac-mini-identification.md`](entities/mac-mini-identification.md) → `personal/`
- [`entities/marco-agent-teams-routing.md`](entities/marco-agent-teams-routing.md) → `personal/`
- [`entities/marco-deal-registry.md`](entities/marco-deal-registry.md) → `personal/`
- [`entities/north-competitive-watchlist.md`](entities/north-competitive-watchlist.md) → `personal/`
- [`entities/rex-mlx-benchmark-spec.md`](entities/rex-mlx-benchmark-spec.md) → `personal/`
- [`entities/vps-claude-remote-control.md`](entities/vps-claude-remote-control.md) → `personal/`
- [`concepts/architecture_k8s_namespace_env_separation.md`](concepts/architecture_k8s_namespace_env_separation.md) → `semantic/`
- [`concepts/mistake_benchmark_selfdestruct.md`](concepts/mistake_benchmark_selfdestruct.md) → `semantic/`
- [`concepts/mistake_cdn_version_not_verified.md`](concepts/mistake_cdn_version_not_verified.md) → `semantic/`
- [`concepts/mistake_fastapi_dep_injection_order.md`](concepts/mistake_fastapi_dep_injection_order.md) → `semantic/`
- [`concepts/mistake_nightly_unvalidated_db_columns.md`](concepts/mistake_nightly_unvalidated_db_columns.md) → `semantic/`
- [`concepts/pattern_contably_integration_module_structure.md`](concepts/pattern_contably_integration_module_structure.md) → `semantic/`
- … and 94 more
