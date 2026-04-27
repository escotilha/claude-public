---
name: OpenRouter API Key
description: OpenRouter key location, validated working models, and OpenClaw VPS gateway routing config
type: reference
originSessionId: 0da3d8b0-d218-4db7-b3cb-d03ad9884366
---
OpenRouter API key (`sk-or-v1-...0811`, ~$16.79 lifetime usage, paid tier — not free).

**Where it lives:**

- **VPS** — `/opt/openclaw/.env` (systemd EnvironmentFile, was `#DISABLED_` until 2026-04-27) AND `/home/openclaw/.openclaw/.env` (active). The former takes precedence.
- **macOS Keychain** — NOT present on this Mac. The 2026-04-02 reference claimed it was; verified missing 2026-04-27 (`security find-generic-password -s OPENROUTER_API_KEY` returns "item could not be found").
- **Mac Mini** — not in keychain.

**OpenClaw VPS routing (as of 2026-04-27):**

- Provider config: `/home/openclaw/.openclaw/openclaw.json` → `models.providers.openrouter`
- Correct baseUrl: `https://openrouter.ai/api/v1` (NOT `/v1` — that returns the marketing HTML page)
- Primary: `openrouter/anthropic/claude-sonnet-4.6`
- Fallback chain: `claude-opus-4.6` → `qwen/qwen3-coder-plus` → `openai/gpt-oss-20b:free`
- Embedded harness runtime: `pi` (NOT `claude-cli` — that fails with "harness not registered" when CLI auth is dead)
- 4 agents migrated off claude-cli: mary, julia, bella (and the default)

**Validated working models (2026-04-27):**

| Model | Status |
|---|---|
| `anthropic/claude-sonnet-4.6` | ✅ HTTP 200 |
| `anthropic/claude-opus-4.6` | ✅ HTTP 200 |
| `qwen/qwen3-coder-plus` | ✅ HTTP 200 |
| `openai/gpt-oss-20b:free` | ✅ HTTP 200 |
| `qwen/qwen3-max` | ✅ HTTP 200 |
| `google/gemini-2.5-flash` | ✅ HTTP 200 |
| `google/gemma-4-31b-it:free` | ⚠️ HTTP 429 rate-limited upstream |
| `meta-llama/llama-3.3-70b-instruct:free` | ⚠️ HTTP 429 rate-limited upstream |

**Dead model IDs (return HTTP 404 "No endpoints found"):**

- `qwen/qwen3.6-plus-preview:free` — preview ended (matches the prediction in this memory's prior version)
- `qwen/qwen3-235b-a22b:free`
- `qwen/qwen-2.5-72b-instruct:free`
- `deepseek/deepseek-chat-v3-0324:free`
- `deepseek/deepseek-r1:free`

**Validation snippet:**

```bash
curl -s -H "Authorization: Bearer $KEY" https://openrouter.ai/api/v1/auth/key
# → {"data":{"label":"sk-or-v1-b1d...811","usage":16.79,"is_free_tier":false,...}}
```

---

## Timeline

- **2026-04-27** — [implementation] Wired OpenRouter into OpenClaw VPS gateway as primary inference path. Patched `openclaw.json`: fixed broken baseUrl, replaced 5 dead model IDs with 4 working ones, set primary + fallback chain, switched embedded harness from `claude-cli` to `pi`, remapped 4 agents (mary/julia/bella + default) from `claude-cli/*` to `openrouter/anthropic/*`. Uncommented `OPENROUTER_API_KEY` in `/opt/openclaw/.env`. Service restarted in 11.4s, log confirmed `[gateway] agent model: openrouter/anthropic/claude-sonnet-4.6`. Backups: `/home/openclaw/.openclaw/openclaw.json.bak-20260427-213002`, `/opt/openclaw/.env.bak-20260427-212844`. (Source: implementation — /opt/openclaw/.env, /home/openclaw/.openclaw/openclaw.json)
- **2026-04-27** — [failure] Discovered `https://openrouter.ai/v1` was returning marketing HTML, not chat completions — config bug present since OpenClaw migration. Correct baseUrl is `/api/v1`. Also discovered every "free preview" model from April 2026 (Qwen3.6-plus, Qwen3-235b, Deepseek-v3, etc.) now returns 404. Free-tier strategy is unreliable — paid models or BYOK only. (Source: failure — `qwen/qwen3.6-plus-preview:free` returned 404 during validation)
- **2026-04-27** — [failure] macOS Keychain entry `OPENROUTER_API_KEY` is missing on this Mac — prior memory's claim that it lived in keychain was wrong, or it was deleted. Key was found on the VPS itself. (Source: failure — `security find-generic-password -s OPENROUTER_API_KEY` not found)
- **2026-04-04** — [research] Qwen3.6-Plus hit ~1.4T tokens/day on OpenRouter — #1 by usage, first to break 1T/day. Strong signal preview pricing would end (confirmed by 2026-04-27, model now returns 404). (Source: research — OpenRouter platform stats)
- **2026-04-02** — [implementation] Default model switched to `qwen/qwen3.6-plus-preview:free` from `qwen/qwen3-235b-a22b`. `max_tokens` raised 4096 → 16384, memory context 8000 → 16000 chars. Applied in claudia-setup — HELPFUL (now obsolete, both models 404 as of 2026-04-27). (Source: implementation — claudia openrouter.ts)

Use count: 2
