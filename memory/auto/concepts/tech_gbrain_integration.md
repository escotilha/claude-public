---
name: tech_gbrain_integration
description: GBrain world-knowledge brain integrated into Claudia as Source 5 — separate Postgres DB, 30 MCP tools, compiled truth + timeline pattern
type: project
originSessionId: 9a9e5be7-5727-42a4-87b4-ce88e7457231
---

GBrain (garrytan/gbrain, current v0.12+) installed as Claudia's world-knowledge layer. Stores people, companies, concepts, meetings as pages with compiled truth + append-only timelines. Separate `gbrain` database on the same Postgres instance (127.0.0.1:5432), uses OpenAI text-embedding-3-large (1536-dim) — different from mcp-memory-pg which uses Ollama nomic-embed-text (768-dim). v0.11 adds **Minions**: a BullMQ-backed durable job queue. v0.12 adds **self-wiring knowledge graph**: every `put_page` call auto-extracts entity references and creates typed links (`attended`, `works_at`, `invested_in`, `founded`, `advises`) with zero LLM calls. New `gbrain graph-query` command for typed-edge traversal. Backlink-boosted hybrid search. Auto-link reconciliation on every edit. BrainBench v1 benchmarks (PR #188, 240-page corpus, Claude Opus, PGLite): Precision@5 +5.4pts (39→44.7%), Recall@5 +11.5pts (83→94.6%), Graph-only F1 +28.8pts (57.8→86.6%). "Who works at Acme?" precision: 21%→94% (graph traversal vs full-corpus grep).

**Why:** Fills the long-term factual memory gap. mcp-memory-pg handles operational state (preferences, decisions). GBrain handles world knowledge (people Pierre knows, companies, deals, concepts). The brain-agent loop makes Claudia compound knowledge across sessions. Minions adds durable compute — jobs survive crashes, auto-retry on failure.

**How to apply:** GBrain context auto-injects into all 10 agents via Source 5 in memory context builder. Direct Postgres queries (no MCP protocol overhead). Install on VPS via `scripts/install-gbrain.sh`. Manage via `/gbrain` Claude Code skill (also deployed to Mary at `/opt/mary/skills/gbrain/SKILL.md`). For any work likely to timeout (>5min) or needing retry — use `gbrain minions enqueue` instead of fire-and-forget Task/subagent. See AgentWave plan.md "Addendum: Minions" for BullMQ-over-Postgres integration pattern. **v0.12 upgrade priority:** replace grep-style queries with `gbrain graph-query` for relationship lookups (works_at, invested_in, etc.) — 73pt precision gain for org lookups.

---

## Timeline

- **2026-04-18** — [research] GBrain v0.12 self-wiring knowledge graph released. Key changes: `put_page` auto-extracts typed links (zero LLM calls), new `gbrain graph-query` typed-edge traversal, backlink-boosted hybrid search, auto-link reconciliation on edit. BrainBench v1: Recall@5 83→94.6% (+11.5pts), Graph F1 57.8→86.6% (+28.8pts), works_at precision 21→94% (+73pts). Upgrade: replace grep-style queries with graph-query for relationship lookups. (Source: research — x.com/garrytan/status/2045447413050363927)
- **2026-04-18** — [implementation] GBrain v0.11 Minions pattern documented across the stack: added Minions section to /gbrain SKILL.md, added durable-queue mode to /parallel-dev Phase 3 and /qa-cycle orchestration, added Phase 4 addendum to AgentWave plan.md (BullMQ-over-Postgres, Steps 40–46, ~1 week, priority position 2), and deployed Mary's new /opt/mary/skills/gbrain/SKILL.md with combined brain + Minions interface. (Source: research — x.com/garrytan/status/2045427057656729985)
- **2026-04-15** — [implementation] Adopted GBrain skillpacks into Claude Code: added signal-detector, brain-ops, and conventions as always-on sections in /gbrain SKILL.md. Upgraded /meditate Phase 6 with MECE validation from GBrain skill-creator pattern. (Source: research — x.com/garrytan skillpacks tweet)
- **2026-04-10** — [implementation] Integrated GBrain into Claudia: gbrain-pool.ts, gbrain-client.ts, context.ts Source 5, BRAIN.md shared prompt, types.ts + registry.ts + system-prompt.ts + index.ts updates (Source: session — /research garrytan/gbrain)
- **2026-04-10** — [implementation] Created /gbrain Claude Code skill at ~/.claude-setup/skills/gbrain/SKILL.md (Source: session)
- **2026-04-10** — [implementation] Created install script at scripts/install-gbrain.sh for VPS deployment (Source: session)
- **2026-04-10** — [research] GBrain discovered via Garry Tan tweet — Postgres-native personal knowledge brain with hybrid RAG search, 30 MCP tools (Source: research — github.com/garrytan/gbrain)
