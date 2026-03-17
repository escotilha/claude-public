---
name: reference:paperclip-vps-setup
description: Paperclip AI orchestration running on VPS with 3 companies (Nuvini, Contably, SourceRank) connected to OpenClaw gateway — ports, IDs, architecture
type: reference
---

## Paperclip on VPS

- **Service:** `paperclip.service` (systemd), port 3100, bind 127.0.0.1
- **Database:** PostgreSQL 16 on port 5433, db=paperclip, user=paperclip
- **Config:** `/root/.paperclip/instances/default/config.json`
- **Mode:** `local_trusted` / private
- **Version:** 0.2.7 (npm: paperclipai)

## Companies

| Company       | ID                                   | Prefix | Budget |
| ------------- | ------------------------------------ | ------ | ------ |
| Nuvini Group  | 4e37d9a0-a4dd-4226-9bc9-f2932243a34e | NUV    | $50/mo |
| Contably      | c025dfac-dbf2-49de-a78f-97e259a89c42 | CON    | $30/mo |
| SourceRank AI | 599ab2a1-533e-477d-b555-5b56e3637f6b | SOU    | $30/mo |

## Agents (all openclaw_gateway adapter → ws://127.0.0.1:3001)

| Agent               | Company    | Role    |
| ------------------- | ---------- | ------- |
| Nuvini CEO          | Nuvini     | ceo     |
| Nuvini Orchestrator | Nuvini     | general |
| Contably CEO        | Contably   | ceo     |
| Contably Operator   | Contably   | general |
| SourceRank CEO      | SourceRank | ceo     |
| SourceRank Operator | SourceRank | general |

## Architecture

- Paperclip (management plane) → OpenClaw gateway (execution plane) → Mac Mini node (MLX compute)
- Personal agents (Claudia, Marco, Arnold, etc.) remain OpenClaw-only — not managed by Paperclip
- Paperclip skill installed at `/root/.openclaw/skills/paperclip/SKILL.md`

**Why:** Paperclip handles company governance (org charts, budgets, task ticketing, audit trail). OpenClaw handles execution (channels, models, skills, voice, messaging).
**How to apply:** Use Paperclip CLI or API for business task assignment; use OpenClaw directly for personal agent interactions.
