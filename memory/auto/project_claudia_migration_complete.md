---
name: claudia-openclaw-migration-complete
description: Claudia fully replaced OpenClaw — all features migrated including voice, TTS, STT, proactive scheduler, media support
type: project
---

Claudia router fully replaced OpenClaw on VPS as of 2026-03-31. Migration included:

**Voice/Audio:**

- STT: Groq Whisper (whisper-large-v3) for WhatsApp + Telegram voice messages
- TTS: ElevenLabs v3 — chat voice cgSgspJ2msm6clMCkdW9, call voice UZ8QqWVrz7tMdxiglcLh
- Twilio voice calls: inbound via /voice/webhook on voice.xurman.com, Polly.Camila for v1 TTS
- From number: +18596952433

**Proactive Scheduler:**

- daily-briefing: 8:00 BRT to Discord command-center
- eod-summary: 18:00 BRT weekdays to Discord
- wa-morning: 8:30 BRT weekdays to Pierre's WhatsApp
- heartbeat: hourly 8-20 BRT, silent unless issues

**Channels:** Discord, Telegram, Slack, WhatsApp (wwebjs), Voice (Twilio)
**Library:** Migrated from Baileys 7-rc (broken 405) to whatsapp-web.js (Puppeteer)

**OpenClaw:** Backed up to /root/openclaw-backup-20260330.tar.gz, removed from /opt/openclaw

**Why:** OpenClaw was unmaintained, Baileys had fatal QR pairing bugs, Claudia uses Claude Code Agent SDK directly.
**How to apply:** All voice/TTS/STT config is in VPS .env. Scheduler tasks in src/scheduler/default-tasks.ts.
