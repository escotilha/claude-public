# Memory Index

## Tier Taxonomy (4 named tiers, 2026-04-21)

Memories are organized into four cognitive tiers. New memories write into the tier that matches their role; legacy flat directories (`concepts/`, `entities/`, `feedback/`, `projects/`, `reference/`) remain until naturally touched and promoted.

| Tier | Path | Role | Decay |
| --- | --- | --- | --- |
| Working | `working/` | Live task state, handoff buffers, next-session intent | Fast (14d) |
| Episodic | `episodic/` | Project timeline — what happened, when | 60d base |
| Semantic | `semantic/` | Distilled patterns, mistakes, tech-insights | 90d base (mistakes 180d, research 60d) |
| Personal | `personal/` | User preferences, credentials, account state | Never auto-decay |

See each tier's `_tier.md` for salience rules, migration notes, and promotion gates. Salience formula: `recency × pain × importance` — dominant term differs per tier.

## References

- [research-finding-karpathy-coding-guidelines.md](research-finding-karpathy-coding-guidelines.md) — CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering, orthogonal edits, and vague success criteria

# currentDate
Today's date is 2026-04-21.
