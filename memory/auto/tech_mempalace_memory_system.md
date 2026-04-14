---
name: tech-insight:mempalace-memory-system
description: MemPalace — free local AI memory system, ChromaDB + MCP server, palace hierarchy, 96.6% R@5 LongMemEval, per-agent diaries, temporal KG
type: tech
originSessionId: f190a821-92df-48a8-b2e2-9fcc886dbb6f
---

## MemPalace

**Source:** https://github.com/milla-jovovich/mempalace
**Stars:** 39,540 | **License:** MIT | **Language:** Python 3.9+

Free local AI memory system. Stores conversations, code, and decisions in ChromaDB using a hierarchical "palace" metaphor, retrievable via semantic search or 19 MCP tools. No cloud dependency, no API calls for search.

## Architecture

### Palace Hierarchy

```
Wing (project/agent)
  └─ Room (topic: auth, billing, deploy)
       └─ Hall (memory type)
       │    hall_facts         — decisions made
       │    hall_events        — sessions and milestones
       │    hall_discoveries   — breakthroughs
       │    hall_preferences   — habits and opinions
       │    hall_advice        — recommendations
       ├─ Drawer (verbatim content unit)
       └─ Tunnel (cross-wing connection for shared rooms)
```

### Storage

- **Vector:** ChromaDB PersistentClient (singleton cache)
- **Knowledge graph:** SQLite, temporal entity relationships (`valid_from`, `as_of`)
- **Audit:** Write-ahead log at `~/.mempalace/wal/write_log.jsonl`

## Performance

| Mode          | R@5 LongMemEval | Notes                   |
| ------------- | --------------- | ----------------------- |
| Raw verbatim  | **96.6%**       | Default, recommended    |
| AAAK compress | 84.2%           | Experimental, regresses |

Always use raw mode. AAAK compression only helps at scale with many repeated entities — not worth the accuracy loss.

Compare: ASMR pipeline ~99% (but requires LLM inference at retrieval time), MemPalace 96.6% (zero inference, fully local).

## Install & MCP Setup

```bash
pip install mempalace

# MCP server (exposes 19 tools)
claude mcp add mempalace -- python -m mempalace.mcp_server --palace ~/.mempalace/palace

# Mine existing files
mempalace init ~/.mempalace/palace
mempalace mine ~/.claude-setup/memory/ --mode general
mempalace mine ~/chats/ --mode convos

# Context injection for local models (~170 tokens)
mempalace wake-up > context.txt
```

## 19 MCP Tools (Key Ones)

| Tool                        | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `mempalace_search`          | Semantic search, optional wing/room filters     |
| `mempalace_check_duplicate` | Dedup before write (threshold 0-1, default 0.9) |
| `mempalace_add_drawer`      | File verbatim content (idempotent IDs)          |
| `mempalace_diary_write`     | Per-agent episodic diary in AAAK format         |
| `mempalace_diary_read`      | Retrieve agent's recent diary entries           |
| `mempalace_kg_add`          | Add temporal fact (subject→predicate→object)    |
| `mempalace_kg_query`        | Query entity relationships with `as_of` filter  |
| `mempalace_traverse`        | Walk connected ideas from a starting room       |
| `mempalace_find_tunnels`    | Find rooms bridging two wings                   |

## Relevance to This Setup

### Claudia (9/10)

- **Per-agent wings:** Map Claudia's 9 personas (claudia, marco, buzz, rex, etc.) to palace wings. Each agent gets isolated episodic memory without namespace pollution.
- **Agent diaries:** `mempalace_diary_write(agent_name, entry, topic)` is a perfect episodic layer for Claudia — currently missing from `mcp-memory-pg`.
- **Tier 2/3 context injection:** `mempalace wake-up` (~170 tokens) injects critical facts into Qwen/Nemotron system prompts at negligible cost.
- **Tunnel mechanism:** Handles cases where multiple agents work on the same topic (marco + swarmy on the same deal → shared room via tunnel).

### Claude Setup Memory (8/10)

- **Semantic dedup:** `mempalace_check_duplicate` improves on keyword-based `mem-search` for near-duplicate detection.
- **Mine existing corpus:** `mempalace mine ~/.claude-setup/memory/` ingests all 40+ existing markdown memories.
- **Dual-write from /meditate:** At session end, file observations via `mempalace_add_drawer` alongside existing `mcp__memory__create_entities`.
- **Hall mapping:** Existing entity types map naturally — `preference:` → `hall_preferences`, `pattern:` → `hall_discoveries`, `design-decision:` → `hall_facts`.

## Cost

- Search: **$0** (local ChromaDB, zero API calls)
- Context injection: **~170 tokens/year** (wake-up approach)
- vs LLM summaries: ~$507/year
- vs mcp-memory-pg: complementary (different strength — episodic + per-agent isolation vs operational KG)

## Discovered: 2026-04-09

## Use count: 1

## Applied in: claudia - 2026-04-09 - PENDING

Related: [tech_asmr_memory_retrieval.md](tech_asmr_memory_retrieval.md) — competing/complementary memory benchmark, ASMR 99% vs MemPalace 96.6% (2026-04-09)
Related: [project_claudia_memory_v2.md](project_claudia_memory_v2.md) — Claudia 5-layer memory system that MemPalace could extend as Layer 6 per-agent episodic (2026-04-09)
Related: [tech_membase_evaluation.md](tech_membase_evaluation.md) — Competing hosted alternative. MemPalace wins on tools (19 vs 3), local cost ($0 vs hosted), per-agent isolation, benchmark quality. Membase wins on cross-platform ingestion (Gmail/Slack/Calendar). Different target markets. (2026-04-14)
