---
name: Use Opus for coding logic — always
description: Explicit user preference (2026-04-21) — any subagent or session doing real coding logic must run on Opus, not Sonnet/Haiku
type: user
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
When the task involves writing, modifying, or reasoning about code (implementation, refactoring, debugging, test authoring), use Opus — not Sonnet or Haiku.

Applies to:
- Main session work (already defaults to Opus)
- Subagents spawned for implementation (override model="opus" in the Agent call)
- Any "logic-heavy" judgment: architecture, migration design, concurrency, data model
- Test authoring counts as coding logic

Does NOT apply to (Haiku/Sonnet still fine):
- File exploration, grep, glob, ls (Explore subagent)
- Pure formatting / template rendering
- Mechanical typecheck/lint runs
- Report-only subagents (they aren't "doing" the code)

**Why:** Pierre stated 2026-04-21 "use opus for all that is coding logic. always" during the Contably OS v3 Phase 1 build. Opus quality on judgment-heavy coding tasks is worth the cost multiplier — avoids the edit-revert-redo cycle that Sonnet triggers on anything non-trivial.

**How to apply:** When spawning agents for code work, add `model="opus"` explicitly. Do not silently accept the default Sonnet subagent model for coding tasks.

---

## Timeline

- **2026-04-21** — [user-feedback] Pierre said "use opus for all that is coding logic. always" during Contably OS v3 Phase 1 build session (Source: user-feedback — direct session instruction). Previously the model-tier-strategy rule already routed most coding to Opus but permitted Sonnet for "bounded" implementation — this memory raises the floor: always Opus for coding logic, no Sonnet coding exceptions.
