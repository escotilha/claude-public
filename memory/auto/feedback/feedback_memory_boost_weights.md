---
name: Memory Search Boost Weights
description: Boost weights for memory search ranking — feedback 3x, user 2x, reference 1.5x, project 1x, with 1.5x recency for last 7 days
type: feedback
---

Memory search results are ranked with type-based boost weights:

- **feedback** memories: 3.0x boost (user corrections are the most valuable — they prevent repeating mistakes)
- **user** memories: 2.0x boost (user profile and preferences inform every interaction)
- **reference** memories: 1.5x boost (pointers to external resources, stable over time)
- **project** memories: 1.0x base (project context changes frequently, recency matters more than type)

Recency boost: memories modified in the last 7 days get an additional 1.5x multiplier.

**Why:** Nox memory system (Toto Busnello's OpenClaw) demonstrated that 2x boost for curated files significantly improved search relevance. Our type system is richer, so we use a graduated scale.

**How to apply:** The `mem-search` CLI tool at `~/.claude-setup/tools/mem-search` applies these weights automatically in the FTS5 query. No manual intervention needed.
