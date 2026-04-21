---
name: Contably OS v4 planning inputs
description: Two design inputs captured 2026-04-21 during v3 Phase 1 E2E sign-off, to feed into v4 planning
type: project
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
Two explicit inputs from Pierre for v4 planning. Both supersede or extend
v3 defaults and should be designed in from the start, not bolted on.

**1. Prefer local Anthropic OAuth over API keys.**
- v3 Phase 1 discovered that SSH dispatch to the mini fails unless
  `~/.claude/.credentials.json` is exported from the macOS Keychain
  because non-interactive shells can't unlock the keychain. This was
  worked around by manually writing the Max-plan OAuth to disk.
- v4 should make OAuth the default auth path and make the export
  self-healing (refresh cycle handled, file regenerated from keychain
  on schedule, no manual `security find-generic-password` step).
- This also dovetails with risk R-OS3-030 in `04-risk-register.md`:
  executors should NOT carry `ANTHROPIC_API_KEY` in their subprocess env.
  OAuth-only execution is the cleaner posture.
- Why: Pierre uses a Max subscription on the mini. Routing all executor
  work through OAuth avoids per-task API costs and keeps billing
  predictable on that plan's rate-limit tier. Also reduces the blast
  radius if a secret leaks.

**2. Account for the `/conta-cpo` skill in v4.**
- `/conta-cpo` is a new 8-seat product/UX/engineering advisory council
  skill under `~/.claude-setup/skills/conta-cpo/`. Context: "fork",
  model: "opus", `alwaysThinkingEnabled: true`. Paths-scoped to
  contably repos. Has its own schema + personas directory.
- Relevance to v3's skill-selection algorithm (design §8): `/conta-cpo`
  is a **deliberation** skill — doesn't ship code, doesn't open PRs.
  v3's current picker would never route to it (no weight entry,
  no triggers). But it's the right skill to invoke when:
  - A roadmap item is ambiguous (multiple viable implementations)
  - A Tier-0 item has competing go-live sequencing options
  - The /cto review flags conflicting concerns worth deeper debate
- v4 should add `/conta-cpo` to `SKILL_WEIGHTS` with triggers like
  "deliberate", "advisory", "trade-off analysis", and wire a pathway
  where the planner can mark a task as `needs_council: true` to route
  it through `/conta-cpo` BEFORE the normal `/cto` → `/ship` chain.
- Why: the autonomous loop today assumes every item decomposes cleanly
  into a ship-able plan. The roadmap's Tier 2-3 items (eSocial, rule
  engine externalization, real-time anomaly detection) genuinely have
  multiple right answers where a quick 8-seat deliberation pass beats
  going straight to /cto review of a half-baked plan.

---

## Timeline

- **2026-04-21** — [user-feedback] Pierre flagged both inputs immediately after v3 Phase 1 E2E dispatch succeeded on task t1-4-skeleton-loaders-01. (Source: user-feedback — post-E2E handoff conversation)
