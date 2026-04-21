---
name: episodic-memory-tier
description: What happened, when. Timeline of projects, deploys, incidents, decisions. Decays to semantic once the pattern distills, or archived once the project is dead.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
# Episodic Memory

**Purpose:** Preserve the *timeline* — what happened, when, and why. This is the work log. Episodic memory answers "what did we ship last quarter?" and "what was the incident on 2026-03-15?"

## What belongs here

- Project status notes (in-flight, completed, blocked)
- Deploy/incident logs with dates and outcomes
- Migration completion notes (`project_claudia_migration_complete`)
- Phase shipping records (`project_esocial_phase2_shipped`)
- Session-level decisions that had lasting consequences

## What does NOT belong here

- Live in-progress state → `working/`
- Reusable patterns extracted from these events → `semantic/`
- User preferences/credentials → `personal/`

## Decay policy

- **60 days** base decay threshold.
- Once a project is **resolved/shipped**, the entry's core insights should be distilled into `semantic/` (as patterns or mistakes), and the episodic entry can be archived.
- Dead/abandoned projects are archived after 60 days regardless of size.
- Long-running projects reset the decay clock on each update.

## Salience formula applied

`recency × pain × importance`
- **pain** is the dominant term here — high-pain incidents (outages, data loss, failed deploys) stay relevant long after the fact
- **recency** decays naturally as the timeline moves on
- **importance** is weighted by blast radius (prod vs staging, critical path vs periphery)

## Migration from legacy structure

- `~/.claude-setup/memory/auto/projects/` → most files fit here. Keep existing paths; new project memories go into `episodic/project_*.md`.
- Completed projects with distilled lessons → mark for semantic promotion during consolidation.
