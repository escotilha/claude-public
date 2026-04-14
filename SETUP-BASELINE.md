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

## Skills (80 on-disk; ~130 in baseline including Finance/M&A not yet created)

**Note (2026-04-14):** Finance/M&A skills listed below under "Finance & M&A" are NOT yet on disk — they were listed in baseline as planned/future skills. The 80 on-disk skills are the actually-deployed set.

### Developer Workflow (24)

ship, deep-plan, cto, first-principles, verify, test-and-fix, review-changes, cpr, sc, cs, run-local, parallel-dev, codebase-cleanup, website-design, project-orchestrator, maketree, revert-track, simplify, get-api-docs, architecture, mini-remote, architect, tech-audit, local-inference

### QA & Testing (9)

qa-cycle, qa-conta, qa-sourcerank, qa-stonegeo, qa-fix, qa-verify, fulltest-skill, virtual-user-testing, health-report

### Deploy & Ops (5)

deploy-conta-staging, deploy-conta-production, deploy-sourcerank, contably-guardian, sourcerank-guardian, oci-health

### Research & Scraping (9)

deep-research, research, firecrawl, scrapling, browserless, pinchtab, qmd, last30days, wiki

### AI & Growth (3)

llm-eval, growth, chief-geo

### Communication (4)

agentmail, slack, tweet, gws

### Product & Business (3)

cpo, office-hours, proposal-source

### Meta & Setup (7)

claude-setup-optimizer, memory-consolidation, meditate, primer, skill-tree, demo, manual

### Infra & Agents (4)

nanoclaw, computer-use, paperclip, paperclip-create-agent

### Built-in Extensions (3)

loop, batch, memory

### Security (1)

rex

### Advisory (1)

vibc

### Finance & M&A (12+)

finance-dcf, finance-comps, finance-lbo, finance-model, finance-memo, finance-pitch, finance-cim, finance-dataroom, finance-ic, finance-nda, finance-loi, finance-spa, mna-pipeline, mna-diligence, mna-synergies, mna-integration, ir-deck, ir-earnings, ir-model, compliance-kyc, compliance-aml, compliance-reporting, legal-review, legal-redline, analyze-deal, committee-presenter, aimpact, generate-deck, portfolio-monitor, portfolio-report, portfolio-valuation, financial-model

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

- Deep research for due diligence (deep-research — active; mna-diligence — NOT ON DISK)
- Financial modeling: uses officecli + gws + deep-research ad-hoc (finance-\* skills NOT on disk)
- Deal pipeline: analyze-deal, proposal-source (active); finance-memo, finance-cim NOT on disk
- IC and board presentation: committee-presenter NOT on disk; officecli covers deck creation
- Legal: legal-review, legal-redline NOT on disk
- Portfolio: portfolio-\* skills NOT on disk
- AI impact: aimpact NOT on disk
- Google Workspace for docs/sheets (active via gws + officecli)

**Coverage downgraded from HIGH to MEDIUM** — finance/M&A skill suite was listed as planned but not yet built. Core capabilities (research, doc creation) exist but specialized financial modeling skills are absent.

### Gaps Identified

#### Developer Gaps (Minor)

- No dedicated monitoring/alerting skill
- No load testing / performance benchmarking skill
- No database migration management skill
