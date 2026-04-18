---
name: project:intel-scanner-vps
description: Intel Scanner on VPS — Exa-powered cron job scanning 30 Twitter/X accounts for Claude Code, Claude, OpenClaw intel, posts to Discord #intel
type: project
originSessionId: 602b7950-2da9-4700-a787-4e38d7a64576
---

## Intel Scanner — VPS Cron Job

Standalone Node.js script on VPS that scans for relevant AI/coding intel every 2 hours and posts digests to Discord #intel channel.

**Why:** Monitor 30 key Twitter/X accounts (OpenClaw ecosystem, open source model leaders, Claude/Anthropic team) for posts that could improve our Claude Code setup, without requiring a Twitter API subscription.

**How to apply:** When debugging intel digests, modifying scan parameters, or adding/removing tracked accounts.

### Infrastructure

- **Location:** `root@100.77.51.51:/opt/intel-scanner/`
- **Files:** `scan.mjs`, `.env` (Exa + Discord keys), `run.sh`, `seen.json` (dedup), `scan.log`
- **Cron:** `7 10,12,14,16,18,20,22 * * *` CEST = every 2h from 5am–5pm BRT
- **Discord channel:** #intel `1476182091006869697`
- **Search engine:** Exa API (content-based, not author-based — can't follow timelines directly)

### Tracked Accounts (30)

**OpenClaw:** steipete, MattPRD, openclaw, chrysb, heyshrutimishra, petergyang, oliverhenry, PrajwalTomar*, benparr, PaulSolt
**OS Models:** karpathy, ylecun, Thom_Wolf, jmorgan, Tim_Dettmers, lvwerra, HamelHusain, swyx, simonw, ClementDelangue
**Claude:** bcherny, alexalbert\_\_, DarioAmodei, AmandaAskell, simonw, swyx, t3dotgg, PrajwalTomar*, HamelHusain, milesdeutscher

### Limitation

Exa indexes content, not Twitter timelines. Catches ~80% of what matters via keyword/topic search. True per-account monitoring would require X API Basic ($100/mo).

---

## Timeline

- **2026-04-12** — [implementation] Created and deployed to VPS. 5 parallel Exa searches (3 X/Twitter, 1 blogs, 1 GitHub), dedup with 48h rolling window, Discord bot posting. (Source: implementation — /opt/intel-scanner/scan.mjs)
