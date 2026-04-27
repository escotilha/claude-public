# Memory Strategy

## Tier Taxonomy (4 tiers, 2026-04-21)

Memories live in one of four cognitive tiers. Pick the tier based on role, not content type.

| Tier | Path | What goes here | Decay |
| --- | --- | --- | --- |
| **Working** | `auto/working/` | Live task state, handoff buffers, next-session intent, in-progress trackers | 14 days |
| **Episodic** | `auto/episodic/` | Project timeline — what happened, when, deploys, incidents | 60 days base |
| **Semantic** | `auto/semantic/` | Distilled patterns, mistakes, tech-insights, architecture decisions | 90 days (mistakes 180d, research 60d) |
| **Personal** | `auto/personal/` | User preferences, credentials, account state, explicit feedback | Never auto-decay |

See each tier's `_tier.md` for full rules. Legacy flat directories (`concepts/`, `entities/`, `feedback/`, `projects/`, `reference/`) remain until naturally touched — new memories write into the tiered structure.

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

Retention and promotion decisions use:

```
salience = recency × pain × importance  (each 0–1)
```

- **recency:** `max(0, 1 - days_since_last_use / tier_decay_threshold)`. `personal/` skips this (always 1.0).
- **pain:** 0.1 trivial → 1.0 prod-outage/data-loss. Dominates retention for mistakes and incidents.
- **importance:** 0.2 project-only → 1.0 user-declared rule. Dominates for personal/ entries.

**Thresholds:** ≥0.7 promote, 0.4–0.7 retain, 0.15–0.4 review, <0.15 archive. See `~/.claude-setup/skills/memory-consolidation/SKILL.md` Phase 2 for the pseudocode and Phase 4 for where it runs.

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

Use lowercase with hyphens. Include project name when project-specific.

## Page Format: Compiled Truth + Timeline

Every memory entity follows the **compiled truth + timeline** pattern (adapted from GBrain):

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

- Compiled truth gets **rewritten** (not appended) when the current understanding changes
- Timeline is **append-only** and reverse-chronological — the evidence trail never gets edited
- Compiled truth answers "what do we currently know?" — timeline answers "how did we get here?"
- When compiled truth and timeline contradict, flag the contradiction explicitly

## Required Observations (Timeline Entries)

Every entity's timeline must include entries with:

- `"Discovered: {date}"`
- `"Source: {type} — {detail}"` (see Source Types below)
- `"Applied in: {project} - {date} - {HELPFUL|NOT HELPFUL|MODIFIED}"`
- `"Use count: {N}"`

### Source Types

Use a typed `Source:` format to enable source-based filtering and pruning during consolidation:

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

During consolidation, source types enable targeted pruning:

- `research` sources decay faster (60 days) — market data goes stale
- `failure` sources are retained longer (180 days) — mistakes are expensive to relearn
- `user-feedback` sources never auto-decay — explicit user preferences are stable

## Dedup Before Write

Before creating any new memory file, check for duplicates using `mem-search`:

```bash
~/.claude-setup/tools/mem-search "<key terms from the memory>"
```

- If a high-relevance match exists → UPDATE the existing file instead of creating a new one
- If partial match (related but different) → consider merging into the existing file
- If no match → create new file as normal
- After writing → run `~/.claude-setup/tools/mem-search --reindex` to update the search index

## Cross-Link on Write

After writing a new memory file, update 3-5 **existing** memory files that the new information touches. This turns isolated memories into a connected knowledge graph at ingest time (Karpathy wiki pattern).

### Process

1. **Search for related memories** — run `mem-search` with 2-3 keyword queries from the new memory's content
2. **Select 3-5 most relevant** existing files, prioritizing:
   - Memories the new one **contradicts** (add contradiction note to both)
   - Memories the new one **extends** (add "Related:" back-reference)
   - Memories the new one **validates** (add confirmation note)
   - Memories in a different type that share the same domain
3. **Update each related file** — append a `Related:` line or update an existing one:
   ```
   Related: [new-memory-title](new-memory-file.md) — one-line why ({date})
   ```
4. **Update MEMORY.md** — if the related file's one-liner in the index should mention the new connection, update it
5. **Reindex** — run `~/.claude-setup/tools/mem-search --reindex` after all writes

### Budget

- Max 5 related files updated per new memory
- Max 2 `mem-search` calls per new memory
- Skip cross-linking if the new memory is trivial (score < 5) or a minor update to an existing file

### When to Skip Cross-Linking

- Simple observation additions to existing memories (e.g., "Applied in: project - date - HELPFUL")
- Updating a single field in an existing memory
- When the `mem-search` returns no results with score >= 3.0

## Save vs Skip

**Save when:** high generality, learned from failure, user explicitly shared, expensive to regenerate, high severity.
**Skip when:** duplicate exists (>85% similar), project-specific detail, trivial/obvious.

## Hybrid Retrieval (v1, 2026-04-21)

`mem-search` default mode fuses FTS5 BM25 with local vector recall via Reciprocal Rank Fusion (k=60, tunable via `MEM_RRF_K`). Embeddings: `sentence-transformers/all-MiniLM-L6-v2` (384-dim, local Python, no network). Each page chunks as one `truth` + one chunk per timeline bullet. Per-file mtime tracked in `vec_meta`; only changed files re-embed on nightly `mem-consolidate`. Escape hatches: `--fts` (FTS5 only), `--vec` (vector only), `MEM_HYBRID=0` (global FTS5 fallback), `mem-embed drop && mem-search --reindex --vectors-full` (after switching `MEM_MODEL`). Observability: `mem-search --vec-status`. A link-graph digest lives at `memory/auto/reports/GRAPH_REPORT.md` — read before `mem-search` for a bird's-eye view.
