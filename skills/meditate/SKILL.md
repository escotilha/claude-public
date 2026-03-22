---
name: meditate
description: "End-of-session judgment extraction. Structured capture of learnings, patterns, and mistakes after completing /ship, /cto, /parallel-dev, /deep-plan, or any substantial session. Feeds the memory pipeline with high-quality, pre-scored observations. Triggers on: meditate, reflect on session, extract learnings, /meditate."
user-invocable: true
context: fork
model: haiku
effort: low
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Agent
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - mcp__memory__search_nodes
  - mcp__memory__create_entities
  - mcp__memory__create_relations
  - mcp__memory__add_observations
memory: user
tool-annotations:
  mcp__memory__create_entities: { readOnlyHint: false, idempotentHint: false }
  mcp__memory__add_observations: { readOnlyHint: false, idempotentHint: false }
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: false
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
    outputFormat: structured
---

# Meditate Skill

End-of-session judgment extraction. Runs after completing substantial work (`/ship`, `/cto`, `/parallel-dev`, `/deep-plan`, or any long session) to capture learnings before context is lost.

This is the **intake step** for the memory pipeline. `/consolidate` is the **maintenance step**. Together they form the full memory lifecycle: meditate captures, consolidate prunes and promotes.

## When to Run

- After completing a `/ship` cycle
- After a `/cto` review (especially swarm mode)
- After `/parallel-dev` finishes all features
- After `/deep-plan` implementation
- After any session >30 minutes with meaningful code changes
- When the user says `/meditate` or "reflect on session"

## Phase 1: Gather Session Context via Parallel Observers

> **ASMR Observer Pattern:** Instead of a single agent scanning all sources sequentially, spawn 2-3 parallel Observer agents that each read a subset of session context and extract structured facts across specialized vectors. Based on Supermemory's ASMR ingestion architecture (3 parallel Observers). This catches cross-cutting patterns that sequential scanning misses.

**Step 1: Pre-read shared context** (orchestrator does this once, passes to all observers):

```bash
# Quick context snapshot — shared with all observers
git log --oneline -20 2>/dev/null
git diff --stat HEAD~10..HEAD 2>/dev/null
ls .ship/state.json .deep-plan/plan.md .parallel-dev/features.json .cto/last-review.md 2>/dev/null
```

**Step 2: Spawn 2-3 Observer agents** (model: haiku) in parallel via Task tool with `run_in_background: true`:

```
Observer "code-observer" (haiku):
  Context: {git log, git diff stat, state files from Step 1}
  Read the git log and changed files to extract:

  EXTRACTION VECTORS:
  1. Technical Patterns — reusable code patterns, framework idioms, API patterns
  2. Mistakes & Fixes — things that broke, what caused them, how they were fixed
  3. Architecture Decisions — structural choices made and their rationale

  For each finding, output: {type, summary, specifics, severity, generalizability}
  Be specific: "Supabase RLS policies need anon key, not service key" not "Supabase is tricky"
  Include the fix for every mistake. Include the trigger for every pattern.
  Max 3 findings. Quality over quantity.

Observer "preference-observer" (haiku):
  Context: {auto-memory entries from today, conversation history summary}
  Read today's auto-memory entries (~/.claude-setup/memory/auto/*.md modified today)
  and any state files for user preference signals:

  EXTRACTION VECTORS:
  1. User Preferences — explicit statements ("always do X", "don't use Y")
  2. Workflow Patterns — how the user likes to work, tool preferences, style choices
  3. Temporal Updates — facts that CONTRADICT or UPDATE previous knowledge

  For each finding, output: {type, summary, specifics, confidence, source}
  Pay special attention to corrections and contradictions — these are high-value.
  Max 2 findings. Only save if the user explicitly stated or strongly implied it.

Observer "impact-observer" (haiku):  # Only spawn if session was >30 min or had failures
  Context: {git log, state files}
  Analyze the session for cross-cutting IMPACT:

  EXTRACTION VECTORS:
  1. Cross-Project Applicability — would this insight help in other projects?
  2. Failure Severity — could ignoring this cause production issues?
  3. Knowledge Gaps — what did we NOT know that we should have?

  For each finding, output: {type, summary, applicability[], severity, gap_description}
  Max 2 findings. Only high-generalizability insights.
```

**Step 3: Merge Observer outputs**

After all observers complete, merge their findings into a unified candidate list:

```
1. Collect all findings from all observers
2. Deduplicate: if two observers found the same insight, keep the more specific one
3. Cap at 5 total candidates (quality over quantity)
4. Each candidate maps to an entity type:
```

| Finding Type          | Maps To                |
| --------------------- | ---------------------- |
| Technical Pattern     | `pattern:` entity      |
| Mistake & Fix         | `mistake:` entity      |
| Architecture Decision | `architecture:` entity |
| User Preference       | `preference:` entity   |
| Technology Learning   | `tech-insight:` entity |

### Extraction Rules

- **Be specific.** "Supabase RLS policies need to be tested with anon key, not service key" is good. "Supabase is tricky" is useless.
- **Include the fix.** Every `mistake:` should include what the correct approach is.
- **Include the trigger.** Every `pattern:` should include when to apply it.
- **Max 5 entities per session.** If you find more, keep only the 5 most generalizable. Quality over quantity.

### Fallback: Single-Agent Mode

If the session was short (<15 min) or produced minimal changes (<3 commits), skip the parallel observers and extract directly using the 5-question method:

| #   | Question                                  | Maps To                |
| --- | ----------------------------------------- | ---------------------- |
| 1   | Did something break that shouldn't have?  | `mistake:` entity      |
| 2   | Did I discover a reusable pattern?        | `pattern:` entity      |
| 3   | Did I learn something about a technology? | `tech-insight:` entity |
| 4   | Did the user express a preference?        | `preference:` entity   |
| 5   | Was an architecture decision made?        | `architecture:` entity |

## Phase 3: Score and Filter

For each candidate, calculate a quick relevance score using the criteria from memory-consolidation:

| Factor                       | Points    | Check                                        |
| ---------------------------- | --------- | -------------------------------------------- |
| Applies to multiple projects | +2 to +3  | Would this help in Contably AND SourceRank?  |
| Learned from failure         | +2        | Did something break?                         |
| User explicitly stated       | +3        | Did the user say "always do X"?              |
| High severity                | +3 to +5  | Could ignoring this cause production issues? |
| Common scenario              | +2        | Will this come up again within a week?       |
| Similar memory exists        | -2        | Check Memory MCP first                       |
| Duplicate (>85%)             | -Infinity | Skip entirely                                |

**Threshold: 5.** Only save entities scoring >= 5.

## Phase 4: Save to Memory MCP

### Deduplicate via mem-search

Before creating any new entity, check for existing similar memories using FTS5 search:

```bash
~/.claude-setup/tools/mem-search "<entity-type> <key-learning-keywords>"
```

- If a result comes back with **score >= 5.0** and covers the same insight, **do not create a new entity**. Instead, add observations to the existing memory via `mcp__memory__add_observations` (e.g., "Applied in: {project} - {date} - HELPFUL", updated use count).
- If a result comes back with **score >= 3.0** but is only partially overlapping, create the new entity and add a `supersedes` or `related_to` relation to the existing one.
- If no relevant results, proceed with creation as normal.

This prevents the memory graph from accumulating near-duplicate entries across sessions.

### Create new entities

For each entity that passes the filter:

```javascript
await mcp__memory__create_entities({
  entities: [
    {
      name: "{type}:{kebab-case-identifier}",
      entityType: "{type}", // pattern, mistake, tech-insight, preference, architecture
      observations: [
        "{the actual learning — specific, actionable, includes context}",
        "Discovered: {today's date}",
        "Source: session — {skill or context that triggered this}",
        "Relevance score: {calculated score}",
        "Use count: 0",
      ],
    },
  ],
});
```

### Create Relations

If the new entity relates to existing memories, create relations:

```javascript
// Check for related existing memories
const related = await mcp__memory__search_nodes({
  query: "{relevant keyword}",
});

// If found, create relation
await mcp__memory__create_relations({
  relations: [
    {
      from: "{new-entity-name}",
      relationType: "related_to", // or derived_from, applies_to, supersedes
      to: "{existing-entity-name}",
    },
  ],
});
```

### Update Existing Memories

If a session **confirms** an existing memory works, update it:

```javascript
await mcp__memory__add_observations({
  observations: [
    {
      entityName: "{existing-entity-name}",
      contents: ["Applied in: {project} - {today's date} - HELPFUL"],
    },
  ],
});
```

### Reindex search index

After all memory writes (creates, updates, new observations) are complete, rebuild the FTS5 index so subsequent searches reflect the new entries:

```bash
~/.claude-setup/tools/mem-search --reindex
```

This is a fast operation (~1s) and ensures `/meditate`, `/consolidate`, and any other skill using `mem-search` will find the freshly written memories.

## Phase 5: Report

Output a concise summary:

```markdown
## Meditation Report

**Session:** {what was done}
**Duration context:** {skill used or manual work}

### Captured ({N} entities)

| Entity      | Type    | Score | Summary |
| ----------- | ------- | ----- | ------- |
| pattern:xyz | pattern | 7     | ...     |
| mistake:abc | mistake | 6     | ...     |

### Updated ({N} existing)

| Entity                    | Update                         |
| ------------------------- | ------------------------------ |
| tech-insight:supabase-rls | Applied in: Contably - HELPFUL |

### Skipped ({N} below threshold)

| Candidate | Score | Reason               |
| --------- | ----- | -------------------- |
| ...       | 3     | Too project-specific |

---

Next consolidation: run `/consolidate` when memory count > 200 or weekly.
```

## Integration with Other Skills

### Auto-trigger after /ship

The `/ship` skill can call `/meditate` at the end of its cycle. Add to ship's post-implementation phase:

```
After QA passes and code is committed, run /meditate to capture learnings.
```

### Auto-trigger after /cto swarm

The `/cto` swarm mode generates cross-concern findings. After the final report, `/meditate` captures the most generalizable insights.

### Standalone use

The user can run `/meditate` at any time to reflect on recent work. The skill adapts to whatever context is available (git log, state files, or just the conversation history).
