# Model Tier Strategy for Subagents

Route subagent tasks to the cheapest model that can handle the work. This saves tokens without sacrificing quality.

## Tier Definitions

| Tier       | Model  | Cost   | Use For                                                                     |
| ---------- | ------ | ------ | --------------------------------------------------------------------------- |
| **Tier 1** | Haiku  | Low    | Deterministic execution, template-driven, report formatting, scaffolding    |
| **Tier 2** | Sonnet | Medium | Nuanced judgment, code review, investigation, moderate complexity           |
| **Tier 3** | Opus   | High   | Architecture decisions, security audits, complex reasoning, production code |

## Decision Matrix

| Task Type                        | Model  | Rationale                                   |
| -------------------------------- | ------ | ------------------------------------------- |
| Run typecheck / lint / tests     | haiku  | Pure execution, no judgment needed          |
| Format or generate reports       | haiku  | Template-driven output                      |
| Explore codebase (Explore agent) | haiku  | File discovery, grep, glob — deterministic  |
| Page testing / smoke testing     | haiku  | Navigate + check console — mechanical       |
| Fix lint/type errors             | sonnet | Needs understanding of code context         |
| Code review (single file)        | sonnet | Nuanced but bounded scope                   |
| Implement a feature in worktree  | sonnet | Judgment + code writing, bounded by spec    |
| Investigate a bug                | sonnet | Requires reasoning about code behavior      |
| Security audit                   | opus   | Critical findings require deep reasoning    |
| Architecture review              | opus   | Cross-system reasoning, trade-off analysis  |
| Full CTO review (orchestrator)   | opus   | Synthesizes across multiple domains         |
| Product spec / PRD generation    | opus   | Requires product thinking + technical depth |

## Per-Skill Recommendations

| Skill              | Orchestrator | Subagent Tasks                                   | Recommended Model |
| ------------------ | ------------ | ------------------------------------------------ | ----------------- |
| **parallel-dev**   | opus         | Feature implementation in worktree               | sonnet            |
| **parallel-dev**   | opus         | CI fix agent                                     | sonnet            |
| **cto**            | opus         | Explore agent (codebase discovery)               | haiku             |
| **cto**            | opus         | Security analyst (swarm)                         | sonnet            |
| **cto**            | opus         | Architecture/performance/quality analyst (swarm) | sonnet            |
| **deep-plan**      | opus         | Explore agent (scope identification)             | haiku             |
| **deep-research**  | opus         | Research track investigators                     | sonnet            |
| **fulltest-skill** | sonnet       | Page testers (navigate + check)                  | haiku             |
| **fulltest-skill** | sonnet       | CSS/JS fixers                                    | sonnet            |
| **qa-cycle**       | opus         | Discovery (Explore)                              | haiku             |
| **qa-cycle**       | opus         | Persona testers                                  | haiku             |
| **qa-cycle**       | opus         | Fix agents                                       | sonnet            |
| **qa-fix**         | sonnet       | Investigation + fix                              | sonnet            |
| **qa-verify**      | sonnet       | Verification testing                             | haiku             |
| **qa-sourcerank**  | opus         | Persona testers (currently sonnet — downgrade)   | haiku             |

## How to Apply

When spawning a subagent via the Agent tool, always include the `model` parameter:

```
Agent(subagent_type="general-purpose", model="haiku", prompt="...")
Agent(subagent_type="Explore", model="haiku", prompt="...")
Agent(subagent_type="general-purpose", model="sonnet", prompt="...")
```

When spawning teammates via Agent Teams, include model guidance in the spawn prompt:
"Use model: sonnet for this teammate" (Agent Teams inherits from parent by default).

## Rule of Thumb

**If the subagent only reads files and reports results → haiku.**
**If the subagent writes code or makes judgment calls → sonnet.**
**If the subagent makes architectural or security decisions → opus.**
