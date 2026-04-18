---
name: tech-insight:claude-code-routines
description: Claude Code Routines (research preview) — Anthropic-managed server-side scheduled/event/API-triggered agent runs, successor to VPS-based cron scheduling
type: reference
originSessionId: 8e82cd06-7749-4a6a-acef-b167d5de87d4
---

Claude Code **Routines** are in research preview as of 2026-04-14. A Routine is a saved configuration of **prompt + repo + connectors (MCP)**, executable on a schedule, via API call, or triggered by an event/webhook. Runs execute on **Anthropic's cloud infrastructure** — no local process or VPS required.

**Key implications:**

- Directly replaces the Claudia-VPS-as-cron-server pattern for pure scheduling use cases
- Skills currently run via Claudia's VPS cron (`/chief-geo`, `/health-report`, `/buzz-daily-triage`, `/intel-scanner`) are migration candidates once GA
- The `/schedule` skill (CronCreate/RemoteTrigger) is the client-side precursor — Routines is the platform-native evolution
- Connectors (MCP) support means repo access + external tools are available in scheduled runs

**What it does NOT replace:**

- Multi-agent orchestration (Claudia's dispatch queue, agent routing)
- Real-time channel handling (WhatsApp, Discord, voice)
- Complex state management between runs (Claudia's 5-layer memory)

**Action:** Use CronCreate/RemoteTrigger today. Migrate to Routines when GA. Do not over-invest in VPS-based scheduling infrastructure.

**Migration priority (2026-04-16, accelerated after Opus 4.7 pairing signal):**

With Opus 4.7 as the canonical Routines model, migration stops being a "wait for GA" project and starts being a "move judgment-heavy scheduled agents off Sonnet-routed VPS crons ASAP" project. Prioritized candidates:

1. **`/chief-geo`** — daily autonomous, judgment-heavy, multi-track research → perfect Routines + 4.7 fit
2. **`/health-report`** — scheduled synthesis + self-verification of outputs → 4.7 self-checks catch regressions
3. **`/buzz-daily-triage`** — competitive intel filtering under ambiguity → judgment-heavy, Sonnet currently misses nuance
4. **`/intel-scanner`** (VPS cron) — keyword scans + relevance scoring → 4.7 improves signal/noise
5. **Claudia VPS crons** (long tail) — migrate incrementally as Routines adds features to match Claudia's memory + dispatch capabilities

---

**Opus 4.7 + Routines pairing (April 2026):**
Claude Opus 4.7 was purpose-built for full-throttle agentic work, judgment under ambiguity, and self-verifying outputs — making it the optimal model for Routines. Noah Zweben (Claude Code PM) explicitly positioned the combination as "the real unlock." This changes the model tier recommendation for Routines: use Opus 4.7 as default, not Sonnet, for scheduled background agents that require judgment.

---

## Timeline

- **2026-04-14** — [research] Announced via @claudeai on X. Research preview, not GA. Source: https://x.com/claudeai/status/2044095086460309790
- **2026-04-16** — [user-feedback] Noah Zweben (Claude Code PM) tweets Routines + Opus 4.7 as the explicit unlock pairing. Opus 4.7 described as built for "full-throttle agentic work, judgment under ambiguity, self-verifying outputs." Source: https://x.com/noahzweben/status/2044812118063747341

Related: [opus-4-7-best-practices](concepts/tech_insight_opus_4_7_best_practices.md) — Routines default to 4.7 with xhigh effort; adaptive thinking replaces fixed budgets; prompt explicitly for subagent fan-out (2026-04-16)
