---
name: semantic-memory-tier
description: Distilled patterns, mistakes, tech insights — the generalizable lessons that transcend a specific project. The filing cabinet of hard-won knowledge.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
# Semantic Memory

**Purpose:** Hold the **distilled, generalizable** knowledge — patterns, mistakes, tech insights, architecture decisions — that should apply across projects. This is what separates a junior from a senior engineer: the library of "things I've learned."

## What belongs here

- `pattern_*` — reusable design/code patterns
- `mistake_*` — errors to avoid (expensive to relearn)
- `tech_*` / `tech-insight:*` — technology-specific learnings (SDKs, frameworks, platforms)
- `architecture_*` — architectural decisions with rationale
- `research-finding-*` — analyzed external sources with implications extracted

## What does NOT belong here

- Active project state → `working/` or `episodic/`
- User-specific rules or credentials → `personal/`
- Raw incident logs (before distillation) → `episodic/`

## Decay policy

- **90 days** base decay threshold, with overrides:
  - `failure` / `mistake` sources: **180 days** (expensive to relearn)
  - `research` sources: **60 days** (market data goes stale)
  - Anything used 5+ times: **multiplier up to 2x** (proven utility)
- Critical memories (marked `critical: true`) never auto-decay.

## Salience formula applied

`recency × pain × importance`
- **pain** drives retention for `mistake_*` entries — the cost of relearning is the retention signal
- **importance** drives retention for `pattern_*` and `tech_*` — generalizability = importance
- **recency** matters less here; a 6-month-old pattern on a still-relevant framework is still valuable

## Migration from legacy structure

- `~/.claude-setup/memory/auto/concepts/` → directly maps here. Existing files stay; new semantic memories write into `semantic/`.
- `~/.claude-setup/memory/auto/entities/*-spec.md`, `*-kb.md`, `*-rules.md` (agent knowledge specs) → promote to semantic when they generalize.

## Promotion gate

Promoted from `episodic/` when:
- The lesson applies to ≥2 projects, OR
- Use count ≥3 and effectiveness ≥70%, OR
- Manual user-flagged as "save this pattern"
