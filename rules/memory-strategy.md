# Memory Strategy

## Tier Taxonomy (4 tiers, 2026-04-21)

Memory live in four cognitive tier. Pick tier by role, not content type.

| Tier | Path | What goes here | Decay |
| --- | --- | --- | --- |
| **Working** | `auto/working/` | Live task state, handoff buffers, next-session intent, in-progress trackers | 14 days |
| **Episodic** | `auto/episodic/` | Project timeline — what happened, when, deploys, incidents | 60 days base |
| **Semantic** | `auto/semantic/` | Distilled patterns, mistakes, tech-insights, architecture decisions | 90 days (mistakes 180d, research 60d) |
| **Personal** | `auto/personal/` | User preferences, credentials, account state, explicit feedback | Never auto-decay |

See each tier `_tier.md` for full rule. Legacy flat dir (`concepts/`, `entities/`, `feedback/`, `projects/`, `reference/`) stay til touched — new memory write into tiered structure.

### Routing guidance

| Situation | Tier |
| --- | --- |
| User just said "always use pnpm" | `personal/` |
| Deploy finished — need to log the outcome | `episodic/` |
| Pattern extracted from a bug we've hit 3 times | `semantic/` |
| /handoff saving resume block | `working/` |
| Credentials / API keys reference | `personal/` |
| Agent identity spec (Marco, Bella, Julia) | `semantic/` (stable domain knowledge) |
| "where was I" snapshot | `working/` |
| Project completed — lessons distilled | write the lesson to `semantic/`, archive the project log in `episodic/` |

## Salience Formula

Retention + promotion use:

```
salience = recency × pain × importance  (each 0–1)
```

- **recency:** `max(0, 1 - days_since_last_use / tier_decay_threshold)`. `personal/` skip (always 1.0).
- **pain:** 0.1 trivial → 1.0 prod-outage/data-loss. Dominate retention for mistake + incident.
- **importance:** 0.2 project-only → 1.0 user-declared rule. Dominate for personal/ entry.

**Thresholds:** ≥0.7 promote, 0.4–0.7 retain, 0.15–0.4 review, <0.15 archive. See `~/.claude-setup/skills/memory-consolidation/SKILL.md` Phase 2 for pseudocode, Phase 4 for run site.

## Entity Naming: `{type}:{identifier}`

| Prefix             | Purpose                       |
| ------------------ | ----------------------------- |
| `pattern:`         | Reusable code/design patterns |
| `mistake:`         | Errors to avoid               |
| `tech-insight:`    | Technology-specific learnings |
| `preference:`      | User/project preferences      |
| `design-decision:` | Design choices made           |
| `test-pattern:`    | Reusable test sequences       |
| `common-bug:`      | Frequently found issues       |
| `architecture:`    | Architecture decisions        |

Lowercase + hyphens. Include project name when project-specific.

## Page Format: Compiled Truth + Timeline

Every memory entity follow **compiled truth + timeline** pattern (from GBrain):

```markdown
---
name: { entity-name }
description: { one-line — used for relevance scoring }
type: { user, feedback, project, reference }
---

{Compiled truth — your CURRENT BEST UNDERSTANDING of this entity.
Rewrite this section when evidence changes. This is NOT append-only.
Keep it concise: 3-10 lines covering the actionable state.}

---

## Timeline

- **{YYYY-MM-DD}** — [{source-type}] {what happened} (Source: {detail})
- **{YYYY-MM-DD}** — [{source-type}] {what happened} (Source: {detail})
```

**Key rules:**

- Compiled truth get **rewritten** (not appended) when current understanding change
- Timeline **append-only** + reverse-chronological — evidence trail never edited
- Compiled truth answer "what we currently know?" — timeline answer "how we got here?"
- When compiled truth + timeline contradict, flag contradiction explicit

## Required Observations (Timeline Entries)

Every entity timeline must have entry with:

- `"Discovered: {date}"`
- `"Source: {type} — {detail}"` (see Source Types below)
- `"Applied in: {project} - {date} - {HELPFUL|NOT HELPFUL|MODIFIED}"`
- `"Use count: {N}"`

### Source Types

Typed `Source:` format enable source-based filter + prune during consolidation:

| Type             | Format                                        | Example                                                    |
| ---------------- | --------------------------------------------- | ---------------------------------------------------------- |
| `implementation` | `Source: implementation — {file or feature}`  | `Source: implementation — src/auth/jwt.ts`                 |
| `failure`        | `Source: failure — {what went wrong}`         | `Source: failure — forgot RLS on profiles table`           |
| `user-feedback`  | `Source: user-feedback — {context}`           | `Source: user-feedback — always use pnpm`                  |
| `research`       | `Source: research — {url or paper}`           | `Source: research — github.com/kbanc85/claudia`            |
| `code-review`    | `Source: code-review — {PR or session}`       | `Source: code-review — PR #42 security findings`           |
| `git-history`    | `Source: git-history — {repo}`                | `Source: git-history — contably commit patterns`           |
| `session`        | `Source: session — {skill or context}`        | `Source: session — /ship feature auth`                     |
| `consolidation`  | `Source: consolidation — merged from {names}` | `Source: consolidation — merged from pattern:a, pattern:b` |

During consolidation, source type enable targeted prune:

- `research` source decay faster (60 days) — market data go stale
- `failure` source kept longer (180 days) — mistake expensive to relearn
- `user-feedback` source never auto-decay — explicit user preference stable

## Dedup Before Write

Before make new memory file, check duplicate with `mem-search`:

```bash
~/.claude-setup/tools/mem-search "<key terms from the memory>"
```

- High-relevance match exist → UPDATE existing file, no make new
- Partial match (related but different) → consider merge into existing
- No match → make new file
- After write → run `~/.claude-setup/tools/mem-search --reindex` to update search index

## Cross-Link on Write

After write new memory file, update 3-5 **existing** memory file the new info touch. Turn isolated memory into connected knowledge graph at ingest time (Karpathy wiki pattern).

### Process

1. **Search related memory** — run `mem-search` with 2-3 keyword query from new memory content
2. **Pick 3-5 most relevant** existing file, prioritize:
   - Memory the new one **contradict** (add contradiction note to both)
   - Memory the new one **extends** (add "Related:" back-ref)
   - Memory the new one **validates** (add confirmation note)
   - Memory in different type sharing same domain
3. **Update each related file** — append `Related:` line or update existing:
   ```
   Related: [new-memory-title](new-memory-file.md) — one-line why ({date})
   ```
4. **Update MEMORY.md** — if related file one-liner in index should mention new connection, update it
5. **Reindex** — run `~/.claude-setup/tools/mem-search --reindex` after all write

### Budget

- Max 5 related file updated per new memory
- Max 2 `mem-search` call per new memory
- Skip cross-link if new memory trivial (score < 5) or minor update to existing

### When to Skip Cross-Linking

- Simple observation add to existing memory (e.g., "Applied in: project - date - HELPFUL")
- Update single field in existing memory
- When `mem-search` return no result with score >= 3.0

## Save vs Skip

**Save when:** high generality, learned from failure, user explicit shared, expensive to regenerate, high severity.
**Skip when:** duplicate exist (>85% similar), project-specific detail, trivial/obvious.

## Hybrid Retrieval (v1, 2026-04-21)

`mem-search` default mode fuse FTS5 BM25 with local vector recall via Reciprocal Rank Fusion (k=60, tunable via `MEM_RRF_K`). Embeddings: `sentence-transformers/all-MiniLM-L6-v2` (384-dim, local Python, no network). Each page chunk as one `truth` + one chunk per timeline bullet. Per-file mtime tracked in `vec_meta`; only changed file re-embed on nightly `mem-consolidate`. Escape hatch: `--fts` (FTS5 only), `--vec` (vector only), `MEM_HYBRID=0` (global FTS5 fallback), `mem-embed drop && mem-search --reindex --vectors-full` (after switch `MEM_MODEL`). Observability: `mem-search --vec-status`. Link-graph digest live at `memory/auto/reports/GRAPH_REPORT.md` — read before `mem-search` for bird's-eye view.