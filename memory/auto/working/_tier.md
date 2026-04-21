---
name: working-memory-tier
description: Live task state — the current thing being worked on. Ephemeral by design. Decays fast or gets promoted to episodic when the work completes.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
# Working Memory

**Purpose:** Hold live task state — in-progress plans, active tracker files, "where was I" context. Think of this as the desk you're currently working on, not the filing cabinet.

## What belongs here

- Live tracker state (JSON, YAML, Markdown) that skills read and mutate during execution
- `next-session-intent` pointers — what should happen on the next session wake
- In-progress plan notes that will be consumed or archived within days
- Handoff buffers (from `/handoff` skill) waiting to be resumed

## What does NOT belong here

- Stable preferences → `personal/`
- Completed project milestones → `episodic/`
- Distilled patterns/mistakes/tech-insights → `semantic/`

## Decay policy

- **Aggressive.** Files untouched for 14 days are candidates for archival.
- On completion of the underlying task, the file should be **promoted** to `episodic/` (with what-happened timeline) or **deleted** if it was pure scaffolding.
- `/memory-consolidation` sweeps this tier every run — stale live state is noise.

## Salience formula applied

Salience here is almost entirely driven by **recency**: `recency × pain × importance`. A working memory that's 3 days stale already scores low; at 14+ days it's archived regardless of importance.

## Migration from legacy structure

Pre-existing files to migrate into this tier as they're touched:
- `~/.claude-setup/memory/auto/.next-session-intent` → move to `working/next-session-intent.md`
- `~/.claude-setup/memory/auto/entities/buzz-triage-state.json` → move here on next update
- `~/.claude-setup/memory/auto/entities/swarmy-context-handoff.md` → move here on next update
- `~/.claude-setup/memory/auto/entities/claudia-heartbeat-tracker.md` → move here (live tracker)
