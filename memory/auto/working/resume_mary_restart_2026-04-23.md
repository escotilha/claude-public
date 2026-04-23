---
name: resume-mary-restart-2026-04-23
description: Working state for Mary restart/audit — overnight prep done 2026-04-23 03:00, morning execution pending
type: project
originSessionId: 8b063cf6-6ed4-43d3-937a-d793abba6893
---
**Status:** Prep done overnight. Plan ready. Morning execution pending.

**Plan doc:** `/Volumes/AI/Code/mary-restart-plan-2026-04-23.md`

**What's already been done (2026-04-23, ~03:00 local, from Mac Mini session):**

1. Created `~/.ssh/config` on Mac Mini (was entirely missing) with `vps` and `vps-root` aliases → unblocks `sync-claude-token.sh`.
2. Ran `sync-claude-token.sh` → pushed fresh Max plan OAuth credential from Mac keychain to VPS (`/home/mary/.claude/.credentials.json`). Previous cred had expired (401 on `claude models list`).
3. Verified `ssh mary@vps "claude auth status"` returns `loggedIn: true, subscriptionType: max`.
4. Verified `openclaw agent --agent mary` returns live responses (routing through claude-cli is functional).
5. No `openclaw.json` or systemd changes made. VPS config untouched.

**Open gaps for morning session:**

- `openclaw models list` tags `claude-cli/claude-opus-4-7` and `haiku-4-5` as `configured,missing` even though routing works. Cosmetic OpenClaw probe issue, not functional. Investigate in Phase 1.5.
- `anthropic/claude-sonnet-4-6` still in `fallback#1`. Guide says strip; plan has a decision gate — don't strip until Gap 1b is understood.
- `+5511945661111` (Pierre's WhatsApp) pinned to `anthropic/claude-opus-4-7` (PAID API) in openclaw.json — bypasses Max plan. Fix in new step 1.9.
- Phase 2: MLX stack audit from THIS Mini (localhost commands, no SSH — it IS the Mini).
- Phase 3: reconcile two stale memory entries (`project_claudia_migration_complete.md` and `project:claudia-router`) that still claim Claudia replaced OpenClaw.

**Context discovered overnight (write into long-term):**

- Mac Mini is `Mac-mini.local` / user `psm2` / Tailscale `100.66.244.112`. Saved as PERMANENT in `personal/host_this_is_mac_mini.md` per Pierre's explicit instruction.
- VPS alias map: `vps` = mary@100.77.51.51, `vps-root` = root@100.77.51.51 (Tailscale peer `vmi3065960`).

## Timeline

- **2026-04-23 ~03:00** — [implementation] SSH config + token sync + functional test from Mac Mini. VPS credential refreshed, Mary agent confirmed routing via claude-cli on Max plan. Plan doc updated with overnight findings. (Source: session — overnight prep before morning audit)
