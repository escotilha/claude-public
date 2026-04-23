---
name: tech-insight:nanoclaw-v2
description: NanoClaw v2 — agent-to-agent communication, HITL approvals, 15 messaging platforms, Vercel partnership
type: tech-insight
originSessionId: 7945353b-aa2c-4899-b2cd-0ec45485bffb
---
NanoClaw v2 (2026-04-23) rebuilds the agent communication layer in partnership with Vercel. Key additions: agent-to-agent (A2A) messaging, human-in-the-loop (HITL) approval flows, and 15 supported messaging platforms (WhatsApp, Telegram, Discord, Slack, MS Teams, iMessage, Matrix, Google Chat, Webex, Linear, GitHub, WeChat, Gmail + 2 more). Architecture: single Node.js host, per-session Docker containers, SQLite inbound/outbound queues (single-writer), credential isolation via Agent Vault. The `/nanoclaw` skill needs updating to reflect v2's channel list and new commands.

---

## Timeline

- **2026-04-23** — [research] NanoClaw v2 announced via @NanoClaw_AI on X, in partnership with Vercel. Source: https://x.com/NanoClaw_AI/status/2047269757653553511
- **2026-04-23** — [research] Fetched nanoclaw.dev — confirmed 15 platform list and A2A + HITL as the two major v2 additions. Source: research — nanoclaw.dev
- **2026-04-23** — Action: queued nanoclaw.dev for wiki harvest. Existing `/nanoclaw` skill needs channel list and command updates.
