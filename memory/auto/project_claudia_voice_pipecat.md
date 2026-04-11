---
name: project_claudia_voice_pipecat
description: Claudia voice pipeline migrated from Twilio to Pipecat + Telnyx + Deepgram + Cartesia — real-time streaming voice
type: project
---

Voice pipeline migration completed 2026-04-05. Replaced Twilio `<Gather>`/`<Say>` polling loop with real-time streaming.

**Architecture:**

```
Phone call → Telnyx PSTN → TeXML webhook → Pipecat (Python, Docker)
  → Silero VAD → Deepgram Nova-3 STT → ClaudiaBridgeLLM (HTTP to Claudia) → Cartesia TTS
  → Audio streamed back via WebSocket
```

**Key details:**

- Pipecat v0.0.108, uses `parse_telephony_websocket` for handshake
- TeXML uses `bidirectionalMode="rtp"` + `<Pause length="40"/>`
- Docker container `claudia-pipecat-voice` with `network_mode: host`
- Caddy reverse proxy on voice.xurman.com (DNS-only, no Cloudflare proxy)
- Firewall: ports 80/443 open to all (needed for direct Telnyx access)
- Daily container restart cron at 4am (Pipecat memory leak mitigation)
- Bridge: Pipecat calls POST /voice/message on Claudia for full agent routing

**Phone:** +1 305 501 6501 (Telnyx, Miami)
**Voice:** Cartesia US voice `e8e5fffb-252c-436d-b842-8879b84445b6`

**Why:** Twilio `<Gather>`/`<Say>` had walkie-talkie UX. Pipecat gives real-time streaming with interruptions, ~40ms TTS TTFA, natural conversation flow.

**How to apply:** When touching voice features, the Python service is at `/opt/claudia/pipecat-voice/`. Claudia's TypeScript voice adapter at `src/channels/voice.ts` exposes POST /voice/message for the bridge.

**Incident note:** During migration, rsync accidentally wiped VPS /opt/claudia files. Recovered from git history + VPS env files + local Keychain. .env reconstructed. Always use `rsync` without `--delete` when pushing to VPS.
