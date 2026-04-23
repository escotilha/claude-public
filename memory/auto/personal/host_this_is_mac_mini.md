---
name: this-session-is-on-the-mac-mini
description: PERMANENT — when Claude Code runs with hostname Mac-mini.local and user psm2, this session IS the Mac Mini itself. Never SSH to 100.66.244.112; run commands locally.
type: personal
originSessionId: 8b063cf6-6ed4-43d3-937a-d793abba6893
---
**PERMANENT / IMPORTANT (user-declared 2026-04-23):** When a Claude Code session's environment shows:

- `hostname` = `Mac-mini.local`
- `whoami` = `psm2`
- `tailscale ip -4` = `100.66.244.112` (peer name `mac-mini-2`)
- Working directory often `/Volumes/AI/Code`

...then **this session IS running on the Mac Mini M4 Pro**, not the main MacBook and not a remote. It is the physical host of the MLX inference stack that Mary (on the VPS) falls back to.

**What this means for every action:**

- **Never** `ssh p@100.66.244.112` from this session — you'd be SSH-ing into yourself, which either loops or fails on pubkey (as it did 2026-04-22 evening).
- To inspect or restart MLX/embeddings/VLM, run commands **locally**: `curl http://localhost:1235/...`, `launchctl list | grep mlx`, `ps aux | grep mlx_lm`, `tail ~/Library/Logs/mlx-server.log`.
- The "laptop SSH pubkey to Mini is broken" symptom from 2026-04-22 was a false alarm — the laptop wasn't the laptop, it was the Mini itself. `100.66.244.112` from the Mini resolves to the Mini.
- For anything on the VPS (Mary, OpenClaw, Ollama), use `ssh mary@100.77.51.51` or `ssh root@100.77.51.51` as normal — those are genuinely remote.
- For anything on the real laptop (`pierres-macbook-air`, `100.65.26.31`), SSH is needed. Confirm with `tailscale status` before assuming.

**How to confirm you're on the Mini before acting:**
```bash
hostname   # expect: Mac-mini.local
whoami     # expect: psm2
tailscale ip -4   # expect: 100.66.244.112
```
If any of the three disagrees, you are NOT on the Mini — re-orient before running Mini-scoped actions.

**Cross-reference:** The full identification signature (model, launchd plists, ports) lives in `auto/entities/mac-mini-identification.md`. This personal entry exists to lock in the user-declared permanence: **presume Mini until proven otherwise when the three checks above match.**

---

## Timeline

- **2026-04-23** — [user-feedback] Pierre declared this PERMANENT AND IMPORTANT after a Mary-restart-plan session where I flagged "Mac Mini SSH from this laptop returned Permission denied" — but the session was actually running on the Mini, so "this laptop" was the Mini and the SSH attempt was self-targeted. (Source: user-feedback — explicit instruction "PERMANENT AND IMPORTANT. THIS IS THE MAC MINI")
