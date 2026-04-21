---
name: Anthropic harness design patterns
description: Planner/generator/evaluator three-agent pattern and structured handoff (no compaction) for long-running agent sessions — from Anthropic engineering post on frontend design
type: reference
originSessionId: 3e3020d1-6f2c-4cd1-853f-c81a972e66f7
---
Anthropic engineering published a detailed breakdown of their three-agent harness (planner → generator → evaluator) used for frontend design and multi-hour autonomous software engineering.

**Key findings:**

1. **Self-evaluation bias:** Generators systematically rate their own work 4-5/5 regardless of quality. An independent evaluator (separate agent, no access to generator's conversation) calibrated toward skepticism catches issues self-review misses.

2. **Structured handoff > compaction:** For long-running sessions, full context resets with a structured handoff document outperform compacted contexts. Compaction preserves "context anxiety" — models become cautious, produce shorter outputs, and rush to complete. A clean handoff with explicit state transfer eliminates this.

3. **Harness design is not static:** Every component encodes an assumption about what the model can't do alone. As capabilities improve, audit and remove scaffolding that's no longer load-bearing.

4. **Design rubric:** Four criteria for evaluating frontend output — design quality (coherent visual identity), originality (custom decisions, not template defaults), craft (typography, spacing), functionality.

**Applied in:**

- `/ship` v6.0.0 — Phase 4.7 Interactive Evaluation + structured handoff (2026-03-24)
- `/parallel-dev` v3.0.0 — Phase 4.65 Interactive Evaluation + structured handoff (2026-03-24)

**Source:** https://anthropic.com/engineering/harness-design-long-running-apps
**Discovered:** 2026-03-24

Related: [tech-insight:hermes-agent-learning-loop](../semantic/tech-insight_hermes-agent-learning-loop.md) — Hermes Agent's complementary 5-layer harness model (instruction/constraint/feedback/memory/orchestration) + skills-vs-memory distinction (2026-04-21)
