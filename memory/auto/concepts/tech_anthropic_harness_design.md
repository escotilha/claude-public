---
name: Anthropic harness design patterns
description: Cross-industry harness engineering synthesis — OpenAI Codex, Anthropic GAN-style eval, ThoughtWorks guide/sensor taxonomy, LangChain Terminal Bench, Opus 4.7 self-verification
type: reference
originSessionId: 3e3020d1-6f2c-4cd1-853f-c81a972e66f7
---
Harness engineering is converging around the same core idea: design the environment the agent works inside — rules, feedback loops, docs structure, dependency order — rather than the agent itself. AlphaSignal synthesis (2026-04-22) covers OpenAI, Anthropic, ThoughtWorks, and LangChain approaches:

**Anthropic (GAN-style, planner→generator→evaluator):**
1. **Self-evaluation bias:** Generators rate their own work 4-5/5 regardless of quality. An independent evaluator (separate agent, no generator context) calibrated toward skepticism catches what self-review misses.
2. **Structured handoff > compaction:** Full context resets with structured handoff document outperform compacted contexts. Compaction produces "context anxiety" — shorter outputs, rushing. Clean handoff eliminates this.
3. **Managed Agents beta (2026-04-09):** Brain (Claude) decoupled from hands (secure sandbox) from session (durable event log). Crash recovery via event log. +10 points on structured file generation vs standard loops.

**OpenAI Codex ("map not a manual"):**
4. **Encode architecture as code, not prose:** Strict dependency layers (Types → Config → Repo → Service → Runtime → UI), structural tests that fail the build on wrong-direction imports. AGENTS.md files distributed per-module.
5. **Agents wrote the linters:** The environment was designed by humans; the constraints were enforced by agents.
6. **Scale proof:** Sora Android — 4 engineers, 28 days, #1 Play Store, 99.9% crash-free rate. 70% of internal PRs weekly.

**LangChain (Terminal Bench 2.0):**
7. **Harness beats model:** Same GPT-5.2-Codex weights, different harness → 52.8% to 66.5% score, rank outside top 30 to rank 5.
8. **"Reasoning sandwich":** High reasoning for planning, reduced for building, high again for verifying = 66.5%. Max reasoning everywhere = 53.9% (worst). The harness must be choosy about when to spend reasoning.
9. **Harness components are bets on model limitations:** As models improve, some scaffolding becomes dead weight. Audit regularly.

**ThoughtWorks (guide/sensor taxonomy):**
10. **Two axes:** Is it a guide (before agent acts) or sensor (after)? Is it computational (linter/test, deterministic) or inferential (LLM-as-judge, semantic)?
11. **Most teams have 3 computational sensors, 0 computational guides** — feedforward-only or feedback-only. Need both.
12. **Harnessability:** Strongly-typed languages, clear module boundaries, structured frameworks make agent work inherently more reliable.

**Opus 4.7 impact on harness design:**
13. **Self-verification built-in:** "Opus 4.7 devises ways to verify its own outputs before reporting back." Separate evaluator agents carry less weight — the model can now do some of what the harness previously had to do.
14. **Implication:** Audit harness components after every major model upgrade. Dead scaffolding wastes tokens and adds latency.

**Applied in:**
- `/ship` v6.0.0 — Phase 4.7 Interactive Evaluation + structured handoff (2026-03-24)
- `/parallel-dev` v3.0.0 — Phase 4.65 Interactive Evaluation + structured handoff (2026-03-24)

**Sources:**
- https://x.com/AlphaSignalAI/status/2046952554421002393 (synthesis article, 2026-04-22)
- https://anthropic.com/engineering/harness-design-long-running-apps
- https://openai.com/index/harness-engineering/
- https://blog.langchain.com/the-anatomy-of-an-agent-harness/
- https://martinfowler.com/articles/harness-engineering.html

**Discovered:** 2026-03-24
**Updated:** 2026-04-23 — expanded with OpenAI Codex, ThoughtWorks, LangChain, and Opus 4.7 implications

Related: [tech-insight:hermes-agent-learning-loop](../semantic/tech-insight_hermes-agent-learning-loop.md) — Hermes Agent's complementary 5-layer harness model (instruction/constraint/feedback/memory/orchestration) + skills-vs-memory distinction (2026-04-21)
