---
name: project:claudia-router
description: Claudia — TypeScript router replacing OpenClaw on VPS, routes multi-channel messages to Claude Code Agent SDK sessions with 3-tier fallback
type: project
---

## Claudia Router

Full OpenClaw replacement. TypeScript service routing Discord/Telegram/Slack/WhatsApp messages to Claude Code Agent SDK sessions.

**Why:** OpenClaw is a walled garden — agents can only chat. Claudia gives every agent full Claude Code powers (filesystem, git, skills, MCP, tools, Agent Teams). Also eliminates dependency on the `openclaw` npm package.

**How to apply:** When working on VPS infrastructure, agent orchestration, or channel integrations, reference this project. Claudia is the new agent runtime.

### Architecture

- **Repo:** escotilha/claudia, local at /Volumes/AI/Code/claudia, VPS at /opt/claudia
- **9 agents:** claudia, buzz, marco, cris, julia, arnold, bella, rex, swarmy
- **3-tier inference:** Agent SDK (Claude Max) → Mac Mini MLX (Qwen 3.5-35B) → VPS Ollama (Nemotron 3 Super)
- **Channels:** Discord (15 bindings), Telegram, Slack (Nuvini socket mode), WhatsApp (Baileys)
- **Session persistence:** SQLite (better-sqlite3), 24hr TTL, auto-cleanup
- **Systemd:** claudia.service on VPS, port 3001

### Status (2026-03-30)

- Phase 1: Complete (core router, Discord, Telegram, Slack, inference, sessions, health)
- Phase 2: In progress (all agent personas, WhatsApp adapter, VPS deployment)
- Phase 3: Pending (failsafe migration, OpenClaw decommission)

### Key Files

- Plan: /Volumes/AI/Code/openclaw-vps/plan.md
- Research: /Volumes/AI/Code/openclaw-vps/research.md
