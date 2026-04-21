---
name: tech-insight:skill-tool-args-not-forwarded-from-orchestrator
description: Invoking a skill via the Skill tool from inside an orchestrator context does NOT forward args to the subprocess — the skill body runs but the args string is silently dropped
type: reference
originSessionId: 83e0ba78-5cea-4191-8d3d-6552e29eaaa5
---
**Symptom:** You call `Skill("conta-cpo", args="Decide: should we adopt X?")` from inside an orchestrator or parent skill. The skill invocation succeeds (no error), but the skill body sees no decision statement and falls back to prompting interactively or using a blank input.

**Root cause:** The Skill tool in orchestrator context does not pass the `args` string into the subprocess's prompt. The subprocess receives the skill body and its own context, but not the invocation arguments from the parent.

**Workaround options (in order of preference):**
1. **Inline the skill workflow** — instead of invoking the skill, reproduce its key phases inline in the orchestrator with the args baked into the prompt
2. **Fresh user-prompt invocation** — real invocations from a fresh `/conta-cpo <args>` user prompt work correctly; the limitation is orchestrator-to-skill forwarding only
3. **State file handoff** — write the args to a temp state file (e.g. `.skill-input.json`) before invoking, have the skill read it on startup

**When this matters:** Any orchestrator or parent skill that invokes a child skill AND needs to pass a specific argument (decision statement, query, target, etc.).

**Confirmed broken context:** Claude Code Skill tool call inside `/meditate`, `/ship`, or any orchestrator-pattern skill.
**Confirmed working context:** Direct user invocation (`/conta-cpo <args>` typed in conversation).

---

## Related

- [pattern_full-skill-vs-flag-when-personas-diverge.md](pattern_full-skill-vs-flag-when-personas-diverge.md) — if child-skill invocation from orchestrator is unreliable, standalone user-prompt invocable skills are even more important (2026-04-21)
- [pattern_spawn-convention-analyzer-before-new-skill-in-family.md](pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — both are skill-authoring insights that emerged from the same /conta-cpo build session (2026-04-21)

## Timeline

- **2026-04-21** — [failure] Smoke test during /conta-cpo build revealed Skill tool args forwarding silently drops args in orchestrator context. Workaround: inline the phases. Source: failure — conta-cpo smoke test, session 2026-04-21
- **2026-04-21** — Relevance score: 8. Use count: 0
