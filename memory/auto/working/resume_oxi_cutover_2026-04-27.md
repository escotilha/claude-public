---
name: resume-oxi-cutover-2026-04-27
description: Resume block for the OXi cutover session paused at 22:11 UTC 2026-04-27 (97% context). Resume at 23:20 UTC / 20:20 BRT.
type: working
originSessionId: 706921c3-0302-451b-8e8a-634ac7e49113
---
Engine state at pause (autonomous, no action needed to keep running):

- Mac Mini tmux: `oxi-saturate` (concurrency 20, $5000/day cap), `oxi-tick` (every 30s), `oxi-dashboard` (:8765) — all persist independent of Claude session
- Dashboard: http://100.90.175.28:8765/
- Mini engine running editable from `/Volumes/AI/Code/oxi/` on branch `feat/sa-pr-watcher-respects-unstable` (already merged to main as PR #218 — local branch is duplicate of main now)
- 16+ Contably PRs auto-merged today by oxi
- Killswitch off (file `/Volumes/AI/Code/contably/.oxi/RELEASE_LOCK` does not exist)
- Repo: Mini host `Mac-mini.local`, Tailscale IP 100.90.175.28
- VPS engine OFF — relocated to Mini today; legacy contably-os archived at `/opt/contably-os-archive-2026-04-27/`

Open work:

1. **PR #225** on Xurman/oxi — auto-upstream-forward feature (the "engine items file as upstream issues instead of dispatching" gate). CI running. Needs manual merge.
2. **6 issues filed** on Xurman/oxi (#219–224) for engine-self items I forwarded manually before #225 landed.
3. **Contably PR #682** already merged — removed legacy `contably-os hook session-stop` SessionEnd hook from `.claude/settings.json`.

Outstanding follow-ups for the new session:

1. Check oxi status: `cd /Volumes/AI/Code/oxi-runtime && set -a && source .env && set +a && venv/bin/oxi status`
2. Check overnight merges: `tail /Volumes/AI/Code/oxi-runtime/saturate.log`
3. Merge PR #225 if CI green (and possibly stack PR #218 cleanup if needed)
4. Restart Mini engine on `xurman/main` — was on feature branch that's now merged. Steps: `cd /Volumes/AI/Code/oxi && git checkout main && git pull xurman main`. Editable install picks up automatically.
5. Optional: cut `oxi-core 0.1.0b5` to PyPI so fresh `pip install --pre oxi-core` gets today's fixes (currently still pulls stale b4)
6. Optional: re-arm the Monitor stream — see prior session's monitor command for the SQLite poll filter (merges, abandons, UNHEALTHY, killswitch flips, big-cost dispatches)

Things to NOT touch unless deliberate:

- Mini tmux sessions (`oxi-saturate`, `oxi-tick`, `oxi-dashboard`)
- Local `/Volumes/AI/Code/contably/.claude/settings.json` — committed upstream
- Killswitch at `/Volumes/AI/Code/contably/.oxi/RELEASE_LOCK`
- The 7 revived T2 tasks (T2-22, T2-21, T2-18, T2-14, T2-12, T2-10, T2-8) — heartbeat 30min grace window

Today's shipped engine fixes (in PR #218, all merged):

1. UNSTABLE PR check status — auto_merge accepts advisory `continue-on-error` failures
2. `DispatchPolicy.oauth_mode` — keychain auth for workers + critic on Mac (no `ANTHROPIC_API_KEY` needed)
3. `GitHubClient.get_pr_diff` — feeds critic real diff substance
4. Draft PRs auto-flipped ready before arming
5. Heartbeat 30-min grace window (Contably override; default 10 min)
6. max_concurrent 20 (was 2)
7. Daily cap $5000 (was $1000)
8. Per-task Opus cap $30 (was $8)
9. Transient critic rejections stay dispatched (auto-defer instead of terminal-fail)
10. Roadmap parser supports `### Tier N — suffix` (was `## Tier N` only)
11. Adapter `dispatch_ssh_alias` kwarg + Path coercion in `__post_init__`

Production receipt at pause: 16 PRs merged, ~$70 spent, 0 UNHEALTHY trips since the loop started firing, 0 killswitch trips.

---

## Timeline

- **2026-04-27 22:11 UTC** — [session] Paused at 97% context. Engine running autonomously. (Source: session — OXi cutover Phase 4 day 1)
- **2026-04-27 23:20 UTC (20:20 BRT)** — [planned] Session resumes; user expects to invoke `/primer` to reconstruct state from this note.
