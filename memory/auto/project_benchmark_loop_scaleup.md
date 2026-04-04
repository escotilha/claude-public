---
name: project_benchmark_loop_scaleup
description: Benchmark optimization loop for Claudia — check ledger after 2-3 weeks and expand to other agents if gate criteria pass
type: project
---

AutoAgent-style benchmark loop deployed 2026-04-04 for claudia agent only (src/benchmark/).

**Why:** Closed-loop hill-climbing on persona (agents/claudia/CLAUDE.md). Runs nightly at 01:00 BRT, 3 iterations, reports to Discord #command-center.

**How to apply:** After 2026-04-20, check the ledger at data/benchmark/results.tsv on VPS. If gate criteria pass, expand to other agents:

Gate criteria:

1. At least 3-5 "improved" or "kept_simpler" entries (not all "reverted")
2. Held-out scores stable or rising
3. No manual reverts needed by user

Expansion order: buzz → marco → north → rest. Each needs a tasks/{agent}.ts file and agents/{agent}/CLAUDE.md persona. OpenRouter agents (all except claudia/bella) need wider verifier tolerances or multi-run averaging due to noisier responses.

Check this proactively around 2026-04-20 without being asked.
