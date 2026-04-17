---
name: Mac Mini identification
description: How to tell when a Claude Code session is running ON the Mac Mini vs the main Mac — hostname, Tailscale IP, user, and the MLX inference server it hosts
type: reference
originSessionId: fdb10dbf-b473-4d5b-8b7b-7505b561c068
---
## Identifying the Mac Mini

When a session is on the Mac Mini (the M4 Pro inference host, not the main Mac), these all hold:

- **hostname:** `Mac-mini.local`
- **ComputerName / LocalHostName:** `Mac mini` / `Mac-mini`
- **Tailscale IP:** `100.66.244.112`
- **Tailscale peer name (from other hosts):** `mac-mini-2`
- **User:** `psm2` (same as main Mac — don't rely on username alone)
- **Model:** `Mac16,11` (M4 Pro), arm64
- **Distinctive local services:**
  - `mlx_lm.server` on port `1235` (e.g. Qwen3.5-35B-A3B-4bit)
  - `mlx_vlm.server` on port `8001` (nanoLLaVA vision)
  - launchctl agents: `com.psm2.mlx-server`, `com.mlx-vlm.server`
  - LM Studio embeddings on `1234` (when active)

## When it matters

The Mini **hosts** the MLX inference endpoint that Claudia/Mary (on the VPS) and several skills fall back to. If you're debugging a "Mary/Claudia LLM timeout" issue and the session says it's "on the Mini," you can skip SSH entirely and run commands locally — `curl http://localhost:1235/...`, `launchctl kickstart`, `ps aux | grep mlx_lm`, etc.

Conversely, if you think you're on the Mini but `tailscale ip -4` returns something other than `100.66.244.112`, you're NOT — verify before taking actions scoped to the Mini.

## Logs

- MLX LM server: `~/Library/Logs/mlx-server.log`
- MLX VLM server: `~/Library/Logs/mlx-vlm-server.log`

## How to apply

Before running Mini-specific commands (restart MLX, kickstart launchctl, inspect inference logs), confirm identity with `hostname` or `tailscale ip -4`. Don't assume — the main Mac and the Mini share `psm2` as the user and both run MLX-adjacent tooling.

Discovered: 2026-04-17
Source: session — Mary-on-VPS outage debug, worktree session turned out to be running on the Mini itself
