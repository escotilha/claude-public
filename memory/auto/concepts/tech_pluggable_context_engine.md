---
name: tech-insight:pluggable-context-engine
description: Pluggable context injection strategy for swarm skills — context manifest YAML in frontmatter, parallel gather, role-based slicing — saves 65-80% discovery tokens
type: feedback
originSessionId: fb76aea6-2be5-4092-80da-2df889604d67
---

Swarm-spawning skills (cto, ship, parallel-dev, deep-plan) should use a **context manifest** pattern to avoid redundant codebase discovery across subagents.

**Pattern:** Orchestrator gathers context once (parallel commands), then injects role-specific slices into each spawn prompt via a `## Pre-computed Context` header block.

**Format:** `context-manifest` YAML block in skill frontmatter with `gather` (named commands) and `roles` (which gathered items each role receives).

**Token savings:** ~65-80% reduction in discovery tokens for 4-agent swarms (12K-20K → 2.7K-3.9K tokens).

**Why:** Inspired by Hermes Agent v0.9.0's pluggable context engine system. Each subagent currently re-discovers stack, directory tree, schema independently — pure waste when the orchestrator already has it.

**How to apply:**

1. parallel-dev — already 80% there (buildProjectContext in Phase 2.5), formalize with manifest + role slicing
2. cto — replace {auth_files}/{src_dirs} placeholders with concrete gather step, use manifest as spec
3. ship — wire Phase 0 state.json output into Phase 4 spawn prompts as Pre-computed Context block
4. deep-plan — add gather step before Explore agent (new behavior, small change)

**Key design decisions:**

- `gather` items use cmd (shell) or glob (file list) — run in parallel before any spawn
- `roles` map to subagent role names — unknown roles get full context (safe default)
- parallel-dev uses dynamic roles (backend/frontend/api/database) based on feature type
- No new tools needed — works with existing Agent()/Task tools
- Opt-in: skills without context-manifest behave unchanged

---

## Timeline

- **2026-04-13** — [research] Designed from Hermes v0.9.0 pluggable context engine inspiration (Source: research — NousResearch/hermes-agent v0.9.0)
- **2026-04-13** — [implementation] Design doc complete, ready for skill file integration
