---
name: swarmy-context-handoff
description: Centralized state file with active priorities, key decisions, and session context for agent calibration
type: project
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Swarmy is Claudia's swarm coordinator. This file is the canonical context handoff — ingest at session start, update after significant decisions or priority shifts.

**As of:** 2026-04-11

---

## Active Priorities

### 1. Claudia v2 Agent Infrastructure

- Memory v2 fully deployed (5 layers: journals, KG, fact extraction, nudge, consolidation)
- MemPalace integrated as Layer 6 (per-agent episodic diaries, ChromaDB, palace hierarchy)
- Managed Agents evaluated (2026-04-09): $0.25/90s, no win over Agent SDK — hold until threads GA + native MCP
- Benchmark loop removed (too dangerous — nuked VPS twice); compound-review (observe-only) kept
- Next infrastructure bets: local nomic embeddings to eliminate OpenAI embedding cost; Managed Agents for `swarmy` multi-agent sessions specifically
- Heartbeat resolved: state tracking, routed to #tech-ops, quiet hours 22:30–04:30 BRT

### 2. Contably eSocial Integration

- Decision: TecnoSpeed as middleware (REST → TX2 → SOAP/signing handled by them)
- Code is 70% done (3,187 backend + 504 UI lines) — S-1.2 schema needs upgrade to S-1.3
- Phase 1 (DB migration + REST client): 3–5 days; Phase 2 (TX2 builders, 48 events): 3–5 days
- Blocking action: TecnoSpeed contract + Conta TecnoSpeed registration for Data Dictionary
- Deploy via Woodpecker CI (ci.contably.ai) — never direct kubectl; always run /contably-guardian first

### 3. M&A Pipeline (micro-SaaS targets)

- Marco is active deal analyst; deal registry at marco-deal-registry.md
- Active: Stripe (prospect, fintech, $65B+ — watch-only, IPO likely before any M&A window)
- Template at deal-template.md; use /deep-research for new targets
- Focus: micro-SaaS acquisitions for Nuvini portfolio; accounttech / vertical SaaS preferred

### 4. SourceRank Growth

- chief-geo agent runs daily autonomous GEO strategy
- Growth levers: AI SEO (GEO), competitor comparison, onboarding flow
- Deployments via Render (/deploy-sourcerank), guardian required before prod

---

## Key Decisions (Affect All Agents)

### Agent Teams Migration Strategy

- Default: subagents (Task tool). Agent Teams only for 3–5 workers with genuine cross-talk
- Migrate: `parallel-dev` (worktree isolation + cross-feature coordination)
- Hybrid: `cto` (sequential stays single-session; swarm gets Agent Teams)
- Stay subagents: `fulltest-skill`, `cpo-ai-skill` (report-back only, no inter-agent reasoning)
- Monitor tool now handles polling elimination — only migrate parallel-dev when cross-feature API coordination is needed
- Always include fallback: every Agent Teams skill must work without TeammateTool

### Model Tier Routing

- Orchestrators: Opus (cto, ship, parallel-dev, deep-plan)
- Judgment tasks: Sonnet (feature impl, code review, bug investigation, fixers)
- Mechanical tasks: Haiku (explore, page testing, formatting, scaffolding)
- Advisor pattern available: Sonnet executor + Opus advisor for long sessions with sparse judgment needs
- Claudia tiers: Claude SDK → Mac Mini MLX (Qwen3.5-35B-A3B, ~103 tok/s) → VPS Ollama → OpenRouter

### Memory Consolidation Pipeline

- /meditate runs after /ship, /cto, /parallel-dev, long sessions
- mem-search dedup before every new memory write
- Cross-link 3–5 related files per new memory (Karpathy wiki pattern)
- Compiled truth rewritten on change; timeline append-only
- Boost weights: feedback 3×, user 2×, reference 1.5×, project 1×; recency 1.5× for last 7 days

### Infrastructure Conventions

- Claudia = VPS only — SSH to /opt/claudia, never check local repo for live state
- All Claudia operations: SSH to Contabo VPS (Tailscale 100.66.244.112)
- Contably CI/CD: Woodpecker (ci.contably.ai) + GitHub Actions — both active
- Parallel-first: batch all independent tool calls in a single message; swarm mode default for /cto, /fulltest-skill, /qa-cycle

---

## Session Context Template

At the start of a new Swarmy session, ingest in this order:

```
1. This file (swarmy-context-handoff.md) — priorities + decisions
2. project_claudia_router.md — architecture reference
3. project_claudia_memory_v2.md — memory layer status
4. marco-deal-registry.md — current M&A pipeline
5. mem-search "<topic>" — any topic-specific memory before acting
```

Key rules to re-apply every session:

- Always run /contably-guardian before any Contably deploy
- Never use github GITHUB_TOKEN env var when using gh CLI (overrides keyring)
- Don't ask for screenshots — use browse/fetch tools to check deployed sites
- Parallel-first: batch reads, greps, globs; swarm mode default

---

## Update Protocol

**When to update this file:**

- After a major priority shifts (new project, project closes, phase completes)
- After a key decision that affects 2+ agents or skills
- After a /meditate session that surfaces portfolio-level learnings
- Max cadence: once per session (avoid micro-updates)

**How to update:**

1. Rewrite the relevant section in the compiled truth (not append-only)
2. Add a timeline entry below with date, source, and what changed
3. Run `~/.claude-setup/tools/mem-search --reindex`
4. Do NOT update MEMORY.md one-liner unless the description itself changes

---

## Timeline

- **2026-04-11** — [session] File created. Active priorities: Claudia v2 infra, eSocial, M&A pipeline, SourceRank growth. Key decisions: Agent Teams strategy, model tiers, memory pipeline. (Source: session — swarmy context handoff)
