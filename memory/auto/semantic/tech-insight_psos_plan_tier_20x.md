---
name: tech-insight-psos-plan-tier-20x
description: Pierre's Claude account is Max 20x (not 5x). PSOS + any tool that respects Anthropic plan tiers should default to `plan_tier="20x"` → 900 msgs per 5h window. The psos_core v0.5.0 default was wrongly `5x` (225 msgs).
type: tech-insight
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
**Pierre's Claude account tier: Max 20x, not Max 5x.**

5-hour rolling window ceiling: **900 messages** (not 225).

PSOS `psos_core` v0.5.0 hardcoded `plan_tier="5x"` as default throughout:
- `cli.py` — 4 separate argparse subparsers had `default="5x"`
- `v3/dashboard.py`, `v3/dashboard_html.py`, `v3/deadman.py` — function parameter defaults
- `MAX_PLAN_CEILINGS = {"5x": 225, "20x": 900}` — ceiling math correct, only the default was wrong

Manifested as `rate_limit: N/225 msg (5h window, Max 5x)` in `psos v3 status` and dashboard rendering. Patched to `20x` on the VPS 2026-04-23. Needs upstream PR to `escotilha/psos`.

**Why:** Wrong ceiling means the engine self-throttles at 225/900 messages = 25% of real capacity. Dispatch decisions, deadman thresholds, and budget alerts were all scaled to the wrong number.

**How to apply:**
- When encoding Pierre's environment in any new tool/script: default plan tier = `20x`, 5h ceiling = 900, daily budget ~4000 msg.
- If a tool asks for plan tier and Pierre doesn't explicitly say, assume 20x.
- Watch for other Claude-plan-aware tools that might have the same 5x default (chief-geo, Claudia's Tier 1 Agent SDK calls, any `plan_max_throughput` config).

## Timeline

- **2026-04-23** — [user-feedback] User corrected "rate limit is 20X plan max, not 5x" during PSOS migration. Patched PSOS defaults same session. (Source: user-feedback — live correction during debugging)

## Related

- [psos-migration-2026-04-23-complete](../projects/psos_migration_2026-04-23_complete.md)
