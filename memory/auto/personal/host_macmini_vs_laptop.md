---
name: host-macmini-vs-laptop
description: Pierre's primary Claude Code host is the Mac Mini — the Mini runs Claude Code sessions AND is the autonomous executor. Default to Mini unless explicitly told otherwise.
type: personal
originSessionId: 94d135c3-3bc2-408d-a0b6-51089b31ad95
---
**Pierre's primary host is the Mac Mini.** Treat this as the default — not the laptop.

- **Mac Mini (`100.66.244.112` on Tailscale)** — this is where Pierre's Claude Code sessions run AND where autonomous Contably OS / PSOS dispatches execute. If a session is open and the user hasn't said "I'm on the laptop," assume Mini.
- **MacBook (laptop)** — occasional sessions only. Must be explicitly stated.

**Deploy path from Mini:**
- `psos-deploy` → SSH to VPS → VPS clones from origin → `pip install`. Same flow regardless of which Mac initiated.
- SSH to Mini itself (e.g. `ssh 100.66.244.112 ...`) FAILS from my local shell because I AM already on the Mini (laptop's SSH key isn't in Mini authorized_keys anyway). Route Mini-targeted commands through the VPS: `ssh root@100.77.51.51 'ssh 100.66.244.112 "..."'`.

**When the user corrects host assumption:**
When Pierre says "I'm on the Mini" or "this is the Mini," update internal state and stop trying to SSH to Mini from the current shell — the current shell IS the Mini.

## Timeline

- **2026-04-22** — [user-feedback] During the duplicate-PR cascade incident, Pierre was on the Mini when I started building `~/.local/bin/psos-deploy`. He flagged: "Hang on, I'm not in my laptop. This is the Mac Mini." (Source: user-feedback — explicit correction during the seeder-cooldown work)
- **2026-04-22 evening** — [user-feedback] Pierre explicitly: "Save this to memory once and for all. You are not on the laptop. You are on the Mac Mini." Rewrote this memory to make Mini the default assumption rather than "both are possible." (Source: user-feedback — engine recovery session after compaction)
