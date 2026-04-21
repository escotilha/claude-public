---
name: pattern:spawn-convention-analyzer-before-new-skill-in-family
description: When building a new skill that extends an existing family (cto, vibc, cpo, ship), spawn a one-shot Opus subagent to analyze 5–10 sibling skills for frontmatter + persona + reference conventions before writing a single file
type: reference
originSessionId: 83e0ba78-5cea-4191-8d3d-6552e29eaaa5
---
Before writing any files for a new skill that belongs to an established skill family, spawn a short-lived Opus subagent to read 5–10 existing sibling skills and extract:
- Frontmatter patterns (required fields, common values for `model`, `effort`, `context`)
- `invocation-contexts` discrimination pattern (user-direct vs agent-spawned verbosity/format)
- Persona spec format (if applicable — how archetypes are described, how context-injection is documented)
- Storage/state conventions (where DBs or state files live, naming patterns)

**Why:** Reading existing skills yourself is expensive and prone to cargo-culting a stale pattern from whichever skill you happen to look at first. A convention analyzer reads the whole family, surfaces the current consensus, and flags where skills diverge. Costs ~1 Opus call, saves multiple rounds of "actually vibc does it differently."

**Trigger:** Any time you are about to write the first file of a new skill that extends vibc, cto, ship, cpo, qa-cycle, or any family with 3+ sibling skills.

**Invocation pattern:**
```
Agent(model="opus", subagent_type="general-purpose", prompt="""
Read the SKILL.md files for these skills: {list 5-10 sibling paths}.
Extract the consensus conventions for:
1. Frontmatter (required fields, model, effort, context, invocation-contexts)
2. Persona spec format (if any)
3. Storage/state file conventions
4. Any fields or patterns that differ across siblings (flag as contested)
Return a compact reference block I can paste into the new skill's frontmatter.
""")
```

---

## Related

- Cross-ref: pattern:full-skill-vs-flag-when-personas-diverge — this pattern runs after the "build a full skill" decision is made (2026-04-21)

## Timeline

- **2026-04-21** — [session] Used during /conta-cpo build to analyze vibc, cto, ship, cpo, qa-cycle for conventions. Prevented several cargo-cult mistakes (stale invocation-contexts format, wrong model tier). Source: session — conta-cpo build 2026-04-21
- **2026-04-21** — Relevance score: 5. Use count: 0
