---
name: bella-systemd-routines
description: VPS service configuration — Claudia systemd unit with auto-restart ensures scheduled routines survive reboots
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Claudia's scheduler runs inside the main process (`src/scheduler/index.ts`). There is no separate routines daemon — all cron tasks initialize when `claudia.service` starts. Because the unit has `Restart=always` with `RestartSec=10`, scheduled routines automatically resume after any crash or reboot.

Current unit file: `/etc/systemd/system/claudia.service`

- User: `claudia`, WorkingDirectory: `/opt/claudia`
- ExecStart: `/usr/bin/node /opt/claudia/dist/index.js`
- Restart: `always`, RestartSec: `10`, TimeoutStopSec: `30`
- After: `network-online.target tailscaled.service ollama.service`
- EnvironmentFile: `/opt/claudia/.env`
- Security: `NoNewPrivileges=false`, `ProtectSystem=false` (required for Agent SDK to spawn `claude` CLI)

Additional units observed on VPS:

- `claudia-ai-watchdog.service` — loaded, activating/auto-restart (external watchdog)
- `claudia-cron.service` — **not-found / failed** (stale reference, unit file missing — can be ignored or cleaned up with `systemctl reset-failed claudia-cron.service`)

Boot-to-routines flow:

1. systemd starts `claudia.service` after network + tailscale + ollama
2. Node process initializes all channel adapters and the scheduler
3. All cron tasks (heartbeat, buzz-daily, chief-geo, etc.) register and begin firing on schedule
4. On crash: systemd restarts after 10s — scheduler re-registers all tasks
5. On reboot: same flow, no manual intervention needed

No separate routines daemon is needed or warranted.

## Quick Ops

```bash
# Check status
ssh root@100.77.51.51 "systemctl is-active claudia"

# Tail logs (last 50 lines)
ssh root@100.77.51.51 "journalctl -u claudia -n 50 --no-pager"

# Follow live
ssh root@100.77.51.51 "journalctl -u claudia -f"

# Restart
ssh root@100.77.51.51 "systemctl restart claudia"

# Clear stale claudia-cron failed status (cosmetic)
ssh root@100.77.51.51 "systemctl reset-failed claudia-cron.service"
```

---

## Timeline

- **2026-04-11** — [session] Verified VPS state via `systemctl cat claudia` + `list-units`. claudia.service active, Restart=always confirmed. claudia-cron.service stale (not-found/failed). claudia-ai-watchdog.service present and auto-restarting. No separate routines daemon needed — scheduler is in-process. (Source: session — bella-systemd-routines task)
