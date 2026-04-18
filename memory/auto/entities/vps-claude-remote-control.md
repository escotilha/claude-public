---
name: VPS Claude Remote Control setup
description: Claude Code Remote Control running on Contabo VPS via systemd — connect from Claude Desktop/browser to work on remote filesystem
type: reference
originSessionId: 2a450ac0-7890-4827-bd7f-3929465f20f0
---
## Current State

Claude Code Remote Control runs as a systemd service on the Contabo VPS (`root@100.77.51.51`), allowing any Claude Desktop or browser session to attach and work against `/root/code` with full Claude Code capabilities (skills, agents, git, MCP).

- **Service:** `claude-remote-control.service` (enabled, auto-starts on reboot)
- **Binary:** `/root/.local/bin/claude` (v2.1.114+), symlinked from `/usr/local/bin/claude`
- **Working dir:** `/root/code` (contains `contably` repo)
- **Log:** `/var/log/claude-rc.log`
- **Sandbox:** off
- **Spawn mode:** `same-dir` (default) — all sessions share `/root/code`; toggle to worktree mode at runtime with `w`
- **Capacity:** 32 concurrent sessions
- **Old binary backup:** `/usr/local/bin/claude.old-2131` (pre-upgrade v2.1.31)

## Connect

Environment URL changes each time the service restarts. Get current URL:

```bash
ssh root@100.77.51.51 'tail -20 /var/log/claude-rc.log | grep "claude.ai/code?environment" | tail -1'
```

Paste into Claude Desktop, browser, or the Claude app.

## Manage

```bash
# Status
ssh root@100.77.51.51 'systemctl status claude-remote-control'

# Restart (new environment URL)
ssh root@100.77.51.51 'systemctl restart claude-remote-control'

# Stop
ssh root@100.77.51.51 'systemctl stop claude-remote-control'

# Logs
ssh root@100.77.51.51 'journalctl -u claude-remote-control -n 50'
ssh root@100.77.51.51 'tail -f /var/log/claude-rc.log'
```

## Systemd unit

Located at `/etc/systemd/system/claude-remote-control.service`:

```ini
[Unit]
Description=Claude Code Remote Control
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/code
Environment=HOME=/root
Environment=PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/root/.local/bin/claude remote-control --name "Contabo VPS"
Restart=on-failure
RestartSec=10
StandardOutput=append:/var/log/claude-rc.log
StandardError=append:/var/log/claude-rc.log

[Install]
WantedBy=multi-user.target
```

## Auth Notes

- Claude Code auth tokens are stored per-install in `~/.claude/` — when upgrading from the old `/usr/local/bin/claude` (shell install) to `~/.local/bin/claude` (native install), `/login` must be re-run interactively on the VPS
- The native installer from `https://claude.ai/install.sh` is the current canonical install method (replaces bootstrap.claude.com)

## Related

- [VPS connection details](reference_vps_connection.md) — Tailscale IP, SSH user, services
- Claude Code Remote Control requires v2.1.51+ (Pro/Max/Team subscription)

---

## Timeline

- **2026-04-18** — [session] Set up Remote Control on VPS (upgrade 2.1.31 → 2.1.114, systemd unit, working dir `/root/code`, sandbox off) (Source: session — user request "connect claude desktop to vps via ssh")
