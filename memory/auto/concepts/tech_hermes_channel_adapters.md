---
name: tech-insight:hermes-channel-adapters
description: Hermes v0.9.0 iMessage (BlueBubbles) and WeChat/WeCom adapter architecture — integration brief for AgentWave channel expansion
type: reference
originSessionId: fb76aea6-2be5-4092-80da-2df889604d67
---

Hermes Agent v0.9.0 ships 4 new channel adapters relevant to AgentWave:

**BlueBubbles (iMessage)** — `gateway/platforms/bluebubbles.py`

- Webhook listener (aiohttp on :8645), registers via BlueBubbles REST API
- Auth: shared password on all URLs
- Supports: text (chunked 4K), images, voice, video, docs, group chats, typing, read receipts, tapback reactions
- Advanced features require Private API macOS helper (detected at connect-time)
- GUID resolution cache for chat addressing (email/phone → iMessage GUID)
- Known bug: `"message"` in webhook events list causes 400 on some server versions
- Prereqs: macOS + BlueBubbles Server v1.0.0+ on same LAN/VPN

**WeCom AI Bot** — `gateway/platforms/wecom.py`

- Persistent WSS to `openws.work.weixin.qq.com`, 30s heartbeat
- AES-256-CBC media decryption, 512KB chunked uploads, 20MB ceiling
- Message dedup: LRU(1000) with 5m TTL
- No public endpoint needed (outbound WebSocket only)
- Text-only limitation on some modes

**WeCom Callback** — `gateway/platforms/wecom_callback.py` + `wecom_crypto.py`

- HTTP callback with AES-encrypted XML + SHA-1 signature verification
- OAuth2 access token with auto-refresh (TTL - 60s buffer)
- Multi-app: single gateway hosts N (corp_id, corp_secret, agent_id) triples
- Requires public HTTPS endpoint

**WeChat Personal (Weixin)** — `gateway/platforms/weixin.py`

- Long-polling against iLink Bot API (unofficial Tencent API)
- QR code login, token auto-refresh (max 3 attempts)
- AES-128-ECB CDN encryption for media
- Stateful context_token echo required per reply
- Complexity: HIGH — unofficial API, unreliable groups

**AgentWave Interface Gaps:**

1. `InboundMessage.mediaUrl` is singular — needs `mediaUrls?: string[]` for multi-attachment
2. No `messageType` field (TEXT/PHOTO/VOICE/VIDEO/DOCUMENT) — agents can't distinguish
3. `start()` doesn't support embedded HTTP servers — BlueBubbles/WeCom callback need this
4. No `typing()`/`markRead()` on interface — optional, no breaking change needed
5. `sendMedia(filePath)` signature is compatible — adapter absorbs platform specifics

**Patterns worth replicating:**

- GUID resolution LRU cache (BlueBubbles)
- Feature detection at connect() stored as instance state
- Message queue + poll loop decoupling HTTP ack from agent processing (WeCom callback)
- WXBizMsgCrypt (SHA-1 + AES-256-CBC) — non-trivial, port directly

---

## Timeline

- **2026-04-13** — [research] Studied Hermes v0.9.0 source + compared to AgentWave adapter interface (Source: research — NousResearch/hermes-agent v0.9.0)
