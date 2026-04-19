---
name: feedback:worktree-agents-must-branch-first
description: Worktree agents must create a feature branch as their FIRST action, never commit on main even inside the worktree
type: feedback
originSessionId: 3538be53-f06e-4407-9e7d-5e968cf57914
---
When spawning agents with `isolation: "worktree"`, the agent's first action MUST be `git checkout -b feat/<task-slug>` (or similar). Never let the agent commit on `main` inside its worktree, even though the worktree is "isolated".

**Why:** When a worktree is torn down, any commit made on `main` inside it gets attached to the parent repo's `main` branch. This bypasses PR review, can land on `main` ahead of `origin/main` (creating divergence), and breaks the parallel-dev pattern where each track should produce a reviewable feature branch. Hit this 2026-04-19 with two parallel agents on Contably: backend agent committed on main inside its worktree, frontend agent left work uncommitted. Required a multi-step rebase + branch-split + force-push to recover.

**How to apply:**

1. **Every worktree agent spawn prompt must include this instruction verbatim:**
   > "Your FIRST action in the worktree is `git checkout -b feat/<task-slug>` where `<task-slug>` is a short kebab-case description of your work. Do NOT commit on `main`. All commits must land on this feature branch. When done, push the branch to origin and report the branch name + last commit SHA."

2. **Default branch naming:** `feat/<task-slug>`, `fix/<task-slug>`, `chore/<task-slug>` per conventional commits.

3. **Verify in the agent's report:** the branch name should be present. If the agent reports `committed to main` or doesn't name a branch, treat that as a recovery situation and run the branch-split procedure (create branch at the agent's commit SHA, reset main back to origin, push branch, PR).

4. **This applies to ALL worktree agents** — `/parallel-dev`, manual `Agent({ isolation: "worktree" })`, and any future skill that spawns isolated agents. Single-track worktree work also follows this rule.

5. **Counterexample — when this rule does NOT apply:** ad-hoc bash worktrees the user is driving manually (they manage their own branching). Only enforced for spawned agents.

---

## Timeline

- **2026-04-19** — [session — contably parallel-dev TASK-008 + TASK-010] Discovered: 2 worktree agents spawned. Backend agent committed `45d18786f` on main inside its worktree → ended up on parent repo's main, ahead of origin/main by 1. Frontend agent left changes uncommitted. Recovery required: stash, reset main to origin, branch backend commit out, rebase, force-push, then pop stash + commit frontend on its own branch + resolve docs conflict + push. Rule encoded after user pushed back: "wasn't it supposed to always be done in worktrees from now on?"
