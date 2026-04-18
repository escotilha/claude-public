---
name: reference:paperclip-vps-setup
description: Paperclip AI orchestration running on VPS with 3 companies (Nuvini, Contably, SourceRank) — hybrid claude_local + openclaw_gateway adapters, Nemotron 3 Super via Ollama for CEOs
type: reference
---

## Paperclip on VPS

- **Host:** vmi3065960 (Contabo), Tailscale IP 100.77.51.51
- **Service:** `paperclip.service` (systemd, User=paperclip), port 3100, bind 0.0.0.0
- **Database:** PostgreSQL 16 on port 5432, db=paperclip, user=paperclip
- **Config:** `/home/paperclip/.paperclip/instances/default/config.json`
- **Mode:** `authenticated` / `private` (HTTP cookies, no Secure flag)
- **Public URL:** `http://100.77.51.51:3100` (Tailscale only)
- **Version:** 2026.318.0 (npm: paperclipai, updated 2026-03-23)
- **Login:** p@xurman.com / Paperclip2026!
- **Claude Auth:** Max subscription (oauth login on paperclip user, no API key needed)

## Companies

| Company       | ID                                   | Prefix | Budget |
| ------------- | ------------------------------------ | ------ | ------ |
| Nuvini Group  | 4e37d9a0-a4dd-4226-9bc9-f2932243a34e | NUV    | $50/mo |
| Contably      | c025dfac-dbf2-49de-a78f-97e259a89c42 | CON    | $30/mo |
| SourceRank AI | 599ab2a1-533e-477d-b555-5b56e3637f6b | SOU    | $30/mo |

## Agents

| Agent               | Company    | Role    | Adapter          | Model                     |
| ------------------- | ---------- | ------- | ---------------- | ------------------------- |
| Nuvini CEO          | Nuvini     | ceo     | openclaw_gateway | nemotron-3-super (Ollama) |
| Nuvini Orchestrator | Nuvini     | general | claude_local     | claude-sonnet-4-6 (Max)   |
| Contably CEO        | Contably   | ceo     | openclaw_gateway | nemotron-3-super (Ollama) |
| Contably Operator   | Contably   | general | claude_local     | claude-sonnet-4-6 (Max)   |
| SourceRank CEO      | SourceRank | ceo     | openclaw_gateway | nemotron-3-super (Ollama) |
| SourceRank Operator | SourceRank | general | claude_local     | claude-sonnet-4-6 (Max)   |

## Architecture

- **CEOs** → OpenClaw gateway (ws://127.0.0.1:3001) → Ollama (nemotron-3-super primary, qwen3:8b backup, anthropic emergency)
- **Operators** → claude_local adapter → Claude Code CLI on VPS as `paperclip` user (Max subscription, sonnet-4-6)
- Personal agents (Claudia, Marco, Arnold, etc.) remain OpenClaw-only — not managed by Paperclip
- Gateway API key file: `/root/.openclaw/workspace/paperclip-claimed-api-key.json`

## Ollama Models on VPS

| Model            | Size   | Role                 |
| ---------------- | ------ | -------------------- |
| nemotron-3-super | 86 GB  | CEO primary (Tier 0) |
| qwen3:8b         | 5.2 GB | CEO backup           |
| qwen2.5:14b      | 9.0 GB | Legacy               |

## Mac Mini MLX Inference (Alternative Tier 0 Host)

- **Host:** Mac Mini M4 Pro, 48 GB RAM, Tailscale IP 100.66.244.112, SSH alias `mini`
- **Python:** 3.14 via Homebrew, venv at `~/mlx-env` (activate: `source ~/mlx-env/bin/activate`)
- **MLX:** v0.31.0 (system), mlx-lm v0.31.1 (venv)
- **KV cache quantization:** `--kv-bits 4` supported (TurboQuant-style, built into mlx-lm)

### Cached Models

| Model                      | Size   | Speed       | Peak Memory | Notes                                  |
| -------------------------- | ------ | ----------- | ----------- | -------------------------------------- |
| Qwen3.5-35B-A3B-4bit (MoE) | ~19 GB | 103 tok/s   | 19.6 GB     | Best quality, 3B active params         |
| Qwen3.5-9B-4bit            | ~5 GB  | 46-52 tok/s | 5.2 GB      | Fast, lightweight                      |
| Qwen3.5-9B-MLX-4bit        | ~5 GB  | —           | —           | Hybrid Mamba arch, mlx-lm incompatible |
| nanoLLaVA-1.5-8bit         | —      | —           | —           | Vision model                           |

### Usage

```bash
ssh mini "source ~/mlx-env/bin/activate && python3 -m mlx_lm generate --model mlx-community/Qwen3.5-35B-A3B-4bit --kv-bits 4 --prompt 'your prompt' --max-tokens 200"
```

### Potential as Paperclip Inference Host

- M4 Pro + 48 GB >> Contabo VPS CPU for inference throughput
- Could serve CEOs via mlx_lm.server over Tailscale (OpenAI-compatible API)
- Limitation: Mini sleeps/goes offline — not always reachable (confirmed 2026-03-30)

## Key Config Notes

- Service runs as `paperclip` user (non-root, required for dangerouslySkipPermissions)
- PG port fixed from 5433→5432 on 2026-03-18
- PAPERCLIP_PUBLIC_URL=http://100.77.51.51:3100 (disables Secure cookie flag for HTTP)
- CEO gateway: password = OPENCLAW_GATEWAY_TOKEN, waitTimeoutMs = 300000 (5min)
- Operator agents: dangerouslySkipPermissions: true, maxTurnsPerRun: 50, timeoutSec: 1800
- Both adapters smoke-tested successfully (NUV-1 via claude_local, NUV-3 via openclaw_gateway/Nemotron)
