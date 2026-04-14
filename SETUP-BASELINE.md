# Setup Baseline Inventory

**Last verified:** 2026-04-14
**Next review:** Biweekly (Wednesday + Sunday, 6am)

---

## MCP Servers (18)

| #   | Server              | Purpose                         | Status                                      |
| --- | ------------------- | ------------------------------- | ------------------------------------------- |
| 1   | sequential-thinking | Structured problem solving      | Active                                      |
| 2   | memory              | Knowledge graph (Turso-backed)  | Active                                      |
| 3   | playwright          | Browser automation              | Active                                      |
| 4   | github              | GitHub API                      | Active                                      |
| 5   | brave-search        | Web search (LLM Context API)    | Active                                      |
| 6   | exa                 | Neural search with highlights   | Active                                      |
| 7   | postgres            | PostgreSQL (Claudia on Contabo) | Active                                      |
| 8   | resend              | Transactional email             | Active                                      |
| 9   | slack               | Slack integration               | Active                                      |
| 10  | notion              | Notion workspace                | Active                                      |
| 11  | digitalocean        | DO App Platform, DBs, Spaces    | Active                                      |
| 12  | chrome-devtools     | Chrome DevTools automation      | Active                                      |
| 13  | firecrawl           | Web scraping/crawling           | Active                                      |
| 14  | ScraplingServer     | Stealth scraping, anti-bot      | Active                                      |
| 15  | context-mode        | Context window compression      | Active                                      |
| 16  | qmd                 | Hybrid search over markdown     | Active                                      |
| 17  | google-workspace    | GWS (p@nuvini.ai)               | Active (uvx workspace-mcp, not in settings) |
| 18  | officecli           | Office doc creation/editing     | Active                                      |

**Note:** plugin:discord and plugin:swift-lsp moved to `enabledPlugins` system. google-workspace is active but configured outside settings.json (uvx workspace-mcp).

## Skills (78 on-disk)

### Developer Workflow (23)

ship, deep-plan, cto, first-principles, verify, test-and-fix, review-changes, cpr, sc, cs, run-local, parallel-dev, codebase-cleanup, website-design, project-orchestrator, maketree, revert-track, get-api-docs, architecture, mini-remote, architect, tech-audit, local-inference

### QA & Testing (9)

qa-cycle, qa-conta, qa-sourcerank, qa-stonegeo, qa-fix, qa-verify, fulltest-skill, virtual-user-testing, health-report

### Deploy & Ops (7)

deploy-conta-staging, deploy-conta-production, deploy-conta-full, deploy-sourcerank, contably-guardian, sourcerank-guardian, oci-health

### Research & Scraping (10)

deep-research, last30days, research, firecrawl, scrapling, browserless, pinchtab, agent-browser, qmd, wiki

### AI & Growth (5)

llm-eval, growth, chief-geo, gbrain, claude-api

### Communication (5)

agentmail, slack, tweet, gws, officecli

### Product & Business (4)

cpo, office-hours, proposal-source, pr-impact

### Meta & Setup (8)

claude-setup-optimizer, memory-consolidation, meditate, primer, skill-tree, demo, manual, schedule

### Infra & Agents (4)

nanoclaw, computer-use, agent-platform, platform-sweep

### Built-in Extensions (3)

loop, batch, memory

### Security (1)

rex

### Advisory (2)

vibc, vault-bootstrap

## Agents (9)

backend-agent, database-agent, devops-agent, frontend-agent, oncall-guide, performance-agent, project-orchestrator, security-agent, review/ (multi-perspective)

## Plugins (8)

discord, codex (OpenAI), frontend-design, typescript-lsp, security-guidance, hookify, pyright-lsp, warp

**Note:** swift-lsp was replaced by typescript-lsp + pyright-lsp. codex (OpenAI) added via external marketplace. warp added via claude-code-warp marketplace.

## Rules (8)

AGENT-TEAMS-STRATEGY.md, memory-strategy.md, model-tier-strategy.md, nuvini-sync-rules.md, parallel-first.md, skill-first.md, tool-annotations.md, web-search-efficiency.md

## Hooks (Active)

| Event                 | Purpose                                  |
| --------------------- | ---------------------------------------- |
| SessionStart          | git pull + core memory load              |
| SessionEnd            | Session teardown                         |
| SubagentStart/Stop    | Logging                                  |
| PostToolUse           | Auto-formatting, skill execution logging |
| PreToolUse            | Security checks                          |
| UserPromptSubmit      | Prompt pre-processing                    |
| TeammateIdle          | Task assignment prompts                  |
| TaskCompleted         | Auto-assignment for idle teammates       |
| TaskCreated           | Task creation logging                    |
| PostCompact           | State file recovery                      |
| CwdChanged            | Git branch context refresh               |
| StopFailure           | API error logging                        |
| ConfigChange          | Config audit logging                     |
| Elicitation/Result    | MCP elicitation logging                  |
| InstructionsLoaded    | Rules file load event                    |
| WorktreeCreate/Remove | Worktree lifecycle management            |
| FileChanged           | File change detection                    |
| PermissionDenied      | Permission denial logging                |
| Setup                 | Repo setup/maintenance                   |

**Missing hook:** `PermissionRequest` — not yet configured (auto-approve/deny tool permissions)

## Role Coverage

### Developer (Primary) — Coverage: HIGH

- Full CI/CD: verify → review → commit → push → PR
- Parallel dev with worktrees
- QA cycle with auto-fix
- CTO-level architecture review
- Deep planning and research
- Browser automation (3 options)
- Web scraping (3 options)

### M&A Analyst (Secondary) — Coverage: MEDIUM

- Deep research for due diligence (deep-research)
- Deal pipeline and client proposals (proposal-source)
- Document creation via officecli and gws (decks, memos, spreadsheets)
- Google Workspace for docs/sheets (gws + officecli)

No dedicated finance/M&A skills exist on disk. Core M&A workflows rely on general-purpose skills (deep-research, officecli, gws, proposal-source).

### Gaps Identified

#### Developer Gaps (Minor)

- No dedicated monitoring/alerting skill
- No load testing / performance benchmarking skill
- No database migration management skill
