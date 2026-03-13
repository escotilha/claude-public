---
name: resend-cli-transactional-email
description: Resend CLI (v1.4.1) added as transactional send channel in /agentmail skill — use for one-way sends from verified domains (nuvini.ai, contably.ai)
type: reference
---

Resend CLI (github.com/resend/resend-cli) is integrated as a transactional email pathway in the `/agentmail` skill.

- **Install:** `pnpm add -g resend`
- **Auth:** `RESEND_API_KEY` env var (not yet configured as of 2026-03-13)
- **Verified domains:** nuvini.ai, contably.ai (via Resend dashboard)
- **Non-TTY mode:** auto-detects agent/CI context, outputs JSON to stdout
- **AI agent detection:** `resend doctor` detects Claude environments

**Routing:** AgentMail for inboxes (receive, reply, thread). Resend CLI for one-way transactional sends from business domains.
