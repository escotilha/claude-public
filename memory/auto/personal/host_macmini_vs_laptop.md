---
name: host-macmini-vs-laptop
description: Pierre works from BOTH the Mac Mini and his MacBook laptop — always confirm which host before assuming deploy paths or scp directionality
type: personal
originSessionId: 94d135c3-3bc2-408d-a0b6-51089b31ad95
---
Pierre runs Claude Code sessions from **both** machines:

- **MacBook (laptop)** — primary daily-driver, where he reviews code, opens PRs
- **Mac Mini (`100.66.244.112` on Tailscale)** — the autonomous executor for Contably OS / PSOS dispatches, AND a working environment Pierre uses directly when at home

**Before assuming a deploy path, ask or check.** The same shell command runs in different places with different consequences:

- `psos-deploy` from laptop → SSH to VPS → VPS clones from origin → `pip install` (the right path)
- `psos-deploy` from Mini → also works the same way (SSH to VPS), BUT if Pierre wanted to install the wheel locally for testing, that's `pip install --user` not a VPS deploy

**Quick host detection:**
```bash
hostname              # mac-mini-2 = Mini, otherwise laptop
echo $TAILSCALE_HOST  # Mini ~ 100.66.244.112
sw_vers -productName  # both say "macOS"; check hostname instead
```

**How to apply:** when Pierre says "I'm on X" or "this is Y," update internal state and re-evaluate any script-paths that assume laptop. Don't auto-detect silently — confirm in the response so he can correct.

## Timeline

- **2026-04-22** — [user-feedback] During the duplicate-PR cascade incident, Pierre was on the Mini, not the laptop, when I started building `~/.local/bin/psos-deploy`. He flagged: "Hang on, I'm not in my laptop. This is the Mac Mini." (Source: user-feedback — explicit correction during the seeder-cooldown work)
