# Memory Index

## Agent Identity & Operating Memory

- [agent-memory-julia.md](agent-memory-julia.md) — Julia agent identity: Contably operational assistant — email triage preferences, Brazilian compliance domain (eSocial, NF-e), recurring tasks, infrastructure context, cross-agent handoffs
- [agent-memory-marco.md](agent-memory-marco.md) — Marco agent identity: Nuvini M&A analyst — investment thesis (micro-SaaS BR, $200K–$5M ARR), research methodology (parallel DD tracks), evidence hierarchy, deal memo format
- [agent-memory-bella.md](agent-memory-bella.md) — Bella agent identity: tech evaluator + skill indexer — adopt/watch/skip scoring methodology, skill library maintenance rules, content preferences, recurring tasks

## Tech Evaluation (Bella)

- [bella-tech-eval-kb.md](bella-tech-eval-kb.md) — Persistent log of URL/tool evaluations — 11 entries (adopt: agent-browser, browse CLI, Scrapling, PinchTab, MemPalace, GBrain; watch: Membase, dev-browser, OpenClaw-RL, Qwen3.5-27B-Opus-Distilled; skip: Lightpanda)

## Nuvini Group Entity Registry

- [cris-nuvini-entity-registry.md](cris-nuvini-entity-registry.md) — Canonical registry of all Nuvini Group entities — NVNI (HoldCo), Heru (Brazil sub), Contably, SourceRank AI, StoneGEO — with jurisdiction, ownership, status, and update protocol for new acquisitions

## Investor Email Triage (Cris)

- [cris-investor-email-rules.md](cris-investor-email-rules.md) — Investor classification rules, PERSONAL_REPLY_NEEDED flag triggers, VIP tier routing, red-flag keywords, and rationale templates for Cris email triage
- [cris-investor-email-triage-samples.md](cris-investor-email-triage-samples.md) — 5 sample triage outputs showing PERSONAL_REPLY_NEEDED flag with rationale (2 flagged, 1 negative-signal, 2 draft-ready)
- [cris-vip-senders.json](cris-vip-senders.json) — Board members, lead investors, observers, and strategic advisors who always trigger personal reply (populate with real emails)

## Competitive Intelligence (Buzz)

- [buzz-daily-triage.md](buzz-daily-triage.md) — Buzz daily competitive triage: scans TechCrunch/Crunchbase/LinkedIn for OMIE, Brex, Stripe, NVNI portfolio — flags funding/hires/launches only, 3-5 bullets, Pierre brief at 08:00 UTC
- [buzz-triage-state.json](buzz-triage-state.json) — Deduplication state for buzz-daily-triage — tracks seen item hashes (30-day TTL) and run stats
- [buzz-skill-matching.md](buzz-skill-matching.md) — Living index of skill trigger patterns for Buzz — when to invoke /research, /growth, /firecrawl, /deep-research vs ad-hoc; missed routing and improvisation log templates

## Competitive Intelligence — M&A (North)

- [north-competitive-watchlist.md](north-competitive-watchlist.md) — Persistent watchlist of 10 key acquirers in Latin SaaS M&A space (Tiny, Vela, Volaris, PSG, Vista, Boopos, etc.) — weekly scan protocol, North Star briefing template, threat levels

## M&A Deal Intelligence (Marco)

- [marco-agent-teams-routing.md](marco-agent-teams-routing.md) — Agent Teams vs subagents decision matrix — 3-5 rule, token multipliers (~1.5-2x), independence criteria, quickstart checklist, current migration status per skill
- [marco-deal-registry.md](marco-deal-registry.md) — Master registry of all M&A deals Marco has analyzed — status, links, key takeaways per deal
- [deal-template.md](deal-template.md) — Reusable template for new deal pages (company overview, triage, DD, financial model, IC decisions, integration, relationship graph)
- [deal_stripe.md](deal_stripe.md) — Stripe deal page: fintech payments infrastructure, $65B+ valuation, watch status — IPO/carve-out monitor

## Agent Routing (Arnold)

- [arnold-task-routing.md](arnold-task-routing.md) — Pre-response checklist for Arnold: 5-step skill/parallelize/investigate/destructive gate + quick-reference task→skill routing table

## Swarm Coordination (Swarmy)

- [swarmy-context-handoff.md](swarmy-context-handoff.md) — Centralized context handoff: active priorities (Claudia v2, eSocial, M&A, SourceRank), key decisions (Agent Teams strategy, model tiers, memory pipeline), session ingest order, update protocol

## Patterns & Tech Insights (Contably Sessions)

- [pattern_sqlalchemy_checkfirst_pytest.md](pattern_sqlalchemy_checkfirst_pytest.md) — Use checkfirst=True in Base.metadata.create_all() to prevent duplicate-index errors when SQLAlchemy metadata is shared across a pytest session
- [mistake_fastapi_dep_injection_order.md](mistake_fastapi_dep_injection_order.md) — FastAPI route params: Depends() injected deps must come before Query()/Path() params in function signature, or Python raises SyntaxError; also Contably uses src.api.deps not src.api.dependencies
- [pattern_nginx_vite_spa_cache.md](pattern_nginx_vite_spa_cache.md) — Vite SPAs need short nginx cache (1h) + no-cache meta on index.html to prevent browsers holding stale hashed-bundle references after deploys
- [pattern_contably_integration_module_structure.md](pattern_contably_integration_module_structure.md) — Contably 3rd-party integration layout: integrations/{name}/{client,service,cache,schemas}.py + models + routes/system + celery tasks; registration checklist included
- [pattern_oci_staging_prod_promote.md](pattern_oci_staging_prod_promote.md) — Push to main builds stg-<sha> image → staging namespace; promote to production via workflow_dispatch with image_tag + confirm=yes guard
- [pattern_karpathy_wiki_github_events.md](pattern_karpathy_wiki_github_events.md) — Feed an AI copilot knowledge wiki by subscribing to GitHub push/PR webhook events and ingesting commit messages + diffs
- [tech_insight_ruff_pin_ci.md](tech_insight_ruff_pin_ci.md) — Ruff changes rules between versions — always pin ruff==x.y.z in CI to prevent random lint failures
- [architecture_k8s_namespace_env_separation.md](architecture_k8s_namespace_env_separation.md) — Separate staging/production into distinct K8s namespaces with separate DB URLs, Redis DB slots (/0 vs /1), and subdomains

## Feedback

- [mistake_nightly_unvalidated_db_columns.md](mistake_nightly_unvalidated_db_columns.md) — Nightly automation added DB columns to queries without verifying schema — crashed all API requests; always validate column existence before querying
- [tech_insight_free_model_tool_calling.md](tech_insight_free_model_tool_calling.md) — Free/smaller LLMs describe tool calls instead of calling them — fix with imperative persona: "IMMEDIATELY call the function, do NOT describe it"
- [pattern_sse_multi_agent_delegation.md](pattern_sse_multi_agent_delegation.md) — SSE broadcast pattern for inter-agent delegation: delegation:task + delegation:response events route specialist work to their own chat channel
- [mistake_cdn_version_not_verified.md](mistake_cdn_version_not_verified.md) — CDN version 404 (qrcode@1.5.4) blocked onboarding in Safari; always verify CDN URLs + add async to non-critical scripts
- [tech_insight_safari_api_caching.md](tech_insight_safari_api_caching.md) — Safari aggressively caches API responses causing stale UI; fix with Cache-Control: no-store on all /api/ routes at middleware level
- [feedback_blackbox_vs_code_review.md](feedback_blackbox_vs_code_review.md) — Always run code-level review (/cto or /review-changes) in addition to black-box testing (/fulltest-skill) — they catch fundamentally different classes of issues
- [feedback_claudia_vps_only.md](feedback_claudia_vps_only.md) — Any mention of Claudia means VPS — always SSH to /opt/claudia, never check local repo for state
- [feedback_contably_uses_github_actions.md](feedback_contably_uses_github_actions.md) — Contably CI/CD is GitHub Actions only — Woodpecker decommissioned 2026-04-10
- [feedback_github_token_override.md](feedback_github_token_override.md) — Invalid GITHUB_TOKEN env var overrides valid gh keyring credential — always unset it when using gh CLI or git clone
- [feedback_memory_boost_weights.md](feedback_memory_boost_weights.md) — Boost weights for memory search ranking — feedback 3x, user 2x, reference 1.5x, project 1x, with 1.5x recency for last 7 days
- [feedback_nuvini_ir_css_classes.md](feedback_nuvini_ir_css_classes.md) — nuvini-ir site uses section-label/section-title/section-description for styled headers — content-\* variants are unstyled
- [feedback_oke_session_auth.md](feedback_oke_session_auth.md) — OKE kubectl doesn't work with API key auth (Unauthorized) despite correct IAM policies — use Woodpecker CI for all cluster operations
- [feedback_parallel_first.md](feedback_parallel_first.md) — User wants Claude to always prefer parallel processing and swarm execution over sequential — maximize concurrent agents, tool calls, and background tasks
- [feedback_run_guardian_before_deploy.md](feedback_run_guardian_before_deploy.md) — Always run /contably-guardian before deploying Contably to staging or production — never skip it
- [feedback_use_browser_tools.md](feedback_use_browser_tools.md) — Don't ask the user for screenshots — use available browser/fetch tools to check visual state of deployed sites before asking
- [feedback_opus_for_investigation.md](feedback_opus_for_investigation.md) — Always use Opus for investigation, debugging, and bug fix subagents — Sonnet/Haiku only for mechanical tasks
- [feedback_no_ci_polling.md](feedback_no_ci_polling.md) — Never poll CI status in a loop — use `gh run watch` in background and wait for notification
- [feedback_oci_deploy_tag_format.md](feedback_oci_deploy_tag_format.md) — Production deploy image_tag is `stg-<7-char-sha>` (GITHUB_SHA::7), not 9-char — failed deploy when wrong length used
- [mistake_benchmark_selfdestruct.md](mistake_benchmark_selfdestruct.md) — Claudia benchmark safety-refuse-destructive test literally sent rm -rf /opt/claudia to Agent SDK running as root — nuked the deployment twice

## Projects

- [project_copilot_wiki.md](project_copilot_wiki.md) — Copilot Knowledge Wiki — Karpathy LLM Wiki pattern, GitHub events → Haiku ingest → DB wiki pages → co-pilot search tool
- [project_mfa_activation.md](project_mfa_activation.md) — Contably MFA was 85% done — fixed login flow + settings endpoint paths (405 bug), now fully functional
- [project_agentwave_deploy.md](project_agentwave_deploy.md) — AgentWave deploys to Contabo VPS via SSH, not Railway
- [project_benchmark_loop_scaleup.md](project_benchmark_loop_scaleup.md) — RESOLVED: Benchmark loop removed (2026-04-09) — too dangerous for autonomous execution (sent rm -rf /opt/claudia twice); compound-review (observe-only) kept
- [project_claudia_memory_v2.md](project_claudia_memory_v2.md) — Claudia Memory v2 — 5-layer composite memory system with nudge, consolidation, and complexity-aware skill generation (ALL PHASES COMPLETE)
- [project_claudia_migration_complete.md](project_claudia_migration_complete.md) — Claudia fully replaced OpenClaw — all features migrated including voice, TTS, STT, proactive scheduler, media support
- [project_claudia_router.md](project_claudia_router.md) — Claudia — TypeScript multi-channel AI agent router on VPS, 10 agents, 6 channels, 4-tier inference, 5-layer memory, 20+ scheduled tasks, dashboard, dispatch queue
- [project_claudia_voice_pipecat.md](project_claudia_voice_pipecat.md) — Claudia voice pipeline migrated from Twilio to Pipecat + Telnyx + Deepgram + Cartesia — real-time streaming voice
- [project_contably_ops.md](project_contably_ops.md) — Contably-ops repo and deal data structure for accounting firm acquisitions — skills, directories, workflow
- [project_esocial_plan.md](project_esocial_plan.md) — Contably eSocial module activation via TecnoSpeed middleware — decisions, phases, and partner strategy
- [project_esocial_phase2_shipped.md](project_esocial_phase2_shipped.md) — eSocial Phase 2 shipped 2026-04-15 — routes wired, S-1000/S-1010, schema S-1.3, 7 event types live
- [project_sla_phases_shipped.md](project_sla_phases_shipped.md) — SLA Phases 1–4a shipped 2026-04-15 + Minha Agenda role-aware redesign, Phase 4b trigger-gated
- [project_certcontrol_integration.md](project_certcontrol_integration.md) — CertControl digital certificate integration plan at docs/certcontrol-integration-plan.md — architecture, review notes, 6 pre-impl fixes
- [project_heartbeat_followup.md](project_heartbeat_followup.md) — RESOLVED: Heartbeat validated and improved (2026-04-09) — state tracking added (heartbeat-state.json), routed to #tech-ops, quiet hours 22:30-04:30 BRT, no split needed
- [claudia-heartbeat-tracker.md](claudia-heartbeat-tracker.md) — Spec for heartbeat issue dedup — active-issues.json on VPS, dedup by issue ID, escalation after count>5 or 2h, auto-resolve after 30min silence
- [project_nuvini_ir_deploy.md](project_nuvini_ir_deploy.md) — nuvini-ir deploys via Cloudflare Pages (wrangler) — build with eleventy, deploy \_site folder, not auto-deployed from git
- [project_woodpecker_ci.md](project_woodpecker_ci.md) — Woodpecker CI running on OKE cluster at ci.contably.ai — replaces OCI DevOps for Contably CI/CD
- [julia-oci-health-monitor.md](julia-oci-health-monitor.md) — Design spec for persistent OCI health monitoring — hourly checks stored in SQLite, status page at /oci-status, change-driven Discord alerts
- [project_intel_scanner_vps.md](project_intel_scanner_vps.md) — Intel Scanner on VPS — Exa-powered cron scanning 30 X accounts for Claude/OpenClaw intel, posts to Discord #intel every 2h (5am-5pm BRT)
- [tech_glasswing_vuln_hunting.md](tech_glasswing_vuln_hunting.md) — Anthropic Project Glasswing — $100M+ AI vulnerability initiative using Claude Mythos Preview (83.1% CyberGym repro rate). Glasswing-style prompting added to /cto security analyst.

## Mary / OpenClaw Operations

- [project_mary_openclaw_fixes.md](project_mary_openclaw_fixes.md) — OpenClaw operational fixes: memory-core blocks readiness, groupPolicy must be "open", claude-cli fails as root, WhatsApp allowFrom/pairing rules, config file locations

## Tech Insights

- [tech_agent_sandbox_distrust.md](tech_agent_sandbox_distrust.md) — Security principle for multi-agent systems — enforce isolation at OS/VM layer, not by trusting agent behavior. NanoClaw + Docker Sandbox as reference implementation.
- [tech_agent_credential_proxy.md](tech_agent_credential_proxy.md) — Egress credential proxy pattern — inject API keys at proxy layer, never expose to agent. Implemented in AgentWave.
- [tech_ai_platform_attack_surface.md](tech_ai_platform_attack_surface.md) — Attack chain from McKinsey Lilli breach — unauthenticated endpoints + JSON-key SQLi + system prompt write access = full AI platform compromise
- [tech_asmr_memory_retrieval.md](tech_asmr_memory_retrieval.md) — Supermemory ASMR pipeline — 3-agent parallel retrieval (facts/context/temporal) replacing vector DB, ~99% on LongMemEval_s. Open-source ~April 2026.
- [tech_agent_browser.md](tech_agent_browser.md) — agent-browser (Vercel Labs) v0.25.4 — Rust CDP CLI, primary browser tool, batch mode, visual diff, self-updating docs
- [tech_browse_cli.md](tech_browse_cli.md) — gstack browse CLI at ~/.local/bin/browse — fallback browser automation (superseded by agent-browser)
- [tech_hyperskill_skill_tree.md](tech_hyperskill_skill_tree.md) — HyperSkill auto-generates SKILL.md files from live docs; skill-tree command splits deep docs into navigable index + sub-files to avoid context bloat
- [tech_lightpanda_browser.md](tech_lightpanda_browser.md) — Lightpanda headless browser (Zig, CDP-compatible) — evaluated as Chrome/Browserless replacement, not ready due to missing PDF/Lighthouse/SPA gaps. Revisit Q3 2026.
- [tech_openclaw_rl.md](tech_openclaw_rl.md) — OpenClaw-RL — Princeton async RL framework that trains local AI agents from conversations; unlocks Tier 0 local model self-improvement with Qwen 3.5-4B/8B
- [tech_claude_managed_agents.md](tech_claude_managed_agents.md) — Claude Managed Agents public beta (2026-04-08) — Anthropic's managed agent harness + cloud infra: Agent/Environment/Session/Events model, built-in Bash/file/web/MCP tools, $0.08/session-hour, replaces DIY agent loops
- [tech_managed_agents_test.md](tech_managed_agents_test.md) — Live Managed Agents test (2026-04-09): $0.25, 90s active, works but no win over Agent SDK — don't enable yet, revisit when threads GA + native MCP
- [tech_vault_as_context_pattern.md](tech_vault_as_context_pattern.md) — CLAUDE.md-as-API-contract pattern for knowledge vaults + vault-as-context subagent spawn prompt pattern (Section 3.6 of AGENT-TEAMS-STRATEGY.md)
- [tech_membase_evaluation.md](tech_membase_evaluation.md) — Membase.so evaluation — hosted personal memory layer (MCP-native, knowledge graph, Gmail/Slack/Calendar sync), WATCH verdict, no REST API blocks AgentWave integration
- [tech_mempalace_memory_system.md](tech_mempalace_memory_system.md) — MemPalace — free local AI memory system, ChromaDB + 19 MCP tools, palace hierarchy (wings/rooms/halls), 96.6% R@5 LongMemEval, per-agent diaries, temporal KG — strong fit for Claudia Layer 6
- [tech_token_efficient_search.md](tech_token_efficient_search.md) — Web search token efficiency research — Brave LLM Context API has explicit token budget, Exa highlights cut 50-75% tokens, pre-search orchestrator pattern saves 60-70% redundant searches
- [tech_advisor_strategy.md](tech_advisor_strategy.md) — Claude Platform advisor strategy (Sonnet executor + Opus advisor) for cost-efficient agentic sessions
- [tech_gbrain_integration.md](tech_gbrain_integration.md) — GBrain world-knowledge brain integrated into Claudia as Source 5 — separate Postgres DB, 30 MCP tools, compiled truth + timeline
- [tech_pluggable_context_engine.md](tech_pluggable_context_engine.md) — Pluggable context injection for swarm skills — context manifest YAML, parallel gather, role-based slicing, 65-80% token savings
- [tech_hermes_channel_adapters.md](tech_hermes_channel_adapters.md) — Hermes v0.9.0 iMessage/WeChat/WeCom adapter architecture — integration brief for AgentWave channel expansion
- [tech_multi_agent_patterns_taxonomy.md](tech_multi_agent_patterns_taxonomy.md) — Anthropic's official 5-pattern multi-agent taxonomy — Generator-Verifier, Orchestrator-Subagent, Agent Teams, Message Bus, Shared State

## Infrastructure (Bella)

- [bella-systemd-routines.md](bella-systemd-routines.md) — VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines survive reboots; claudia-cron.service stale (safe to reset-failed)

## Mary Migration (OpenClaw)

- [project_mary_migration.md](project_mary_migration.md) — Mary (OpenClaw v2026.4.10) replaced Claudia on VPS — config paths, model routing, channel status, deferred work (memory plugin, dispatch queue, OpenAI billing)

## Rex Agent (Security Audit)

- [rex-mlx-benchmark-spec.md](rex-mlx-benchmark-spec.md) — Benchmark spec for local MLX models on Rex tasks — test design, metrics, routing recommendations (35B-A3B, 9B, 27B-Distilled vs Sonnet baseline across 5 task types)

## References

- [reference_gemini_api.md](reference_gemini_api.md) — Google Gemini API key in macOS Keychain (GEMINI_API_KEY)
- [reference_cloudflare.md](reference_cloudflare.md) — Cloudflare API token with Zone.DNS edit for all zones, account details, zone IDs, and where credentials are stored
- [reference_cloudflare_nuvini.md](reference_cloudflare_nuvini.md) — Cloudflare API token for nuvini.ai domain DNS — separate account (P@nuvini.co) from main (p@nove.co)
- [reference_orchestrator_technical.md](reference_orchestrator_technical.md) — Contably Orchestrator full technical reference — webhook API, service accounts, job types, circuit breaker, dead letter, DB models, integration patterns
- [reference_oci_contably.md](reference_oci_contably.md) — OCI infrastructure credentials, OCIDs, cluster topology, kubectl auth, and CI/CD pipeline details for Contably
- [reference_openrouter_api.md](reference_openrouter_api.md) — OpenRouter API key for Qwen 3.6 Plus and other models — stored in macOS Keychain and Claudia VPS .env
- [reference_paperclip_vps.md](reference_paperclip_vps.md) — Paperclip AI orchestration running on VPS with 3 companies (Nuvini, Contably, SourceRank) — hybrid claude_local + openclaw_gateway adapters, Nemotron 3 Super via Ollama for CEOs
- [reference_resend_cli.md](reference_resend_cli.md) — Resend CLI (v1.4.1) configured as transactional send channel in /agentmail skill — use for one-way sends from verified domains (contably.ai, xurman.com, agentwave.io)
- [reference_search_api_keys.md](reference_search_api_keys.md) — API keys for web search tools — Brave Search LLM Context API and Exa.ai neural search, stored in macOS Keychain and settings.json
- [reference_telnyx_voice.md](reference_telnyx_voice.md) — Telnyx voice infrastructure — API key in Keychain, Claudia's phone number, connection details
- [reference_vps_connection.md](reference_vps_connection.md) — How to reach the Contabo VPS (Claudia, Paperclip) — Tailscale IP, SSH user, hostname, ports
- [julia-searxng-fallback.md](julia-searxng-fallback.md) — SearXNG fallback chain — health checks, error patterns, tool fallback order for web search (Mac Mini :8888 → Brave → Exa → WebSearch)
- [tech_anthropic_harness_design.md](tech_anthropic_harness_design.md) — Planner/generator/evaluator three-agent pattern and structured handoff (no compaction) for long-running agent sessions — from Anthropic engineering post on frontend design
- [tech_hermes_subconscious_pattern.md](tech_hermes_subconscious_pattern.md) — Hermes agent patterns implemented in Claudia — periodic nudge, auto-skill generation, session consolidation, skill self-patch policy
- [tech_prompt_cache_1h_vs_5m.md](tech_prompt_cache_1h_vs_5m.md) — Prompt cache TTL: subagents = 5m (intentional), main agent = 1h (rolling out), telemetry off = 5m — from Boris Cherny (Anthropic)
- [tech_claude_code_routines.md](tech_claude_code_routines.md) — Claude Code Routines (research preview 2026-04-14) — server-side scheduled/event/API-triggered agent runs on Anthropic cloud, successor to VPS cron scheduling
- [tech_insight_opus_4_7_best_practices.md](tech_insight_opus_4_7_best_practices.md) — Opus 4.7 official guidance (2026-04-16) — xhigh default effort, adaptive thinking (no budget_tokens), explicit subagent fan-out required

# currentDate

Today's date is 2026-04-11.
