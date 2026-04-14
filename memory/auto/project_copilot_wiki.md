---
name: project_copilot_wiki
description: Copilot Knowledge Wiki — Karpathy LLM Wiki pattern applied to Contably co-pilot, fed by GitHub events
type: project
originSessionId: 6ea5db7f-79e0-4d73-b797-b82e975141f0
---

Contably's Copiloto now has a 4th knowledge layer: a persistent, LLM-maintained wiki stored in PostgreSQL that auto-updates from GitHub push/PR/release events. Inspired by Karpathy's LLM Wiki pattern (gist 442a6bf555914893e9891c11519de94f).

**Architecture:** GitHub webhook → Celery worker → Claude Haiku (tool_use) → DB wiki pages → co-pilot searches via `search_copilot_wiki` tool at query time ($0/query, SQL only).

**Why:** The co-pilot's knowledge was frozen in `prompts.py`. Every new feature (eSocial, NF-e live feed, Pluggy) required manual prompt updates. The wiki automates this — new features flow in via GitHub events.

**Key files:**

- Models: `apps/api/src/models/copilot_wiki.py` (3 tables: sources, pages, log)
- Migration: `alembic/versions/..._053_copilot_wiki_tables.py`
- Webhook: `apps/api/src/api/routes/webhooks/github_wiki.py`
- Ingest task: `apps/api/src/workflows/tasks/wiki_tasks.py`
- Seed script: `apps/api/src/scripts/seed_copilot_wiki.py` (8 initial pages)
- Plan doc: `docs/copilot-wiki-plan.md`
- Tool: `search_copilot_wiki` in `tools.py` + `GLOBAL_TOOL_DEFINITIONS`

**CTO review fixes incorporated:** composite idempotency_key (not unique SHA), FULLTEXT index, sync Anthropic client in Celery, 20K diff limit, tool_use for structured output, 1MB payload limit, wiki tool always available (not gated on company_id).

**Cost:** ~$0.006/event (Haiku), $0/query, ~$1-5/month.

**How to apply:** When adding new co-pilot tools or features, they will be auto-documented in the wiki via GitHub events. No manual prompt updates needed for product knowledge.

---

## Timeline

- **2026-04-13** — [implementation] Built and deployed to main (commits 1de73b82a, 47b29703e). CTO reviewed and approved with changes — all critical fixes applied. (Source: implementation — apps/api/src/ai_assistant/, apps/api/src/workflows/tasks/wiki_tasks.py)
