# Nuvini Claude Repo Sync Rules

Rules for what to include/exclude when pushing to `escotilha/claude-public`.

## Purpose

The `escotilha/claude-public` repo is a **public-facing showcase** of reusable Claude Code skills and agents. It should contain only generic, portable skills — not project-specific, infrastructure-specific, or internal tooling.

## EXCLUDE from escotilha/claude-public

### Project-Specific Skills (tied to a single project)

- `qa-conta` — Contably-specific QA
- `qa-sourcerank` — SourceRank-specific QA
- `qa-stonegeo` — StoneGEO-specific QA
- `virtual-user-testing` — Contably-specific persona testing
- `verify-conta` — Contably-specific verification suite (ruff, mypy, tsc, vitest)
- `contably-ci-rescue` — Contably-specific CI failure diagnosis and fix playbook
- `contably-eod` — Contably end-of-day autonomous pipeline
- `contably-snapshot` — Generate Contably CODEBASE-REFERENCE.md
- `oci-health` — Contably OCI infrastructure health check
- `proposal-source` — SourceRank client proposals
- `chief-geo` — SourceRank GEO officer (daily autonomous)
- `health-report` — SourceRank-specific health report

### Deployment Skills (project-specific pipelines)

- `deploy-conta-staging` — Contably OCI staging deployment
- `deploy-conta-production` — Contably OCI production promotion
- `deploy-conta-full` — Contably staging → production pipeline
- `deploy-sourcerank` — SourceRank Render deployment
- `deploy-claudia` — Claudia VPS deployment
- `contably-guardian` — Contably pre-deploy checks
- `sourcerank-guardian` — SourceRank pre-deploy checks

### Internal Tooling (personal workflow, not reusable)

- `cs` — syncs escotilha/claude personal repo
- `cpr` — personal commit+push+PR shortcut
- `sc` — personal ship commit shortcut
- `paperclip` — Paperclip control plane (internal orchestration)
- `paperclip-create-agent` — Paperclip agent creation
- `slack` — personal Slack automation
- `agentmail` — personal email automation
- `tweet` — personal tweet fetching
- `gws` — personal Google Workspace automation
- `mini-remote` — SSH relay to Mac Mini
- `computer-use` — macOS/iOS desktop automation
- `nanoclaw` — personal agent runtime setup

### Personal Decision/Context Tools

- `pr-impact` — Nuvini (NVNI) press release optimizer
- `rex` — infrastructure security audit across personal machines
- `office-hours` — product office hours (internal brainstorming)
- `primer` — personal session context recovery
- `vibc` — advisory board deliberation simulator

### Infrastructure References (sensitive)

Never push content containing:

- Contabo VPS details (IPs, hostnames, SSH ports)
- Tailscale IPs or network topology
- Supabase project URLs or keys
- API endpoints for staging/production (e.g., api.contably.ai)
- Personal email addresses or agent mailboxes
- GitHub tokens or auth details

### Meta/Setup Skills

- `claude-setup-optimizer` — only useful for this specific setup
- `memory-consolidation` — tied to personal memory pipeline
- `meditate` — tied to personal memory pipeline
- `test-memory` — debug skill

## INCLUDE in escotilha/claude-public

### Generic, Reusable Skills

- `cto` — architecture/security/performance review (any project)
- `ship` — end-to-end feature shipping (any project)
- `deep-plan` — research + plan + implement (any project)
- `deep-research` — multi-track research (any topic)
- `qmd` — semantic search over markdown collections (any project)
- `parallel-dev` — parallel feature development (any project)
- `first-principles` — problem decomposition (any problem)
- `qa-cycle` — master QA orchestrator (any project)
- `qa-fix` — fix QA issues (any project)
- `qa-verify` — verify fixes (any project)
- `fulltest-skill` — full-spectrum testing (any site)
- `website-design` — B2B SaaS design (any project)
- `codebase-cleanup` — find unused files (any project)
- `project-orchestrator` — full project lifecycle (any project)
- `review-changes` — code review (any project)
- `test-and-fix` — auto-fix tests (any project)
- `verify` — typecheck + tests + build (any project)
- `skill-tree` — split large docs into navigable hierarchies (any project)
- `run-local` — start dev server (any project)
- `research` — analyze URLs/tools (any topic)
- `firecrawl` — web scraping (any site)
- `get-api-docs` — fetch current API docs via chub (any library)
- `scrapling` — stealth scraping (any site)
- `browserless` — headless browser (any site)
- `pinchtab` — local browser automation, token-efficient (any site)
- `maketree` — git worktree management (any project)
- `revert-track` — revert features (any project)
- `manual` — build user manual (any project)
- `officecli` — create/edit Office documents via CLI (any project)
- `demo` — reproducible demo documents (any project)
- `cpo` — product lifecycle (any project)
- `llm-eval` — LLM output evaluation pipeline (any AI feature)
- `growth` — SaaS growth engineering (any SaaS product)

### Generic Agents

All agents in `~/.claude-setup/agents/` are generic and safe to share.

### LLM-Discoverable Index Files (auto-generated)

These are generated by `tools/build-llms.sh` and regenerated nightly by `mem-consolidate`. They inline skill + rule content and are safe to share — the generator already excludes `_*` (private/archived) skills and any rule files listed in `RULE_EXCLUDES`:

- `llms.txt` — llmstxt.org-spec index with links to rules and skills
- `llms-full.txt` — single-file context (rules inlined, skill frontmatter + preview per skill)

These are published per the llmstxt.org convention so any LLM agent can fetch a single URL to understand the full setup.

## Decision Rule

**Before sharing a skill to escotilha/claude-public, ask:**

1. Does it reference a specific project name (Contably, SourceRank, StoneGEO)? -> EXCLUDE
2. Does it contain hardcoded IPs, URLs, or credentials? -> EXCLUDE
3. Does it only work with personal accounts/services (Slack, email, GitHub)? -> EXCLUDE
4. Could a stranger clone the repo and use this skill on their own project? -> INCLUDE
