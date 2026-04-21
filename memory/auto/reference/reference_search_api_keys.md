---
name: reference_search_api_keys
description: (SUPERSEDED 2026-04-21) Brave + Exa search API keys — now part of the unified Keychain reference. See personal/reference_api_keys_keychain.md for current state.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
> **SUPERSEDED 2026-04-21:** This page is kept for history only. Current state lives in `personal/reference_api_keys_keychain.md` which covers all four keys (Resend, Brave, Exa, Turso) under the post-incident Keychain-first policy. settings.json no longer stores literal key values — uses `${VAR}` references pulled from Keychain.

## Search API Keys (legacy, pre-incident)

Both keys were originally stored in:

1. **macOS Keychain** (syncs across devices via iCloud Keychain) — account: "ps", services: "BRAVE_API_KEY" and "EXA_API_KEY"
2. **Claude settings.json** at `~/.claude-setup/settings.json` under `env` ← LITERAL VALUES, now removed after 2026-04-21 incident

### Brave Search API

- **Service:** Brave LLM Context API
- **Free tier:** $5 monthly credit (~1,000 queries)
- **Key feature:** `count` parameter controls token budget per call
- **MCP server:** `brave-search` in settings.json
- **Retrieve:** `security find-generic-password -a ps -s BRAVE_API_KEY -w`

### Exa.ai API

- **Service:** Exa neural search with highlights mode
- **Free tier:** $10 starting credit
- **Key feature:** `highlights` mode returns only query-relevant passages (500-1,500 tokens vs 5,000-15,000 full text)
- **MCP server:** `exa` in settings.json
- **Retrieve:** `security find-generic-password -a ps -s EXA_API_KEY -w`

### Added: 2026-03-17
