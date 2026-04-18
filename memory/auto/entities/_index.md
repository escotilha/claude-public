# Entities & Agents

Category index. See [MEMORY.md](../MEMORY.md) for the top-level TOC.

- [agent-memory-bella](agent-memory-bella.md) — Bella agent identity — Chief Technology Officer, Contably (dedicated); owns all Contably engineering/infra/security/scaling; tech evaluation + skill library kept as secondary duties
- [agent-memory-julia](agent-memory-julia.md) — Julia agent identity — Product Manager for Contably; roadmap, user research, sprint planning, stakeholder mgmt; keeps eSocial/NF-e domain expertise, drops pure ops to Bella
- [agent-memory-marco](agent-memory-marco.md) — Marco agent identity, operating preferences, investment thesis, and M&A research methodology — Nuvini Group M&A research analyst
- [arnold-task-routing](arnold-task-routing.md) — Pre-response checklist for routing tasks to skills, parallelization, or ad-hoc execution
- [bella-systemd-routines](bella-systemd-routines.md) — VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines survive reboots
- [bella-tech-eval-kb](bella-tech-eval-kb.md) — Persistent log of URL/tool evaluations with scores, verdicts, and reasoning — Bella agent tech research tracker
- [buzz-daily-triage](buzz-daily-triage.md) — Daily competitive signal triage for NVNI portfolio — scans TechCrunch, Crunchbase, LinkedIn for high-signal moves by OMIE, Brex, Stripe, and NVNI portfolio companies
- [buzz-skill-matching](buzz-skill-matching.md) — Living index of skill trigger patterns — when to invoke which skill, missed routing, parallelism opportunities
- [buzz-triage-sample-2026-04-10](buzz-triage-sample-2026-04-10.md) — Sample daily competitive brief output — 2026-04-10 — showing what Pierre would receive each morning
- [claudia-heartbeat-tracker](claudia-heartbeat-tracker.md) — Spec for heartbeat issue dedup — tracks active issues, prevents re-reporting, escalates persistent ones
- [cris-investor-email-rules](cris-investor-email-rules.md) — Cris email triage rules — investor classification, PERSONAL_REPLY_NEEDED flag, VIP routing
- [cris-investor-email-triage-samples](cris-investor-email-triage-samples.md) — Sample triage output showing PERSONAL_REPLY_NEEDED flag with rationale — 5 examples
- [cris-nuvini-entity-registry](cris-nuvini-entity-registry.md) — Canonical registry of all Nuvini Group entities — names, jurisdictions, ownership, status
- [deal-template](deal-template.md) — M&A deal intelligence page — {Company Name} ({status})
- [deal_stripe](deal_stripe.md) — M&A deal intelligence page — Stripe (prospect)
- [julia-oci-health-monitor](julia-oci-health-monitor.md) — Design spec for persistent OCI health monitoring — hourly checks stored in SQLite, status page at /oci-status
- [julia-searxng-fallback](julia-searxng-fallback.md) — SearXNG fallback chain — health checks, error patterns, tool fallback order for web search
- [mac-mini-identification](mac-mini-identification.md) — How to tell when a Claude Code session is running ON the Mac Mini vs the main Mac — hostname, Tailscale IP, user, and the MLX inference server it hosts
- [marco-agent-teams-routing](marco-agent-teams-routing.md) — Consolidated Agent Teams vs subagents decision matrix — 3-5 rule, token multipliers, independence criteria, quickstart checklist
- [marco-deal-registry](marco-deal-registry.md) — Master registry of all M&A deals analyzed by Marco — status, links, key takeaways
- [north-competitive-watchlist](north-competitive-watchlist.md) — Persistent competitive intelligence watchlist for Nuvini Group M&A strategy — Latin SaaS acquisition space, weekly scan protocol, North Star integration
- [rex-mlx-benchmark-spec](rex-mlx-benchmark-spec.md) — Benchmark spec for local MLX models on Rex tasks — test design, metrics, routing recommendations
- [swarmy-context-handoff](swarmy-context-handoff.md) — Centralized state file with active priorities, key decisions, and session context for agent calibration
- [vps-claude-remote-control](vps-claude-remote-control.md) — Claude Code Remote Control running on Contabo VPS via systemd — connect from Claude Desktop/browser to work on remote filesystem
