---
name: mistake:oxi-engine-fork-target
description: The deployed oxi engine on the Mac Mini reads from xurman/oxi (NOT Contably/oxi). Contably/oxi is a stale parallel fork. Always confirm the deployed fork via git reflog before merging engine PRs.
type: mistake
originSessionId: db8b7a66-ea55-4429-8965-c5a75b7635a3
---
The Mac Mini editable install at `/Volumes/AI/Code/oxi/` tracks `xurman/main` — the previous-day's reflog showed `git pull xurman main` was the canonical workflow. The runtime venv at `/Volumes/AI/Code/oxi-runtime/venv/` is editable-installed from that path, so the engine code = whatever's checked out on `/Volumes/AI/Code/oxi/main`.

Contably/oxi is a **separate, divergent fork**. Each side has commits the other lacks:
- Contably/oxi has Mini-specific dispatch fields (`oauth_token_file`, `main_clone`, `dispatch_binary`, `scrub_home`) and shadow parity automation.
- Xurman/oxi has the actual engine features (auto-merge loop, route_for, critic-tier gate, ship_recovery, memory backend, asyncio fix).

**Neither fork is a strict superset.** Cherry-picks between them hit real conflicts on `DispatchHost` shape and adapter/contably-vps/.

## How to confirm the right fork before merging

1. `git reflog --date=local | head -10` — look for `pull xurman main` vs `pull origin main` to see which remote was last sync'd from on the Mini.
2. `git log main..xurman/main --oneline | head` — if non-empty, xurman has commits the local doesn't.
3. `git log main..origin/main --oneline | head` — if non-empty, origin (Contably) has commits the local doesn't.
4. The deployed engine's code = local `main` HEAD. PR target should be the remote that local `main` last pulled from.
5. `cat /Volumes/AI/Code/oxi-runtime/venv/lib/python*/site-packages/*direct_url.json` — confirms editable-install source path.

## What went wrong on 2026-04-28

Today's session opened 6 PRs against `Contably/oxi:main` (PRs #4–#9) thinking it was the deployed fork. Reasons for the mistake:
- Earlier session attempt against Xurman/oxi hit conflicts (the 22 Contably-only commits on local main weren't on Xurman). I assumed Contably was the production fork.
- Did NOT consult the resume note's step 4 ("Restart Mini engine on `xurman/main`") which would have flagged this immediately.
- Did NOT check git reflog for `pull xurman main` vs `pull origin main`.

The fix was a 30-45 min cherry-pick + push cycle to xurman/main, where the engine actually reads from. Contably/oxi PRs #4–#9 are now stale — should be retired or kept as a record but not merged anywhere.

## Rule going forward

Before opening a PR for the oxi engine:
1. Run the 5 confirmation steps above.
2. The PR's base must be the remote that local `main` last pulled from (xurman as of 2026-04-28).
3. If a fork has the engine features your PR depends on, that's the fork to target — not whichever one accepted your branch first.

Cross-fork upstreaming (sending the same commits to both xurman/oxi AND Contably/oxi) is fine if you do it deliberately — but the deployed engine only needs whichever fork it reads from.

---

## Timeline

- **2026-04-28** — [failure] Opened 6 PRs (#4–#9) on Contably/oxi believing it was the deployed fork; engine actually reads from xurman/oxi. Resolution: cherry-pick the 6 commits onto xurman/main, push directly. (Source: failure — fork-target misidentification on session resume)
