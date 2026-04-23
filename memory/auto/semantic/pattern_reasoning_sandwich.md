---
name: pattern-reasoning-sandwich
description: Per-phase reasoning effort allocation (high for plan/verify, low for execute/format) beats uniform-max across multi-phase skills on Opus 4.7
type: concept
originSessionId: 44d280b3-522a-43c3-b134-229c5c3b0644
---
Multi-phase skills (/ship, /parallel-dev, /cto, /deep-plan) should encode **per-phase reasoning directives** in the skill prompt — NOT set max thinking everywhere. LangChain benchmarked same model/same weights with varying reasoning allocation: uniform-max scored 53.9%, sandwich pattern (high → low → high) scored 66.5%. Free prompt-only change, +12.6pp.

**Pattern:**

- Planning / spec phases: "Think carefully and step-by-step before responding."
- Execution / dispatch / format phases: "Prioritize responding quickly rather than thinking deeply. The plan is decided."
- Verification / synthesis / root-cause phases: "Think carefully. Verify each artifact / reconcile findings / find the root cause."

Propagate the phase directive into subagent spawn prompts — do not assume inheritance. Opus 4.7 uses adaptive thinking (no `budget_tokens`), so these directives are the only steering mechanism.

Applied 2026-04-23 to:
- `~/.claude-setup/skills/ship/SKILL.md` (7 phases)
- `~/.claude-setup/skills/parallel-dev/SKILL.md` (5 phases)
- `~/.claude-setup/skills/cto/SKILL.md` (sequential + swarm)

Complements `opus-4-7-prompting.md` rule. Related to `tech-insight-opus-4-7-best-practices` (Boris Cherny).

---

## Timeline

- **2026-04-23** — [research] AlphaSignalAI synthesis of harness engineering from OpenAI, Anthropic, ThoughtWorks, LangChain landed; LangChain benchmark quoted 52.8% → 66.5% on reasoning-sandwich vs unguided. (Source: research — x.com/AlphaSignalAI/status/2046952554421002393)
- **2026-04-23** — [implementation] Reasoning-sandwich blocks added to ship, parallel-dev, cto SKILL.md files. (Source: implementation — ~/.claude-setup/skills/{ship,parallel-dev,cto}/SKILL.md)

Related: [tech-insight-opus-4-7-best-practices](../concepts/tech_insight_opus_4_7_best_practices.md) — Boris Cherny's prompt guidance is the mechanism this pattern exploits (2026-04-23)
