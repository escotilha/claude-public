---
name: heartbeat-followup
description: Follow-up review of Claudia's HEARTBEAT.md system — check if it's useful after 2 weeks, decide whether to split tasks.md out
type: project
---

Claudia's context-aware heartbeat was deployed on 2026-04-04. It reads `/root/.claudia/workspaces/claudia/HEARTBEAT.md` every hour (08:00-20:00 BRT) and decides whether to message #command-center or stay silent.

**Why:** Inspired by Ryan Carson's ClawChief pattern (externalized heartbeat context via markdown). We took the high-value piece (HEARTBEAT.md) and deferred the rest (separate tasks.md, priority-map.md, auto-resolver.md, tasks-completed.md) until we have evidence it's needed.

**How to apply:** Around 2026-04-18, review the heartbeat's behavior:

1. Check Discord #command-center for heartbeat messages: `ssh vps "journalctl -u claudia --since '2 weeks ago' | grep heartbeat | grep -c 'Delivered'"` vs `grep -c 'suppressed'`
2. If 100% silent → HEARTBEAT.md template needs better defaults or heartbeat isn't worth the token spend. Consider disabling or enriching the template.
3. If noisy (>3 messages/day) → tighten silence rules in HEARTBEAT.md
4. If Pierre is manually editing HEARTBEAT.md tasks daily → split `tasks.md` as a standalone file that agents can read/write during conversations (Carson's canonical task source pattern)
5. If the meeting-prep cron surfaces tasks that should flow into the heartbeat → build the meeting-notes → tasks ingestion pipeline

**Decision tree after review:**

- Working well, no manual editing needed → keep as-is
- Manual editing is frequent → split tasks.md out, let agents write to it
- Not useful at all → disable heartbeat runner, revert to simple health ping or remove entirely
