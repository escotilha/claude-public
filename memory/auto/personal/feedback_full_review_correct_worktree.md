---
name: feedback_full_review_correct_worktree
description: When user asks to run /full-review (or any branch-gating skill) on work that lives in a different worktree, switch cwd to that worktree first — don't run it against the current dirty tree
type: feedback
originSessionId: 205f79ac-ea6f-49da-a2ad-643b639ff3c9
---
When the user has just discussed work on a specific branch/worktree and asks to run `/full-review`, `/verify`, `/review-changes`, or any skill that reviews "the current branch", **switch to that worktree before invoking the skill**. Don't run the skill from whatever cwd happens to be active.

**Why:** 2026-04-28 — I reviewed Phases 1-3 on `feat/sa-overseer-v5` (worktree `/Volumes/AI/Code/contably-overseer-v5`), then user invoked `/full-review`. The skill ran against the active cwd (`/Volumes/AI/Code/contably`, branch `feat/oxi-v5-t10`) which had unrelated uncommitted work (db.py scaffolding + half-built open_banking.py router). The review BLOCKED on findings that had nothing to do with the v5 branch we'd just discussed. User had to point this out manually.

**How to apply:**
- Before invoking any branch-scoped review skill, check: is the work I just reviewed/discussed on the *current* worktree's branch?
- If `git worktree list` shows a different worktree for the relevant branch, `cd` there first.
- For Contably specifically: v5 phases live in `/Volumes/AI/Code/contably-overseer-v5`. Other tracks (`oxi-v5-t6`, `oxi-v5-t8`, `oxi-v5-t10`, `sa-analyst-is-active`) each have their own worktree.
- This is a "trust the conversation context" rule — if the last 5 messages were about branch X, the review skill should run on branch X, not on whatever the shell happens to be in.

Related: concurrent-sessions.md global rule already says "always work in a worktree on a named branch" — this extends it to "review work where it lives."
