# Claude Managed Agents

**Discovered:** 2026-04-08
**Source:** research — https://x.com/claudeai/status/2041927687460024721 + https://platform.claude.com/docs/en/managed-agents/overview
**Use count:** 1
**Applied in:** research session — 2026-04-08 — HELPFUL

## What It Is

Anthropic launched the public beta of **Claude Managed Agents** on April 8, 2026 — a suite of composable APIs providing a pre-built, configurable agent harness running on managed cloud infrastructure. Available to all Claude API accounts by default.

Instead of building your own agent loop, tool execution, and sandbox, you get a fully managed environment where Claude can read files, run commands, browse the web, and execute code. Sessions are stateful, long-running, and persist through disconnections.

## Four Core Concepts

| Concept         | Description                                                             |
| --------------- | ----------------------------------------------------------------------- |
| **Agent**       | Model + system prompt + tools + MCP servers + skills                    |
| **Environment** | Configured cloud container (packages, network rules, mounted files)     |
| **Session**     | A running agent instance within an environment                          |
| **Events**      | SSE-streamed messages in/out (user turns, tool results, status updates) |

## Built-In Tools

- Bash (shell commands in the container)
- File ops: Read, Write, Edit, Glob, Grep
- Web search and fetch
- MCP servers (first-class, defined in Agent config)

## Technical Details

- Beta header required on all requests: `managed-agents-2026-04-01` (SDK sets automatically)
- Enabled by default for all Claude API accounts
- Sessions stream responses via Server-Sent Events (SSE)
- Built-in: prompt caching, context compaction, automatic error recovery
- Can steer or interrupt running sessions with additional events

## Research Preview Features (request access)

- **Outcomes** — self-evaluation and iteration toward defined outcomes
- **Multi-agent coordination** — agents monitor/coordinate with other Claude agents
- **Memory** — persistent agent memory across sessions

## Pricing

- Standard API token cost (same as Messages API)
- $0.08 per session-hour (active runtime, measured in ms)
- $10 per 1,000 web searches

## Rate Limits

- 60 create requests/min per org
- 600 read requests/min per org

## vs Messages API

|                    | Messages API                       | Claude Managed Agents             |
| ------------------ | ---------------------------------- | --------------------------------- |
| **What**           | Direct model prompting             | Pre-built harness + managed infra |
| **Best for**       | Custom loops, fine-grained control | Long-running tasks, async work    |
| **Infrastructure** | You build it                       | Anthropic provides it             |

## Performance

Internal testing: +10 points task success rate over standard prompting for structured file generation tasks. Customers report "10x faster to production."

## Early Adopters

Notion (Custom Agents in workspaces), Rakuten, Asana.

### Notion Integration Detail (2026-04-08)

Notion announced "Claude agents in Notion" — Anthropic runs the model and the **agent harness** (Managed Agents), while Notion acts as the **orchestration layer**: context, UI, and collaboration surface for teams. Key pattern: task board = Claude's to-do list. Waitlist: https://www.notion.com/partners/claude

This is a significant partnership signal: Notion frames itself not as an AI company but as the UX/context/orchestration layer sitting on top of Anthropic's managed infrastructure. This is the canonical Managed Agents integration pattern for SaaS products.

## Relevance to Claudia

- Could replace or augment the current Agent SDK CLI harness for session management
- MCP servers are native to Agent config — mcp-memory-pg could connect without custom wiring
- Multi-agent coordination research preview maps to `swarmy` persona use cases
- Pricing ($0.08/session-hour) needs comparison vs current infra cost (VPS + MLX)

## Relevance to Skills

- `/claude-api` skill needs updating to cover Managed Agents API surface alongside Messages API
- Branding rule: partners CANNOT use "Claude Code" or "Claude Cowork" in their products

## Docs

- Overview: https://platform.claude.com/docs/en/managed-agents/overview
- Blog: https://claude.com/blog/claude-managed-agents
- API ref: https://platform.claude.com/docs/en/api/beta/sessions
- Access form: https://claude.com/form/claude-managed-agents
