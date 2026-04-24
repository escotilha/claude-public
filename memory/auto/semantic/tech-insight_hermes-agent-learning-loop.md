---
name: tech-insight:hermes-agent-learning-loop
description: Hermes Agent patterns — 5-layer harness model, skills-vs-memory, auto-skill-generation, and v0.11.0 interface-release additions (transport abstraction, /steer, pre_tool_call veto, file-coordination)
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

**5. v0.11.0 "Interface Release" patterns (Apr 2026 — 700+ PRs, ~200 contributors)**

- **Transport layer abstraction** — `agent/transports/` makes LLM provider pluggable (AnthropicTransport, ChatCompletions, ResponsesApi, Bedrock). Applies to our MCP tool routing: generalize `web-search-efficiency.md`'s "cheapest-capable-tool" pattern to all MCP tools, not just search.
- **`/steer` mid-run course correction** — injects guidance after the agent's next tool call without breaking prompt caching. Applies to `/parallel-dev`, `/cto` swarm, `/qa-cycle`: document a convention where a user message mid-skill is absorbed at the next `AskUserQuestion` gate as steering input, so long runs don't require restart to redirect.
- **`pre_tool_call` veto hooks** — plugins can block a tool call before execution. Stronger than our prompt-based `/careful` skill. Our Claude Code hooks system already supports `PreToolUse`; worth an audit of whether destructive-ops coverage (`rm -rf`, `DROP TABLE`, `kubectl delete`, force-push) is harness-enforced or still LLM-discretionary.
- **File-coordination for concurrent siblings** — lightweight manifest so sibling subagents don't clobber shared files. Our worktree-per-feature model already handles feature-level isolation; this pattern matters only for intra-worktree multi-agent edits (rare in our usage).
- **Unlimited subagent recursion depth/width** — Hermes removed the depth cap. Claude Code has no explicit cap but model-tier-strategy's "3-5 sweet spot" is still the right rule — Hermes's unbounded recursion is for long-lived autonomous runs, not our interactive sessions.
- **Shell scripts as first-class lifecycle hooks** — no-Python-required hooks lower the barrier for contributors. Already supported in our setup (settings.json hooks accept bash directly); worth documenting explicitly in skill-authoring-conventions.

---

## Related

- [pattern_learn-distill-encode-evolve.md](pattern_learn-distill-encode-evolve.md) — Hermes "harness engineering" is the same philosophy as learn→distill→encode; complementary articulation of the same meta-pattern (2026-04-21)
- [pattern_spawn-convention-analyzer-before-new-skill-in-family.md](pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — Hermes auto-skill generation heuristic (≥3 repeated sequences) aligns with when to extract a skill during /meditate Phase 6 (2026-04-21)

## Timeline

- **2026-04-24** — [research] Hermes Agent v0.11.0 "Interface Release" shipped — 700+ PRs, ~200 contributors. Source: research — github.com/NousResearch/hermes-agent/releases/tag/v2026.4.23 via https://x.com/Teknium/status/2047506967909015907. Key additions: transport layer abstraction, /steer mid-run injection, pre_tool_call veto hooks, file-coordination for siblings, React/Ink TUI rewrite, 5 new LLM providers. Applies to: /parallel-dev, /cto swarm, /qa-cycle (steering convention), /careful (veto hooks), web-search-efficiency rule (generalize MCP routing).
- **2026-04-21** — [research] Discovered via @KSimback tweet (https://x.com/KSimback/status/2046528526581383643). Source: research — hermesatlas.com/guide/ (18 min read, Apr 2026 edition). Applies to: memory-strategy rule, /meditate skill, skill-first routing table.
