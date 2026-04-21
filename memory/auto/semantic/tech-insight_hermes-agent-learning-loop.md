---
name: tech-insight:hermes-agent-learning-loop
description: Hermes Agent learning loop patterns — 5-layer harness model, skills-vs-memory distinction, auto-skill-generation heuristic
type: reference
originSessionId: 3e3020d1-6f2c-4cd1-853f-c81a972e66f7
---
Hermes Agent (Nous Research) is a self-improving autonomous agent runtime. Key architectural insights from their April 2026 beginner guide that apply to the Claude Code setup:

**1. Five-layer harness model ("harness engineering")**
Instruction layer → Constraint layer → Feedback layer → Memory layer → Orchestration layer. The LLM is a replaceable component inside this harness — swapping models requires no architectural changes. This is a useful mental model for our ~/.claude-setup: rules/ = instruction+constraint, hooks = feedback, memory/ = memory, skills/ = orchestration.

**2. Skills-as-procedures vs. memory-as-facts**
Explicit distinction: skills are executable workflows (procedural knowledge), memory is facts/preferences/context. Skills differ fundamentally from stored facts — they capture how to do something, not just what. Useful routing rule at write time: repeated tool-call sequence → skill file; distilled insight → memory entity.

**3. Auto-skill generation heuristic**
After ~5 tool calls on a repeated pattern, write a reusable skill file. Applies to /meditate Phase 6 (skill extraction): if same multi-step tool sequence observed ≥3 times in a session, flag as skill candidate rather than relying on subjective "does this feel reusable?" judgment.

**4. Hermes vs. Claude Code — complementary, not competing**
Hermes is positioned for long-running autonomous tasks outside any single session. Claude Code is inside-repo coding. Most power users run both. Hermes architecture choices (persistent daemon, 16 platform integrations, execution backends) solve a different problem than Claude Code's skill harness.

---

## Related

- [pattern_learn-distill-encode-evolve.md](pattern_learn-distill-encode-evolve.md) — Hermes "harness engineering" is the same philosophy as learn→distill→encode; complementary articulation of the same meta-pattern (2026-04-21)
- [pattern_spawn-convention-analyzer-before-new-skill-in-family.md](pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — Hermes auto-skill generation heuristic (≥3 repeated sequences) aligns with when to extract a skill during /meditate Phase 6 (2026-04-21)

## Timeline

- **2026-04-21** — [research] Discovered via @KSimback tweet (https://x.com/KSimback/status/2046528526581383643). Source: research — hermesatlas.com/guide/ (18 min read, Apr 2026 edition). Applies to: memory-strategy rule, /meditate skill, skill-first routing table.
