---
name: feedback:read-existing-code-before-writing
description: Before writing any new file/function/route, search the codebase for existing implementations — never duplicate what's already there
type: feedback
originSessionId: 3538be53-f06e-4407-9e7d-5e968cf57914
---
Before writing any new code (file, function, route, hook, schema, helper, script), first search the existing codebase for prior implementations. Do this **at every step** — both when planning and inside each agent's work, not just at spawn time.

**Why:** Hit this 2026-04-19 multiple times. Twice during today's session I almost duplicated functionality that already existed:
1. The `engagement_tracking.py` service was nearly re-implemented when only the HTTP route was missing — the QA report's "no route exists" finding doesn't mean "no code exists for the feature"
2. Earlier in the day a worktree agent almost wrote a separate retry helper when an existing pattern in the codebase could have been reused (luckily flagged as "no shared retry helper exists" before writing — but the spawn prompt explicitly required this check)

User feedback (verbatim, 2026-04-19): *"Just make sure you look at the current code before you write new code to ensure we are not rewriting things that are already in the system. Do this in every step, okay?"*

**How to apply:**

1. **Before writing a new function**: `grep -rn "def <similar_name>\|class <similar_name>" <project>/src/` — match by function name, signature, or domain
2. **Before adding a new HTTP route**: `grep -rn "prefix=.*<area>\|@router.<verb>.*<path>" <project>/src/api/` — and check the package `__init__.py` for the registration pattern
3. **Before creating a new helper module**: search for utility files in the same domain (`grep -rn "<domain>_utils\|helpers/<domain>" <project>/`)
4. **Before adding a new env var or config**: `grep -rn "<VAR_NAME>\|settings\.<var_lowercase>" <project>/` to ensure no existing knob covers it
5. **Before drafting a new doc**: `find <project>/docs -name "*<topic>*"` to see if there's already a related doc to extend instead
6. **Inside spawned worktree agents**: their prompts must include "**Read first** ..." with concrete grep/find/Read commands targeting the area they'll touch — not optional, not "if you have time"

**Spawn-prompt template addition** (paste verbatim into every agent prompt that involves writing code):

> Before writing any new file or function, search the codebase for existing implementations of the same concept. Use `grep -rn` / `find` / `Read` against the area you'll touch. If you find an existing implementation: extend or reuse it. If you find a similar pattern elsewhere in the codebase: mirror it. Only write from scratch when there's genuinely no prior art. Document what you searched for in your final report so the orchestrator can verify the dedup pass happened.

**Counterexamples (when this rule does NOT apply):**

- Trivial one-line edits (changing a string, fixing a typo)
- Pure config files where the schema is dictated externally (e.g., a new K8s manifest)
- When the user explicitly says "I know there's no existing code, write it"

---

## Timeline

- **2026-04-19** — [session — contably P3 fixes + EOD batch] User flagged after I successfully avoided duplicating `engagement_tracking.py` (only added the HTTP route) but still wanted the rule encoded so I do this every time, not just when I happen to remember. Rule applies to all autonomous code work going forward.
