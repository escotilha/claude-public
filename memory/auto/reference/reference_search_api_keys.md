---
name: reference_search_api_keys
description: API keys for web search tools — Brave Search LLM Context API and Exa.ai neural search, stored in macOS Keychain and settings.json
type: reference
---

## Search API Keys

Both keys are stored in:

1. **macOS Keychain** (syncs across devices via iCloud Keychain) — account: "ps", services: "BRAVE_API_KEY" and "EXA_API_KEY"
2. **Claude settings.json** at `~/.claude-setup/settings.json` under `env`

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
