---
name: OpenRouter API Key
description: OpenRouter API key for Qwen 3.6 Plus and other models — stored in macOS Keychain and Claudia VPS .env
type: reference
---

OpenRouter API key stored in:

- **macOS Keychain** (this Mac): `security find-generic-password -s "OPENROUTER_API_KEY" -w`
- **Claudia VPS**: `/opt/claudia/.env` as `OPENROUTER_API_KEY`
- **Mac Mini**: not in keychain (SSH blocks interactive auth) — add manually if needed

**Account:** Created March 2026. Free preview pricing for Qwen 3.6 Plus ($0/$0). Expect pricing to change — Qwen 3.5 went to $0.1/$0.3 after preview.

**Where it's used:**

- Claudia VPS (`/opt/claudia/.env`) — Tier 0R fallback in inference chain
- Default model: `qwen/qwen3-235b-a22b` (configurable via `OPENROUTER_MODEL` env var)

**Qwen3.6-Plus (April 2, 2026):** Alibaba released Qwen3.6-Plus — 1M context window by default, native chain-of-thought + tool use as core features (not prompt-engineered), agentic coding with multi-file planning + self-refinement on test feedback. Available free on OpenRouter during preview. Likely MoE architecture (similar to Qwen3-Coder-480B: 480B total / ~35B active). Recommend switching `OPENROUTER_MODEL` to `qwen/qwen3.6-plus` once slug is confirmed. Open weights on phased release — benchmark on Mac Mini M4 Pro when available to evaluate as Tier 0b replacement.

- Applied in: claudia-setup - 2026-04-02 - PENDING
