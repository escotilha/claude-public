---
name: mistake:gamification-oxi-branch-contamination
description: Accidentally committed a fix to the oxi worktree branch feat/sa-nfe-phase2-classification instead of main
type: feedback
originSessionId: 9f12effa-c620-456c-9290-bb2a0fd3c2a4
---
Never commit to an oxi branch. When `git branch --show-current` returns anything starting with `feat/oxi-`, `fix/oxi-`, or containing `nfe` or other oxi tracks — STOP. Do not commit, do not cherry-pick onto it. Switch to main first (`git checkout main`), then apply the change.

The incident: a migration fix was committed to `feat/sa-nfe-phase2-classification` (an oxi NFe track branch in a worktree). Required an extra cherry-pick step to land it on main.

**Why:** Oxi runs Claude Code agents in isolated worktrees on separate branches. The working directory may be inside one of those worktrees. Always check the branch before committing.

**How to apply:** Before every `git commit` or `git add`, run `git branch --show-current`. If the result is not `main`, abort and switch to main unless the user explicitly said to work on that branch.

---

## Timeline

- **2026-04-28** — [session] Committed migration fix to `feat/sa-nfe-phase2-classification` instead of `main` during gamification Phase 2 CI fix. Required cherry-pick to main. (Source: session — gamification phase 2 deploy)
