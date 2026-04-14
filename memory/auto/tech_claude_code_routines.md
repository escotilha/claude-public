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

---

## Timeline

- **2026-04-14** — [research] Announced via @claudeai on X. Research preview, not GA. Source: https://x.com/claudeai/status/2044095086460309790
