---
name: tech-insight:membase-evaluation
description: Membase.so evaluation — hosted personal memory layer for AI agents, MCP-native, knowledge graph with auto-extraction from Gmail/Slack/Calendar. Assessed for AgentWave integration and Claude setup memory replacement.
type: project
originSessionId: 143a71c8-513d-4e8b-a4ff-4d94861ba317
---

**Verdict: WATCH** — promising concept, too early for integration. Re-evaluate when API/webhook layer ships.

Membase (membase.so, by Aristo/Joshua Park) is a hosted personal memory layer for AI agents. It captures context from conversations + data sources (Gmail, Google Calendar, Slack, Notion, GitHub) into a knowledge graph, then serves that context to agents via MCP.

**MCP surface (confirmed):**

- Hosted MCP server at `https://mcp.membase.so/mcp`
- Tools: `add_memory` (store), `search_memory` (retrieve with semantic + date filtering), `get_current_date` (date resolution)
- Resources: `membase://profile` (user settings), `membase://recent` (top 10 latest memories)
- Auth: OAuth (browser-based, no API key)
- Install CLI: `npx -y membase@latest --client claude-code`
- npm package: `membase@0.1.4` (MIT, TypeScript, 7 commits, published 2026-04-07)

**Knowledge graph features:**

- Auto-extraction of entities/relations from conversations
- Deduplication, conflict resolution, relationship discovery
- Dashboard with graph + table views
- "Chat with Memory" — natural language query over your graph
- Data source sync: Gmail, Calendar, Slack (auto-import)

**AgentWave integration assessment (Score: 4/10, downgraded from initial 8/10):**

Blockers:

1. **No REST API or webhook** — only MCP. AgentWave would need an MCP client library to consume Membase, or Membase needs a REST API. AgentWave's current architecture uses direct Postgres + pgvector, not MCP consumption.
2. **No multi-tenant API** — each user gets their own MCP session via browser OAuth. No API key auth = no server-side integration where AgentWave creates/manages memories on behalf of users.
3. **No programmatic data ingestion** — memories come from agent conversations or connected apps. No bulk import API for AgentWave to push workspace data.
4. **Minimal MCP surface** — only 3 tools + 2 resources. Compare to AgentWave's 4-strategy RRF search (semantic, keyword, BM25, graph traversal) — Membase's `search_memory` is a single opaque call.
5. **Private beta, invitation-only** — no self-serve for AgentWave users.
6. **Very early** — 0.1.4, 7 npm commits, 17 GitHub stars on the decentralized repo.

What would change the verdict:

- REST API with API key auth (server-to-server)
- Webhook/SSE for real-time memory events (new entity, relation change)
- Multi-tenant support (workspace-level, not per-user browser OAuth)
- Bulk import/export API

**Claude setup memory replacement assessment (Score: 3/10):**

The current auto-memory pipeline (file-based, mem-search, MEMORY.md index) is more capable than Membase for Claude Code use:

- Full control over memory structure (compiled truth + timeline)
- No network dependency (local files)
- Custom ranking (boost weights, type-based scoring)
- Cross-linking and dedup at write time
- No invitation code needed

Membase's advantage is cross-platform context (Gmail, Slack, Calendar) — but Claude Code doesn't need that. The `/wiki` skill and GBrain integration already handle knowledge graph needs.

**Comparison with MemPalace (existing evaluation):**

- MemPalace: local, ChromaDB, 19 MCP tools, 96.6% R@5, per-agent diaries — better for Claudia Layer 6
- Membase: hosted, opaque graph, 3 MCP tools, cross-platform ingestion — better for consumer agent memory
- Different target markets. MemPalace wins for our infra.

**Note:** There are TWO "membase" projects — `unibaseio/membase-mcp` (blockchain/decentralized memory, Ethereum-style accounts, 17 stars) and `aristoapp/membase-cli` (the hosted product at membase.so). The tweet references the latter.

---

## Timeline

- **2026-04-14** — [research] Evaluated Membase for AgentWave integration + Claude setup memory. Downgraded from 8/10 to 4/10 after discovering no REST API, no multi-tenant auth, minimal MCP surface. (Source: research — x.com/JoshuaIPark/status/2043734397225157043, docs.membase.so, npmjs.com/membase)
