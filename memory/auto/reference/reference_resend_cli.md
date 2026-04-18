---
name: resend-cli-transactional-email
description: Resend CLI (v1.4.1) configured as transactional send channel in /agentmail skill — use for one-way sends from verified domains (contably.ai, xurman.com, agentwave.io)
type: reference
---

Resend CLI (github.com/resend/resend-cli) is integrated as a transactional email pathway in the `/agentmail` skill.

- **Install:** `npm install -g resend-cli` (not `resend` — that's the SDK)
- **Auth:** `RESEND_API_KEY` env var set in `~/.zshrc` + macOS Keychain
- **API key name:** `claude-cli` (full access, all domains)
- **Resend account:** nove (p@xurman.com Google login, Pro plan)
- **Verified domains:** contably.ai, xurman.com, agentwave.io, nuvini.ai (added 2026-03-31)
- **Partially failed:** agents.xurman.com (DNS records incomplete)
- **nuvini.ai Resend domain ID:** 3c1a13d9-053e-4038-9e10-09529867d8c8
- **nuvini.ai audience (IR Subscribers):** 8ca880cc-8839-4d7d-8461-dc9b7cc443b9
- **Non-TTY mode:** auto-detects agent/CI context, outputs JSON to stdout

**Routing:** AgentMail for inboxes (receive, reply, thread). Resend CLI for one-way transactional sends from business domains.
