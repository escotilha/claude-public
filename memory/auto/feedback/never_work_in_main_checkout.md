---
name: never-work-in-main-checkout
description: Every action in a session — file edits, gh pr commands, scp deploys — must happen from a worktree, never from the main checkout dir
type: feedback
originSessionId: 94d135c3-3bc2-408d-a0b6-51089b31ad95
---
**The rule:** the main checkout directory (`/Volumes/AI/Code/contably`, `/Volumes/AI/Code/psos`) is read-only mental scratch space. Every concrete action — file reads for editing, `gh pr merge`, `git commit`, `scp`, `psos-deploy`, `python -m pytest` — must happen from a session-dedicated worktree created via `ppr <branch>`.

**Why:** Working in main checkout invites these failure modes:
- Local main is stale → I read pre-PR state and "fix" what was already fixed (today: 3× this pattern)
- An accidental `git commit` lands directly on main, bypassing PR review
- `git status` shows my edits commingled with whatever the engine just synced
- Multiple parallel sessions stomp each other if both work in main

**How to apply:** First action of any session must be `eval "$(ppr <branch>)"` even if I don't think I need a worktree yet. The worktree:

1. Forces a `git fetch origin` + branch off `origin/main` — eliminates stale-clone bugs
2. Has a clear branch name in `git worktree list` — easy to track what's being done
3. Is disposable — close the session, remove the worktree, no orphan state

**Even for "just" running `gh pr merge` or reading docs:** still in a worktree. The cost is one shell command; the cost of a wrong-place commit is hours.

## When this rule applies

- Editing any file in a project I plan to PR — even one-line docs
- Running gh pr commands (merge, close, comment) — to keep the working dir consistent with the action
- scp deploys — to ensure the source files match the branch I think I'm on
- Reading source code I'll need to verify against current main — main checkout may be hours stale

## When it doesn't apply

- Pure read-only commands that don't touch the file system: `gh pr list`, `gh issue view`, `gh run view`
- VPS-side commands via SSH that don't depend on local checkout state
- Engine state queries (sqlite3 over SSH)

## Timeline

- **2026-04-22** — [user-feedback] Pierre flagged: "Nothing should be running in main. Every one of these should be a worktree, including what we are doing here." During the engine recovery + memory store roadmap session. Until then I had been doing PR work in worktrees but ad-hoc gh pr commands + diagnostics in the main checkout dir. (Source: user-feedback — explicit correction)
